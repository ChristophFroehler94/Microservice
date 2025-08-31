<# =====================================================================
 Install-Consul.ps1
 Windows-Setup für Consul (TLS) + Firewall + KV-Seeding
 für 2 Server und 1 Agent (Agent OHNE Microservices).

 Ziel: PowerShell 5.1 (Windows 10). JSON wird UTF-8 ohne BOM geschrieben.
 Debug/Details via -Verbose.
 Konsul wird im ÜBERGEORDNETEN Verzeichnis dieses Skripts installiert.
===================================================================== #>

[CmdletBinding(PositionalBinding = $false)]
param(
  # --- Rolle dieses Hosts ---
  [Parameter(Mandatory)][ValidateSet('server','agent')] [string] $Role,

  # --- Minimal notwendige Parameter ---
  [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Version,   # z.B. 1.21.4
  [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $ServerIP,  # IP dieses Hosts (auch für Agent)
  [Parameter()][int]    $BootstrapExpect = 2,                           # nur Server-relevant (bei 2 Servern -> 2)

  # --- Optional: Join & Basis ---
  [Parameter()][string[]] $RetryJoin  = @(),
  [Parameter()][string]   $Datacenter = "dc1",
  [Parameter()][string]   $NodeName   = "consul-node-1",
  [Parameter()][switch]   $UseExistingCA = $false,                      # Server2/Agent verwenden CA aus pki\
  [Parameter()][string]   $GossipKey = "",                              # optional: vorhandenen Key vorgeben

  # --- Optional: TLS-/Security-Features ---
  [Parameter()][switch]   $HardenTLS,       # HTTPS verify_incoming=true
  [Parameter()][switch]   $EnableACL,       # ACL-Block in Config
  [Parameter()][switch]   $BootstrapACL,    # ACL bootstrap (einmalig, nur Server)
  [Parameter()][int]      $LeaderTimeoutSec = 300,
  [Parameter()][switch]   $OpenDNSWan,      # WAN(8302)/DNS(8600) zusätzlich öffnen (Default: aus)

  # --- Optional: Aufräumen / KV-Write-Policy ---
  [Parameter()][switch]   $CleanFirst,      # löscht Dienst/Regeln/Ordner (pki wird geschont s.u.)
  [Parameter()][switch]   $ForceKV,         # KV überschreiben statt idempotent

  # --- Microservice-Defaults (nur SERVER) ---
  [Parameter()][int]      $GrpcPortCamera   = 5294,
  [Parameter()][int]      $GrpcPortPolFlash = 5295,
  [Parameter()][string]   $ViscaPort  = "COM4",
  [Parameter()][int]      $ViscaBaud  = 9600
)

# ------------------------ Grundeinstellungen ------------------------
$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# Pfade (Consul im ÜBERGEORDNETEN Verzeichnis)
$ScriptRoot  = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptRoot
$InstallDir  = Join-Path $ProjectRoot "consul"

# Abgeleitete Defaults
$ConsulAddr  = "https://${ServerIP}:8501"
$ConsulCAPath= Join-Path $InstallDir "pki\consul-agent-ca.pem"
$ServiceNameCamera   = "CameraService"
$ServiceIdCamera     = "camera-1"
$ServiceNamePolFlash = "PolFlashService"
$ServiceIdPolFlash   = "polflash-1"
$AdvertisedHostOverride = $null
$KvCameraPath   = "camera/$NodeName/config.json"
$KvPolFlashPath = "polflash/$NodeName/config.json"

# Portkollisionen (nur für Server relevant – Agent öffnet keine Microservice-Ports)
$ReservedConsulPorts = 8300,8301,8302,8500,8501,8502,8503,8600
if ($Role -eq 'server') {
  foreach ($p in @($GrpcPortCamera,$GrpcPortPolFlash)) {
    if ($p -in $ReservedConsulPorts) { throw "gRPC-Port $p kollidiert mit Consul-Ports ($($ReservedConsulPorts -join ', '))." }
  }
  if ($GrpcPortCamera -eq $GrpcPortPolFlash) { throw "GrpcPortCamera und GrpcPortPolFlash dürfen nicht identisch sein." }
}

# ------------------------ Ausgabe-Helper ------------------------
function Write-Step($msg){ Write-Host ("[STEP]  {0}" -f $msg) -ForegroundColor Cyan }
function Write-Info($msg){ Write-Host ("[INFO]  {0}" -f $msg) }
function Write-Ok  ($msg){ Write-Host ("[OK]    {0}" -f $msg) -ForegroundColor Green }
function Write-Bad ($msg){ Write-Host ("[ERR]   {0}" -f $msg) -ForegroundColor Red }
function Write-Note($msg){ Write-Host ("[NOTE]  {0}" -f $msg) -ForegroundColor DarkGray }

# ------------------------ Funktionen ------------------------
function Ensure-Admin {
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
             ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) { throw "Bitte PowerShell als Administrator ausführen." }
}

# UTF-8 ohne BOM Writer
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
function Write-Utf8NoBom {
  param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Content)
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Stop-And-Cleanup {
  param([switch]$KeepPki)  # <-- NEU: pki optional bewahren (für -UseExistingCA / Agent)
  Write-Step "Cleanup (Dienst/Prozesse/Firewall/Ordner)"
  try { Stop-Service -Name Consul -ErrorAction Stop } catch {}
  try { sc.exe delete Consul | Out-Null } catch {}
  Get-Process consul -ErrorAction SilentlyContinue | Stop-Process -Force
  Get-NetFirewallRule -DisplayName "*Consul*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -Confirm:$false
  Get-NetFirewallRule -DisplayName "Medicam gRPC *" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -Confirm:$false
  Get-NetFirewallRule -DisplayName "PolFlash gRPC *" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -Confirm:$false

  if (Test-Path $InstallDir) {
    foreach ($sub in @('config','data','bin')) {
      $path = Join-Path $InstallDir $sub
      if (Test-Path $path) { Remove-Item -Recurse -Force $path }
    }
    $exe = Join-Path $InstallDir 'consul.exe'
    if (Test-Path $exe) { Remove-Item $exe -Force }
    if (-not $KeepPki) {
      $pki = Join-Path $InstallDir 'pki'
      if (Test-Path $pki) { Remove-Item -Recurse -Force $pki }
    }
  }
  Write-Ok "Bereinigt. PKI behalten: $($KeepPki.IsPresent)"
}

function Ensure-Dirs {
  Write-Step "Verzeichnisse anlegen"
  foreach ($p in @(
    (Join-Path $InstallDir ''), (Join-Path $InstallDir 'bin'),
    (Join-Path $InstallDir 'config'), (Join-Path $InstallDir 'data'),
    (Join-Path $InstallDir 'pki')
  )) { if (!(Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }
  Write-Ok "Verzeichnisse OK."
}

function Download-And-Install-Consul {
  [CmdletBinding()] param([string]$Version,[string]$TargetDir)
  Write-Step "Consul $Version herunterladen & entpacken"
  $zip    = "consul_${Version}_windows_amd64.zip"
  $zipUrl = "https://releases.hashicorp.com/consul/$Version/$zip"
  Write-Verbose "Download: $zipUrl"
  Invoke-WebRequest $zipUrl -OutFile (Join-Path $TargetDir "bin\$zip") -UseBasicParsing
  Expand-Archive (Join-Path $TargetDir "bin\$zip") -DestinationPath (Join-Path $TargetDir 'bin') -Force
  Remove-Item (Join-Path $TargetDir "bin\$zip") -Force
  Copy-Item  (Join-Path $TargetDir 'bin\consul.exe') (Join-Path $TargetDir 'consul.exe') -Force
  Write-Ok ("consul.exe installiert: {0}" -f (Join-Path $TargetDir 'consul.exe'))
}

function Install-TrustedRootCA {
  [CmdletBinding()] param([Parameter(Mandatory)][string]$CaPath)
  if (-not (Test-Path $CaPath)) { throw "CA-Datei nicht gefunden: $CaPath" }
  Ensure-Admin
  Write-Step "CA in LocalMachine\Root importieren"
  try {
    $res = Import-Certificate -FilePath $CaPath -CertStoreLocation Cert:\LocalMachine\Root -ErrorAction Stop
    $thumb = ($res | Select-Object -First 1).Thumbprint
    if ($thumb) { Write-Ok ("CA importiert (Thumbprint: {0})." -f $thumb); return }
  } catch {
    Write-Verbose ("Import-Certificate fehlgeschlagen: {0} – fallback: certutil" -f $_.Exception.Message)
  }
  $out = & certutil.exe -f -addstore Root $CaPath 2>&1
  if ($LASTEXITCODE -ne 0) { throw ("certutil -addstore Root fehlgeschlagen (ExitCode {0}). Output: {1}" -f $LASTEXITCODE,$out) }
  Write-Ok "CA via certutil importiert."
}

function Generate-TLS {
  Write-Step "TLS: CA + Zertifikate erzeugen (rollenabhängig)"
  Push-Location (Join-Path $InstallDir 'pki')

  if ($Role -eq 'server') {
    if (-not $UseExistingCA) {
      if (-not (Test-Path (Join-Path $InstallDir 'pki\consul-agent-ca.pem'))) {
        & (Join-Path $InstallDir 'consul.exe') tls ca create | Out-Null
      }
    } else {
      Write-Note "Überspringe tls ca create (UseExistingCA aktiv)."
    }
    & (Join-Path $InstallDir 'consul.exe') tls cert create -server -dc $Datacenter ("-additional-ipaddress={0}" -f $ServerIP) | Out-Null
    & (Join-Path $InstallDir 'consul.exe') tls cert create -cli | Out-Null
  } else {
    Write-Note "Agent: keine TLS-Certs erzeugt (nutzt Auto-Encrypt & vorhandene CA)."
  }

  Pop-Location
  Write-Ok "TLS-Setup abgeschlossen."
}

function Ensure-Gossip-Key {
  Write-Step "Gossip-Verschlüsselung (encrypt) sicherstellen"
  $gossipKeyPath = Join-Path $InstallDir 'pki\gossip.key'

  if ($GossipKey -and $GossipKey.Trim()) {
    [IO.File]::WriteAllText($gossipKeyPath, $GossipKey.Trim(), $Utf8NoBom)
  }

  if (-not (Test-Path $gossipKeyPath)) {
    if ($Role -eq 'server') {
      # NEU: Auf JEDERM Server generieren, falls noch kein Key existiert/übergeben wurde
      $gk = & (Join-Path $InstallDir 'consul.exe') keygen
      [IO.File]::WriteAllText($gossipKeyPath, $gk.Trim(), $Utf8NoBom)
    } else {
      throw "Gossip-Key fehlt. Übergib -GossipKey oder kopiere pki\gossip.key von einem Server."
    }
  }

  $script:ConsulGossipKey = (Get-Content $gossipKeyPath -Raw).Trim()
  Write-Ok "Gossip-Key vorhanden."
}


function Write-ServerConfig {
  Write-Step "server.json schreiben"
  $verifyIncoming = $HardenTLS.IsPresent
  $ipExists = $false
  try {
    $match = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
             Where-Object { $_.IPAddress -eq $ServerIP } | Select-Object -First 1
    if ($match) { $ipExists = $true }
  } catch {}
  $bindAddr      = if ($ipExists) { $ServerIP } else { '0.0.0.0' }
  $advertiseAddr = $ServerIP

  $dataDir = Join-Path $InstallDir 'data'
  $caFile  = Join-Path $InstallDir 'pki\consul-agent-ca.pem'
  $crtFile = Join-Path $InstallDir ("pki\{0}-server-consul-0.pem"     -f $Datacenter)
  $keyFile = Join-Path $InstallDir ("pki\{0}-server-consul-0-key.pem" -f $Datacenter)

  $config = @{
    datacenter        = $Datacenter
    data_dir          = $dataDir
    node_name         = $NodeName
    server            = $true
    bootstrap_expect  = $BootstrapExpect
    bind_addr         = $bindAddr
    advertise_addr    = $advertiseAddr
    client_addr       = "0.0.0.0"
    ui_config         = @{ enabled = $true }
    ports             = @{ http = -1; https = 8501; grpc = -1; grpc_tls = 8503 }
    retry_join        = @($RetryJoin)
    tls               = @{
      defaults = @{
        ca_file                = $caFile
        cert_file              = $crtFile
        key_file               = $keyFile
        verify_outgoing        = $true
        verify_server_hostname = $true
        verify_incoming        = $HardenTLS.IsPresent
      }
      https = @{ verify_incoming = $HardenTLS.IsPresent }
      internal_rpc = @{ verify_server_hostname = $true }
    }
    auto_encrypt      = @{ allow_tls = $true }
    encrypt           = $script:ConsulGossipKey
    raft_logstore     = @{ backend = "boltdb" }
  }

  if ($EnableACL) {
    $config.acl = @{
      enabled = $true
      default_policy = "deny"
      down_policy = "extend-cache"
      enable_token_persistence = $true
    }
    $config.primary_datacenter = $Datacenter
  }

  $json   = $config | ConvertTo-Json -Depth 12
  $cfgPath= Join-Path $InstallDir 'config\server.json'
  Write-Utf8NoBom -Path $cfgPath -Content $json
  Write-Ok "server.json OK."
}

function Write-ClientConfig {
  Write-Step "client.json schreiben (Agent ohne Microservices)"
  $verifyIncoming = $HardenTLS.IsPresent
  $dataDir = Join-Path $InstallDir 'data'
  $caFile  = Join-Path $InstallDir 'pki\consul-agent-ca.pem'

  $config = @{
    datacenter        = $Datacenter
    data_dir          = $dataDir
    node_name         = $NodeName
    server            = $false
    bind_addr         = "0.0.0.0"
    advertise_addr    = $ServerIP
    client_addr       = "0.0.0.0"
    retry_join        = @($RetryJoin)
    ports             = @{ http = -1; https = 8501; grpc = -1; grpc_tls = 8503 }
    addresses         = @{ https = "0.0.0.0" }
    tls               = @{
      defaults = @{
        ca_file                = $caFile
        verify_outgoing        = $true
        verify_incoming        = $verifyIncoming
      }
      https = @{ verify_incoming = $verifyIncoming }
      internal_rpc = @{ verify_server_hostname = $true }
    }
    auto_encrypt      = @{ tls = $true }     # Agent holt Agent-Zert automatisch
    encrypt           = $script:ConsulGossipKey
  }

  if ($EnableACL) {
    $config.acl = @{
      enabled = $true
      default_policy = "deny"
      down_policy = "extend-cache"
      enable_token_persistence = $true
    }
    $config.primary_datacenter = $Datacenter
  }

  $json   = $config | ConvertTo-Json -Depth 12
  $cfgPath= Join-Path $InstallDir 'config\client.json'
  Write-Utf8NoBom -Path $cfgPath -Content $json
  Write-Ok "client.json OK."
}

function Add-FirewallRules {
  Write-Step "Firewall-Regeln anlegen (Domain,Private)"
  $profile = 'Domain,Private'
  if ($Role -eq 'server') {
    New-NetFirewallRule -DisplayName "Consul RPC 8300"            -Direction Inbound -Protocol TCP -LocalPort 8300 -Action Allow -Profile $profile | Out-Null
  }
  # Serf LAN + HTTPS + gRPC-TLS
  New-NetFirewallRule -DisplayName "Consul Serf LAN TCP 8301"   -Direction Inbound -Protocol TCP -LocalPort 8301 -Action Allow -Profile $profile | Out-Null
  New-NetFirewallRule -DisplayName "Consul Serf LAN UDP 8301"   -Direction Inbound -Protocol UDP -LocalPort 8301 -Action Allow -Profile $profile | Out-Null
  New-NetFirewallRule -DisplayName "Consul HTTPS 8501"          -Direction Inbound -Protocol TCP -LocalPort 8501 -Action Allow -Profile $profile | Out-Null
  New-NetFirewallRule -DisplayName "Consul gRPC-TLS 8503"       -Direction Inbound -Protocol TCP -LocalPort 8503 -Action Allow -Profile $profile | Out-Null

  if ($OpenDNSWan) {
    New-NetFirewallRule -DisplayName "Consul Serf WAN TCP 8302"   -Direction Inbound -Protocol TCP -LocalPort 8302 -Action Allow -Profile $profile | Out-Null
    New-NetFirewallRule -DisplayName "Consul Serf WAN UDP 8302"   -Direction Inbound -Protocol UDP -LocalPort 8302 -Action Allow -Profile $profile | Out-Null
    New-NetFirewallRule -DisplayName "Consul DNS TCP 8600"        -Direction Inbound -Protocol TCP -LocalPort 8600 -Action Allow -Profile $profile | Out-Null
    New-NetFirewallRule -DisplayName "Consul DNS UDP 8600"        -Direction Inbound -Protocol UDP -LocalPort 8600 -Action Allow -Profile $profile | Out-Null
  }

  if ($Role -eq 'server') {
    # Nur Server hosten die beiden gRPC-Microservices
    New-NetFirewallRule -DisplayName ("Medicam gRPC {0}" -f $GrpcPortCamera)    -Direction Inbound -Protocol TCP -LocalPort $GrpcPortCamera   -Action Allow -Profile $profile | Out-Null
    New-NetFirewallRule -DisplayName ("PolFlash gRPC {0}" -f $GrpcPortPolFlash) -Direction Inbound -Protocol TCP -LocalPort $GrpcPortPolFlash -Action Allow -Profile $profile | Out-Null
  }
  Write-Ok "Firewall-Regeln OK."
}

function Install-ConsulService {
  Write-Step "Windows-Dienst 'Consul' erstellen & starten"
  Ensure-Admin
  $svc = Get-Service -Name "Consul" -ErrorAction SilentlyContinue
  $consulExe  = Join-Path $InstallDir 'consul.exe'
  $configDir  = Join-Path $InstallDir 'config'
  $logDir     = Join-Path $env:ProgramData "Consul"
  if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
  $logFile    = Join-Path $logDir "consul.log"

  $binaryPath = '"{0}" agent "-config-dir={1}" "-bind={2}" "-advertise={2}" "-log-level=DEBUG" "-log-file={3}"' -f $consulExe, $configDir, $ServerIP, $logFile

  if (-not $svc) {
    try {
      New-Service -Name "Consul" -BinaryPathName $binaryPath -DisplayName "Consul" -StartupType Automatic
    } catch {
      $out = & sc.exe create Consul binPath= "$binaryPath" start= auto DisplayName= "Consul" 2>&1
      if ($LASTEXITCODE -ne 0) { throw ("sc.exe create fehlgeschlagen (ExitCode {0}). Output: {1}" -f $LASTEXITCODE,$out) }
    }
    sc.exe failure Consul reset= 86400 actions= restart/5000/restart/30000/restart/60000 | Out-Null
  }

  Start-Service -Name "Consul" -ErrorAction SilentlyContinue
  $ok = $false
  foreach ($i in 1..15) {
    Start-Sleep 1
    try { if ((Get-Service Consul).Status -eq 'Running') { $ok = $true; break } } catch {}
  }
  if (-not $ok) {
    if (Test-Path $logFile) { Write-Note "Letzte Logzeilen:"; Get-Content $logFile -Tail 80 | Write-Host }
    throw "Consul-Dienst konnte nicht gestartet werden."
  }
  Write-Ok "Dienst läuft."
}

function Set-ConsulEnv {
  [CmdletBinding()]
  param(
    [ValidateSet("Process","User","Machine")] [string] $Scope = "Machine",
    [string] $HttpToken = ""
  )
  Write-Step "CONSUL_* Umgebungsvariablen ($Scope + Prozess) setzen"

  $caDir = Split-Path $ConsulCAPath -Parent

  # 1) Im aktuellen Prozess
  $env:CONSUL_HTTP_ADDR  = $ConsulAddr
  $env:CONSUL_CACERT     = $ConsulCAPath
  $env:CONSUL_CAPATH     = $caDir
  $env:CONSUL_NODENAME   = $NodeName
  if ($HttpToken) { $env:CONSUL_HTTP_TOKEN = $HttpToken }

  # 2) Persistieren
  [Environment]::SetEnvironmentVariable("CONSUL_HTTP_ADDR",  $ConsulAddr,   $Scope)
  [Environment]::SetEnvironmentVariable("CONSUL_CACERT",     $ConsulCAPath, $Scope)
  [Environment]::SetEnvironmentVariable("CONSUL_CAPATH",     $caDir,        $Scope)
  [Environment]::SetEnvironmentVariable("CONSUL_NODENAME",   $NodeName,     $Scope)
  if ($HttpToken) {
    [Environment]::SetEnvironmentVariable("CONSUL_HTTP_TOKEN",$HttpToken,    $Scope)
  }

  # Robust: Zertifikat ≠ Key
  $pkiDir = Join-Path $InstallDir 'pki'
  $cliCert = Get-ChildItem -Path $pkiDir -Filter "*cli-*.pem" -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -notmatch "-key\.pem$" } |
             Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $cliKey  = Get-ChildItem -Path $pkiDir -Filter "*cli-*-key.pem" -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending | Select-Object -First 1

  if ($cliCert -and $cliKey) {
    [Environment]::SetEnvironmentVariable("CONSUL_CLIENT_CERT", $cliCert.FullName, $Scope)
    [Environment]::SetEnvironmentVariable("CONSUL_CLIENT_KEY",  $cliKey.FullName,  $Scope)
    $env:CONSUL_CLIENT_CERT = $cliCert.FullName
    $env:CONSUL_CLIENT_KEY  = $cliKey.FullName
  } else {
    Write-Note "Kein CLI-Zert/Key gefunden – mTLS-Clientauth kann fehlschlagen, wenn verify_incoming aktiv ist."
  }

  Write-Ok "ENV gesetzt."
}

function Wait-ConsulUp { param([int]$TimeoutSec=60)
  Write-Step ("Warte auf Consul (TCP 8501/8301) (max {0}s)" -f $TimeoutSec)
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  do {
    $httpsOk = Test-NetConnection -ComputerName $ServerIP -Port 8501 -InformationLevel Quiet
    $serfOk  = Test-NetConnection -ComputerName $ServerIP -Port 8301 -InformationLevel Quiet
    if ($httpsOk -and $serfOk) { Write-Ok "Consul lauscht (HTTPS/Serf)."; return }
    Start-Sleep 1
  } while ((Get-Date) -lt $deadline)
  throw "Consul-Ports 8501/8301 nicht erreichbar."
}


function Wait-ForLeader {
  param([int]$TimeoutSec = 300)
  Write-Step ("Warte auf Leader / ggf. ACL-Bootstrap (max {0}s)" -f $TimeoutSec)

  $consul   = Join-Path $InstallDir 'consul.exe'
  $deadline = (Get-Date).AddSeconds($TimeoutSec)

  do {
    Start-Sleep 3

    # 1) Wenn bereits ein Token da ist: peers pruefen (benoetigt operator:read)
    if ($env:CONSUL_HTTP_TOKEN) {
      $o = New-TemporaryFile; $e = New-TemporaryFile
      try {
        $p = Start-Process -FilePath $consul -ArgumentList @('operator','raft','list-peers') `
             -NoNewWindow -Wait -PassThru -RedirectStandardOutput $o.FullName -RedirectStandardError $e.FullName
        $out = Get-Content $o.FullName -Raw -ErrorAction SilentlyContinue
        if ($p.ExitCode -eq 0 -and $out -match '\bleader\b') {
          Write-Ok "Leader vorhanden (raft list-peers)."
          return $true
        }
      } finally { Remove-Item $o,$e -Force -ErrorAction SilentlyContinue }

      # Kein Leader trotz Token -> weiter warten
    }

    # 2) Wenn ACLs aktiv & Bootstrap gewuenscht & noch kein Token: Bootstrap versuchen (idempotent)
    if ($EnableACL -and $BootstrapACL -and -not $env:CONSUL_HTTP_TOKEN) {
      $o = New-TemporaryFile; $e = New-TemporaryFile
      try {
        $p = Start-Process -FilePath $consul -ArgumentList @('acl','bootstrap','-format=json') `
             -NoNewWindow -Wait -PassThru -RedirectStandardOutput $o.FullName -RedirectStandardError $e.FullName
        if ($p.ExitCode -eq 0) {
          # Erfolgreich -> JSON mit SecretID parsen
          $bootRaw = Get-Content $o.FullName -Raw -ErrorAction SilentlyContinue
          $secretId = $null
          try { $obj = $bootRaw | ConvertFrom-Json; if ($obj -and $obj.SecretID) { $secretId = $obj.SecretID } } catch {}
          if (-not $secretId) {
            $bootTxt = ($bootRaw + "`n" + (Get-Content $e.FullName -Raw -ErrorAction SilentlyContinue))
            $m = ($bootTxt | Select-String -Pattern 'SecretID:\s+([0-9a-f-]{20,})').Matches
            if ($m.Count -gt 0) { $secretId = $m[0].Groups[1].Value }
          }
          if ($secretId) {
            $tokPath = Join-Path $InstallDir "pki\management-token.txt"
            Set-Content -Path $tokPath -Value $secretId -Encoding ASCII -Force
            try { icacls $tokPath /inheritance:r /grant:r "$env:USERNAME:(R)" | Out-Null } catch {}

            [Environment]::SetEnvironmentVariable("CONSUL_HTTP_TOKEN", $secretId, "Machine")
            $env:CONSUL_HTTP_TOKEN = $secretId
            Write-Ok "ACL-Bootstrap erfolgreich. Token gesetzt."
            return $true
          }
        } else {
          # Typischer Fall VOR Leader: ExitCode!=0 und stderr enthaelt "No cluster leader" -> still weiter warten
          $err = Get-Content $e.FullName -Raw -ErrorAction SilentlyContinue
          if ($err -match 'No cluster leader') {
            Write-Note "Noch kein Leader (ACL bootstrap 500). Warte weiter..."
          }
        }
      } finally { Remove-Item $o,$e -Force -ErrorAction SilentlyContinue }
    }

    # 3) Sonst einfach weiter warten bis Timeout (Server 2 muss erst joinen, dann gibt's einen Leader)
  } while ((Get-Date) -lt $deadline)

  Write-Note "Kein Leader innerhalb von $TimeoutSec Sekunden erkannt."
  return $false
}




function Validate-Config {
  Write-Step "Consul-Konfiguration validieren"
  & (Join-Path $InstallDir 'consul.exe') validate (Join-Path $InstallDir 'config')
  if ($LASTEXITCODE -ne 0) { throw "Consul-Konfiguration ungültig. Bitte Config prüfen." }
  Write-Ok "Config valid."
}

function Run-PortTroubleshoot {
  Write-Step "Port-Check (consul troubleshoot ports)"
  try {
    $base = "8301,8501,8503"
    if ($Role -eq 'server') { $base = "8300," + $base }
    & (Join-Path $InstallDir 'consul.exe') troubleshoot ports ("-host={0}" -f $ServerIP) ("-ports={0}" -f $base)
    if ($OpenDNSWan) { & (Join-Path $InstallDir 'consul.exe') troubleshoot ports ("-host={0}" -f $ServerIP) "-ports=8302,8600" }
    Write-Ok "Troubleshoot OK."
  } catch {
    Write-Note ("consul troubleshoot ports nicht verfügbar oder Fehler: {0}" -f $_.Exception.Message)
  }
}

# --- KV Utilities (idempotent; -ForceKV überschreibt) -----------------------
function KV-Exists {
  param([string]$Key)
  & (Join-Path $InstallDir 'consul.exe') kv get $Key 1>$null 2>$null
  return ($LASTEXITCODE -eq 0)
}
function KV-Put {
  param([string]$Key,[string]$Value,[switch]$Overwrite)
  if (-not $Overwrite) {
    if (KV-Exists -Key $Key) { Write-Info "KV existiert (skip): $Key"; return }
  }
  if ($null -ne $Value) {
    & (Join-Path $InstallDir 'consul.exe') kv put $Key $Value | Out-Null
  } else {
    & (Join-Path $InstallDir 'consul.exe') kv put $Key | Out-Null
  }
  if ($LASTEXITCODE -ne 0) { throw "KV put fehlgeschlagen: $Key" }
  Write-Ok ("KV '{0}' gesetzt." -f $Key)
}

function Build-KvObject {
  param(
    [string]$ServerIP,[int]$GrpcPort,[string]$Datacenter,
    [string]$ServiceName,[string]$ServiceId,[string]$InstallDir,
    [hashtable]$ExtraTopLevel
  )
  $advHost = if ($AdvertisedHostOverride -and $AdvertisedHostOverride.Trim()) { $AdvertisedHostOverride } else { $ServerIP }
  $certPath = Join-Path $InstallDir ("pki\{0}-server-consul-0.pem"     -f $Datacenter)
  $keyPath  = Join-Path $InstallDir ("pki\{0}-server-consul-0-key.pem" -f $Datacenter)

  $base = @{
    Kestrel = @{
      Endpoints = @{
        Grpc = @{
          Url        = ("https://0.0.0.0:{0}" -f $GrpcPort)
          Protocols  = "Http2"
          Certificate = @{ Path = $certPath; KeyPath = $keyPath }
        }
      }
    }
    Consul  = @{
      Address     = $ConsulAddr
      Token       = ""
      CAPath      = $ConsulCAPath
      ServiceName = $ServiceName
      ServiceId   = $ServiceId
    }
    Service = @{ AdvertisedHost = $advHost }
  }

  if ($ExtraTopLevel -and $ExtraTopLevel.Count -gt 0) {
    foreach ($k in $ExtraTopLevel.Keys) { $base[$k] = $ExtraTopLevel[$k] }
  }
  return $base
}

function Seed-ConsulKV-JsonObject {
  [CmdletBinding()] param([string]$Key,[Parameter(Mandatory)]$JsonObject,[switch]$Overwrite)
  if (-not $Overwrite -and (KV-Exists -Key $Key)) {
    Write-Info "KV existiert (skip): $Key"
    return
  }
  $tmp  = [System.IO.Path]::GetTempFileName()
  $json = ($JsonObject | ConvertTo-Json -Depth 12)
  Write-Utf8NoBom -Path $tmp -Content $json
  & (Join-Path $InstallDir 'consul.exe') kv put $Key "@$tmp"
  $code = $LASTEXITCODE
  Remove-Item $tmp -Force
  if ($code -ne 0) { throw "KV put fehlgeschlagen: $Key" }
  Write-Ok ("KV '{0}' gesetzt." -f $Key)
}

function Show-Summary {
  Write-Host ""
  Write-Host -ForegroundColor Green ("Consul UI (auf diesem Host): https://{0}:8501/ui" -f $ServerIP)

  # PS 5.1: Kein Ternary-Operator – daher if/else:
  $ports = "8301(TCP/UDP), 8501(HTTPS), 8503(gRPC-TLS)"
  if ($Role -eq 'server') { $ports = "8300, " + $ports }
  if ($OpenDNSWan) { $ports += ", 8302(TCP/UDP), 8600(TCP/UDP)" }

  if ($Role -eq 'server') {
    Write-Host ("Offen: {0}; plus {1} (Medicam), {2} (PolFlash)" -f $ports, $GrpcPortCamera, $GrpcPortPolFlash)
  } else {
    Write-Host ("Offen: {0}" -f $ports)
  }
  if ($HardenTLS) { Write-Note "Eingehendes mTLS (verify_incoming) ist AKTIV." } else { Write-Note "Mit -HardenTLS kannst du verify_incoming aktivieren." }
}

# ------------------------ MAIN ------------------------
try {
  Ensure-Admin

  if ($CleanFirst) {
    # pki AUTOMATISCH SCHONEN, wenn UseExistingCA oder Agent-Rolle:
    $keep = $UseExistingCA.IsPresent -or ($Role -eq 'agent')
    Stop-And-Cleanup -KeepPki:$keep
  }

  Ensure-Dirs
  Download-And-Install-Consul -Version $Version -TargetDir $InstallDir
  Generate-TLS
  Ensure-Gossip-Key
  Install-TrustedRootCA -CaPath $ConsulCAPath

  if ($Role -eq 'server') { Write-ServerConfig } else { Write-ClientConfig }

  Add-FirewallRules
  Validate-Config
  Install-ConsulService

  # ENV setzen (inkl. evtl. CLI-mTLS)
  Set-ConsulEnv -Scope Machine

  Wait-ConsulUp

  # --- Optional: ACL Bootstrap (einmalig, nur Server) ---
  if ($Role -eq 'server' -and $EnableACL -and $BootstrapACL) {
    if (-not (Wait-ForLeader -TimeoutSec $LeaderTimeoutSec)) { throw "Kein Leader; ACL Bootstrap abgebrochen." }
    Write-Step "Starte 'consul acl bootstrap' (einmalig)"
    $out = & (Join-Path $InstallDir 'consul.exe') acl bootstrap 2>&1
    $token = ($out | Select-String -Pattern "SecretID:\s+([0-9a-f-]{20,})").Matches.Groups[1].Value
    if ($token) {
      $tokPath = Join-Path $InstallDir "pki\management-token.txt"
      Set-Content -Path $tokPath -Value $token -Encoding ASCII -Force
      icacls $tokPath /inheritance:r /grant:r "$env:USERNAME:(R)" | Out-Null
      Write-Ok "ACL Management Token gespeichert: $tokPath"
      Set-ConsulEnv -Scope Machine -HttpToken $token
    } else {
      Write-Note "ACL Bootstrap Ausgabe:"
      Write-Host $out
    }
  }

  # --- Leader warten, danach KV seeden ---
  if (-not (Wait-ForLeader -TimeoutSec $LeaderTimeoutSec)) { throw "Kein Leader; KV-Seeding abgebrochen." }

  # Node-Infos ins KV (für DNS-losen Zugriff) – für Server & Agent:
  KV-Put -Key ("nodes/{0}/name"      -f $NodeName) -Value $NodeName -Overwrite:$ForceKV
  KV-Put -Key ("nodes/{0}/ip"        -f $NodeName) -Value $ServerIP -Overwrite:$ForceKV
  KV-Put -Key ("nodes/{0}/https_api" -f $NodeName) -Value $ConsulAddr -Overwrite:$ForceKV

  if ($Role -eq 'server') {
    # Nur Server: Microservice-Configs seeden
    $kvCam   = Build-KvObject -ServerIP $ServerIP -GrpcPort $GrpcPortCamera   -Datacenter $Datacenter -ServiceName $ServiceNameCamera   -ServiceId $ServiceIdCamera   -InstallDir $InstallDir -ExtraTopLevel @{ Visca = @{ Port = $ViscaPort; Baud = ("{0}" -f $ViscaBaud) } }
    $kvFlash = Build-KvObject -ServerIP $ServerIP -GrpcPort $GrpcPortPolFlash -Datacenter $Datacenter -ServiceName $ServiceNamePolFlash -ServiceId $ServiceIdPolFlash -InstallDir $InstallDir -ExtraTopLevel @{}

    Seed-ConsulKV-JsonObject -Key $KvCameraPath   -JsonObject $kvCam   -Overwrite:$ForceKV
    Seed-ConsulKV-JsonObject -Key $KvPolFlashPath -JsonObject $kvFlash -Overwrite:$ForceKV
  }

  Run-PortTroubleshoot
  Show-Summary
}
catch {
  Write-Bad $_.Exception.Message
  throw
}
