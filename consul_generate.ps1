#requires -Version 7.0
<#
.SYNOPSIS
  Erzeugt einmalig CA, Server-Zertifikate (ohne -domain, Default "consul") und Gossip-Key.
  Liest 'datacenter' und 'bootstrap_expect' ausschließlich aus server.hcl.

.DESCRIPTION
  - CA:    consul-agent-ca.pem / consul-agent-ca-key.pem (Default-Domain "consul")
  - SRV:   <auto-benannte Dateien>, erzeugt per 'consul tls cert create -server -dc <dc> -node <i>'
  - KEY:   gossip.key (ASCII, ohne BOM)
  - Idempotent: Vorhandenes bleibt unangetastet; es werden nur fehlende Server-Zertifikatspaare ergänzt.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Pfade --------------------------------------------------------------------
$Root      = $PSScriptRoot
$Install   = Join-Path $Root "Consul"
$Bin       = Join-Path $Install "bin"
$Certs     = Join-Path $Install "certs"
$ConfigDir = Join-Path $Install "config"
$ConsulExe = Join-Path $Bin "consul.exe"

$ServerHcl = Join-Path $ConfigDir "server.hcl"

if (-not (Test-Path -LiteralPath $ServerHcl)) { throw "Konfig fehlt: '$ServerHcl'." }
if (-not (Test-Path -LiteralPath $ConsulExe)) { throw "consul.exe nicht gefunden: '$ConsulExe'." }
if (-not (Test-Path -LiteralPath $Certs)) { New-Item -ItemType Directory -Path $Certs | Out-Null }

# --- HCL lesen: datacenter & bootstrap_expect ---------------------------------
function Get-ConsulConfigValues {
  # Kommentare entfernen: /*...*/, //..., #...
  $raw     = Get-Content -LiteralPath $ServerHcl -Raw
  $noBlock = [regex]::Replace($raw, '/\*.*?\*/', '', 'Singleline')
  $noLine  = ($noBlock -split "`n" | ForEach-Object { ($_ -replace '//.*$', '') -replace '#.*$', '' }) -join "`n"

  $dcMatch = [regex]::Match($noLine, '(?m)^\s*datacenter\s*=\s*(?:"([^"]+)"|''([^'']+)''|([^\s#//]+))')
  $beMatch = [regex]::Match($noLine, '(?m)^\s*bootstrap_expect\s*=\s*(\d+)')

  $dc = @($dcMatch.Groups[1].Value, $dcMatch.Groups[2].Value, $dcMatch.Groups[3].Value) |
        Where-Object { $_ -and $_.Trim() } | Select-Object -First 1
  $be = if ($beMatch.Success) { [int]$beMatch.Groups[1].Value } else { $null }

  if (-not $dc) { throw "Konfig-Fehler: 'datacenter' nicht gefunden in $ServerHcl." }
  if (-not $be -or $be -lt 1) { throw "Konfig-Fehler: 'bootstrap_expect' fehlt/ungültig in $ServerHcl." }

  [pscustomobject]@{ Datacenter = "$dc"; BootstrapExpect = $be }
}

$cfg         = Get-ConsulConfigValues
$Datacenter  = $cfg.Datacenter
$ServerCount = $cfg.BootstrapExpect

Write-Host "Konfiguration: datacenter='$Datacenter', bootstrap_expect=$ServerCount"

# --- Gossip-Key ---------------------------------------------------------------
$GossipKeyFile = Join-Path $Certs "gossip.key"
if (-not (Test-Path -LiteralPath $GossipKeyFile)) {
  $gossip = & $ConsulExe keygen
  if ([string]::IsNullOrWhiteSpace($gossip)) { throw "consul keygen fehlgeschlagen." }
  Set-Content -Path $GossipKeyFile -Value $gossip -NoNewline -Encoding ascii
  Write-Host "✓ Gossip-Key erzeugt: $GossipKeyFile"
} else {
  Write-Host "↷ Gossip-Key vorhanden: $GossipKeyFile"
}

# --- CA (Default-Domain "consul") --------------------------------------------
Push-Location $Certs
try {
  $CA  = "consul-agent-ca.pem"
  $CAK = "consul-agent-ca-key.pem"

  if (-not ((Test-Path -LiteralPath $CA) -and (Test-Path -LiteralPath $CAK))) {
    & $ConsulExe tls ca create | Out-Null
    if (-not ((Test-Path -LiteralPath $CA) -and (Test-Path -LiteralPath $CAK))) {
      throw "CA nicht erzeugt (erwartet '$CA' und '$CAK')."
    }
    Write-Host "✓ CA erzeugt: $CA / $CAK"
  } else {
    Write-Host "↷ CA vorhanden: $CA / $CAK"
  }

  # --- vorhandene Server-Zertifikatspaare zählen -----------------------------
  function Get-ExistingServerPairs {
    $certs = Get-ChildItem -LiteralPath . -Filter "*-server-consul-*.pem" -File |
             Where-Object { $_.Name -notmatch '-key\.pem$' }
    foreach ($c in $certs) {
      $k = ($c.Name -replace '\.pem$', '-key.pem')
      if (Test-Path -LiteralPath $k) { [pscustomobject]@{ Cert=$c.Name; Key=$k } }
    }
  }

  $existing = @(Get-ExistingServerPairs)
  $have     = $existing.Count
  $need     = [Math]::Max(0, $ServerCount - $have)

  if ($need -eq 0) {
    Write-Host "↷ Bereits $have Server-Zertifikatspaare vorhanden. Keine Neuerzeugung nötig."
  } else {
    for ($i = 0; $i -lt $need; $i++) {
      # WICHTIG: -server klar voranstellen; -dc aus HCL; -node = laufende Nummer (oder Hostname)
      $out = & $ConsulExe tls cert create -server -dc $Datacenter -node $i 2>&1
      if ($LASTEXITCODE -ne 0) { throw "consul tls cert create fehlgeschlagen:`n$out" }

      # Tatsächlich gespeicherte Dateinamen aus der CLI-Ausgabe extrahieren
      $saved = [regex]::Matches($out, 'Saved\s+(\S+\.pem)') | ForEach-Object { $_.Groups[1].Value }
      $crt   = $saved | Where-Object { $_ -notmatch '-key\.pem$' } | Select-Object -Last 1
      $key   = $saved | Where-Object { $_ -match    '-key\.pem$' } | Select-Object -Last 1

      if (-not ($crt -and $key -and (Test-Path -LiteralPath $crt) -and (Test-Path -LiteralPath $key))) {
        throw "Server-Zertifikat nicht verifizierbar erzeugt. Konsolenausgabe:`n$out"
      }
      Write-Host "✓ Server-Zertifikat erzeugt: $crt"
    }
  }
}
finally {
  Pop-Location
}

# --- Verteilhinweis -----------------------------------------------------------
Write-Host ""
Write-Host "Verteilung (pro Server genau EIN Paar wählen):"
(Get-ChildItem -LiteralPath $Certs -Filter "*-server-consul-*.pem" -File |
  Where-Object { $_.Name -notmatch '-key\.pem$' } |
  ForEach-Object { " - $($_.FullName)`n   $($Certs + '\' + ($_.Name -replace '\.pem$','-key.pem'))" }) -join "`n"
Write-Host "CA:     $Certs\$CA"
Write-Host "CAK:    $Certs\$CAK"
Write-Host "Gossip: $GossipKeyFile"
Write-Host "Fertig."
