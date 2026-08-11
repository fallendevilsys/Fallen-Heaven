#!/usr/bin/env bash
# =====================================================================
# validate_release.sh — validiert ein veroeffentlichtes Update
#
# Aufruf:
#   bash tools/validate_release.sh <VERSION> [<GITHUB_REPO>]
#
# Beispiel:
#   bash tools/validate_release.sh 6.2.0 fallendevilsys/Fallen-Heaven
#
# Prueft:
#   1. GitHub-Release + ZIP-Asset existieren
#   2. Update-Manifest (GitHub Pages) ist erreichbar
#   3. Manifest-Version passt zur lokalen EXE-Version
#   4. SHA-256 + Groesse des ZIP stimmen mit dem Manifest ueberein
#      (und mit dem Digest, den GitHub selbst angibt)
#   5. Die Entry-Executable (die die App sucht) liegt im ZIP
#
# Exit-Code 0 = alles OK, 1 = mindestens eine Pruefung fehlgeschlagen.
# =====================================================================
set -euo pipefail

VERSION="${1:?Verwendung: validate_release.sh <VERSION> [<GITHUB_REPO>]}"
REPO="${2:-fallendevilsys/Fallen-Heaven}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"
TAG="v${VERSION}"
ASSET="fallen-heaven-${VERSION}.zip"
ASSET_URL="https://github.com/${REPO}/releases/download/${TAG}/${ASSET}"
MANIFEST_URL="https://${OWNER}.github.io/${NAME}/update-manifest.json"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

report() { # ok|bad, text...
  if [ "$1" = "ok" ]; then
    echo "  [ OK ] ${*:2}"
    PASS=$((PASS+1))
  else
    echo "  [FEHLER] ${*:2}"
    FAIL=$((FAIL+1))
  fi
}

# --- JSON-Feld lesen (via PowerShell, Windows-sicher) ---
json_get() { # datei, eigenschaft
  local win
  win="$(cygpath -w "$1" 2>/dev/null || echo "$1")"
  powershell -NoProfile -Command \
    "Get-Content -Raw '$win' | ConvertFrom-Json | Select-Object -ExpandProperty $2" 2>/dev/null \
    || true
}

# --- Version normalisieren (6.2.0 == 6.2.0.0) ---
norm_version() {
  echo "$1" | sed -E 's/(\.0)+$//'
}

echo "== Validiere Release ${TAG} (${REPO}) =="

# ---------------------------------------------------------------------
# 1) GitHub-Release + ZIP-Asset
# ---------------------------------------------------------------------
echo "--- 1. GitHub-Release ---"
RELEASE_JSON="${TMP}/release.json"
if curl -sfSL "https://api.github.com/repos/${REPO}/releases/tags/${TAG}" -o "$RELEASE_JSON"; then
  report ok "Release ${TAG} existiert"
  if grep -q "$ASSET" "$RELEASE_JSON"; then
    report ok "ZIP-Asset '${ASSET}' ist im Release vorhanden"
  else
    report bad "ZIP-Asset '${ASSET}' fehlt im Release"
  fi
else
  report bad "Release ${TAG} nicht gefunden (404)"
fi

# ---------------------------------------------------------------------
# 2) Update-Manifest (GitHub Pages)
# ---------------------------------------------------------------------
echo "--- 2. Update-Manifest ---"
MANIFEST_JSON="${TMP}/manifest.json"
if curl -sfSL "$MANIFEST_URL" -o "$MANIFEST_JSON"; then
  report ok "Manifest erreichbar: ${MANIFEST_URL}"
else
  report bad "Manifest nicht erreichbar: ${MANIFEST_URL}"
fi

# ---------------------------------------------------------------------
# 3) Versions-Konsistenz
# ---------------------------------------------------------------------
echo "--- 3. Versions-Konsistenz ---"
MANIFEST_VERSION="$(json_get "$MANIFEST_JSON" "version")"
MANIFEST_EXPECTED="$(json_get "$MANIFEST_JSON" "expectedVersion")"
MANIFEST_ENTRY="$(json_get "$MANIFEST_JSON" "entryExecutable")"

EXE="Fallen-Heaven Discord App.exe"
if [ ! -f "$EXE" ]; then
  EXE="$(ls *.exe 2>/dev/null | head -1 || true)"
fi

