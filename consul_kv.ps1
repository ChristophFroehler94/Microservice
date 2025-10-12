#requires -Version 7.0
<#
  Liest .\consul\config\server.hcl, setzt ENV (CONSUL_HTTP_ADDR/CACERT/…)
  und schreibt camera/<NodeName>/config.json nach Consul KV.
  ACL/TOKEN wird nicht gesetzt (wie gewünscht).

  Aufruf-Beispiel:
    .\Seed-Env-And-KV.ps1 -ServiceName CameraService -ServiceId camera-1 -AdvertisedHost 192.168.178.40
#>

[CmdletBinding()]
param(
  [string] $ServerHclPath = "$PSScriptRoot\consul\config\server.hcl",
  [string] $ConsulExePath = (Get-Command consul -ErrorAction SilentlyContinue | ForEach-Object Source) ?? "$PSScriptRoot\consul\bin\consul.exe",

  # KV-Namespace & Service-Metadaten
  [string] $ServicePrefix = "camera",
  [string] $ServiceName   = "CameraService",
  [string] $ServiceId     = "camera-1",

  # gRPC-Dienst (Kestrel) – Bind + Advertised Adresse
  [string] $AdvertisedHost = $env:COMPUTERNAME,        # IP oder DNS für Clients/Consul
  [string] $GrpcListenUrl  = "https://0.0.0.0:5294",

  # Zertifikat des gRPC-Dienstes (nicht das Consul-Server-Zertifikat!)
  [string] $SvcCertPath    = "$PSScriptRoot\consul\certs\dc1-server-consul-0.pem",
  [string] $SvcKeyPath     = "$PSScriptRoot\consul\certs\dc1-server-consul-0-key.pem"
)

function Fail($m){ throw $m }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host   "[OK ] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

# --- Eingaben prüfen ---
if(-not (Test-Path -LiteralPath $ServerHclPath)){ Fail "server.hcl nicht gefunden: $ServerHclPath" }
if(-not (Test-Path -LiteralPath $ConsulExePath)){ Fail "consul.exe nicht gefunden:  $ConsulExePath" }

# --- server.hcl robust parsen ---
$hcl = Get-Content -LiteralPath $ServerHclPath -Raw -ErrorAction Stop

# Einzelwerte zeilenweise:
$bind = if ($hcl -match '(?m)^\s*bind_addr\s*=\s*"([^"]+)"') { $Matches[1] } else { $null }
$node = if ($hcl -match '(?m)^\s*node_name\s*=\s*"([^"]+)"') { $Matches[1] } else { $null }

# ca_file kann im tls.defaults-Block stehen -> global suchen:
$caFile = if ($hcl -match '(?m)ca_file\s*=\s*"([^"]+)"') { $Matches[1] } else { $null }

# https-Port aus dem ports-Block (Block-Match, non-greedy):
$https = if ($hcl -match '(?s)ports\s*=\s*\{.*?https\s*=\s*([-]?\d+).*?\}') { $Matches[1] } else { $null }

if (-not $bind)  { throw "bind_addr nicht gefunden (Regex)." }
if (-not $node)  { $node = $env:CONSUL_NODENAME ?? $env:COMPUTERNAME }
if (-not $https) { $https = '8501' }    # Fallback
if ($https -eq '-1') { throw "HTTPS in server.hcl deaktiviert (ports.https = -1) — TLS-API nicht erreichbar." }

$CONSUL_HTTP_ADDR = "https://127.0.0.1:$https"
$CONSUL_CACERT    = if ($caFile) { $caFile } else { "C:\consul\pki\consul-agent-ca.pem" }
$CONSUL_CAPATH    = Split-Path -Parent $CONSUL_CACERT
$CONSUL_KVPATH    = "$ServicePrefix/$node/config.json"

Write-Host "[INFO] CONSUL_HTTP_ADDR=$CONSUL_HTTP_ADDR"
Write-Host "[INFO] CONSUL_CACERT=$CONSUL_CACERT"
Write-Host "[INFO] KV-Pfad=$CONSUL_KVPATH"

# --- ENV dauerhaft + im aktuellen Prozess setzen ---
$Target = [EnvironmentVariableTarget]::User  # für systemweit: ::Machine
$envMap = @{
  "CONSUL_HTTP_ADDR" = $CONSUL_HTTP_ADDR
  "CONSUL_CACERT"    = $CONSUL_CACERT
  "CONSUL_CAPATH"    = $CONSUL_CAPATH
  "CONSUL_NODENAME"  = $node
  "SERVICE_PREFIX"   = $ServicePrefix
  "CONSUL_KVPATH"    = $CONSUL_KVPATH
}

foreach ($kv in $envMap.GetEnumerator()) {
  [Environment]::SetEnvironmentVariable($kv.Key, $kv.Value, $Target)
  Set-Item -Path ("Env:{0}" -f $kv.Key) -Value $kv.Value     # Prozess-ENV sofort
  Write-Host "[OK ] ENV $($kv.Key) = $($kv.Value)" -ForegroundColor Green
}


# --- KV-JSON für deinen .NET-Dienst bauen ---
$kvObj = @{
  Kestrel = @{
    Endpoints = @{
      Grpc = @{
        Url        = $GrpcListenUrl
        Protocols  = "Http2"
        Certificate = @{ Path = $SvcCertPath; KeyPath = $SvcKeyPath }
      }
    }
  }
  Consul = @{
    Address     = $CONSUL_HTTP_ADDR
    ServiceName = $ServiceName
    ServiceId   = $ServiceId
  }
  Service = @{ AdvertisedHost = $AdvertisedHost }
  Visca   = @{ Port = "COM5"; Baud = "9600" }
  Logging = @{
    LogLevel = @{
      Default = "Information"
      "Camera.Grpc.Service" = "Debug"
      "FfmpegCoreVideoStream" = "Debug"
      "Grpc.AspNetCore.Server" = "Warning"
      "Microsoft.AspNetCore.Server.Kestrel.Http2" = "Warning"
      "Microsoft" = "Warning"
    }
  }
}
$kvJson = $kvObj | ConvertTo-Json -Depth 8

# --- KV schreiben (robust via Temp-Datei + konsistentes UTF-8 ohne BOM) ---
$tmp = New-TemporaryFile
[System.IO.File]::WriteAllText($tmp, $kvJson, [System.Text.UTF8Encoding]::new($false))

try {
    # Variante A: baue das @<datei>-Argument explizit als EIN String-Argument
    $fileArg = '@' + $tmp         # z.B. "@C:\Users\...\tmp1234.tmp"
    & $ConsulExePath kv put $CONSUL_KVPATH $fileArg | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "consul kv put fehlgeschlagen (ExitCode=$LASTEXITCODE)."
    }
    Write-Host "[OK ] KV geschrieben: $CONSUL_KVPATH" -ForegroundColor Green
}
finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
}


# --- einfache Verifikation ---
try {
  & $ConsulExePath info | Out-Null
  & $ConsulExePath kv get $CONSUL_KVPATH | Select-Object -First 10 | Write-Host
  Ok "Consul erreichbar & KV lesbar."
} catch {
  Warn "Verifikation: $($_.Exception.Message)"
}

