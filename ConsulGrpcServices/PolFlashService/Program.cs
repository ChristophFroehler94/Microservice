// Program.cs – PolFlash: ENV+Consul-KV, TLS (PFX aus ENV), konsistente Kestrel-Fallbacks, gRPC-Health & Metriken

using Consul;
using FotoFinder.PolFlashGrpc.Services;
using FotoFinder.PolFlashXE.FlashDevices;
using Grpc.Core;
using Grpc.Core.Interceptors;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Primitives;
using System.Security.Cryptography.X509Certificates;
using Winton.Extensions.Configuration.Consul;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions { Args = args });

// Konfigquellen: nur ENV (APP_*) + Args
builder.Configuration.Sources.Clear();
builder.Configuration.AddEnvironmentVariables(prefix: "APP_");
builder.Configuration.AddCommandLine(args);

// Konsul-ENV (CA/Token/Adresse)
string consulAddr = Environment.GetEnvironmentVariable("CONSUL_HTTP_ADDR") ?? "https://127.0.0.1:8501";
string? consulToken = Environment.GetEnvironmentVariable("CONSUL_HTTP_TOKEN");
string? cacert = Environment.GetEnvironmentVariable("CONSUL_CACERT");
string? capath = Environment.GetEnvironmentVariable("CONSUL_CAPATH");
var consulRoots = LoadRootCAsFromEnv(cacert, capath);
Console.WriteLine($"[TLS] {consulRoots?.Count ?? 0} Root-CA(s) geladen aus {(cacert ?? capath ?? "(keine)")}");

// KV-Pfad (vom Bootstrap-Skript geschrieben)
string node = Environment.GetEnvironmentVariable("CONSUL_NODENAME") ?? Environment.MachineName;
string servicePrefix = Environment.GetEnvironmentVariable("SERVICE_PREFIX") ?? "polflash";
string kvPath = Environment.GetEnvironmentVariable("CONSUL_KVPATH") ?? $"{servicePrefix}/{node}/config.json";

// Consul-KV als Konfigquelle (mit TLS-Validierung)
builder.Configuration.AddConsul(
    kvPath,
    options =>
    {
        options.ConsulConfigurationOptions = cco =>
        {
            cco.Address = new Uri(consulAddr);
            if (!string.IsNullOrWhiteSpace(consulToken)) cco.Token = consulToken;
        };

        if (consulRoots is not null)
        {
            options.ConsulHttpClientHandlerOptions = handler =>
            {
                handler.ServerCertificateCustomValidationCallback =
                    (req, cert, chain, errs) => ValidateWithCustomRoots(cert, consulRoots);
            };
        }

        options.Optional = false;
        options.ReloadOnChange = true;
        options.PollWaitTime = TimeSpan.FromSeconds(5);
        options.OnLoadException = ctx => ctx.Ignore = false; // fail-fast
    });

// Server-Zertifikat (PFX aus ENV)
var tlsPfxPath = Environment.GetEnvironmentVariable("APP_TLS_PFX");
var tlsPfxPwd = Environment.GetEnvironmentVariable("APP_TLS_PFX_PASSWORD");
X509Certificate2? serverCert = null;
if (!string.IsNullOrWhiteSpace(tlsPfxPath) && File.Exists(tlsPfxPath))
{
    serverCert = new X509Certificate2(
        tlsPfxPath,
        tlsPfxPwd ?? string.Empty,
        X509KeyStorageFlags.MachineKeySet | X509KeyStorageFlags.Exportable);
}

// Kestrel: Konfig aus KV + Fallback-Endpoint
builder.WebHost.ConfigureKestrel((context, kestrel) =>
{
    // Konfiguration aus "Kestrel" (optional aus KV)
    kestrel.Configure(context.Configuration.GetSection("Kestrel"), reloadOnChange: true);

    // optionale HTTP/2-Fenster
    try
    {
        kestrel.Limits.Http2.InitialConnectionWindowSize = 16 * 1024 * 1024;
        kestrel.Limits.Http2.InitialStreamWindowSize = 16 * 1024 * 1024;
    }
    catch { }

    // Fallback, falls keine Endpoints definiert sind
    bool hasEndpoints = context.Configuration.GetSection("Kestrel:Endpoints").GetChildren().Any();
    if (!hasEndpoints)
    {
        const int DefaultGrpcPort = 5295;
        kestrel.ListenAnyIP(DefaultGrpcPort, listen =>
        {
            listen.Protocols = HttpProtocols.Http1AndHttp2;
            if (serverCert is not null) listen.UseHttps(serverCert);
            else listen.UseHttps(); // Dev-Fallback
        });
        Console.WriteLine($"[Kestrel] Fallback: https://0.0.0.0:{DefaultGrpcPort}");
    }
});

