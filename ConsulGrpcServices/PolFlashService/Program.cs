// Program.cs – PolFlash (Consul-KV + Winton + TLS-Roots aus ENV + v1/v2 Tagging)

using Consul;
using FotoFinder.PolFlashGrpc.Services;
using FotoFinder.PolFlashXE.FlashDevices;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Primitives;
using System.Security.Cryptography.X509Certificates;
using Winton.Extensions.Configuration.Consul;

var builder = WebApplication.CreateBuilder(new WebApplicationOptions { Args = args });

// ------------------------------------------------------------
// 1) Konfigquellen: ENV (Standard), Args – KEIN appsettings.*
// ------------------------------------------------------------
builder.Configuration.Sources.Clear();
builder.Configuration.AddEnvironmentVariables(prefix: "APP_"); // optional
builder.Configuration.AddCommandLine(args);

// ---- Standard-ENV (HashiCorp Consul) ----
// Doku: CONSUL_HTTP_ADDR / _TOKEN / _CACERT / _CAPATH / CONSUL_NODENAME
string consulAddr = Environment.GetEnvironmentVariable("CONSUL_HTTP_ADDR") ?? "https://127.0.0.1:8501";
string? consulToken = Environment.GetEnvironmentVariable("CONSUL_HTTP_TOKEN");
string? cacert = Environment.GetEnvironmentVariable("CONSUL_CACERT");
string? capath = Environment.GetEnvironmentVariable("CONSUL_CAPATH");
var consulRoots = LoadRootCAsFromEnv(cacert, capath);

var rootCount = consulRoots?.Count ?? 0;
Console.WriteLine($"[TLS] Loaded {rootCount} root CA(s) from {(cacert ?? capath ?? "(none)")}");

// ---- KV-Key exakt wie das Setup-Skript seeden würde ----
// polflash/<NodeName>/config.json  (NodeName via CONSUL_NODENAME)
string node = Environment.GetEnvironmentVariable("CONSUL_NODENAME") ?? Environment.MachineName;
string servicePrefix = Environment.GetEnvironmentVariable("SERVICE_PREFIX") ?? "polflash";
string kvPath = Environment.GetEnvironmentVariable("CONSUL_KVPATH") ?? $"{servicePrefix}/{node}/config.json";

