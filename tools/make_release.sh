#!/usr/bin/env bash
# =====================================================================
# make_release.sh — baut Release-ZIP + Update-Manifest
#
# Aufruf:
#   bash tools/make_release.sh <VERSION> [<GITHUB_REPO>]
#
# Beispiele:
#   bash tools/make_release.sh 6.2.0 fallendevilsys/Fallen-Heaven
#   bash tools/make_release.sh 6.2.0            (ohne Repo -> packageUrl leer)
#
# WICHTIG (Versions-Guard):
#   Die App lehnt ein Update ab, wenn die Version im Manifest nicht zur
#   Version der EXE im Paket passt ("The update entry executable is
#   invalid"). Deshalb:
#     - Die Version wird IMMER aus der EXE-Datei ausgelesen (FileVersion).
#     - Passt die uebergebene VERSION nicht zur EXE-Version, bricht das
#       Skript mit einer klaren Meldung ab (Exit-Code 1).
#   -> Vor dem Taggen immer die NEUE EXE/DLL committen und pushen!
#
# Erzeugt:
#   release/fallen-heaven-<VERSION>.zip   - das Update-Paket
#   docs/update-manifest.json             - Manifest für GitHub Pages
#   release/update-manifest.json          - identische Kopie
#
# Manifest-Felder (aus der App-EXE ermittelt):
#   version, expectedVersion, entryExecutable, packageUrl, packageSize,
#   sha256, createdUtc, releaseNotes, signature (leer ohne Signatur-Key)
# =====================================================================
set -euo pipefail

VERSION="${1:-}"
REPO="${2:-}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RELEASE_DIR="release"
STAGE_DIR="${RELEASE_DIR}/stage"
ZIP_NAME="fallen-heaven-${VERSION}.zip"
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
# WICHTIG: entryExecutable muss der Dateiname der tatsaechlich installierten
# EXE sein (z. B. "Fallen-Heaven Discord App.exe") - NICHT der interne
# Assembly-Name. Der Update-Helper validiert, dass im Zielordner eine Datei
# mit diesem Namen existiert ("The installed app was not found.").
# Die installierte App heisst aber wie der Anzeigename der EXE-Datei.
ENTRY_EXE="${EXE}"

if [ -z "$EXE_VERSION" ] || [ -z "$ASSEMBLY_NAME" ]; then
  echo "FEHLER: EXE-Infos konnten nicht ausgelesen werden ($EXE)." >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 3) Versions-Guard: Tag-Version muss zur EXE-Version passen
#    (6.2.0 == 6.2.0.0, fuehrende Nullen ignoriert)
# ---------------------------------------------------------------------
norm_version() {
  echo "$1" | sed -E 's/(\.0)+$//'
}

if [ -n "$VERSION" ]; then
  if [ "$(norm_version "$VERSION")" != "$(norm_version "$EXE_VERSION")" ]; then
    echo "FEHLER: Tag-Version '${VERSION}' passt nicht zur EXE-Version '${EXE_VERSION}'." >&2
    echo "  Die App wuerde das Update ablehnen (\"The update entry executable is invalid\")." >&2
    echo "  Loesung: Neue EXE/DLL mit Version ${VERSION} in den Projektordner legen," >&2
    echo "           committen+pushen, DANN taggen." >&2
    exit 1
  fi
else
  VERSION="$EXE_VERSION"
  ZIP_NAME="fallen-heaven-${VERSION}.zip"
  TAG="v${VERSION}"
fi

ZIP_PATH="${RELEASE_DIR}/${ZIP_NAME}"
mkdir -p "$RELEASE_DIR" docs

echo "EXE           : ${EXE} (Version ${EXE_VERSION})"
echo "Entry-EXE     : ${ENTRY_EXE}"

# ---------------------------------------------------------------------
# 4) Dateien in einen Staging-Ordner legen (nur was ins Paket gehört)
# ---------------------------------------------------------------------
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

for f in \
  "$EXE" \
  "FH.YoutubeResolver.dll" \
  "FH.SpotifyResolver.dll" \
  "Fallen-Heaven Launcher.exe" \
  "fh-app.ico" \
  "fh-ui-logo.png" \
  "fh_logo.png" \
  "README.md" \
  "LICENSE.md"
do
  [ -f "$f" ] && cp "$f" "$STAGE_DIR/"
done


# app-config.json als Vorlage "app-config.example.json" beilegen
[ -f "app-config.json" ] && cp "app-config.json" "$STAGE_DIR/app-config.example.json"

# app-config.json MIT ins Paket nehmen: Der Update-Helper startet aus dem
# Staging-Ordner und braucht die Config dort (AppStorage.Initialize), sonst
# crasht er beim Start und das Update wird nie installiert.
# Beim Installieren wird app-config.json NICHT ueberschrieben (ShouldPreserve),
# der Nutzer behaelt also seine eigene Config.
[ -f "app-config.json" ] && cp "app-config.json" "$STAGE_DIR/app-config.json"

if [ -z "$(ls -A "$STAGE_DIR")" ]; then
  echo "FEHLER: Keine App-Dateien im Projektstamm gefunden." >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 5) ZIP erstellen (Fallback-Kette: zip -> bsdtar -> PowerShell)
# ---------------------------------------------------------------------
rm -f "$ZIP_PATH"

make_zip() {
  if command -v zip >/dev/null 2>&1; then
    (cd "$STAGE_DIR" && zip -q -X -r "../${ZIP_NAME}" .)
  elif command -v bsdtar >/dev/null 2>&1; then
    (cd "$STAGE_DIR" && bsdtar -a -cf "../${ZIP_NAME}" .)
  elif command -v powershell >/dev/null 2>&1; then
    local win_stage win_zip
    win_stage="$(cygpath -w "$PWD" 2>/dev/null || echo "$PWD")/${STAGE_DIR}"
    win_zip="$(cygpath -w "$PWD" 2>/dev/null || echo "$PWD")/${RELEASE_DIR}/${ZIP_NAME}"
    powershell -NoProfile -Command \
      "Compress-Archive -Path '${win_stage}\\*' -DestinationPath '${win_zip}' -Force"
  else
    echo "FEHLER: Kein ZIP-Werkzeug verfuegbar (zip, bsdtar oder powershell)." >&2
    exit 1
  fi
}

make_zip
rm -rf "$STAGE_DIR"

if [ ! -s "$ZIP_PATH" ]; then
  echo "FEHLER: ZIP konnte nicht erstellt werden: $ZIP_PATH" >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 6) SHA-256 + Groesse berechnen
# ---------------------------------------------------------------------
SHA256="$(sha256sum "$ZIP_PATH" | awk '{print $1}')"
PACKAGE_SIZE="$(stat -c %s "$ZIP_PATH" 2>/dev/null || wc -c < "$ZIP_PATH" | tr -d ' ')"
CREATED_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
NOTES="Automatisch erstellt aus Tag ${TAG}."

if [ -n "$REPO" ]; then
  PACKAGE_URL="https://github.com/${REPO}/releases/download/${TAG}/${ZIP_NAME}"
else
  PACKAGE_URL=""
fi

# ---------------------------------------------------------------------
# 7) Update-Manifest schreiben
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
  "signature": ""
}
EOF
}

write_manifest "docs/update-manifest.json"
write_manifest "${RELEASE_DIR}/update-manifest.json"

echo "================================================================"
echo " Release-ZIP  : ${ZIP_PATH}  (${PACKAGE_SIZE} Bytes)"
echo " SHA-256      : ${SHA256}"
echo " Manifest     : docs/update-manifest.json"
echo " Package-URL  : ${PACKAGE_URL}"
echo "================================================================"