// Logging + gRPC + Health + Reflection + Metrik-Interceptor
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(Microsoft.Extensions.Logging.LogLevel.Information);
builder.Services.AddGrpc(o =>
{
    o.EnableDetailedErrors = true;
    o.Interceptors.Add<PolGrpcMetricsInterceptor>();
});
builder.Services.AddGrpcReflection();
builder.Services.AddGrpcHealthChecks().AddCheck("polflash", () => HealthCheckResult.Healthy());

// Gerätesuche (vereinfacht)
var devices = await FlashDeviceFactory.RefreshDeviceListAsync();
var device = devices.OfType<IFlashDevice>().FirstOrDefault()
    ?? throw new InvalidOperationException("Kein kompatibles PolFlash-Gerät gefunden");
device.Initialize();
bool isV2 = device is IFlashDevice2;
builder.Services.AddSingleton<IFlashDevice>(device);

// Konsul-Client (TLS-Validierung über Custom Roots)
builder.Services.AddSingleton<IConsulClient>(_ =>
{
    return new ConsulClient(
        configOverride: c =>
        {
            c.Address = new Uri(builder.Configuration["Consul:Address"] ?? consulAddr);
            var token = builder.Configuration["Consul:Token"] ?? consulToken;
            if (!string.IsNullOrWhiteSpace(token)) c.Token = token;
        },
        clientOverride: _ => { },
        handlerOverride: handler =>
        {
            if (consulRoots is not null)
            {
                handler.ServerCertificateCustomValidationCallback =
                    (req, cert, chain, errs) => ValidateWithCustomRoots(cert, consulRoots);
            }
        });
});

var app = builder.Build();

// gRPC-Endpunkte
app.MapGrpcService<FlashControlService>();
app.MapGrpcHealthChecksService();
#if DEBUG
app.MapGrpcReflectionService();
#endif

// Metrik-Snapshot (setzt Sliding-Window zurück)
app.MapGet("/metrics/snapshot", () => Results.Json(PolTelemetry.GetSnapshotAndReset()))
   .WithDisplayName("Metrics Snapshot (E2E, p95/p99)");
app.MapGet("/", () => $"PolFlash gRPC Service läuft ({(isV2 ? "v2" : "v1")})");

// Consul-Registrierung (gRPC-Health über TLS)
var cfg = app.Configuration;
var consul = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Lifetime;
var grpcUrl = cfg["Kestrel:Endpoints:Grpc:Url"] ?? "https://0.0.0.0:5295";
var uri = new Uri(grpcUrl);
var svcAddr = cfg["Service:AdvertisedHost"] ?? "127.0.0.1";
var svcPort = uri.Port;
var svcId = cfg["Consul:ServiceId"] ?? $"polflash-{(isV2 ? "v2" : "v1")}-{node}";
var svcName = cfg["Consul:ServiceName"] ?? "PolFlashService";
bool skipHv = (Environment.GetEnvironmentVariable("APP_HEALTH_TLS_SKIPVERIFY") ?? "true")
                .Equals("true", StringComparison.OrdinalIgnoreCase);

var registration = new AgentServiceRegistration
{
    ID = svcId,
    Name = svcName,
    Address = svcAddr,
    Port = svcPort,
    Tags = new[] { "grpc", "polflash", isV2 ? "v2" : "v1" },
    Meta = new Dictionary<string, string> { ["impl"] = isV2 ? "IFlashDevice2" : "IFlashDevice" },
    Checks = new[]
    {
        new AgentServiceCheck
        {
            GRPC = $"{svcAddr}:{svcPort}",
            GRPCUseTLS = true,
            TLSSkipVerify = skipHv, // PROD: false + gültige CA im Truststore
            Interval = TimeSpan.FromSeconds(10),
            Timeout  = TimeSpan.FromSeconds(5),
            DeregisterCriticalServiceAfter = TimeSpan.FromMinutes(2)
        }
    }
};

await consul.Agent.ServiceRegister(registration);

// Re-Register bei KV-Änderungen (AdvertisedHost / ServiceName)
ChangeToken.OnChange(cfg.GetReloadToken, async () =>
{
    var newAddr = cfg["Service:AdvertisedHost"] ?? svcAddr;
    var newName = cfg["Consul:ServiceName"] ?? svcName;
    if (newAddr != svcAddr || newName != svcName)
    {
        try { await consul.Agent.ServiceDeregister(svcId); } catch { }
        svcAddr = newAddr; svcName = newName;
        registration.Address = svcAddr; registration.Name = svcName;
        await consul.Agent.ServiceRegister(registration);
    }
});

// Deregistrierung beim Shutdown
lifetime.ApplicationStopping.Register(() =>
{
    try { consul.Agent.ServiceDeregister(svcId).Wait(); } catch { }
});

app.Run();


// --------------------- Hilfsfunktionen & Telemetrie ---------------------

