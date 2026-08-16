$ErrorActionPreference = 'Stop'

# Simuliert GitHub Actions: Secret als Umgebungsvariable (ggf. mit BOM, wie es
# beim Pipe-Setzen eines UTF-8-BOM-Datei passieren wuerde).
$keyFile = Join-Path (Split-Path -Parent $PSScriptRoot) 'keys\private.xml'
$rawBytes = [System.IO.File]::ReadAllBytes($keyFile)
$keyText = [System.Text.Encoding]::UTF8.GetString($rawBytes)   # behaelt evtl. BOM

# Fall 1: sauberer Key (ohne BOM) - der erwartete CI-Fall nach dem Fix
$env:FH_UPDATE_PRIVATE_KEY = $keyText.TrimStart([char]0xFEFF).Trim()
$sig1 = & (Join-Path $PSScriptRoot 'sign_manifest.ps1') `
    -Version '6.3.5.0' `
    -PackageUrl 'https://example.com/pkg.zip' `
    -Sha256 'ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890' `
    -EntryExecutable 'FallenHeaven.exe'
"Fall 1 (sauber): Signatur laenge = $($sig1.Length), beginnt mit = $($sig1.Substring(0, [Math]::Min(12, $sig1.Length)))"

# Fall 2: Key MIT BOM (defensive: sollte dank TrimStart trotzdem klappen)
$env:FH_UPDATE_PRIVATE_KEY = [char]0xFEFF + $keyText.TrimStart([char]0xFEFF).Trim()
$sig2 = & (Join-Path $PSScriptRoot 'sign_manifest.ps1') `
    -Version '6.3.5.0' `
    -PackageUrl 'https://example.com/pkg.zip' `
    -Sha256 'ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890' `
    -EntryExecutable 'FallenHeaven.exe'
"Fall 2 (mit BOM): Signatur laenge = $($sig2.Length), identisch = $($sig1 -eq $sig2)"
