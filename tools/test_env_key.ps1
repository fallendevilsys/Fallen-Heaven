$ErrorActionPreference = 'Stop'

# Simuliert GitHub Actions: FH_UPDATE_PRIVATE_KEY ist BASE64-kodiert
# (einzeilig, robust gegen BOM-/Zeilenumbruch-Probleme beim Secret-Setzen).
$keyFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'keys\private.xml'
$keyText = [System.IO.File]::ReadAllText($keyFile)   # ReadAllText strippt BOM automatisch

# Fall 1: base64 OHNE BOM (der erwartete CI-Fall)
$env:FH_UPDATE_PRIVATE_KEY = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($keyText))
$sig1 = & (Join-Path $PSScriptRoot 'sign_manifest.ps1') `
    -Version '6.3.5.0' `
    -PackageUrl 'https://example.com/pkg.zip' `
    -Sha256 'ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890' `
    -EntryExecutable 'FallenHeaven.exe'
"Fall 1 (base64, sauber): Signatur laenge = $($sig1.Length), beginnt mit = $($sig1.Substring(0, [Math]::Min(12, $sig1.Length)))"

# Fall 2: base64 MIT BOM (defensive: TrimStart nach Decode muss greifen)
$env:FH_UPDATE_PRIVATE_KEY = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(([char]0xFEFF + $keyText)))
$sig2 = & (Join-Path $PSScriptRoot 'sign_manifest.ps1') `
    -Version '6.3.5.0' `
    -PackageUrl 'https://example.com/pkg.zip' `
    -Sha256 'ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890' `
    -EntryExecutable 'FallenHeaven.exe'
"Fall 2 (base64, mit BOM): Signatur laenge = $($sig2.Length), identisch = $($sig1 -eq $sig2)"
