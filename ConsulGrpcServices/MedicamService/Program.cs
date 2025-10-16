// Program.cs – Medicam: ENV+Consul-KV, TLS (PFX aus ENV), konsistente Kestrel-Fallbacks, gRPC-Health & Metriken

using Consul;
using Medicam.Infrastructure;
using Medicam.Options;
using Medicam.Service;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Primitives;
using System.Security.Cryptography.X509Certificates;
using Winton.Extensions.Configuration.Consul;
// Alias für vorhandene Telemetrie (falls Bibliothek vorhanden)
using AppTelemetry = Medicam.Diagnostics.Telemetry;

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
string servicePrefix = Environment.GetEnvironmentVariable("SERVICE_PREFIX") ?? "camera";
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

    // Fallback, falls keine Endpoints definiert sind
    bool hasEndpoints = context.Configuration.GetSection("Kestrel:Endpoints").GetChildren().Any();
    if (!hasEndpoints)
    {
        const int DefaultGrpcPort = 5294;
        kestrel.ListenAnyIP(DefaultGrpcPort, listen =>
        {
            listen.Protocols = HttpProtocols.Http1AndHttp2; // gRPC + /metrics
            if (serverCert is not null) listen.UseHttps(serverCert);
            else listen.UseHttps(); // Dev-Fallback
        });
        Console.WriteLine($"[Kestrel] Fallback: https://0.0.0.0:{DefaultGrpcPort}");
    }
});

// Logging + gRPC + Health + Reflection + (vorhandener) Metrik-Interceptor
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(Microsoft.Extensions.Logging.LogLevel.Information);
builder.Services.AddGrpc(o =>
{
    o.EnableDetailedErrors = true;
    // Falls eigener Interceptor vorhanden:
    o.Interceptors.Add<Medicam.Diagnostics.GrpcMetricsInterceptor>();
});
builder.Services.AddGrpcReflection();
builder.Services.AddHealthChecks().AddCheck("self", () => HealthCheckResult.Healthy());
builder.Services.AddGrpcHealthChecks();

// Fachdienste (Beispiel)
builder.Services.AddOptions<VideoOptions>();
builder.Services.AddSingleton<Medicam.Diagnostics.FaultState>();
builder.Services.AddSingleton<ViscaController>(sp =>
{
    var faults = sp.GetRequiredService<Medicam.Diagnostics.FaultState>();
    int baud = 9600;
    string? auto = Medicam.Interop.SerialPorts.AutoDetectFtdiComPort();
    string port = !string.IsNullOrWhiteSpace(auto) ? auto : "COM5";
    Console.WriteLine($"[VISCA] Port={port} baud={baud} {(auto is not null ? "[auto-FTDI]" : "[fallback]")}");
    return new ViscaController(port, baud, deviceAddress: 1, faults);
});
builder.Services.AddSingleton<FfmpegCoreVideoStream>(sp =>
{
    var cfg = sp.GetRequiredService<IConfiguration>();
    string devName = cfg["Video:DeviceName"] ?? "XI100DUSB-SDI Video";
    return new FfmpegCoreVideoStream(devName);
});

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

// gRPC/HTTP-Endpunkte
app.MapGrpcService<CameraServiceImpl>();
app.MapGrpcHealthChecksService();
#if DEBUG
app.MapGrpcReflectionService();
#endif
app.MapHealthChecks("/healthz");

// Metrik-Snapshot (falls Bibliothek vorhanden)
app.MapGet("/metrics/snapshot", () =>
{
    var snapshot = AppTelemetry.GetSnapshotAndReset();
    return Results.Json(snapshot);
})
.WithDisplayName("Metrics Snapshot (E2E, p95/p99)");

app.MapGet("/", () => "Medicam gRPC Service läuft (TLS, HTTP/2).");

// Consul-Registrierung (gRPC-Health über TLS)
var cfg = app.Configuration;
var consul = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Lifetime;
string svcAddr = cfg["Service:AdvertisedHost"] ?? "127.0.0.1";
int svcPort = (cfg["Kestrel:Endpoints:Grpc:Url"] is string u && Uri.TryCreate(u, UriKind.Absolute, out var tmp)) ? tmp.Port : 5294;
string svcId = cfg["Consul:ServiceId"] ?? $"medicam-{node}";
string svcName = cfg["Consul:ServiceName"] ?? "MedicamService";
bool skipHv = (Environment.GetEnvironmentVariable("APP_HEALTH_TLS_SKIPVERIFY") ?? "true")
                 .Equals("true", StringComparison.OrdinalIgnoreCase);

var registration = new AgentServiceRegistration
{
    ID = svcId,
    Name = svcName,
    Address = svcAddr,
    Port = svcPort,
    Tags = new[] { "grpc", "medicam" },
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

// Re-Register bei KV-Änderung (AdvertisedHost / ServiceName)
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


// --------------------- Hilfsfunktionen ---------------------

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
