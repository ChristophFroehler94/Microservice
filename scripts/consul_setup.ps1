# =========================
# Datei: consul_setup.ps1
# Zweck : Konsistente Einrichtung von HashiCorp Consul (Download, Entpacken, Basis-Config, Firewall)
# Umgebung: PowerShell 7.x (als Administrator ausführen)
# =========================

param(
  [string]$ConsulVersion = "1.21.5",
  [ValidateSet("windows_amd64","windows_arm64")]
  [string]$Arch = "windows_amd64"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Hilfsfunktionen (Ausgabe)
function Fail([string]$msg) { throw $msg }
function Info([string]$msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Ok  ([string]$msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
#endregion Hilfsfunktionen (Ausgabe)

#region Administratorprüfung
function Assert-Administrator {
  if ($IsWindows) {
    $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pri = [Security.Principal.WindowsPrincipal]::new($id)
    if (-not $pri.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
      Fail "Dieses Skript muss als Administrator ausgeführt werden."
    }
  } else {
    Fail "Dieses Skript zielt auf Windows/PowerShell 7."
  }
}
Assert-Administrator
Ok "Administratorrechte erkannt."
#endregion Administratorprüfung

#region Pfade und Verzeichnisse
$ScriptDir   = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { (Get-Location).Path } else { $PSScriptRoot }
$ProjectRoot = Split-Path -Path $ScriptDir -Parent

$InstallRoot = Join-Path $ProjectRoot "consul"
$BinDir      = Join-Path $InstallRoot "bin"
$ConfigDir   = Join-Path $InstallRoot "config"
$DataDir     = Join-Path $InstallRoot "data"
$LogDir      = Join-Path $InstallRoot "logs"
$CertDir     = Join-Path $InstallRoot "certs"

function Ensure-Dir([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) {
    New-Item -ItemType Directory -Path $p -Force | Out-Null
    Ok "Verzeichnis angelegt: $p"
  }
}
$null = ($BinDir,$ConfigDir,$DataDir,$LogDir,$CertDir) | ForEach-Object { Ensure-Dir $_ }
#endregion Pfade und Verzeichnisse

#region Konfiguration aus Template kopieren
$TemplatesDir  = Join-Path $ProjectRoot "templates"
$LocalTemplate = Join-Path $TemplatesDir "template.hcl"
$TargetHcl     = Join-Path $ConfigDir "server.hcl"
if (-not (Test-Path -LiteralPath $LocalTemplate)) {
  Fail "template.hcl nicht gefunden: `"$LocalTemplate`"."
}
Copy-Item -Path $LocalTemplate -Destination $TargetHcl -Force
Ok "Konfiguration kopiert: $LocalTemplate -> $TargetHcl"
#endregion Konfiguration aus Template kopieren

#region Download und Entpacken von Consul
$BaseUrl   = "https://releases.hashicorp.com/consul/$ConsulVersion"
$ZipName   = "consul_${ConsulVersion}_${Arch}.zip"
$ZipUrl    = "$BaseUrl/$ZipName"
$ZipPath   = Join-Path $ProjectRoot $ZipName
$ConsulExe = Join-Path $BinDir "consul.exe"

if (-not (Test-Path -LiteralPath $ZipPath)) {
  Info "Lade Consul $ConsulVersion ($Arch) von $ZipUrl ..."
  Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath
  Ok "Download abgeschlossen: $ZipPath"
} else {
  Info "Archiv bereits vorhanden: $ZipPath"
}

if (-not (Test-Path -LiteralPath $ConsulExe)) {
  $tmp = Join-Path $ProjectRoot ("unzip-" + [guid]::NewGuid())
  Ensure-Dir $tmp

  Expand-Archive -LiteralPath $ZipPath -DestinationPath $tmp -Force
  Move-Item -LiteralPath (Join-Path $tmp "consul.exe") -Destination $BinDir -Force

  function Remove-ItemWithRetry {
    param([Parameter(Mandatory)][string]$Path, [int]$MaxAttempts = 12, [int]$DelayMs = 250)
    for($i=1; $i -le $MaxAttempts; $i++){
      try {
        if (Test-Path -LiteralPath $Path) {
          Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
        }
        return
      } catch [System.IO.IOException],[System.UnauthorizedAccessException] {
        if ($i -eq $MaxAttempts) { throw }
        Start-Sleep -Milliseconds $DelayMs
      }
    }
  }
  Remove-ItemWithRetry -Path $tmp
  Ok "Consul entpackt nach $BinDir und temporären Ordner entfernt."
} else {
  Info "Konsolen-Binärdatei bereits vorhanden: $ConsulExe"
}
#endregion Download und Entpacken von Consul

#region Firewallregeln anlegen/aktivieren
$profileString = 'Any'
$firewallRules = @(
  @{ Name = "Consul TCP 8300 (Server RPC)";   Protocol = "TCP"; Port = 8300 },
  @{ Name = "Consul TCP 8301 (LAN Serf)";     Protocol = "TCP"; Port = 8301 },
  @{ Name = "Consul UDP 8301 (LAN Serf)";     Protocol = "UDP"; Port = 8301 },
  @{ Name = "Consul TCP 8302 (WAN Serf)";     Protocol = "TCP"; Port = 8302 },
  @{ Name = "Consul UDP 8302 (WAN Serf)";     Protocol = "UDP"; Port = 8302 },
  @{ Name = "Consul TCP 8500 (HTTP API/UI)";  Protocol = "TCP"; Port = 8500 },
  @{ Name = "Consul TCP 8501 (HTTPS API/UI)"; Protocol = "TCP"; Port = 8501 },
  @{ Name = "Consul TCP 8502 (gRPC)";         Protocol = "TCP"; Port = 8502 },
  @{ Name = "Consul TCP 8503 (gRPC TLS)";     Protocol = "TCP"; Port = 8503 },
  @{ Name = "Consul TCP 8600 (DNS)";          Protocol = "TCP"; Port = 8600 },
  @{ Name = "Consul UDP 8600 (DNS)";          Protocol = "UDP"; Port = 8600 }
)

function Ensure-FirewallRule {
  param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][ValidateSet('TCP','UDP')][string]$Protocol,
    [Parameter(Mandatory)][int]$Port
  )
  if (-not (Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object DisplayName -eq $Name)) {
    New-NetFirewallRule -DisplayName $Name `
      -Direction Inbound -Action Allow -Protocol $Protocol -LocalPort $Port `
      -Profile $profileString -ErrorAction Stop | Out-Null
    Ok ("Firewall-Regel angelegt: {0} ({1}/{2})" -f $Name,$Protocol,$Port)
  } else {
    Set-NetFirewallRule -DisplayName $Name -Enabled True -Profile $profileString -ErrorAction Stop | Out-Null
    Info ("Firewall-Regel vorhanden/aktiviert: {0}" -f $Name)
  }
}

foreach ($rule in $firewallRules) { Ensure-FirewallRule @rule }
#endregion Firewallregeln anlegen/aktivieren

#region Abschlussinformationen
& $ConsulExe version | ForEach-Object { Info $_ }
Ok    "Fertig."
Info  "Binärdatei : $ConsulExe"
Info  "Config     : $TargetHcl"
Info  "Projekt-Root: $ProjectRoot"
#endregion Abschlussinformationen
