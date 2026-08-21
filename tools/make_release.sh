#!/usr/bin/env bash
# =====================================================================
# make_release.sh â€” baut Windows-Installer + Update-Manifest
#
# Aufruf:
#   bash tools/make_release.sh <VERSION> [<GITHUB_REPO>]
#
# Beispiele:
#   bash tools/make_release.sh 6.3.5 fallendevilsys/Fallen-Heaven
#   bash tools/make_release.sh 6.3.5            (ohne Repo -> packageUrl leer)
#
# WICHTIG (Versions-Guard):
#   Die App lehnt ein Update ab, wenn die Version im Manifest nicht zur
#   Version der EXE im Paket passt. Deshalb:
#     - Die Version wird IMMER aus der EXE-Datei ausgelesen (FileVersion).
#     - Passt die uebergebene VERSION nicht zur EXE-Version, bricht das
#       Skript mit einer klaren Meldung ab (Exit-Code 1).
#   -> Vor dem Taggen immer die NEUE EXE/DLL committen und pushen!
#
# Erzeugt:
#   release/Fallen-Heaven-Setup-<VERSION>.exe  - das Update-Paket (Installer)
#   docs/update-manifest.json                  - Manifest fÃ¼r GitHub Pages
#   release/update-manifest.json               - identische Kopie
#
# Manifest-Felder (aus der App-EXE ermittelt):
#   version, expectedVersion, entryExecutable, packageUrl, packageSize,
#   sha256, createdUtc, releaseNotes, signature (leer ohne Signatur-Key)
#
# Der Installer installiert die App per-Nutzer (keine Admin-Rechte), ueber-
# schreibt nie eine vorhandene Nutzer-Config und startet die App nach einem
# Update automatisch neu (Flag /RESTARTAPP=1 des stillen Update-Aufrufs).
# =====================================================================
set -euo pipefail

VERSION="${1:-}"
REPO="${2:-}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RELEASE_DIR="release"
TAG="v${VERSION}"

# ---------------------------------------------------------------------
# 1) Haupt-EXE finden
# ---------------------------------------------------------------------
EXE="Fallen-Heaven Discord App.exe"
if [ ! -f "$EXE" ]; then
  EXE="$(ls *.exe 2>/dev/null | head -1 || true)"
fi
if [ -z "${EXE:-}" ] || [ ! -f "$EXE" ]; then
  echo "FEHLER: Keine App-EXE im Projektstamm gefunden." >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 2) EXE-Infos auslesen (FileVersion + Assembly-Name, via PowerShell)
# ---------------------------------------------------------------------
export FH_EXE="$EXE"
EXE_INFO="$(powershell -NoProfile -Command \
  "\$i=[Diagnostics.FileVersionInfo]::GetVersionInfo(\$env:FH_EXE); \
   \$a=[Reflection.AssemblyName]::GetAssemblyName(\$env:FH_EXE); \
   Write-Output \$i.FileVersion; Write-Output \$a.Name")"

EXE_VERSION="$(echo "$EXE_INFO" | sed -n '1p' | tr -d '[:space:]')"
ASSEMBLY_NAME="$(echo "$EXE_INFO" | sed -n '2p' | tr -d '[:space:]')"
# entryExecutable muss der Dateiname der tatsaechlich installierten EXE
# sein (z. B. "Fallen-Heaven Discord App.exe").
ENTRY_EXE="${EXE}"

if [ -z "$EXE_VERSION" ] || [ -z "$ASSEMBLY_NAME" ]; then
  echo "FEHLER: EXE-Infos konnten nicht ausgelesen werden ($EXE)." >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 3) Versions-Guard: Tag-Version muss zur EXE-Version passen
#    (6.3.5 == 6.3.5.0, fuehrende Nullen ignoriert)
# ---------------------------------------------------------------------
norm_version() {
  echo "$1" | sed -E 's/(\.0)+$//'
}

if [ -n "$VERSION" ]; then
  if [ "$(norm_version "$VERSION")" != "$(norm_version "$EXE_VERSION")" ]; then
    echo "FEHLER: Tag-Version '${VERSION}' passt nicht zur EXE-Version '${EXE_VERSION}'." >&2
    echo "  Die App wuerde das Update ablehnen." >&2
    echo "  Loesung: Neue EXE/DLL mit Version ${VERSION} in den Projektordner legen," >&2
    echo "           committen+pushen, DANN taggen." >&2
    exit 1
  fi
else
  VERSION="$EXE_VERSION"
  TAG="v${VERSION}"
fi

SETUP_NAME="Fallen-Heaven-Setup-${VERSION}.exe"
SETUP_PATH="${RELEASE_DIR}/${SETUP_NAME}"
mkdir -p "$RELEASE_DIR" docs

