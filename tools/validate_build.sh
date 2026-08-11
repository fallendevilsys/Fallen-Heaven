#!/usr/bin/env bash
# =====================================================================
# validate_build.sh — Selbstcheck direkt nach dem Release-Build
#
# Aufruf:
#   bash tools/validate_build.sh <VERSION> [<GITHUB_REPO>]
#
# Beispiel (im Workflow):
#   bash tools/validate_build.sh 6.2.0 fallendevilsys/Fallen-Heaven
#
# Wird nach dem Bauen UND nach dem Hochladen des Releases ausgefuehrt.
# Im Gegensatz zu validate_release.sh braucht es KEIN GitHub Pages
# (Pages baut erst nach dem Lauf) — es prueft die frisch gebauten
# Artefakte direkt im Runner:
#
#   1. ZIP + Manifest existieren
#   2. Manifest-Version passt zum Tag UND zur EXE-Version
#   3. SHA-256 + Groesse des ZIP stimmen mit dem Manifest ueberein
#   4. Entry-Executable (die die App sucht) liegt im ZIP
#   5. GitHub-Check (nur wenn GH_TOKEN gesetzt, z. B. im Workflow):
#      Release + Asset existieren, GitHub-Digest == lokaler SHA-256
#
# Exit-Code 0 = alles OK, 1 = mindestens eine Pruefung fehlgeschlagen.
# Wenn dieser Schritt im Workflow rot wird, ist das Update kaputt und
# darf NICHT veroeffentlicht werden.
# =====================================================================
set -euo pipefail

VERSION="${1:?Verwendung: validate_build.sh <VERSION> [<GITHUB_REPO>]}"
REPO="${2:-fallendevilsys/Fallen-Heaven}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TAG="v${VERSION}"
ASSET="fallen-heaven-${VERSION}.zip"
ZIP_PATH="release/${ASSET}"
MANIFEST_PATH="docs/update-manifest.json"

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

echo "== Selbstcheck fuer Release ${TAG} (${REPO}) =="

# ---------------------------------------------------------------------
# 1) ZIP + Manifest vorhanden
# ---------------------------------------------------------------------
echo "--- 1. Artefakte ---"
if [ -s "$ZIP_PATH" ]; then
  report ok "ZIP vorhanden: ${ZIP_PATH}"
else
  report bad "ZIP fehlt: ${ZIP_PATH}"
fi

if [ -s "$MANIFEST_PATH" ]; then
  report ok "Manifest vorhanden: ${MANIFEST_PATH}"
else
  report bad "Manifest fehlt: ${MANIFEST_PATH}"
fi

if [ ! -s "$ZIP_PATH" ] || [ ! -s "$MANIFEST_PATH" ]; then
  echo
  echo "== Ergebnis: ${PASS} OK, ${FAIL} Fehler =="
  exit 1
fi

# ---------------------------------------------------------------------
# 2) Versions-Konsistenz (Tag / Manifest / EXE)
# ---------------------------------------------------------------------
echo "--- 2. Versions-Konsistenz ---"
MANIFEST_VERSION="$(json_get "$MANIFEST_PATH" "version")"
MANIFEST_EXPECTED="$(json_get "$MANIFEST_PATH" "expectedVersion")"
MANIFEST_ENTRY="$(json_get "$MANIFEST_PATH" "entryExecutable")"

if [ -n "$MANIFEST_VERSION" ] && [ "$(norm_version "$MANIFEST_VERSION")" = "$(norm_version "$VERSION")" ]; then
  report ok "Manifest-Version ${MANIFEST_VERSION} == Tag-Version ${VERSION}"
else
  report bad "Manifest-Version (${MANIFEST_VERSION}) != Tag-Version (${VERSION})"
fi

if [ -n "$MANIFEST_VERSION" ] && [ "$MANIFEST_VERSION" = "$MANIFEST_EXPECTED" ]; then
  report ok "expectedVersion entspricht version"
