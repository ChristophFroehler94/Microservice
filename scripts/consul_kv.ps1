# =========================
# Datei: consul_kv.ps1
# Zweck: Consul-ENV setzen + KV-Einträge für Services schreiben/verifizieren
# Umgebung: PowerShell 7.x
# =========================

#region Eingabeparameter
[CmdletBinding()]
param(
  [string] $ServerHclPath,
  [string] $ConsulExePath
)
#endregion Eingabeparameter

#region Setup & Pfade
$ErrorActionPreference = 'Stop'

$ScriptDir   = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { (Get-Location).Path } else { $PSScriptRoot }
$ProjectRoot = Split-Path -Path $ScriptDir -Parent

$InstallRoot = Join-Path $ProjectRoot "consul"
$BinDir      = Join-Path $InstallRoot "bin"
$ConfigDir   = Join-Path $InstallRoot "config"
$DataDir     = Join-Path $InstallRoot "data"
$LogDir      = Join-Path $InstallRoot "logs"
$CertDir     = Join-Path $InstallRoot "certs"

if (-not $ServerHclPath) { $ServerHclPath = Join-Path $ConfigDir "server.hcl" }
#endregion Setup & Pfade

#region Hilfsfunktionen
function Fail($msg) { throw $msg }
function Info($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }

function Resolve-ConsulExe {
  param([string] $HintPath)
  if ($HintPath -and (Test-Path -LiteralPath $HintPath)) { return (Resolve-Path -LiteralPath $HintPath).Path }

  $gc = Get-Command consul -ErrorAction SilentlyContinue
  if ($gc) { return $gc.Source }

  $binGuess = Join-Path $BinDir "consul.exe"
  if (Test-Path -LiteralPath $binGuess) { return (Resolve-Path -LiteralPath $binGuess).Path }

  # optionale weitere Vermutungen (auskommentiert bei Bedarf)
  # $pf = Join-Path $env:ProgramFiles "Consul\consul.exe"
  # if (Test-Path -LiteralPath $pf) { return (Resolve-Path -LiteralPath $pf).Path }

  return $null
}

function Test-PfxValid([string] $fullpath, [string] $pwd) {
  try {
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
      $fullpath, $pwd,
      [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet
    )
    $now = [DateTime]::UtcNow
    return ($cert.HasPrivateKey -and $cert.NotBefore.ToUniversalTime() -le $now -and $cert.NotAfter.ToUniversalTime() -ge $now), $cert
  } catch { return $false, $null }
}
#endregion Hilfsfunktionen

#region Vorprüfungen & Pfadfindung
if (-not (Test-Path -LiteralPath $ServerHclPath)) { Fail "server.hcl nicht gefunden: $ServerHclPath" }

$ConsulExePath = Resolve-ConsulExe -HintPath $ConsulExePath
if (-not $ConsulExePath) { Fail "consul.exe nicht gefunden. PATH prüfen oder -ConsulExePath angeben." }
Ok "consul.exe: $ConsulExePath"
#endregion Vorprüfungen & Pfadfindung

#region HCL lesen
$hcl      = Get-Content -LiteralPath $ServerHclPath -Raw
$nodeName = if ($hcl -match '(?m)^\s*node_name\s*=\s*"([^"]+)"')              { $Matches[1] } else { $null }
$caFile   = if ($hcl -match '(?m)^\s*ca_file\s*=\s*"([^"]+)"')                 { $Matches[1] } else { $null }
$httpsPort= if ($hcl -match '(?s)ports\s*=\s*\{.*?https\s*=\s*([-]?\d+).*?\}') { $Matches[1] } else { $null }
$advAddr  = if ($hcl -match '(?m)^\s*advertise_addr\s*=\s*"([^"]+)"')          { $Matches[1] } else { $null }

if (-not $nodeName)  { $nodeName  = $env:CONSUL_NODENAME ?? $env:COMPUTERNAME }
if (-not $httpsPort) { $httpsPort = '8501' }
if ($httpsPort -eq '-1') { Fail "Consul HTTPS deaktiviert (ports.https = -1)" }
if (-not $advAddr)   { $advAddr   = $env:COMPUTERNAME }

$CONSUL_HTTP_ADDR = "https://127.0.0.1:$httpsPort"
$CONSUL_CACERT    = if ($caFile) { $caFile } else { Join-Path $CertDir 'consul-agent-ca.pem' }
$CONSUL_CAPATH    = Split-Path -Parent $CONSUL_CACERT