// ------------------------------------------------------------
// 2) Consul-KV als Konfigquelle (Winton) + TLS-Validierung
// ------------------------------------------------------------
builder.Configuration.AddConsul(
    kvPath,
    options =>
    {
        options.ConsulConfigurationOptions = cco =>
        {
            cco.Address = new Uri(consulAddr);
            if (!string.IsNullOrWhiteSpace(consulToken))
                cco.Token = consulToken;
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

// ------------------------------------------------------------
// 3) Kestrel dynamisch aus "Kestrel"-Section + HTTP/2-Fenster
// ------------------------------------------------------------
builder.WebHost.ConfigureKestrel((context, kestrel) =>
{
    kestrel.Configure(context.Configuration.GetSection("Kestrel"), reloadOnChange: true);
    try
    {
        kestrel.Limits.Http2.InitialConnectionWindowSize = 16 * 1024 * 1024;
        kestrel.Limits.Http2.InitialStreamWindowSize     = 16 * 1024 * 1024;
    }
    catch { /* falls Http2-Limits fehlen, ignorieren */ }
});

// ------------------------------------------------------------
// 4) Logging / gRPC / Health (Name wird unten nach Geräte-Detect gesetzt)
// ------------------------------------------------------------
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(Microsoft.Extensions.Logging.LogLevel.Information);

builder.Services.AddGrpc(o => o.EnableDetailedErrors = true);
builder.Services.AddGrpcReflection();

// ------------------------------------------------------------
// 5) PolFlash-Gerät entdecken & DI registrieren (+ v1/v2-Flag)
// ------------------------------------------------------------
var devices = await FlashDeviceFactory.RefreshDeviceListAsync();
var device = devices.OfType<IFlashDevice>().FirstOrDefault()
    ?? throw new InvalidOperationException("No compatible PolFlash device found");
device.Initialize();

// v2 erkennen (falls Interface vorhanden)
bool isV2 = device is IFlashDevice2;
string versionTag = isV2 ? "v2" : "v1";

builder.Services.AddSingleton<IFlashDevice>(device);

// Health-Check-Name dynamisch nach Version
builder.Services.AddGrpcHealthChecks().AddCheck($"polflash-{versionTag}", () => HealthCheckResult.Healthy());

// ------------------------------------------------------------
// 6) Consul-Client (TLS-Validation optional über Root-CAs)
// ------------------------------------------------------------
builder.Services.AddSingleton<IConsulClient>(_ =>
{
    return new ConsulClient(
        configOverride: c =>
        {
            c.Address = new Uri(builder.Configuration["Consul:Address"] ?? consulAddr);
            var token = builder.Configuration["Consul:Token"] ?? consulToken;
            if (!string.IsNullOrWhiteSpace(token)) c.Token = token;
        },
        clientOverride: client => { /* client.Timeout = TimeSpan.FromSeconds(30); */ },
        handlerOverride: handler =>
        {
            if (consulRoots is not null)
            {
                handler.ServerCertificateCustomValidationCallback =
                    (req, cert, chain, errs) => ValidateWithCustomRoots(cert, consulRoots);
            }
        });
});

// ------------------------------------------------------------
// 7) App-Endpunkte
// ------------------------------------------------------------
var app = builder.Build();

app.MapGrpcService<FlashControlService>();
app.MapGrpcHealthChecksService();
app.MapGrpcReflectionService();
app.MapGet("/", () => $"PolFlash gRPC Service is running… ({versionTag})");

// ------------------------------------------------------------
// 8) Consul-Registrierung aus KV (mit Tags für v1/v2)
// ------------------------------------------------------------
var cfg = app.Configuration;
var consul = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Lifetime;

// Port aus Kestrel-Konfig lesen (Fallback 5295 für PolFlash)
var grpcUrl = cfg["Kestrel:Endpoints:Grpc:Url"] ?? "https://0.0.0.0:5295";
var uri = new Uri(grpcUrl);

// Advertised Host (aus Config), sonst loopback
var serviceAddress = cfg["Service:AdvertisedHost"] ?? "127.0.0.1";
var servicePort = uri.Port;

// Dienst-IDs/-Namen aus Config (Defaults für PolFlash)
var serviceId = cfg["Consul:ServiceId"]   ?? $"polflash-{versionTag}-1";
var serviceName = cfg["Consul:ServiceName"] ?? "PolFlashService";

// Tags & Meta für Version unterscheiden
var tags = new List<string> { "grpc", "polflash", versionTag }; // <- v1 / v2
var meta = new Dictionary<string, string>
{
    ["deviceVersion"] = versionTag,
    ["impl"] = isV2 ? "IFlashDevice2" : "IFlashDevice"
};

var registration = new AgentServiceRegistration
{
    ID      = serviceId,
    Name    = serviceName,
    Address = serviceAddress,
    Port    = servicePort,
    Tags    = tags.ToArray(),
    Meta    = meta,
    Checks  = new[]
    {
        // gRPC-Health-Check via TLS
        new AgentServiceCheck
        {
            GRPC       = $"{serviceAddress}:{servicePort}",
            GRPCUseTLS = true,
            Interval   = TimeSpan.FromSeconds(10),
            Timeout    = TimeSpan.FromSeconds(5),
            DeregisterCriticalServiceAfter = TimeSpan.FromMinutes(2)
        }
    }
};

await consul.Agent.ServiceRegister(registration);

// Bei KV-Änderungen ggf. neu registrieren (wenn Name/Adresse wechseln)
ChangeToken.OnChange(cfg.GetReloadToken, async () =>
{
    var newAddr = cfg["Service:AdvertisedHost"] ?? serviceAddress;
    var newName = cfg["Consul:ServiceName"] ?? serviceName;

    if (newAddr != serviceAddress || newName != serviceName)
    {
        try { await consul.Agent.ServiceDeregister(serviceId); } catch { /* ignore */ }
        serviceAddress = newAddr; serviceName = newName;
        registration.Address = serviceAddress; registration.Name = serviceName;
        await consul.Agent.ServiceRegister(registration);
    }
});

lifetime.ApplicationStopping.Register(() =>
{
    try { consul.Agent.ServiceDeregister(serviceId).Wait(); } catch { /* ignore */ }
});

app.Run();

// ========================== Helpers ==========================
static X509Certificate2Collection? LoadRootCAsFromEnv(string? caFile, string? caDir)
{
    var col = new X509Certificate2Collection();

    void ImportOne(string path)
    {
        if (path.EndsWith(".pem", StringComparison.OrdinalIgnoreCase))
        {
            col.ImportFromPemFile(path); // alle CERTIFICATE-Blöcke
        }
        else if (path.EndsWith(".crt", StringComparison.OrdinalIgnoreCase) ||
                 path.EndsWith(".cer", StringComparison.OrdinalIgnoreCase))
        {
            col.Import(File.ReadAllBytes(path));
        }
    }

    if (!string.IsNullOrWhiteSpace(caFile) && File.Exists(caFile))
    {
        ImportOne(caFile);
        return col;
    }

    if (!string.IsNullOrWhiteSpace(caDir) && Directory.Exists(caDir))
    {
        foreach (var p in Directory.EnumerateFiles(caDir, "*.*", SearchOption.TopDirectoryOnly))
        {
            try { ImportOne(p); } catch { /* ungültige Dateien ignorieren */ }
        }
        return col.Count > 0 ? col : null;
    }

    return null;
}

static bool ValidateWithCustomRoots(X509Certificate2? serverCert, X509Certificate2Collection roots)
{
    if (serverCert is null) return false;

    using var chain = new X509Chain
    {
        ChainPolicy =
        {
            RevocationMode    = X509RevocationMode.NoCheck,
            VerificationFlags = X509VerificationFlags.AllowUnknownCertificateAuthority
        }
    };

    chain.ChainPolicy.ExtraStore.AddRange(roots);
    return chain.Build(serverCert);
}