if [ -n "${EXE:-}" ] && [ -f "$EXE" ]; then
  export FH_EXE="$EXE"
  EXE_VERSION="$(powershell -NoProfile -Command \
    "[Diagnostics.FileVersionInfo]::GetVersionInfo(\$env:FH_EXE).FileVersion" | tr -d '[:space:]')"
  if [ -n "$MANIFEST_VERSION" ] && [ -n "$EXE_VERSION" ]; then
    if [ "$(norm_version "$MANIFEST_VERSION")" = "$(norm_version "$EXE_VERSION")" ]; then
      report ok "Manifest-Version ${MANIFEST_VERSION} == EXE-Version ${EXE_VERSION}"
    else
      report bad "Manifest-Version ${MANIFEST_VERSION} != EXE-Version ${EXE_VERSION} (App wuerde das Update ablehnen)"
    fi
  else
    report bad "Manifest- oder EXE-Version nicht lesbar"
  fi
else
  report bad "Keine EXE im Projektstamm gefunden - Versionscheck uebersprungen"
fi

if [ -n "$MANIFEST_VERSION" ] && [ "$MANIFEST_VERSION" = "$MANIFEST_EXPECTED" ]; then
  report ok "expectedVersion entspricht version"
else
  report bad "expectedVersion (${MANIFEST_EXPECTED}) != version (${MANIFEST_VERSION})"
fi

# ---------------------------------------------------------------------
# 4) ZIP: Download + SHA-256 + Groesse
# ---------------------------------------------------------------------
echo "--- 4. ZIP-Integritaet ---"
PKG="${TMP}/pkg.zip"
if curl -sfSL -o "$PKG" "$ASSET_URL"; then
  report ok "ZIP heruntergeladen: ${ASSET_URL}"
else
  report bad "ZIP nicht ladbar: ${ASSET_URL}"
fi

if [ -s "$PKG" ]; then
  SHA="$(sha256sum "$PKG" | awk '{print $1}')"
  SIZE="$(stat -c %s "$PKG" 2>/dev/null || wc -c < "$PKG" | tr -d ' ')"
  MANIFEST_SHA="$(json_get "$MANIFEST_JSON" "sha256")"
  MANIFEST_SIZE="$(json_get "$MANIFEST_JSON" "packageSize")"

  if [ -n "$MANIFEST_SHA" ] && [ "$SHA" = "$MANIFEST_SHA" ]; then
    report ok "SHA-256 stimmt: ${SHA}"
  else
    report bad "SHA-256 weicht ab (Manifest: ${MANIFEST_SHA}, ZIP: ${SHA})"
  fi

  if [ -n "$MANIFEST_SIZE" ] && [ "$SIZE" = "$MANIFEST_SIZE" ]; then
    report ok "Groesse stimmt: ${SIZE} Bytes"
  else
    report bad "Groesse weicht ab (Manifest: ${MANIFEST_SIZE}, ZIP: ${SIZE})"
  fi

  GH_DIGEST="$(grep -o '"digest": *"sha256:[a-f0-9]*"' "$RELEASE_JSON" 2>/dev/null \
    | head -1 | sed -E 's/.*sha256:([a-f0-9]*).*/\1/')"
  if [ -n "$GH_DIGEST" ]; then
    if [ "$GH_DIGEST" = "$MANIFEST_SHA" ]; then
      report ok "GitHub-eigener Digest passt ebenfalls"
    else
      report bad "GitHub-Digest ${GH_DIGEST} != Manifest ${MANIFEST_SHA}"
    fi
  fi
fi

# ---------------------------------------------------------------------
# 5) Entry-Executable im ZIP
# ---------------------------------------------------------------------
echo "--- 5. Entry-Executable ---"
if [ -s "$PKG" ] && [ -n "$MANIFEST_ENTRY" ]; then
  PKG_WIN="$(cygpath -w "$PKG" 2>/dev/null || echo "$PKG")"
  if powershell -NoProfile -Command \
    "Add-Type -AssemblyName System.IO.Compression.FileSystem; \
     \$z=[System.IO.Compression.ZipFile]::OpenRead('${PKG_WIN}'); \
     \$found=(\$z.Entries.FullName -contains '${MANIFEST_ENTRY}'); \
     \$z.Dispose(); if (\$found) { exit 0 } else { exit 1 }" >/dev/null 2>&1; then
    report ok "Entry-Executable '${MANIFEST_ENTRY}' liegt im ZIP"
  else
    report bad "Entry-Executable '${MANIFEST_ENTRY}' fehlt im ZIP"
  fi
fi

# ---------------------------------------------------------------------
# Ergebnis
# ---------------------------------------------------------------------
echo
echo "== Ergebnis: ${PASS} OK, ${FAIL} Fehler =="
if [ "$FAIL" -eq 0 ]; then
  echo "== ALLES OK - das Update ist gueltig =="
  exit 0
else
  echo "== Es gibt Probleme - Release NICHT veroeffentlichen =="
  exit 1
fi
