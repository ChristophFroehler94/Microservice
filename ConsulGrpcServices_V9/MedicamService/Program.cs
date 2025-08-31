using Camera.Grpc.Service;
using Consul;
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
// Doku: CONSUL_HTTP_ADDR / _TOKEN / _CACERT / _CAPATH
string consulAddr = Environment.GetEnvironmentVariable("CONSUL_HTTP_ADDR") ?? "https://127.0.0.1:8501";
string? consulToken = Environment.GetEnvironmentVariable("CONSUL_HTTP_TOKEN");
string? cacert = Environment.GetEnvironmentVariable("CONSUL_CACERT");
string? capath = Environment.GetEnvironmentVariable("CONSUL_CAPATH");
var consulRoots = LoadRootCAsFromEnv(cacert, capath);

var rootCount = consulRoots?.Count ?? 0;
Console.WriteLine($"[TLS] Loaded {rootCount} root CA(s) from {(cacert ?? capath ?? "(none)")}");

// ---- KV-Key exakt wie im Skript geseeded ----
// camera/<NodeName>/config.json  (NodeName kommt aus Skript via CONSUL_NODENAME)
string node = Environment.GetEnvironmentVariable("CONSUL_NODENAME") ?? Environment.MachineName;
string servicePrefix = Environment.GetEnvironmentVariable("SERVICE_PREFIX") ?? "camera";
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
// 3) Kestrel dynamisch aus "Kestrel"-Section (inkl. PEM Path/KeyPath)
// ------------------------------------------------------------
builder.WebHost.ConfigureKestrel((context, kestrel) =>
{
    kestrel.Configure(context.Configuration.GetSection("Kestrel"), reloadOnChange: true);
});

// ------------------------------------------------------------
// 4) Logging / gRPC / Health
// ------------------------------------------------------------
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(Microsoft.Extensions.Logging.LogLevel.Information);

builder.Services.AddGrpc(o => o.EnableDetailedErrors = true);
builder.Services.AddGrpcReflection();
builder.Services.AddGrpcHealthChecks().AddCheck("camera-v1", () => HealthCheckResult.Healthy());

// ------------------------------------------------------------
// 5) Optionen & DI (Visca initial; kein Reconfigure-Aufruf nötig)
// ------------------------------------------------------------
builder.Services.Configure<ViscaOptions>(builder.Configuration.GetSection("Visca"));
builder.Services.AddSingleton<ViscaController>(sp =>
{
    var cfg = sp.GetRequiredService<IConfiguration>();
    var port = cfg["Visca:Port"] ?? "COM5";
    var baud = int.TryParse(cfg["Visca:Baud"], out var b) ? b : 9600;
    return new ViscaController(port, baud, deviceAddress: 1);
});
builder.Services.AddSingleton<FfmpegCoreVideoStream>();

// ------------------------------------------------------------
// 6) Consul-Client (TLS-Validation optional über Root-CAs)
// ------------------------------------------------------------
builder.Services.AddSingleton<IConsulClient>(_ =>
{
    return new ConsulClient(
        configOverride: c =>
        {
            // Falls in KV überschrieben, sonst Bootstrap-ENV
            c.Address = new Uri(builder.Configuration["Consul:Address"] ?? consulAddr);
            var token = builder.Configuration["Consul:Token"] ?? consulToken;
            if (!string.IsNullOrWhiteSpace(token)) c.Token = token;
        },
        clientOverride: client =>
        {
            // z.B. Timeouts setzen, falls gewünscht:
            // client.Timeout = TimeSpan.FromMinutes(2);
        },
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

app.MapGrpcService<CameraServiceImpl>();
app.MapGrpcHealthChecksService();
app.MapGrpcReflectionService();
app.MapGet("/", () => "Camera Service gRPC running…");

// ------------------------------------------------------------
// 8) Consul-Registrierung aus KV
// ------------------------------------------------------------
var cfg = app.Configuration;
var consul = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Lifetime;

var grpcUrl = cfg["Kestrel:Endpoints:Grpc:Url"] ?? "https://0.0.0.0:5294";
var uri = new Uri(grpcUrl);

var serviceAddress = cfg["Service:AdvertisedHost"] ?? "127.0.0.1";
var servicePort = uri.Port;
var serviceId = cfg["Consul:ServiceId"] ?? "camera-1";
var serviceName = cfg["Consul:ServiceName"] ?? "CameraService";

var registration = new AgentServiceRegistration
{
    ID = serviceId,
    Name = serviceName,
    Address = serviceAddress,
    Port = servicePort,
    Checks = new[]
    {
        new AgentServiceCheck
        {
            GRPC = $"{serviceAddress}:{servicePort}",
            GRPCUseTLS = true,
            // TLSSkipVerify = true, // nur falls der Agent deiner CA (vorübergehend) nicht vertraut
            Interval = TimeSpan.FromSeconds(10),
            Timeout  = TimeSpan.FromSeconds(5),
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
            // importiert alle CERTIFICATE-Blöcke aus der PEM-Datei (ohne Keys)
            col.ImportFromPemFile(path);
        }
        else if (path.EndsWith(".crt", StringComparison.OrdinalIgnoreCase) ||
                 path.EndsWith(".cer", StringComparison.OrdinalIgnoreCase))
        {
            // DER/CRT einlesen
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
            // CRL/OCSP für interne Test-CA meist nicht verfügbar
            RevocationMode    = X509RevocationMode.NoCheck,
            // Erlaube unbekannte (nicht im Windows-Rootstore verankerte) CAs,
            // wir liefern die CA(s) über ExtraStore selbst mit:
            VerificationFlags = X509VerificationFlags.AllowUnknownCertificateAuthority
        }
    };

    // unsere(n) Root-/Intermediate-CA(s) anhängen
    chain.ChainPolicy.ExtraStore.AddRange(roots);

    // Wenn die Kette gegen unsere ExtraStore-CAs gebaut werden kann, ok:
    return chain.Build(serverCert);
}


// ===== DTOs =====
public record ViscaOptions
{
    public string? Port { get; init; }
    public string? Baud { get; init; }
}
