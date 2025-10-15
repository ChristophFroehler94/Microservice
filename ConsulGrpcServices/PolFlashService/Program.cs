// Program.cs — PolFlash (vereinheitlicht nach medicam; fixer Port 5295; ENV + Args + Consul-KV nur für Service.AdvertisedHost; TLS-PFX aus ENV)

using Consul;
using FotoFinder.PolFlashGrpc.Services;
using FotoFinder.PolFlashXE.FlashDevices;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Primitives;
using System.Security.Cryptography.X509Certificates;
using Winton.Extensions.Configuration.Consul;
using System.Linq;

const int GrpcPort = 5295;
const string ServiceName = "PolFlashService";

var builder = WebApplication.CreateBuilder(new WebApplicationOptions { Args = args });

// ------------------------------------------------------------
// 1) Konfigquellen: ENV + Args + Consul KV (KEIN appsettings.*)
// ------------------------------------------------------------
builder.Configuration.Sources.Clear();
builder.Configuration.AddEnvironmentVariables(prefix: "APP_");
builder.Configuration.AddCommandLine(args);

// Konsul-Bootstrap aus ENV (DEV-freundliche Defaults)
string consulAddr = Environment.GetEnvironmentVariable("CONSUL_HTTP_ADDR") ?? "https://127.0.0.1:8501";
string node = Environment.GetEnvironmentVariable("CONSUL_NODENAME") ?? Environment.MachineName;
string servicePrefix = Environment.GetEnvironmentVariable("SERVICE_PREFIX") ?? "polflash";
string kvPath = Environment.GetEnvironmentVariable("CONSUL_KVPATH") ?? $"{servicePrefix}/{node}/config.json";

// Minimal: nur Service.AdvertisedHost aus KV
builder.Configuration.AddConsul(
    kvPath,
    options =>
    {
        options.ConsulConfigurationOptions = cco => { cco.Address = new Uri(consulAddr); };

        // DEV ONLY: Consul-Agent nutzt eigene CA/Zerts → ohne Root-Import zulassen
        options.ConsulHttpClientHandlerOptions = h =>
        {
            h.ServerCertificateCustomValidationCallback =
                HttpClientHandler.DangerousAcceptAnyServerCertificateValidator;
        };

        options.Optional = false;
        options.ReloadOnChange = true;
        options.PollWaitTime = TimeSpan.FromSeconds(5);
        options.OnLoadException = ctx => ctx.Ignore = false; // fail-fast
    });

// ------------------------------------------------------------
// 2) Kestrel: fester Port 5295 + HTTPS mit Dev-Zertifikat (PFX aus ENV)
// ------------------------------------------------------------
var tlsPfxPath = Environment.GetEnvironmentVariable("APP_TLS_PFX");
var tlsPfxPwd = Environment.GetEnvironmentVariable("APP_TLS_PFX_PASSWORD");

X509Certificate2? serverCert = null;
if (!string.IsNullOrWhiteSpace(tlsPfxPath) && File.Exists(tlsPfxPath))
{
    // MachineKeySet damit auch als Dienst nutzbar; Exportable nur für Dev/Test
    serverCert = new X509Certificate2(
        tlsPfxPath,
        tlsPfxPwd ?? string.Empty,
        X509KeyStorageFlags.MachineKeySet | X509KeyStorageFlags.Exportable);
}

builder.WebHost.ConfigureKestrel(kestrel =>
{
    kestrel.ListenAnyIP(GrpcPort, listen =>
    {
        listen.Protocols = HttpProtocols.Http2; // gRPC benötigt HTTP/2
        if (serverCert is not null)
        {
            listen.UseHttps(serverCert); // explizites Dev-PFX
        }
        else
        {
            listen.UseHttps(); // Fallback: lokales Dev-Zertifikat (dotnet dev-certs)
        }
    });
});

// ------------------------------------------------------------
// 3) Logging / gRPC / Health
// ------------------------------------------------------------
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(Microsoft.Extensions.Logging.LogLevel.Information);

