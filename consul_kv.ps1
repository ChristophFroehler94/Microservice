#requires -Version 7.0
<#
  Setzt ENV + KV, und stellt sicher, dass eine PFX im Unterordner tlscerts existiert:
    - Wenn keine PFX vorhanden ist oder sie abgelaufen ist → dev-Zertifikat erzeugen/exportieren via dotnet dev-certs
    - Nutzt das PFX mit Passwort "default"
    - Liest advertise_addr aus server.hcl und nutzt als AdvertisedHost
#>

[CmdletBinding()]
param(
  [string] $ServerHclPath    = "$PSScriptRoot\consul\config\server.hcl",
  [string] $ConsulExePath    = (Get-Command consul -ErrorAction SilentlyContinue | ForEach-Object Source) ?? "$PSScriptRoot\consul\bin\consul.exe",
  [string] $ServicePrefix    = "camera"
)

function Fail($msg) { throw $msg }
function Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "[OK  ] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

# --- Prüfen existence ---
if (-not (Test-Path -LiteralPath $ServerHclPath)) { Fail "server.hcl nicht gefunden: $ServerHclPath" }
if (-not (Test-Path -LiteralPath $ConsulExePath)) { Fail "consul.exe nicht gefunden: $ConsulExePath" }

# --- HCL parsen ---
$hcl = Get-Content -LiteralPath $ServerHclPath -Raw -ErrorAction Stop

$node = if ($hcl -match '(?m)^\s*node_name\s*=\s*"([^"]+)"') { $Matches[1] } else { $null }
$caFile = if ($hcl -match '(?m)^\s*ca_file\s*=\s*"([^"]+)"') { $Matches[1] } else { $null }
$httpsPort = if ($hcl -match '(?s)ports\s*=\s*\{.*?https\s*=\s*([-]?\d+).*?\}') { $Matches[1] } else { $null }
$advAddr = if ($hcl -match '(?m)^\s*advertise_addr\s*=\s*"([^"]+)"') { $Matches[1] } else { $null }

if (-not $node) { $node = $env:CONSUL_NODENAME ?? $env:COMPUTERNAME }
if (-not $httpsPort) { $httpsPort = '8501' }
if ($httpsPort -eq '-1') { Fail "Consul HTTPS deaktiviert (ports.https = -1)" }
if (-not $advAddr) { $advAddr = $env:COMPUTERNAME }

$CONSUL_HTTP_ADDR = "https://127.0.0.1:$httpsPort"
$CONSUL_CACERT    = if ($caFile) { $caFile } else { "C:\consul\pki\consul-agent-ca.pem" }
$CONSUL_CAPATH    = Split-Path -Parent $CONSUL_CACERT
$CONSUL_KVPATH    = "$ServicePrefix/$node/config.json"

Info "CONSUL_HTTP_ADDR = $CONSUL_HTTP_ADDR"
Info "CONSUL_CACERT = $CONSUL_CACERT"
Info "KV-Pfad = $CONSUL_KVPATH"
Info "AdvertisedHost = $advAddr"

# --- TLS / PFX in tlscerts sicherstellen ---
$tlsDir = Join-Path $PSScriptRoot "tlscerts"
if (-not (Test-Path -LiteralPath $tlsDir)) {
    Info "Erstelle tls-Verzeichnis: $tlsDir"
    New-Item -ItemType Directory -Path $tlsDir -Force | Out-Null
}

# Finde existierende PFX
$pfxFiles = Get-ChildItem -LiteralPath $tlsDir -Filter *.pfx -File
$pfx = $pfxFiles | Select-Object -First 1

# Funktion: Prüfen, ob PFX gültig (Zert nicht abgelaufen)
function Test-PfxValid($fullpath, [string] $pwd) {
    try {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($fullpath, $pwd)
        # Prüfen Ablaufdatum
        $now = [DateTime]::UtcNow
        if ($cert.NotBefore -le $now -and $cert.NotAfter -ge $now) {
            return $true
        } else {
            return $false
        }
    }
    catch {
        return $false
    }
}

$usePfx = $false
if ($pfx) {
    Info "Gefundene PFX: $($pfx.FullName)"
    if (Test-PfxValid $pfx.FullName "default") {
        Ok "PFX ist gültig (nicht abgelaufen)."
        $usePfx = $true
        $TlsPfxPath = $pfx.FullName
        $TlsPfxPassword = "default"
    } else {
        Warn "Gefundene PFX ist ungültig oder abgelaufen. Erzeuge neues Zertifikat."
    }
} else {
    Info "Keine PFX vorhanden im tls-Verzeichnis. Erzeuge neues Zertifikat."
}

# Wenn kein gültiges PFX, erzeugen / exportieren
if (-not $usePfx) {
    # Erstelle oder vertraue dev-cert
    Info "dotnet dev-certs prüfen/erzeugen..."
    & dotnet dev-certs https --check | Out-Null
    & dotnet dev-certs https --trust | Out-Null

    # Export in PFX
    $exportPath = Join-Path $tlsDir "$($node)-dev.pfx"
    Info "Exportiere dev-Zertifikat nach: $exportPath"
    & dotnet dev-certs https -ep $exportPath -p "default" | Out-Null
    if (-not (Test-Path -LiteralPath $exportPath)) {
        Fail "Export des dev-certs nach PFX fehlgeschlagen: $exportPath"
    }
    Ok "Export erfolgreich: $exportPath"

    $TlsPfxPath = $exportPath
    $TlsPfxPassword = "default"
}

Ok "TLS PFX wird verwendet: $TlsPfxPath"

# --- ENV setzen (User + aktuell) ---
$Target = [EnvironmentVariableTarget]::User
$envMap = @{
    "CONSUL_HTTP_ADDR"        = $CONSUL_HTTP_ADDR
    "CONSUL_CACERT"           = $CONSUL_CACERT
    "CONSUL_CAPATH"           = $CONSUL_CAPATH
    "CONSUL_NODENAME"         = $node
    "SERVICE_PREFIX"          = $ServicePrefix
    "CONSUL_KVPATH"           = $CONSUL_KVPATH

    "APP_TLS_PFX"              = $TlsPfxPath
    "APP_TLS_PFX_PASSWORD"     = $TlsPfxPassword
}
foreach ($kv in $envMap.GetEnumerator()) {
    [Environment]::SetEnvironmentVariable($kv.Key, $kv.Value, $Target)
    Set-Item -Path ("Env:{0}" -f $kv.Key) -Value $kv.Value
    Ok "ENV $($kv.Key) = $($kv.Value)"
}

# --- KV schreiben ---
$kvObj = @{
    Service = @{ AdvertisedHost = $advAddr }
}
$kvJson = $kvObj | ConvertTo-Json -Depth 4

$tmp = New-TemporaryFile
[System.IO.File]::WriteAllText($tmp, $kvJson, [System.Text.UTF8Encoding]::new($false))
try {
    $fileArg = '@' + $tmp
    & $ConsulExePath kv put $CONSUL_KVPATH $fileArg | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "consul kv put fehlgeschlagen (ExitCode=$LASTEXITCODE)" }
    Ok "KV geschrieben: $CONSUL_KVPATH"
}
finally { Remove-Item $tmp -ErrorAction SilentlyContinue }

# --- Verifikation (optional) ---
try {
    & $ConsulExePath info | Out-Null
    & $ConsulExePath kv get $CONSUL_KVPATH | Select-Object -First 10 | Write-Host
    Ok "Consul erreichbar & KV lesbar."
} catch {
    Warn "Verifikation fehlgeschlagen: $($_.Exception.Message)"
}
