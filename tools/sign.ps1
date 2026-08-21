# =====================================================================
# sign.ps1 - signiert die Fallen-Heaven-Release-Dateien mit einem
#            Code-Signing-Zertifikat (Authenticode).
#
# WARUM:
#   Smart App Control & SmartScreen blockieren unsignierte/unbekannte
#   EXEs. Eine echte OV/EV-Codesignatur hebt die Blockierung auf -
#   lokal UND bei deinen Nutzern (auch nach Auto-Updates).
#
# WICHTIG:
#   Ein SELBST erstelltes Zertifikat (self-signed) hilft NICHT -
#   Smart App Control/SmartScreen vertrauen nur Zertifikaten einer
#   oeffentlichen Zertifizierungsstelle (DigiCert, Sectigo, ...).
#   Siehe docs/SIGNING.md fuer Kauf + Einrichtung.
#
# VORAUSSETZUNGEN:
#   1) Code-Signing-Zertifikat:
#        - .pfx-Datei mit Passwort   ODER
#        - im Zertifikatsspeicher CurrentUser\My (z. B. USB-Token)
#   2) signtool.exe aus dem Windows SDK
#        https://developer.microsoft.com/windows/downloads/windows-sdk/
#        (Komponente "Signing Tools for Desktop Apps")
#
# AUFRUF (pfx):
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\sign.ps1 `
#     -PfxPath C:\certs\codesign.pfx -PfxPassword "GEHEIM"
#
# AUFRUF (Zertifikat im Speicher, per Thumbprint):
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\sign.ps1 `
#     -Thumbprint A1B2C3D4E5F6...
#
# AUFRUF (automatisch: erstes passendes CodeSigning-Zertifikat im
#         CurrentUser\My-Speicher verwenden):
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\sign.ps1
#
# Alternativ per Umgebungsvariable:
#   FH_SIGN_PFX, FH_SIGN_PASSWORD
# =====================================================================
param(
    [string]$PfxPath,
    [string]$PfxPassword,
    [string]$Thumbprint,
    [string]$TimestampServer = "http://timestamp.digicert.com"
)

$ErrorActionPreference = "Stop"

# Projekt-Stamm (tools/ -> eine Ebene hoeher)
$Root = Split-Path -Parent $PSScriptRoot

# ---------------------------------------------------------------------
# 1) signtool.exe finden
# ---------------------------------------------------------------------
function Find-Signtool {
    $hits = @()
    $cmd = Get-Command signtool.exe -ErrorAction SilentlyContinue
    if ($cmd) { $hits += $cmd.Source }
    foreach ($base in @(
        "C:\Program Files (x86)\Windows Kits\10\bin",
        "C:\Program Files\Windows Kits\10\bin"
    )) {
        $hits += Get-ChildItem $base -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending | Select-Object -ExpandProperty FullName
    }
    return ($hits | Select-Object -First 1)
}

$signtool = Find-Signtool
if (-not $signtool) {
    throw "signtool.exe nicht gefunden. Installiere das Windows SDK (Komponente 'Signing Tools for Desktop Apps'): https://developer.microsoft.com/windows/downloads/windows-sdk/"
}

# ---------------------------------------------------------------------
# 2) Zertifikat aufloesen
#    -> bei pfx:  signieren mit /f <pfx> /p <pw>
#    -> sonst:    signieren mit /sha1 <thumbprint> aus dem Speicher
# ---------------------------------------------------------------------
$usePfx = $false
$pfx    = $PfxPath
$pw     = $PfxPassword

if (-not $pfx -and $env:FH_SIGN_PFX)      { $pfx = $env:FH_SIGN_PFX }
if (-not $pw  -and $env:FH_SIGN_PASSWORD) { $pw  = $env:FH_SIGN_PASSWORD }

if ($pfx) {
    if (-not (Test-Path $pfx)) { throw "PFX-Datei nicht gefunden: $pfx" }
    $usePfx = $true
    # Kurz testen, ob die PFX-Datei mit dem Passwort lesbar ist:
    $probe = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfx, $pw)
    $certThumb = $probe.Thumbprint
    $probe.Reset()
} elseif ($Thumbprint) {
    $certThumb = $Thumbprint.ToUpper().Replace(" ", "")
} else {
    $auto = Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue |
        Where-Object { $_.HasPrivateKey -and ($_.EnhancedKeyUsageList | Where-Object { $_.ObjectId -eq "1.3.6.1.5.5.7.3.3" }) } |
        Select-Object -First 1
    if (-not $auto) {
        throw "Kein CodeSigning-Zertifikat gefunden. Gib -PfxPath (mit -PfxPassword) oder -Thumbprint an."
    }
    $certThumb = $auto.Thumbprint
}

# ---------------------------------------------------------------------
# 3) Zu signierende Dateien (nur vorhandene)
# ---------------------------------------------------------------------
$files = @(
    (Join-Path $Root "Fallen-Heaven Discord App.exe"),
    (Join-Path $Root "lib\FH.YoutubeResolver.dll"),
    (Join-Path $Root "lib\FH.SpotifyResolver.dll")
) | Where-Object { Test-Path $_ }

if ($files.Count -eq 0) {
    throw "Keine zu signierenden Dateien im Projektstamm gefunden."
}

Write-Host ""
Write-Host "signtool  : $signtool" -ForegroundColor Cyan
Write-Host "Zertifikat: $certThumb" -ForegroundColor Cyan
Write-Host "Timestamp : $TimestampServer" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------
# 4) Signieren (SHA256 + RFC3161-Zeitstempel)
# ---------------------------------------------------------------------
foreach ($f in $files) {
    Write-Host ("Signiere " + (Split-Path $f -Leaf) + " ...") -ForegroundColor Yellow
    $signArgs = @("sign", "/fd", "SHA256", "/td", "SHA256", "/tr", $TimestampServer)
    if ($usePfx) {
        $signArgs += @("/f", $pfx, "/p", $pw)
    } else {
        $signArgs += @("/sha1", $certThumb)
    }
    $signArgs += $f
    & $signtool @signArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Signieren fehlgeschlagen (Exit $LASTEXITCODE): $f"
    }
}

# ---------------------------------------------------------------------
# 5) Verifizieren
# ---------------------------------------------------------------------
Write-Host "Verifiziere Signaturen ..." -ForegroundColor Yellow
foreach ($f in $files) {
    & $signtool verify /pa /v $f | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Signatur-Verifikation fehlgeschlagen: $f"
    }
    $s = Get-AuthenticodeSignature $f
    $subject = ""
    if ($s.SignerCertificate) { $subject = $s.SignerCertificate.Subject }
    Write-Host ("  OK  {0}  ->  {1}  ({2})" -f (Split-Path $f -Leaf), $s.Status, $subject) -ForegroundColor Green
}

Write-Host ""
Write-Host "Fertig: alle Dateien signiert und verifiziert." -ForegroundColor Green
Write-Host "Hinweis: Danach die signierte EXE/DLL committen + taggen - das Release enthaelt dann die Signatur." -ForegroundColor DarkGray
