#!/usr/bin/env bash
# =====================================================================
# make_release.sh — baut Release-ZIP + Update-Manifest
#
# Aufruf:
#   bash tools/make_release.sh <VERSION> [<GITHUB_REPO>]
#
# Beispiele:
#   bash tools/make_release.sh 6.3.0 fallendevilsys/Fallen-Heaven
#   bash tools/make_release.sh 6.3.0            (ohne Repo -> packageUrl leer)
#
# Erzeugt:
#   release/fallen-heaven-<VERSION>.zip   - das Update-Paket
#   docs/update-manifest.json             - Manifest für GitHub Pages
#   release/update-manifest.json          - identische Kopie
#
# Manifest-Felder (aus der App-EXE ermittelt):
#   version, expectedVersion, packageUrl, packageSize, sha256,
#   createdUtc, releaseNotes, signature (leer, solange kein Key hinterlegt)
# =====================================================================
set -euo pipefail

VERSION="${1:?Verwendung: make_release.sh <VERSION> [<GITHUB_REPO>]}"
REPO="${2:-}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RELEASE_DIR="release"
STAGE_DIR="${RELEASE_DIR}/stage"
ZIP_NAME="fallen-heaven-${VERSION}.zip"
ZIP_PATH="${RELEASE_DIR}/${ZIP_NAME}"
TAG="v${VERSION}"

mkdir -p "$RELEASE_DIR" docs

# ---------------------------------------------------------------------
# 1) Dateien in einen Staging-Ordner legen (nur was ins Paket gehört)
# ---------------------------------------------------------------------
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

for f in \
  "Fallen-Heaven Discord App.exe" \
  "FH.YoutubeResolver.dll" \
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

if [ -z "$(ls -A "$STAGE_DIR")" ]; then
  echo "FEHLER: Keine App-Dateien im Projektstamm gefunden." >&2
  exit 1
fi

# ---------------------------------------------------------------------
# 2) ZIP erstellen (Fallback-Kette: zip -> bsdtar -> PowerShell)
# ---------------------------------------------------------------------
rm -f "$ZIP_PATH"

make_zip() {
  if command -v zip >/dev/null 2>&1; then
    (cd "$STAGE_DIR" && zip -q -X -r "../${ZIP_NAME}" .)
  elif command -v bsdtar >/dev/null 2>&1; then
    (cd "$STAGE_DIR" && bsdtar -a -cf "../${ZIP_NAME}" .)
  elif command -v powershell >/dev/null 2>&1; then
    local win_stage win_zip
    win_stage="$(cd "$STAGE_DIR" && pwd -W 2>/dev/null || cygpath -w "$PWD")"
    win_zip="$(cd "$RELEASE_DIR" && pwd -W 2>/dev/null || cygpath -w "$PWD")/${ZIP_NAME}"
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
# 3) SHA-256 + Groesse berechnen
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
# 4) Update-Manifest schreiben
# ---------------------------------------------------------------------
write_manifest() {
  cat > "$1" <<EOF
{
  "version": "${VERSION}",
  "expectedVersion": "${VERSION}",
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
