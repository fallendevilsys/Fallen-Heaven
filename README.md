# FALLEN HEAVEN — Discord Rich Presence

> „Wo gefallene Engel landen" — die portable Desktop-App, die deine Spiel-,
> YouTube- und Twitch-Aktivität automatisch als Discord-Rich-Presence
> anzeigt. Mit eigener Client ID, 6 Sprachen, Privacy-Modus und
> automatischen Updates.

![Version](https://img.shields.io/badge/Version-6.2.0-9665ff) ![Sprachen](https://img.shields.io/badge/Sprachen-6-blue) ![Lizenz](https://img.shields.io/badge/Lizenz-All%20Rights%20Reserved-black)

---

## Features

- 🎮 **Automatische Spiele-Erkennung** — offene Apps, Steam-Spiele und
  bekannte Browser werden automatisch erkannt (Brave, Chrome, Edge,
  Firefox, Opera, Vivaldi, Chromium) — inkl. passendem App-Icon.
- ▶️ **YouTube-Titel & Thumbnail** — erkennt das laufende Video im
  Browser und zeigt Titel + Kanalbild als Presence.
- 🔴 **Twitch-Erkennung** — erkennt Streams und zeigt den Kanal an.
- 👤 **Eigene Client ID** — binde die Presence an deinen eigenen
  Discord-Account (bis zu 2 Client IDs, mit Verbergen-Funktion für
  Datenschutz bei Bildschirmübertragung).
- 🔒 **Privacy-Modus** — sobald OBS, Streamlabs & Co. laufen, zeigt die
  App eine neutrale Presence statt des echten Fenstertitels.
- 🌍 **6 Sprachen** — English, Deutsch, Русский, Français, Español, العربية
  (inkl. RTL-Unterstützung für Arabisch).
- ✨ **Animierte Start-Intro** & moderne Glassmorphism-Oberfläche.
- 🚀 **Automatische Updates** — vollautomatisch über Manifest
  (GitHub Pages) oder GitHub-Releases-Fallback.
- 🛡️ **Stopp-Bestätigung** & Single-Instance-Schutz — kein versehentliches
  Beenden, kein doppeltes Fenster.

## Schnellstart

1. `Fallen-Heaven Discord App.exe` starten (portabel, keine Installation).
2. Einmalig eine **Application im [Discord Developer Portal](https://discord.com/developers/applications)**
   anlegen und deren **Client ID** in der App eintragen
   (Einstellungen → Client ID). Ohne eigene Application zeigt Discord
   keinen Rich-Presence-Status.
3. START drücken — die Presence erscheint in deinem Discord-Profil.

Ausführliche Anleitung: **[README.txt](README.txt)** (deutsch, inkl. aller
Einstellungsbereiche, Privacy-Modus und Update-Mechanik).

## Updates

Die App prüft beim Start automatisch auf neue Versionen:

- **`updateManifestUrl`** — vollautomatisches In-App-Update
  (ZIP + SHA-256-Prüfung + Neustart), z. B. über GitHub Pages.
- **`githubRepository`** — Fallback: Release-Erkennung über die
  GitHub-Releases-API, Download über die Release-Seite.

Alle Details zum Einrichten: **[UPDATE-SETUP.txt](UPDATE-SETUP.txt)**.
Release-ZIP + Manifest baut `tools/make_release.sh` in einem Schritt.

## Projektstruktur

| Datei | Zweck |
|-------|-------|
| `Fallen-Heaven Discord App.exe` | Die App (alle Features gepatcht) |
| `FH.YoutubeResolver.dll` | Laufzeit-DLL (YouTube-/Twitch-Erkennung) |
| `fh-app.ico`, `fh-ui-logo.png`, `fh_logo.png` | App-Assets |
| `app-config.json` | Wird als Vorlage (`app-config.example.json`) mitgeliefert, danach von der App verwaltet |
| `tools/` | Entwicklungs-Pipeline (Patch-Quellen, Build-Skripte, Tests) |
| `docs/` | GitHub-Pages-Host für das Update-Manifest |

## Lizenz

**Alle Rechte vorbehalten** — siehe [LICENSE](LICENSE). Die Software ist
proprietär; Vervielfältigung, Verbreitung oder Weiterverkauf nur mit
ausdrücklicher schriftlicher Genehmigung.
