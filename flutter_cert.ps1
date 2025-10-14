# Pfade anpassen:
$pfxPath = Join-Path $PSScriptRoot 'tlscerts\consul-srv-1-dev.pfx'  # oder dein tatsächlicher Name
$pemOut  = Join-Path $PSScriptRoot 'flutter_application\assets\medicam-dev-cert.pem'
$pwd     = 'default'

# 1) Zertifikat aus PFX laden (nur End-Entity-Zertifikat)
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfxPath, $pwd)

# 2) DER -> Base64 -> PEM mit Header/Footers
$der = $cert.RawData
$b64 = [System.Convert]::ToBase64String($der)
# in 64-Zeichen-Zeilen umbrechen (optional, aber üblich)
$lines = ($b64.ToCharArray() -split '(.{1,64})' | Where-Object { $_ -ne '' }) -join "`n"
$pem = "-----BEGIN CERTIFICATE-----`n$lines`n-----END CERTIFICATE-----`n"

# 3) Datei schreiben
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $pemOut) | Out-Null
Set-Content -LiteralPath $pemOut -Value $pem -NoNewline -Encoding ascii

Write-Host "PEM geschrieben: $pemOut"