// CA-Roots aus CONSUL_CACERT / CONSUL_CAPATH laden
static X509Certificate2Collection? LoadRootCAsFromEnv(string? caFile, string? caDir)
{
    var col = new X509Certificate2Collection();

    void ImportOne(string path)
    {
        if (path.EndsWith(".pem", StringComparison.OrdinalIgnoreCase))
            col.ImportFromPemFile(path);
        else if (path.EndsWith(".crt", StringComparison.OrdinalIgnoreCase) ||
                 path.EndsWith(".cer", StringComparison.OrdinalIgnoreCase))
            col.Import(File.ReadAllBytes(path));
    }

    if (!string.IsNullOrWhiteSpace(caFile) && File.Exists(caFile)) { ImportOne(caFile); return col; }
    if (!string.IsNullOrWhiteSpace(caDir) && Directory.Exists(caDir))
    {
        foreach (var p in Directory.EnumerateFiles(caDir, "*.*", SearchOption.TopDirectoryOnly))
            try { ImportOne(p); } catch { }
        return col.Count > 0 ? col : null;
    }
    return null;
}

// TLS-Validierung mit Custom-Root-Store
static bool ValidateWithCustomRoots(X509Certificate2? serverCert, X509Certificate2Collection roots)
{
    if (serverCert is null) return false;

    using var chain = new X509Chain
    {
        ChainPolicy =
        {
            RevocationMode = X509RevocationMode.NoCheck,
#if NET8_0_OR_GREATER
            TrustMode = X509ChainTrustMode.CustomRootTrust
#else
            VerificationFlags = X509VerificationFlags.AllowUnknownCertificateAuthority
#endif
        }
    };

#if NET8_0_OR_GREATER
    chain.ChainPolicy.CustomTrustStore.AddRange(roots);
#else
    chain.ChainPolicy.ExtraStore.AddRange(roots);
#endif

    return chain.Build(serverCert);
}

// Einfache E2E-Metriken (Sliding-Window + p95/p99)
internal static class PolTelemetry
{
    private sealed class Window
    {
        public long Total, GrpcErr, BizErr;
        public readonly System.Collections.Concurrent.ConcurrentQueue<double> Samples = new();
    }
    private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, Window> _byMethod =
        new(StringComparer.Ordinal);
    private const int WindowSize = 4096;

    public static void Record(string method, bool ok, double ms)
    {
        var w = _byMethod.GetOrAdd(method, _ => new Window());
        System.Threading.Interlocked.Increment(ref w.Total);
        if (!ok) System.Threading.Interlocked.Increment(ref w.GrpcErr);
        w.Samples.Enqueue(ms);
        while (w.Samples.Count > WindowSize && w.Samples.TryDequeue(out _)) { }
    }

    public static void RecordBusiness(string method, bool ok)
    {
        if (ok) return;
        var w = _byMethod.GetOrAdd(method, _ => new Window());
        System.Threading.Interlocked.Increment(ref w.BizErr);
    }

    public static object GetSnapshotAndReset()
    {
        var result = new Dictionary<string, object>(StringComparer.Ordinal);
        foreach (var kv in _byMethod)
        {
            var method = kv.Key; var w = kv.Value;
            var arr = w.Samples.ToArray(); Array.Sort(arr);

            double P(int p)
            {
                if (arr.Length == 0) return 0;
                double rank = (p / 100.0) * (arr.Length - 1);
                int lo = (int)Math.Floor(rank), hi = (int)Math.Ceiling(rank);
                if (lo == hi) return arr[lo];
                double frac = rank - lo;
                return arr[lo] + frac * (arr[hi] - arr[lo]);
            }

            result[method] = new
            {
                total = System.Threading.Interlocked.Read(ref w.Total),
                grpc_errors = System.Threading.Interlocked.Read(ref w.GrpcErr),
                business_errors = System.Threading.Interlocked.Read(ref w.BizErr),
                p95_ms = P(95),
                p99_ms = P(99),
                sample_count = arr.Length
            };

            System.Threading.Interlocked.Exchange(ref w.Total, 0);
            System.Threading.Interlocked.Exchange(ref w.GrpcErr, 0);
            System.Threading.Interlocked.Exchange(ref w.BizErr, 0);
            while (w.Samples.TryDequeue(out _)) { }
        }

        return new { service = "FotoFinder.PolFlash", timestamp_utc = DateTime.UtcNow, methods = result };
    }
}

// Metrik-Interceptor
internal sealed class PolGrpcMetricsInterceptor : Interceptor
{
    public override async Task<TResponse> UnaryServerHandler<TRequest, TResponse>(
        TRequest request,
        ServerCallContext context,
        UnaryServerMethod<TRequest, TResponse> continuation)
    {
        var sw = System.Diagnostics.Stopwatch.StartNew();
        StatusCode code = StatusCode.OK;
        try
        {
            var resp = await continuation(request, context);
            return resp;
        }
        catch (RpcException ex) { code = ex.StatusCode; throw; }
        catch { code = StatusCode.Unknown; throw; }
        finally
        {
            sw.Stop();
            bool ok = code == StatusCode.OK;
            PolTelemetry.Record(context.Method ?? "unknown", ok, sw.Elapsed.TotalMilliseconds);
        }
    }
}
