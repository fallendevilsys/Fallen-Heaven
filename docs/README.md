# Update-Manifest (GitHub Pages)

Dieser Ordner dient als **GitHub-Pages-Host für das Update-Manifest** der App.

- `update-manifest.json` wird bei jedem Release automatisch von
  `tools/make_release.sh` hierher geschrieben (und nach `release/`).
- Bei einem Release **committen und pushen**, dann liefert GitHub Pages
  das Manifest unter:

  `https://<DEINUSERNAME>.github.io/<REPO>/update-manifest.json`

  (Repo → Settings → Pages → „Deploy from a branch" → `main` → `/docs`)

- In `app-config.json` der Nutzer dann eintragen:

  `"updateManifestUrl": "https://<DEINUSERNAME>.github.io/<REPO>/update-manifest.json"`

Damit bekommt die App vollautomatische In-App-Updates (ZIP-Download,
SHA-256-Prüfung, sichere Installation, Neustart) — siehe
`UPDATE-SETUP.txt` Abschnitt 1 und 6.