builder.Services.AddGrpc(o => o.EnableDetailedErrors = true);
builder.Services.AddGrpcReflection();

// ------------------------------------------------------------
// 4) PolFlash-Gerät ermitteln & DI registrieren (+ v1/v2 Tagging für Health/Consul)
// ------------------------------------------------------------
var devices = await FlashDeviceFactory.RefreshDeviceListAsync();
var device = devices.OfType<IFlashDevice>().FirstOrDefault()
    ?? throw new InvalidOperationException("No compatible PolFlash device found");
device.Initialize();

bool isV2 = device is IFlashDevice2;
string versionTag = isV2 ? "v2" : "v1";

// Health-Check-Name mit Versionstag (analog camera-v1 im medicam)
builder.Services.AddGrpcHealthChecks().AddCheck($"polflash-{versionTag}", () => HealthCheckResult.Healthy());

// DI
builder.Services.AddSingleton<IFlashDevice>(device);

// ------------------------------------------------------------
// 5) Consul-Client (DEV: Zertvalidierung gelockert; Consul nutzt eigene Zerts)
// ------------------------------------------------------------
builder.Services.AddSingleton<IConsulClient>(_ =>
{
    return new ConsulClient(
        configOverride: c => { c.Address = new Uri(consulAddr); },
        clientOverride: _ => { },
        handlerOverride: h =>
        {
            // DEV ONLY: akzeptiere Consul-Agent-Zertifikate ohne Root-Import
            h.ServerCertificateCustomValidationCallback =
                HttpClientHandler.DangerousAcceptAnyServerCertificateValidator;
        });
});

// ------------------------------------------------------------
// 6) App-Endpunkte
// ------------------------------------------------------------
var app = builder.Build();

app.MapGrpcService<FlashControlService>();
app.MapGrpcHealthChecksService();
app.MapGrpcReflectionService();
app.MapGet("/", () => $"PolFlash gRPC Service is running… ({versionTag})");

// ------------------------------------------------------------
// 7) Consul-Registrierung (nur AdvertisedHost aus KV)
// ------------------------------------------------------------
var cfg = app.Configuration;
var consul = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Lifetime;

string serviceAddress = cfg["Service:AdvertisedHost"] ?? "127.0.0.1";
string serviceId = cfg["Consul:ServiceId"] ?? $"polflash-{node}";

var registration = new AgentServiceRegistration
{
    ID = serviceId,
    Name = ServiceName,
    Address = serviceAddress,
    Port = GrpcPort,
    Tags = new[] { "grpc", "polflash", versionTag },
    Meta = new Dictionary<string, string>
    {
        ["deviceVersion"] = versionTag,
        ["impl"] = isV2 ? "IFlashDevice2" : "IFlashDevice"
    },
    Checks = new[]
    {
        new AgentServiceCheck
        {
            GRPC                 = $"{serviceAddress}:{GrpcPort}",
            GRPCUseTLS           = true,
            TLSSkipVerify        = true, // DEV: Agent darf self-signed akzeptieren
            Interval             = TimeSpan.FromSeconds(10),
            Timeout              = TimeSpan.FromSeconds(5),
            DeregisterCriticalServiceAfter = TimeSpan.FromMinutes(2)
        }
    }
};

await consul.Agent.ServiceRegister(registration);

// Re-Registration bei KV-Änderung (nur Adresse)
ChangeToken.OnChange(cfg.GetReloadToken, async () =>
{
    string newAddr = cfg["Service:AdvertisedHost"] ?? serviceAddress;
    if (newAddr != serviceAddress)
    {
        try { await consul.Agent.ServiceDeregister(serviceId); } catch { /* ignore */ }
        serviceAddress = newAddr;
        registration.Address = serviceAddress;
        await consul.Agent.ServiceRegister(registration);
    }
});

lifetime.ApplicationStopping.Register(() =>
{
    try { consul.Agent.ServiceDeregister(serviceId).Wait(); } catch { /* ignore */ }
});

app.Run();
