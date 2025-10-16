# =========================
# Datei: consul_start.ps1
# Zweck : Consul-Dienst konfigurieren, Windows-Service neu anlegen und starten
# Umgebung: PowerShell 7.x (als Administrator ausführen)
# =========================

$ErrorActionPreference = 'Stop'

#region Hilfsfunktionen (Ausgabe)
function Fail([string]$msg) { throw $msg }
function Info([string]$msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Ok  ([string]$msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
#endregion Hilfsfunktionen (Ausgabe)

#region Pfade und Verzeichnisse
$ScriptDir   = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { (Get-Location).Path } else { $PSScriptRoot }
$ProjectRoot = Split-Path -Path $ScriptDir -Parent

$InstallRoot = Join-Path $ProjectRoot "consul"
$Bin         = Join-Path $InstallRoot "bin"
$ConfigDir   = Join-Path $InstallRoot "config"
$DataDir     = Join-Path $InstallRoot "data"
$LogDir      = Join-Path $InstallRoot "logs"
$Certs       = Join-Path $InstallRoot "certs"
$SvcName     = "Consul"

$ConsulExe = Join-Path $Bin "consul.exe"
$HclPath   = Join-Path $ConfigDir "server.hcl"

if (-not (Test-Path $HclPath))   { Fail "server.hcl fehlt: $HclPath" }
if (-not (Test-Path $ConsulExe)) { Fail "consul.exe fehlt: $ConsulExe" }
Ok "Grundlegende Pfade geprüft."
#endregion Pfade und Konstanten

#region Parser- und Hilfsfunktionen
function Convert-ToSlashPath([string]$p){ $p -replace '\\','/' }
function Get-HclVal([string]$content,[string]$key){
  ([regex]::Match($content,'(?m)^\s*'+[regex]::Escape($key)+'\s*=\s*"?(?<v>[^"\r\n#]+)"?')).Groups['v'].Value.Trim()
}
#endregion Parser- und Hilfsfunktionen

#region HCL laden und Basiswerte ermitteln
$hclRaw   = Get-Content -Path $HclPath -Raw
$dc       = Get-HclVal $hclRaw 'datacenter'; if (-not $dc) { $dc = 'dc1' }
$domain   = Get-HclVal $hclRaw 'domain';     if (-not $domain) { $domain = 'consul' }
Info "Datacenter: $dc | Domain: $domain"
#endregion HCL laden und Basiswerte ermitteln

#region Pflichtdateien prüfen (Zertifikate/Gossip)
$GossipKey = Join-Path $Certs "gossip.key"
$CA        = Join-Path $Certs "consul-agent-ca.pem"
if (-not (Test-Path $GossipKey)) { Fail "Fehler: gossip.key nicht gefunden in $Certs" }
if (-not (Test-Path $CA))        { Fail "Fehler: consul-agent-ca.pem nicht gefunden in $Certs" }
Ok "Erforderliche Schlüssel/CA gefunden."
#endregion Pflichtdateien prüfen (Zertifikate/Gossip)

#region Serverzertifikate auswählen
$serverCrt = Get-ChildItem -Path $Certs -Filter "dc1-server-consul-*.pem" | Where-Object { $_.Name -notmatch '-key\.pem$' } | Select-Object -First 1
$serverKey = Get-ChildItem -Path $Certs -Filter "dc1-server-consul-*-key.pem" | Select-Object -First 1
if (-not $serverCrt -or -not $serverKey) {
  Fail "Kein gültiges Zertifikatspaar gefunden in $Certs. Erwartet: dc1-server-consul-<x>.pem + dc1-server-consul-<x>-key.pem"
}
Ok ("Zertifikat ausgewählt: {0}" -f $serverCrt.Name)
#endregion Serverzertifikate auswählen

#region Platzhalter in server.hcl ersetzen
$txt = $hclRaw.
  Replace('__DATA_DIR__',        (Convert-ToSlashPath $DataDir)).
  Replace('__LOG_FILE__',        ((Convert-ToSlashPath $LogDir) + '/consul.log')).
  Replace('__GOSSIP_KEY__',      ((Get-Content $GossipKey -Raw).Trim())).
  Replace('__TLS_CA_FILE__',     (Convert-ToSlashPath $CA)).
  Replace('__TLS_CERT_FILE__',   (Convert-ToSlashPath $serverCrt.FullName)).
  Replace('__TLS_KEY_FILE__',    (Convert-ToSlashPath $serverKey.FullName))

Set-Content -Path $HclPath -Value $txt -Encoding UTF8
Ok "Konfiguration aktualisiert: $HclPath"
Info "Datacenter : $dc"
Info "Domain     : $domain"
Info "Zertifikat : $($serverCrt.Name)"
Info "CA-Datei   : $(Split-Path -Leaf $CA)"
#endregion Platzhalter in server.hcl ersetzen

#region Existierenden Dienst bereinigen
$svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
if ($svc) {
  try { if ($svc.Status -ne 'Stopped') { Stop-Service $SvcName -Force -ErrorAction Stop } } catch {}
  sc.exe delete $SvcName | Out-Null
  $deadline = (Get-Date).AddSeconds(30)
  while (Get-Service -Name $SvcName -ErrorAction SilentlyContinue) {
    if (Get-Date -gt $deadline) { break }
    Start-Sleep -Milliseconds 300
  }
  Info "Alter Dienst entfernt (falls vorhanden)."
}
#endregion Existierenden Dienst bereinigen

#region Dienst anlegen und starten
$binPath = "`"$(Join-Path $Bin 'consul.exe')`" agent -config-dir=`"$ConfigDir`""
sc.exe create $SvcName binPath= "$binPath" start= auto | Out-Null
sc.exe failure $SvcName reset= 86400 actions= restart/5000 | Out-Null
Ok "Windows-Dienst erstellt/konfiguriert: $SvcName"

Start-Service $SvcName
Ok "Dienst gestartet: $SvcName"

Info "Version:"
& $ConsulExe version | ForEach-Object { "    $_" }

Info "UI-Hinweis (HTTPS empfohlen): https://<bind_addr>:8501/ui"
#endregion Dienst anlegen und starten
