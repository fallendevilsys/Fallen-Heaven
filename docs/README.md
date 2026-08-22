# Dokumentation & Update-Manifest

Dieser Ordner enthält die **Dokumentation** und den **GitHub-Pages-Host für das Update-Manifest** der App.

## Dokumentation

- `UPDATE-SETUP.txt` — Anleitung zum Einrichten der automatischen Updates
- `SIGNING.md` — Informationen zur Code-Signierung (für Entwickler)

## Update-Manifest

- `update-manifest.json` wird bei jedem Release automatisch von
  `tools/make_release.sh` hierher geschrieben (und nach `release/`).
- Bei einem Release **committen und pushen**, dann liefert GitHub Pages
  das Manifest unter:

  `https://<DEINUSERNAME>.github.io/<REPO>/update-manifest.json`

  (Repo → Settings → Pages → „Deploy from a branch" → `main` → `/docs`)

Die App liest das Manifest automatisch beim Start — keine manuelle Konfiguration nötig.
Siehe `UPDATE-SETUP.txt` für Details.