echo "EXE           : ${EXE} (Version ${EXE_VERSION})"
echo "Entry-EXE     : ${ENTRY_EXE}"
echo "Update-Paket  : ${SETUP_NAME} (Windows-Installer)"

# ---------------------------------------------------------------------
# 4) Windows-Installer bauen (Inno Setup, portabel in tools/inno)
#    Der Installer enthaelt EXE + lib + Bilder + READMEs + Lizenz.
#    Vorhandene Nutzer-Configs bleiben erhalten (onlyifdoesntexist).
# ---------------------------------------------------------------------
if [ ! -f "tools/inno/ISCC.exe" ]; then
  echo "FEHLER: tools/inno/ISCC.exe fehlt - Installer kann nicht gebaut werden." >&2
  exit 1
fi

MSYS_NO_PATHCONV=1 tools/inno/ISCC.exe tools/installer/installer.iss >/dev/null
# ISCC benennt die Datei nach der FileVersion der EXE (z. B. ...-6.3.5.0.exe).
# Fuer einheitliche GitHub-Assets auf die Tag-Version umbenennen.
BUILT_SETUP="$(ls -t release/Fallen-Heaven-Setup-*.exe 2>/dev/null | head -1 || true)"
if [ -z "$BUILT_SETUP" ] || [ ! -s "$BUILT_SETUP" ]; then
  echo "FEHLER: Installer wurde nicht erzeugt." >&2
  exit 1
fi
if [ "$(basename "$BUILT_SETUP")" != "$SETUP_NAME" ]; then
  mv -f "$BUILT_SETUP" "$SETUP_PATH"
fi

if [ ! -s "$SETUP_PATH" ]; then
  echo "FEHLER: Installer fehlt: $SETUP_PATH" >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 5) SHA-256 + Groesse des Installers berechnen
# ---------------------------------------------------------------------
SHA256="$(sha256sum "$SETUP_PATH" | awk '{print $1}')"
PACKAGE_SIZE="$(stat -c %s "$SETUP_PATH" 2>/dev/null || wc -c < "$SETUP_PATH" | tr -d ' ')"
CREATED_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
NOTES="Automatisch erstellt aus Tag ${TAG}."

if [ -n "$REPO" ]; then
  PACKAGE_URL="https://github.com/${REPO}/releases/download/${TAG}/${SETUP_NAME}"
else
  PACKAGE_URL=""
fi

# ---------------------------------------------------------------------
# 5b) Signatur berechnen (RSA-SHA256, Base64) - nur wenn Private-Key
#     verfuegbar ist. Ohne Key bleibt "signature" leer (unsigniertes
#     Manifest fuer den gestuften Signatur-Rollout).
# ---------------------------------------------------------------------
SIGNATURE=""
if [ -n "${FH_UPDATE_PRIVATE_KEY:-}" ] || [ -f "keys/private.xml" ]; then
  SIGNATURE="$(powershell -NoProfile -ExecutionPolicy Bypass -File tools/sign_manifest.ps1 \
    -Version "${EXE_VERSION}" -PackageUrl "${PACKAGE_URL}" \
    -Sha256 "${SHA256}" -EntryExecutable "${ENTRY_EXE}")"
  SIGNATURE="$(echo "$SIGNATURE" | tr -d '[:space:]')"
  echo "Signatur       : vorhanden (${#SIGNATURE} Zeichen)"
else
  echo "Signatur       : leer (kein Private-Key -> unsigniertes Manifest)"
fi

# ---------------------------------------------------------------------
# 6) Update-Manifest schreiben
# ---------------------------------------------------------------------
write_manifest() {
  cat > "$1" <<EOF
{
  "version": "${EXE_VERSION}",
  "expectedVersion": "${EXE_VERSION}",
  "entryExecutable": "${ENTRY_EXE}",
  "packageUrl": "${PACKAGE_URL}",
  "packageSize": ${PACKAGE_SIZE},
  "sha256": "${SHA256}",
  "createdUtc": "${CREATED_UTC}",
  "releaseNotes": "${NOTES}",
  "signature": "${SIGNATURE}"
}
EOF
}

write_manifest "docs/update-manifest.json"
write_manifest "${RELEASE_DIR}/update-manifest.json"

echo "===================================================================="
echo " Update-Paket : ${SETUP_PATH}  (${PACKAGE_SIZE} Bytes)"
echo " SHA-256      : ${SHA256}"
echo " Manifest     : docs/update-manifest.json"
echo " Package-URL  : ${PACKAGE_URL}"
echo "===================================================================="
