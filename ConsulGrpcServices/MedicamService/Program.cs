using Camera.Grpc.Service;
using Consul;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Primitives;
// NEW usings for TLS handling
using System.Security.Cryptography.X509Certificates;
using System.Text.RegularExpressions;
using Winton.Extensions.Configuration.Consul;

const int GrpcPort = 5294;
const string ServiceName = "CameraService";

var builder = WebApplication.CreateBuilder(new WebApplicationOptions { Args = args });

// ------------------------------------------------------------
// 1) Konfigquellen: ENV + Args + Consul KV (KEIN appsettings.*)
// ------------------------------------------------------------
builder.Configuration.Sources.Clear();
builder.Configuration.AddEnvironmentVariables(prefix: "APP_");
builder.Configuration.AddCommandLine(args);

// Konsul-Bootstrap aus ENV
string consulAddr = Environment.GetEnvironmentVariable("CONSUL_HTTP_ADDR") ?? "https://127.0.0.1:8501";
string node = Environment.GetEnvironmentVariable("CONSUL_NODENAME") ?? Environment.MachineName;
string servicePrefix = Environment.GetEnvironmentVariable("SERVICE_PREFIX") ?? "camera";
string kvPath = Environment.GetEnvironmentVariable("CONSUL_KVPATH") ?? $"{servicePrefix}/{node}/config.json";

// Minimal: nur Service.AdvertisedHost aus KV
builder.Configuration.AddConsul(
    kvPath,
    options =>
    {
        options.ConsulConfigurationOptions = cco => { cco.Address = new Uri(consulAddr); };

        // DEV ONLY: Consul-Agent nutzt eigene CA/Zerts. Für DEV ohne Root-Import:
        options.ConsulHttpClientHandlerOptions = h =>
        {
            h.ServerCertificateCustomValidationCallback =
                HttpClientHandler.DangerousAcceptAnyServerCertificateValidator; // DEV!
        };

        options.Optional = false;
        options.ReloadOnChange = true;
        options.PollWaitTime = TimeSpan.FromSeconds(5);
        options.OnLoadException = ctx => ctx.Ignore = false; // fail-fast
    });

// ------------------------------------------------------------
// 2) Kestrel: fester Port + HTTPS mit Dev-Zertifikat (PFX aus ENV)
// ------------------------------------------------------------
var tlsPfxPath = Environment.GetEnvironmentVariable("APP_TLS_PFX");
var tlsPfxPwd = Environment.GetEnvironmentVariable("APP_TLS_PFX_PASSWORD");

X509Certificate2? serverCert = null;
if (!string.IsNullOrWhiteSpace(tlsPfxPath) && File.Exists(tlsPfxPath))
{
    // MachineKeySet damit auch als Dienst nutzbar; Exportable nur für Dev-Tests
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
            listen.UseHttps(); // Fallback: lokales Dev-Zertifikat
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
builder.Services.AddGrpcHealthChecks().AddCheck("camera-v1", () => HealthCheckResult.Healthy());

// ------------------------------------------------------------
// 4) DI: Options + Visca (FTDI auto) + VideoStreamer
// ------------------------------------------------------------
builder.Services.AddOptions<VideoOptions>();

builder.Services.AddSingleton<ViscaController>(_ =>
{
    int baud = 9600;  // feste Baudrate für Prototyp
    string? auto = AutoDetectFtdiComPort();
    string port = !string.IsNullOrWhiteSpace(auto) ? auto : "COM5"; // Fallback
    Console.WriteLine($"[VISCA] Port={port} baud={baud} {(auto is not null ? "[auto-FTDI]" : "[fallback]")}");
    return new ViscaController(port, baud, deviceAddress: 1);
});

builder.Services.AddSingleton<FfmpegCoreVideoStream>();

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

app.MapGrpcService<CameraServiceImpl>();
app.MapGrpcHealthChecksService();
app.MapGrpcReflectionService();
app.MapGet("/", () => "Camera Service gRPC running…");

// ------------------------------------------------------------
// 7) Consul-Registrierung (nur AdvertisedHost aus KV)
// ------------------------------------------------------------
var cfg = app.Configuration;
var consul = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Lifetime;

string serviceAddress = cfg["Service:AdvertisedHost"] ?? "127.0.0.1";
string serviceId = cfg["Consul:ServiceId"] ?? $"camera-{node}";

var registration = new AgentServiceRegistration
{
    ID = serviceId,
    Name = ServiceName,
    Address = serviceAddress,
    Port = GrpcPort,
    Checks = new[]
    {
        new AgentServiceCheck
        {
            GRPC = $"{serviceAddress}:{GrpcPort}",
            GRPCUseTLS = true,
            TLSSkipVerify = true, // DEV: Agent darf self-signed akzeptieren
            Interval = TimeSpan.FromSeconds(10),
            Timeout  = TimeSpan.FromSeconds(5),
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
        try { await consul.Agent.ServiceDeregister(serviceId); } catch { }
        serviceAddress = newAddr;
        registration.Address = serviceAddress;
        await consul.Agent.ServiceRegister(registration);
    }
});

lifetime.ApplicationStopping.Register(() =>
{
    try { consul.Agent.ServiceDeregister(serviceId).Wait(); } catch { }
});

app.Run();

// ========================== Helpers ==========================

// FTDI COM-Port Auto-Detection (VID_0403 / PID_6001)
static string? AutoDetectFtdiComPort()
{
    if (!OperatingSystem.IsWindows()) return null;
    try
    {
        using var searcher = new System.Management.ManagementObjectSearcher(
            "SELECT Name, PNPDeviceID FROM Win32_PnPEntity WHERE Name LIKE '%(COM%'");
        foreach (var mo in searcher.Get())
        {
            string name = mo["Name"]?.ToString() ?? "";
            string pnp = mo["PNPDeviceID"]?.ToString() ?? "";

            bool isFtdi = pnp.Contains(@"FTDIBUS\COMPORT&VID_0403&PID_6001", StringComparison.OrdinalIgnoreCase)
                          || (pnp.Contains("VID_0403", StringComparison.OrdinalIgnoreCase)
                           && pnp.Contains("PID_6001", StringComparison.OrdinalIgnoreCase));
            if (!isFtdi) continue;

            var m = Regex.Match(name, @"\((COM\d+)\)");
            if (m.Success) return m.Groups[1].Value;
        }
    }
    catch { /* ignore → fallback */ }
    return null;
}
