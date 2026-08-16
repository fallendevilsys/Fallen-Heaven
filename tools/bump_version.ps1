# =====================================================================
# bump_version.ps1 - Version der App-EXE aendern (dnlib + VERSIONINFO)
#
# Aufruf (aus Projektstamm, z. B.):
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\bump_version.ps1 -NewVersion 6.3.6.0
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\bump_version.ps1 -NewVersion 6.3.6
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\bump_version.ps1 -NewVersion 6.3.6 -Apply
#
# Die AKTUELLE Version wird automatisch aus der EXE gelesen - es muss nur
# die neue Version angegeben werden. Geaendert werden:
#   1) AssemblyDef.Version          (GetName().Version - Update-Vergleich)
#   2) AssemblyFileVersionAttribute + AssemblyVersionAttribute
#   3) VERSIONINFO-Ressource        (ASCII + UTF-16LE)
#
# WICHTIG (gleiche Laenge):
#   Der VERSIONINFO-Byte-Patch ersetzt die Versions-Zeichenkette IN PLACE.
#   Neue Version muss daher GLEICH LANG sein wie die alte
#   (z. B. 6.3.5.0 -> 6.3.6.0  ok |  6.3.9.0 -> 6.3.10.0  NICHT moeglich).
#   Das Skript prueft das und bricht sonst mit einer klaren Meldung ab.
#
# Ohne -Apply wird nur "fh_bump_tmp.exe" erzeugt (EXE danach selbst ersetzen).
# Mit -Apply wird die Haupt-EXE direkt ersetzt.
# =====================================================================
param(
    [Parameter(Mandatory=$true)][string]$NewVersion,
    [string]$ExePath = 'Fallen-Heaven Discord App.exe',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
# Absoluter Pfad bleibt absolut, relativer wird auf den Projektstamm bezogen
if ([System.IO.Path]::IsPathRooted($ExePath)) { $exe = $ExePath } else { $exe = Join-Path $Root $ExePath }
$tmp  = Join-Path $Root 'fh_bump_tmp.exe'
$dnlib = Join-Path $Root 'tools\dnlib.dll'

if (-not (Test-Path $dnlib)) { throw "dnlib.dll nicht gefunden: $dnlib (lokal, gitignored)." }
if (-not (Test-Path $exe))   { throw "EXE nicht gefunden: $exe" }

# --- 0) Aktuelle Version ermitteln ------------------------------------
$oldVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe).FileVersion
if (-not $oldVersion) { throw "Aktuelle Version konnte nicht ermittelt werden: $exe" }

# --- Neue Version normalisieren (X.Y.Z -> X.Y.Z.0) ----------------------
$parts = $NewVersion.Trim() -split '\.'
while ($parts.Count -lt 4) { $parts += '0' }
if ($parts.Count -gt 4) { throw "Ungueltige Version '$NewVersion' (max. 4 Teile)." }
$newVersion = $parts -join '.'
$newVer = [System.Version]::Parse($newVersion)

if ($newVersion -eq $oldVersion) {
    throw "EXE hat bereits Version $oldVersion - nichts zu tun."
}

# --- Laengen-Check (VERSIONINFO-Byte-Patch braucht gleiche Laenge) ------
if ($oldVersion.Length -ne $newVersion.Length) {
    throw "Neue Version '$newVersion' ($($newVersion.Length) Zeichen) hat andere Laenge als alte '$oldVersion' ($($oldVersion.Length) Zeichen). VERSIONINFO-Byte-Patch benoetigt gleiche Laenge (z. B. 6.3.5.0 -> 6.3.6.0)."
}

Write-Output "Alt  : $oldVersion"
Write-Output "Neu  : $newVersion"
Write-Output "EXE  : $exe"

# --- 1) + 2) dnlib: AssemblyDef.Version + Attribute ----------------------
Add-Type -Path $dnlib
$m = [dnlib.DotNet.ModuleDefMD]::Load($exe)
try {
    Write-Output ('Alt AssemblyDef.Version: ' + $m.Assembly.Version)
    $m.Assembly.Version = $newVer

    $hasVersionAttr = $false
    foreach ($ca in $m.Assembly.CustomAttributes) {
        if ($ca.TypeFullName -match 'AssemblyFileVersionAttribute') {
            Write-Output ('Alt AssemblyFileVersionAttribute: ' + $ca.ConstructorArguments[0].Value)
            $ca.ConstructorArguments[0].Value = [dnlib.DotNet.UTF8String]$newVersion
            $hasVersionAttr = $true
        }
        if ($ca.TypeFullName -match 'AssemblyVersionAttribute') {
            Write-Output ('Alt AssemblyVersionAttribute: ' + $ca.ConstructorArguments[0].Value)
            $ca.ConstructorArguments[0].Value = [dnlib.DotNet.UTF8String]$newVersion
            $hasVersionAttr = $true
        }
    }
    if (-not $hasVersionAttr) {
        Write-Output 'Hinweis: Kein AssemblyFile/AssemblyVersionAttribute vorhanden (nur AssemblyDef.Version wird gesetzt).'
    }

    $m.Write($tmp)
} finally {
    $m.Dispose()
}
Write-Output "dnlib geschrieben: $tmp"

# --- 3) VERSIONINFO-Ressource byte-patchen (ASCII + UTF-16LE) ------------
$bytes = [System.IO.File]::ReadAllBytes($tmp)
$asciiOld = [System.Text.Encoding]::ASCII.GetBytes($oldVersion)
$asciiNew = [System.Text.Encoding]::ASCII.GetBytes($newVersion)
$utf16Old = [System.Text.Encoding]::Unicode.GetBytes($oldVersion)
$utf16New = [System.Text.Encoding]::Unicode.GetBytes($newVersion)

function Replace-All($data, $old, $new) {
    $count = 0
    for ($i = 0; $i -le $data.Length - $old.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $old.Length; $j++) {
            if ($data[$i + $j] -ne $old[$j]) { $match = $false; break }
        }
        if ($match) {
            for ($j = 0; $j -lt $new.Length; $j++) { $data[$i + $j] = $new[$j] }
            $count++
            $i += $old.Length - 1
        }
    }
    return $count
}

$c1 = Replace-All $bytes $asciiOld $asciiNew
$c2 = Replace-All $bytes $utf16Old $utf16New
Write-Output ("VERSIONINFO-Patches: ASCII=$c1 UTF16=$c2")
if ($c1 -eq 0 -and $c2 -eq 0) {
    Write-Output 'Hinweis: Keine alte Version in der VERSIONINFO-Ressource gefunden (evtl. schon gepatcht).'
}
[System.IO.File]::WriteAllBytes($tmp, $bytes)

# --- 4) Verifizieren ------------------------------------------------------
$fi = [Diagnostics.FileVersionInfo]::GetVersionInfo($tmp)
$a  = [Reflection.AssemblyName]::GetAssemblyName($tmp)
Write-Output ('NEU FileVersion: ' + $fi.FileVersion + ' | ProductVersion: ' + $fi.ProductVersion)
Write-Output ('NEU AssemblyVersion: ' + $a.Version)

if ($Apply) {
    Copy-Item $tmp $exe -Force
    Remove-Item $tmp -Force
    Write-Output "Angewendet auf: $exe"
} else {
    Write-Output ''
    Write-Output "Ergebnis: $tmp"
    Write-Output 'Danach: EXE selbst ersetzen, committen+pushen, DANN taggen. (oder -Apply verwenden)'
}
Write-Output 'Fertig.'