else
  report bad "expectedVersion (${MANIFEST_EXPECTED}) != version (${MANIFEST_VERSION})"
fi

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
      report bad "Manifest-Version ${MANIFEST_VERSION} != EXE-Version ${EXE_VERSION}"
    fi
  else
    report bad "Manifest- oder EXE-Version nicht lesbar"
  fi
else
  report bad "Keine EXE im Projektstamm gefunden - Versionscheck uebersprungen"
fi

# ---------------------------------------------------------------------
# 3) SHA-256 + Groesse des ZIP gegen das Manifest
# ---------------------------------------------------------------------
echo "--- 3. ZIP-Integritaet ---"
SHA="$(sha256sum "$ZIP_PATH" | awk '{print $1}')"
SIZE="$(stat -c %s "$ZIP_PATH" 2>/dev/null || wc -c < "$ZIP_PATH" | tr -d ' ')"
MANIFEST_SHA="$(json_get "$MANIFEST_PATH" "sha256")"
MANIFEST_SIZE="$(json_get "$MANIFEST_PATH" "packageSize")"

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

# ---------------------------------------------------------------------
# 4) Entry-Executable im ZIP
# ---------------------------------------------------------------------
echo "--- 4. Entry-Executable ---"
if [ -n "$MANIFEST_ENTRY" ]; then
  ZIP_WIN="$(cygpath -w "$ZIP_PATH" 2>/dev/null || echo "$ZIP_PATH")"
  if powershell -NoProfile -Command \
    "Add-Type -AssemblyName System.IO.Compression.FileSystem; \
     \$z=[System.IO.Compression.ZipFile]::OpenRead('${ZIP_WIN}'); \
     \$found=(\$z.Entries.FullName -contains '${MANIFEST_ENTRY}'); \
     \$z.Dispose(); if (\$found) { exit 0 } else { exit 1 }" >/dev/null 2>&1; then
    report ok "Entry-Executable '${MANIFEST_ENTRY}' liegt im ZIP"
  else
    report bad "Entry-Executable '${MANIFEST_ENTRY}' fehlt im ZIP"
  fi
else
  report bad "Kein entryExecutable im Manifest"
fi

# ---------------------------------------------------------------------
# 5) GitHub-Check (nur im Workflow, wenn GH_TOKEN gesetzt ist)
# ---------------------------------------------------------------------
if [ -n "${GH_TOKEN:-}" ]; then
  echo "--- 5. GitHub-Release ---"
  RELEASE_JSON="$(curl -sfSL -H "Authorization: Bearer ${GH_TOKEN}" \
    "https://api.github.com/repos/${REPO}/releases/tags/${TAG}")" || RELEASE_JSON=""
  if [ -n "$RELEASE_JSON" ]; then
    report ok "Release ${TAG} existiert auf GitHub"
    if echo "$RELEASE_JSON" | grep -q "$ASSET"; then
      report ok "ZIP-Asset '${ASSET}' ist im Release hochgeladen"
    else
      report bad "ZIP-Asset '${ASSET}' fehlt im Release"
    fi
    GH_DIGEST="$(echo "$RELEASE_JSON" | grep -o '"digest": *"sha256:[a-f0-9]*"' \
      | head -1 | sed -E 's/.*sha256:([a-f0-9]*).*/\1/')"
    if [ -n "$GH_DIGEST" ]; then
      if [ "$GH_DIGEST" = "$SHA" ]; then
        report ok "GitHub-eigener Digest passt zum lokalen SHA-256"
      else
        report bad "GitHub-Digest ${GH_DIGEST} != lokaler SHA-256 ${SHA}"
      fi
    else
      report bad "Kein Digest fuer das Asset in der GitHub-API gefunden"
    fi
  else
    report bad "Release ${TAG} auf GitHub nicht gefunden (404)"
  fi
else
  echo "--- 5. GitHub-Release ---"
  echo "  (uebersprungen - GH_TOKEN nur im Workflow gesetzt)"
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
