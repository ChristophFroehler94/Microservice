# =========================
# Datei: 03-service-start.ps1
# PowerShell 7.x (als Administrator ausführen)
# - leitet Anzahl Zertifikat-Indizes aus bootstrap_expect ab
# - nimmt das erste vorhandene Server-Zertifikatspaar (Index 0..bootstrap_expect-1)
# - verwendet Gossip-Key und CA-Zertifikat (CA-Private-Key wird ignoriert)
# - ersetzt Platzhalter in server.hcl
# - erstellt/started den Windows-Dienst "Consul"
# =========================

$ErrorActionPreference = 'Stop'

$Root      = $PSScriptRoot
$Install   = Join-Path $Root "Consul"
$Bin       = Join-Path $Install "bin"
$ConfigDir = Join-Path $Install "config"
$DataDir   = Join-Path $Install "data"
$LogDir    = Join-Path $Install "logs"
$Certs     = Join-Path $Install "certs"
$SvcName   = "Consul"

$ConsulExe = Join-Path $Bin "consul.exe"
$HclPath   = Join-Path $ConfigDir "server.hcl"

if (-not (Test-Path $HclPath))   { throw "server.hcl fehlt: $HclPath" }
if (-not (Test-Path $ConsulExe)) { throw "consul.exe fehlt: $ConsulExe" }

# --- Helfer ---
function Convert-ToSlashPath([string]$p){ $p -replace '\\','/' }
function Get-HclVal([string]$content,[string]$key){
  ([regex]::Match($content,'(?m)^\s*'+[regex]::Escape($key)+'\s*=\s*"?(?<v>[^"\r\n#]+)"?')).Groups['v'].Value.Trim()
}

# --- HCL laden & Werte extrahieren ---
$hclRaw   = Get-Content -Path $HclPath -Raw
$dc       = Get-HclVal $hclRaw 'datacenter'; if (-not $dc) { $dc = 'dc1' }
$domain   = Get-HclVal $hclRaw 'domain';     if (-not $domain) { $domain = 'consul' }  # Default-Domain laut Doku
$beStr    = Get-HclVal $hclRaw 'bootstrap_expect'
[int]$be  = 1
if ($beStr -match '^\d+$') { $be = [int]$beStr }
if ($be -lt 1) { $be = 1 }

# --- Pflicht-Artefakte prüfen ---
$GossipKey = Join-Path $Certs "gossip.key"
$CA        = Join-Path $Certs "consul-agent-ca.pem"         # nur CA-Zertifikat
$CAK       = Join-Path $Certs "consul-agent-ca-key.pem"     # existiert evtl., wird aber bewusst ignoriert
foreach ($f in @($GossipKey,$CA)) { if (-not (Test-Path $f)) { throw "Fehlt: $f" } }

# --- Kandidaten 0..bootstrap_expect-1 durchiterieren und erstes vorhandenes Paar wählen ---
$chosen = $null
for ($i = 0; $i -lt $be; $i++) {
  $crt = Join-Path $Certs "$dc-server-$domain-$i.pem"
  $key = Join-Path $Certs "$dc-server-$domain-$i-key.pem"
  if ((Test-Path $crt -PathType Leaf) -and (Test-Path $key -PathType Leaf)) {
    $chosen = [pscustomobject]@{ Index = $i; Cert = $crt; Key = $key }
    break
  }
}

if (-not $chosen) {
  $expected = @()
  0..([math]::Max($be-1,0)) | ForEach-Object { $expected += "$dc-server-$domain-$_.pem" }
  throw "Kein Server-Zertifikatspaar gefunden. Erwartete Kandidaten (0..$($be-1)) in ${Certs}:`n  - $($expected -join "`n  - ")"
}

# --- Platzhalter in server.hcl ersetzen ---
# Erwartete Platzhalter: __DATA_DIR__, __LOG_FILE__, __GOSSIP_KEY__, __TLS_CA_FILE__, __TLS_CERT_FILE__, __TLS_KEY_FILE__
$gossipVal = (Get-Content $GossipKey -Raw).Trim()
$SrvCrt = $chosen.Cert
$SrvKey = $chosen.Key

$txt = $hclRaw.
  Replace('__DATA_DIR__',        (Convert-ToSlashPath $DataDir)).
  Replace('__LOG_FILE__',        ((Convert-ToSlashPath $LogDir) + '/consul.log')).
  Replace('__GOSSIP_KEY__',      ((Get-Content $GossipKey -Raw).Trim())).
  Replace('__TLS_CA_FILE__',     (Convert-ToSlashPath $CA)).
  Replace('__TLS_CERT_FILE__',   (Convert-ToSlashPath $SrvCrt)).
  Replace('__TLS_KEY_FILE__',    (Convert-ToSlashPath $SrvKey))

Set-Content -Path $HclPath -Value $txt -Encoding UTF8
Write-Host "==> Konfiguration aktualisiert: $HclPath"
Write-Host "    Datacenter : $dc"
Write-Host "    Domain     : $domain"
Write-Host "    bootstrap_expect : $be"
Write-Host "    Zertifikat : $(Split-Path -Leaf $($chosen.Cert))  (Index $($chosen.Index))"
Write-Host "    CA         : $(Split-Path -Leaf $CA)  (CA-Private-Key wird ignoriert)"

# --- Dienst clean re-create ---
$svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
if ($svc) {
  try { if ($svc.Status -ne 'Stopped') { Stop-Service $SvcName -Force -ErrorAction Stop } } catch {}
  sc.exe delete $SvcName | Out-Null
  $deadline = (Get-Date).AddSeconds(30)
  while (Get-Service -Name $SvcName -ErrorAction SilentlyContinue) {
    if (Get-Date -gt $deadline) { break }
    Start-Sleep -Milliseconds 300
  }
}

# Dienst anlegen
$binPath = "`"$(Join-Path $Bin 'consul.exe')`" agent -config-dir=`"$ConfigDir`""
sc.exe create $SvcName binPath= "$binPath" start= auto | Out-Null
sc.exe failure $SvcName reset= 86400 actions= restart/5000 | Out-Null

Start-Service $SvcName

Write-Host "`n==> Consul gestartet:"
& $ConsulExe version | ForEach-Object { "    $_" }
Write-Host "UI (HTTPS empfohlen; siehe tls.defaults & ports.https): https://<bind_addr>:8501/ui"

# --- Consul CLI: Ports-Troubleshooting (lokal) ---
# prüft die Standard-TCP-Ports der Consul-Server-Instanz
Start-Sleep -Seconds 2
Write-Host "`n==> consul troubleshoot ports (localhost) ..."
& $ConsulExe troubleshoot ports -host=localhost
