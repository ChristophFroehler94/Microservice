#Requires -Version 7.0

param(
  [string]$ConsulVersion = "1.21.5",
  [ValidateSet("windows_amd64","windows_arm64")]
  [string]$Arch = "windows_amd64"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Admin-Check (erforderlich für Firewall & Installation)
function Assert-Administrator {
  if ($IsWindows) {
    $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pri = [Security.Principal.WindowsPrincipal]::new($id)
    if (-not $pri.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
      throw "Dieses Skript muss als Administrator ausgeführt werden."
    }
  } else {
    throw "Dieses Skript zielt auf Windows/PowerShell 7."
  }
}
Assert-Administrator
#endregion

#region Pfade & Verzeichnisse
$Root        = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {(Get-Location).Path} else {$PSScriptRoot}
$InstallRoot = Join-Path $Root "Consul"
$BinDir      = Join-Path $InstallRoot "bin"
$ConfigDir   = Join-Path $InstallRoot "config"
$DataDir     = Join-Path $InstallRoot "data"
$LogDir      = Join-Path $InstallRoot "logs"
$CertDir     = Join-Path $InstallRoot "certs"

function Ensure-Dir([string]$p){
  if (-not (Test-Path -LiteralPath $p)) {
    New-Item -ItemType Directory -Path $p -Force | Out-Null
  }
}
$null = ($BinDir,$ConfigDir,$DataDir,$LogDir,$CertDir) | ForEach-Object { Ensure-Dir $_ }
#endregion

#region Config aus Template kopieren
$LocalTemplate = Join-Path $Root "template.hcl"
$TargetHcl     = Join-Path $ConfigDir "server.hcl"
if (-not (Test-Path -LiteralPath $LocalTemplate)) {
  throw "template.hcl fehlt neben dem Skript (`$LocalTemplate`)."
}
Copy-Item -Path $LocalTemplate -Destination $TargetHcl -Force
Write-Host "Config kopiert: $LocalTemplate -> $TargetHcl"
#endregion

#region Download & Entpacken von Consul
$BaseUrl = "https://releases.hashicorp.com/consul/$ConsulVersion"
$ZipName = "consul_${ConsulVersion}_${Arch}.zip"
$ZipUrl  = "$BaseUrl/$ZipName"
$ZipPath = Join-Path $Root $ZipName
$ConsulExe = Join-Path $BinDir "consul.exe"

if (-not (Test-Path -LiteralPath $ZipPath)) {
  Write-Host "Lade Consul $ConsulVersion ($Arch) ..."
  Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath
}

if (-not (Test-Path -LiteralPath (Join-Path $BinDir "consul.exe"))) {
  $tmp = Join-Path $Root ("unzip-" + [guid]::NewGuid())
  Ensure-Dir $tmp

  # Entpacken (LiteralPath wegen Sonderzeichen im Pfad), Force erlaubt Überschreiben
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $tmp -Force

  # Konsul-Binärdatei in Ziel verschieben (statt kopieren), reduziert Quelle/Locks
  Move-Item -LiteralPath (Join-Path $tmp "consul.exe") -Destination $BinDir -Force

  # Robustes Aufräumen mit Retry bei transienten Locks (AV/Indexer)
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
  Write-Host "Consul entpackt nach $BinDir und Temp-Ordner entfernt"
}

#region Vollständige Firewall-Regeln für Consul (nur Domain,Private)
# Profile als einzelner String, nicht als Array, um Binding-Irritationen zu vermeiden
$profileString = 'Domain,Private'

$firewallRules = @(
  @{ Name = "Consul TCP 8300 (Server RPC)"; Protocol = "TCP"; Port = 8300 },
  @{ Name = "Consul TCP 8301 (LAN Serf)";   Protocol = "TCP"; Port = 8301 },
  @{ Name = "Consul UDP 8301 (LAN Serf)";   Protocol = "UDP"; Port = 8301 },
  @{ Name = "Consul TCP 8302 (WAN Serf)";   Protocol = "TCP"; Port = 8302 },
  @{ Name = "Consul UDP 8302 (WAN Serf)";   Protocol = "UDP"; Port = 8302 },
  @{ Name = "Consul TCP 8500 (HTTP API/UI)"; Protocol = "TCP"; Port = 8500 },
  @{ Name = "Consul TCP 8501 (HTTPS API/UI)"; Protocol = "TCP"; Port = 8501 },
  @{ Name = "Consul TCP 8502 (gRPC)";        Protocol = "TCP"; Port = 8502 },
  @{ Name = "Consul TCP 8503 (gRPC TLS)";    Protocol = "TCP"; Port = 8503 },
  @{ Name = "Consul TCP 8600 (DNS)";         Protocol = "TCP"; Port = 8600 },
  @{ Name = "Consul UDP 8600 (DNS)";         Protocol = "UDP"; Port = 8600 }
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
    Write-Host ("Firewall-Regel angelegt: {0} ({1}/{2})" -f $Name,$Protocol,$Port)
  } else {
    Set-NetFirewallRule -DisplayName $Name -Enabled True -Profile $profileString -ErrorAction Stop | Out-Null
    Write-Host ("Firewall-Regel vorhanden/aktiviert: {0}" -f $Name)
  }
}

# WICHTIG: Richtig splatten – über eine Variable, nicht @$_
foreach ($rule in $firewallRules) {
  Ensure-FirewallRule @rule
}
#endregion


#region Version 
& $ConsulExe version
Write-Host "Fertig. Binärdatei: $ConsulExe"
Write-Host "Config: $TargetHcl"
