# =====================================================================
# sign_manifest.ps1 - signiert die Update-Manifest-Daten (RSA-SHA256).
#
# Die App prueft Updates kryptografisch. Signierte Daten (UTF-8):
#   {version}\n{packageUrl}\n{SHA256 GROSS}\n{entryExecutable}
#
# Private Key-Quellen (in dieser Reihenfolge):
#   1) Umgebungsvariable FH_UPDATE_PRIVATE_KEY = BASE64-kodierter Key
#      (fuer GitHub Actions Secret - einzeilig, robust gegen BOM/Umbrueche)
#   2) Datei keys\private.xml (lokal, rohes XML)
#
# Aufruf (aus Projektstamm):
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\sign_manifest.ps1 `
#     -Version "6.3.6.0" -PackageUrl "https://..." `
#     -Sha256 "abc123..." -EntryExecutable "Fallen-Heaven Discord App.exe"
#
# Ausgabe: Base64-Signatur (eine Zeile)
# =====================================================================
param(
    [Parameter(Mandatory=$true)][string]$Version,
    [Parameter(Mandatory=$true)][string]$PackageUrl,
    [Parameter(Mandatory=$true)][string]$Sha256,
    [Parameter(Mandatory=$true)][string]$EntryExecutable
)

$ErrorActionPreference = 'Stop'

$priv = $null
if ($env:FH_UPDATE_PRIVATE_KEY) {
    # Secret ist base64 (einzeilig). Decodieren + evtl. BOM strippen.
    $b64 = $env:FH_UPDATE_PRIVATE_KEY.Trim()
    $priv = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64)).TrimStart([char]0xFEFF).Trim()
} elseif (Test-Path (Join-Path (Split-Path -Parent $PSScriptRoot) 'keys\private.xml')) {
    $keyFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'keys\private.xml'
    $priv = [System.IO.File]::ReadAllText($keyFile).TrimStart([char]0xFEFF).Trim()
} else {
    throw 'Kein Private-Key gefunden (FH_UPDATE_PRIVATE_KEY oder keys\private.xml).'
}

$shaUpper = $Sha256.ToUpperInvariant()
$data = "$Version`n$PackageUrl`n$shaUpper`n$EntryExecutable"

$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
$rsa.FromXmlString($priv)
$sig = $rsa.SignData(
    [System.Text.Encoding]::UTF8.GetBytes($data),
    (New-Object System.Security.Cryptography.SHA256CryptoServiceProvider)
)

Write-Output ([Convert]::ToBase64String($sig))
