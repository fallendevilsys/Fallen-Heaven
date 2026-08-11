# FALLEN HEAVEN — Discord Rich Presence

> „Wo gefallene Engel landen" — verwandle deinen Discord-Status in etwas,
> das wirklich zu dir passt. Zeige Spiele, erstelle deinen eigenen Text
> oder bewirb deinen Discord-Server direkt in deiner Presence.
> Einfach, lokal und ohne Installation.

[![Version](https://img.shields.io/badge/Version-6.2.0-9665ff)](https://github.com/fallendevilsys/Fallen-Heaven/releases)
![Sprachen](https://img.shields.io/badge/Sprachen-6-blue)
![Lizenz](https://img.shields.io/badge/Lizenz-All%20Rights%20Reserved-black)

*English version: [README-EN.md](README-EN.md)*

---

## Was ist FALLEN HEAVEN?

FALLEN HEAVEN ist eine kleine, portable Desktop-App für Windows, die deinen
Discord-Status automatisch und live gestaltet:

- 🎮 **Spiele** — startest du ein Spiel, erscheint es mit passendem Icon in deinem Profil
- ✍️ **Eigener Text** — schreibe deine eigene Presence: ein Motto, eine Nachricht oder Werbung für deinen Discord-Server
- 🔘 **Buttons mit Links** — bis zu 2 klickbare Buttons in deiner Presence, z. B. „Mein Server" mit deinem Einladungslink
- ▶️ **YouTube** — laufende Videos werden mit Titel und Kanalbild angezeigt
- 🔴 **Twitch** — schaust du einen Stream, siehst du den Kanal

Du musst nichts manuell konfigurieren — alles läuft **lokal** auf deinem PC,
nichts wird gespeichert, hochgeladen oder weitergegeben.

---

## Schnellstart (2 Minuten)

1. **App herunterladen und starten** — die neueste Version findest du unter
   [Releases](https://github.com/fallendevilsys/Fallen-Heaven/releases).
   Die App ist **portabel**: keine Installation nötig, einfach die EXE starten.

2. **Client ID eintragen** (einmalig, ca. 2 Minuten):
   - Öffne das [Discord Developer Portal](https://discord.com/developers/applications)
   - Klicke auf **New Application**, gib einen Namen ein (z. B. „Meine Presence") und bestätige
   - Kopiere unter **General Information** die **Application ID (Client ID)**
   - Trage sie in der App ein: **Einstellungen → Client ID**

3. **START drücken** — deine Presence erscheint sofort in deinem Discord-Profil.

> 💡 **Ohne eigene Client ID zeigt Discord keinen Rich-Presence-Status.**
> Die App führt dich durch die Schritte direkt in den Einstellungen.

---

## ✍️ Dein eigener Text — mache deine Presence zu deinem Werbebanner

Das Herzstück von FALLEN HEAVEN: Du bestimmst selbst, was andere in deinem
Discord-Profil sehen. Die Presence ist **frei gestaltbar** — kein vorgegebener
Text, sondern **dein** Text.

### Was du einstellen kannst

| Element | Beschreibung | Beispiel |
|---|---|---|
| **Haupttext** | Der große Text über deinem Status | „Fallen Heaven – Wo gefallene Engel landen" |
| **Status-Zeilen** | Bis zu 3 Zeilen, die sich automatisch abwechseln | „Deutschsprachige Community", „Gaming • Voice • Events", „Kein Drama • Kein Druck • Gute Vibes" |
| **Kommentar** | Ein kurzer Text, der bei erkanntem Spiel erscheint | „:)  " |
| **Button 1 + 2** | Bis zu 2 Buttons mit eigenem Namen und Link | „Mein Server" → `https://discord.gg/dein-server` |

### Beispiel: Deinen Discord-Server bewerben

So bewirbst du deinen Server direkt in deiner Presence — ganz ohne Bot oder Werbung:

1. Öffne **Einstellungen → Presence-Einstellungen**
2. **Haupttext**: Dein Slogan, z. B. `Unser Discord — wo alles passiert`
3. **Status-Zeilen**: Was deinen Server ausmacht, z. B.
   `Tägliche Events`, `Freundliche Community`, `Gaming & Chill`
4. **Button 1**: Name `Mein Server`, Link deine Einladung (z. B. `https://discord.gg/dein-server`)
5. **Button 2**: z. B. `Mein Profil` → `https://guns.lol/deinname`
6. **Speichern** — fertig. Jeder, der dein Profil öffnet, sieht deinen Text
   und kann direkt auf deinen Server klicken.

> 💡 **Wichtig zu wissen:** Die Buttons siehst du in deinem eigenen Profil nicht
> (das ist eine Discord-Einschränkung) — **andere Nutzer** sehen sie. Du kannst
> sie trotzdem sofort testen, indem du ein anderes Konto oder einen Freund fragst.

---

## Alle Features im Überblick

- ✍️ **Eigener Presence-Text** — Haupttext, rotierende Status-Zeilen, Kommentar und
  2 Buttons mit Links (z. B. Discord-Server-Werbung).
- 🎮 **Automatische Spiele-Erkennung** — Steam-Spiele und weitere Apps werden
  automatisch erkannt. Zusätzlich kannst du **eigene Spielregeln** anlegen
  (bis zu 50) — einfach Prozessname und Anzeigename eintragen.
- ▶️ **YouTube-Titel & Thumbnail** — erkennt das laufende Video und zeigt Titel
  + Kanalbild als Presence.
- 🔴 **Twitch-Erkennung** — schaust du einen Stream, erscheint der Kanal.
- 👤 **Eigene Client ID** — binde deine Presence an deinen Discord-Account.
  Bis zu **2 Client IDs** möglich (z. B. für verschiedene Zwecke), inkl.
  Funktion zum Verbergen der Presence bei Bildschirmübertragung.
- 🔒 **Privacy-Modus** — sobald OBS, Streamlabs & Co. laufen, zeigt die App eine
  neutrale Presence statt des echten Fenstertitels. Perfekt für Streamer.
- 🌍 **6 Sprachen** — English, Deutsch, Русский, Français, Español, العربية
  (inkl. RTL-Unterstützung für Arabisch). Jederzeit wechselbar.
- ✨ **Moderne Oberfläche** — Glassmorphism-Design mit animiertem Start.
- 🚀 **Automatische Updates** — die App sucht beim Start selbst nach Updates
  und installiert sie. Manuell: **UPDATES SUCHEN**.
- 🛡️ **Schutzfunktionen** — Stopp-Bestätigung gegen versehentliches Beenden
  und Single-Instance-Schutz gegen doppelte Fenster.
- 🪟 **Im Hintergrund weiterlaufen** — Fenster ausblenden, die Presence läuft
  im Tray weiter. Optional mit Windows starten.

---

## Die App im Detail — jede Einstellung erklärt

### Presence-Einstellungen (dein Text)
Hier gestaltest du deine Presence komplett selbst — siehe Abschnitt
[„Dein eigener Text"](#dein-eigener-text--mache-deine-presence-zu-deinem-werbebanner).
Gespeichert wird lokal in `app-config.json` im App-Ordner.

### Spielerkennung
- **Automatische Spielerkennung** — erkennt Spiele und Apps auf deinem PC.
- **Eigene Spielregeln** — füge eigene Regeln hinzu: Prozessname → Anzeigename
  (z. B. `MeinSpiel.exe = Mein Spiel`). Maximal 50 Regeln.
- **Scan-Intervall** — wie oft die App nach Spielen sucht (3–60 Sekunden).

### Privacy-Modus
Sobald Streaming-Software (OBS, Streamlabs …) läuft, zeigt die App automatisch
eine neutrale Presence — dein echter Fenstertitel bleibt geheim. So vermeidest
du versehentliche Spoiler im Livestream.

### Client ID / Zweite Client ID
- **Client ID** — deine Application ID aus dem Discord Developer Portal
  (Pflicht für Rich Presence).
- **Zweite Client ID** — optional, z. B. eine zweite Presence für einen anderen
  Zweck. Mit der Verbergen-Option kannst du steuern, welche Presence bei
  Bildschirmübertragung sichtbar ist.

### Timing & Synchronisierung
- **Status-Wechsel** — wie lange jede Status-Zeile angezeigt wird (mind. 15 Sekunden).
- **Synchronisierung** — wie oft die Presence mit Discord synchronisiert wird (5–300 Sekunden).

### Sprache
6 Sprachen direkt in der App wählbar — inklusive Arabisch mit RTL-Layout.
Der Wechsel ist sofort wirksam.

### Autostart & Tray
- **Mit Windows starten** — die App startet automatisch beim Login.
- **Fenster ausblenden** — die App läuft unsichtbar im Tray weiter; deine
  Presence bleibt aktiv.

---

## Datenschutz & Lokalität

- Alles läuft **lokal** auf deinem PC — es gibt keinen Server, kein Konto,
  kein Tracking.
- Die App verbindet sich nur mit **Discord** (für deine Presence) und —
  nur wenn aktiviert — mit **YouTube/Twitch**, um Video-/Stream-Infos zu laden.
- Für Update-Prüfungen wird das öffentliche **GitHub-Release** abgefragt —
  ohne Token, ohne Hintergrunddienst.

---

## Updates

Die App prüft beim Start automatisch, ob eine neue Version verfügbar ist, und
installiert sie selbstständig. Du musst nichts tun. Über den Button
**UPDATES SUCHEN** kannst du jederzeit manuell nachschauen.

---

## Häufige Fragen (FAQ)

**Warum sehe ich keine Presence?**
Fast immer fehlt die Client ID. Ohne eigene Application ID zeigt Discord keine
Rich Presence. Trage deine Client ID in den Einstellungen ein (siehe
[Schnellstart](#schnellstart-2-minuten)).

**Warum sehe ich meine Buttons nicht selbst?**
Discord zeigt Buttons nur **anderen Nutzern** in deinem Profil. Zum Testen
schaue mit einem zweiten Konto oder frag einen Freund.

**Die App erkennt mein Spiel nicht?**
Lege eine eigene Spielregel an: **Einstellungen → Spielerkennung → eigene
Regel** (Prozessname + Anzeigename). Achte darauf, dass das Scan-Intervall
nicht zu groß ist.

**Kann ich die App im Hintergrund laufen lassen?**
Ja — über „Fenster ausblenden" läuft sie unsichtbar im Tray weiter.
Optional startet sie mit Windows.

**Wie wechsle ich die Sprache?**
Einstellungen → Sprache → gewünschte Sprache wählen. Fertig.

**Wo werden meine Einstellungen gespeichert?**
Lokal im App-Ordner (`app-config.json`). Die App ist portabel — du kannst den
kompletten Ordner kopieren und überall mitnehmen.

---

## Community & Support

Fragen, Feedback oder Ideen? Komm in die Community:

- 💬 [Discord-Server](https://discord.gg/fallen-heaven)
- 🎮 [Creator-Profil](https://guns.lol/fallendevil)

---

## Lizenz

**Alle Rechte vorbehalten** — siehe [LICENSE](LICENSE). Die Software ist
proprietär; Vervielfältigung, Verbreitung oder Weiterverkauf nur mit
ausdrücklicher schriftlicher Genehmigung.