Info "CONSUL_HTTP_ADDR = $CONSUL_HTTP_ADDR"
Info "CONSUL_CACERT    = $CONSUL_CACERT"
Info "Node             = $nodeName"
Info "AdvertisedHost   = $advAddr"
#endregion HCL lesen

#region PFX laden/prüfen
$ServiceCertDir = Join-Path $ProjectRoot "service_certs"
if (-not (Test-Path -LiteralPath $ServiceCertDir -PathType Container)) { Fail "Zertifikatsordner fehlt: $ServiceCertDir" }

$pfxFiles = Get-ChildItem -LiteralPath $ServiceCertDir -Filter *.pfx -File
if ($pfxFiles.Count -eq 0) { Fail "Kein .pfx in $ServiceCertDir gefunden." }
if ($pfxFiles.Count -gt 1) { Fail "Mehr als ein .pfx in $ServiceCertDir gefunden." }

$TlsPfxPath     = $pfxFiles[0].FullName
$TlsPfxPassword = "changeit"

$valid, $certObj = Test-PfxValid -fullpath $TlsPfxPath -pwd $TlsPfxPassword
if (-not $valid) { Fail "PFX ungültig oder Passwort falsch: $TlsPfxPath" }

Ok  "PFX: $TlsPfxPath"
Info ("Zertifikat: {0} | Thumbprint={1} | {2:u}–{3:u}" -f $certObj.Subject, $certObj.Thumbprint, $certObj.NotBefore.ToUniversalTime(), $certObj.NotAfter.ToUniversalTime())
#endregion PFX laden/prüfen

#region ENV setzen
$Target = [EnvironmentVariableTarget]::User
$envMap = @{
  "CONSUL_HTTP_ADDR"     = $CONSUL_HTTP_ADDR
  "CONSUL_CACERT"        = $CONSUL_CACERT
  "CONSUL_CAPATH"        = $CONSUL_CAPATH
  "CONSUL_NODENAME"      = $nodeName
  "APP_TLS_PFX"          = $TlsPfxPath
  "APP_TLS_PFX_PASSWORD" = $TlsPfxPassword
}
foreach ($kv in $envMap.GetEnumerator()) {
  [Environment]::SetEnvironmentVariable($kv.Key, $kv.Value, $Target)
  Set-Item -Path ("Env:{0}" -f $kv.Key) -Value $kv.Value
  Ok "ENV gesetzt: $($kv.Key)"
}
#endregion ENV setzen

#region KV schreiben
$servicePrefixes = @("camera", "polflash")
$kvObj  = @{ Service = @{ AdvertisedHost = $advAddr } }
$kvJson = $kvObj | ConvertTo-Json -Depth 4

foreach ($prefix in $servicePrefixes) {
  $key = "$prefix/$nodeName/config.json"
  $tmp = New-TemporaryFile
  try {
    [System.IO.File]::WriteAllText($tmp.FullName, $kvJson, [System.Text.UTF8Encoding]::new($false))
    & "$ConsulExePath" kv put $key ("@" + $tmp.FullName) | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "kv put fehlgeschlagen: $key" }
    Ok "KV geschrieben: $key"
  } finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
  }
}
#endregion KV schreiben

#region Verifikation
try {
  & "$ConsulExePath" info | Out-Null
  foreach ($prefix in $servicePrefixes) {
    & "$ConsulExePath" kv get "$prefix/$nodeName/config.json" | Select-Object -First 10 | Write-Host
  }
  Ok "Consul erreichbar und KV lesbar."
} catch {
  Warn "Verifikation fehlgeschlagen: $($_.Exception.Message)"
}
#endregion Verifikation

#region Zusammenfassung
Write-Host ""
Write-Host "======== Zusammenfassung ========" -ForegroundColor Magenta
Write-Host ("Node:            {0}" -f $nodeName)
Write-Host ("AdvertisedHost:  {0}" -f $advAddr)
Write-Host ("Consul HTTPS:    {0}" -f $CONSUL_HTTP_ADDR)
Write-Host ("CA (CONSUL):     {0}" -f $CONSUL_CACERT)
Write-Host ("Service PFX:     {0}" -f $TlsPfxPath)
Write-Host ("PFX Thumbprint:  {0}" -f $certObj.Thumbprint)
Write-Host "=================================" -ForegroundColor Magenta
#endregion Zusammenfassung
