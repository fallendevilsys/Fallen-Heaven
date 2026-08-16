# FALLEN HEAVEN — Discord Rich Presence

> „Wo gefallene Engel landen" — verwandle deinen Discord-Status in etwas,
> das zu dir passt. Zeige Spiele, YouTube & Twitch oder bewirb deinen eigenen
> Discord-Server direkt in deiner Presence. Einfach, lokal, ohne Installation.

[![Version](https://img.shields.io/badge/Version-6.3.5-9665ff)](https://github.com/fallendevilsys/Fallen-Heaven/releases)
![Sprachen](https://img.shields.io/badge/Sprachen-6-blue)
![Lizenz](https://img.shields.io/badge/Lizenz-All%20Rights%20Reserved-black)

*English version: [README-EN.md](README-EN.md)*

---

## Was ist FALLEN HEAVEN?

Eine kleine, portable Windows-App, die deinen Discord-Status automatisch gestaltet:

- 🎮 **Spiele** — erkennbare Spiele erscheinen mit Icon in deinem Profil
- ✍️ **Dein Text** — schreibe deine eigene Presence: Motto, Nachricht oder Server-Werbung
- 🔘 **Buttons** — bis zu 2 klickbare Buttons mit eigenem Namen und Link
- ▶️ **YouTube & Twitch** — laufende Videos und Streams werden angezeigt

Alles läuft **lokal** auf deinem PC — kein Konto, kein Tracking, nichts wird
gespeichert oder hochgeladen.

---

## Schnellstart (2 Minuten)

1. **App herunterladen** — die neueste Version findest du unter
   [Releases](https://github.com/fallendevilsys/Fallen-Heaven/releases).
   Die App ist **portabel**: keine Installation nötig, einfach starten.

2. **Client ID eintragen** (einmalig, ca. 2 Minuten):
   - Öffne das [Discord Developer Portal](https://discord.com/developers/applications)
   - **New Application** → Name vergeben → bestätigen
   - Unter **General Information** die **Application ID (Client ID)** kopieren
   - In der App einfügen: **Einstellungen → Client ID**

3. **START drücken** — deine Presence erscheint sofort in deinem Discord-Profil.

> 💡 Ohne eigene Client ID zeigt Discord keinen Rich-Presence-Status.
> Die App führt dich Schritt für Schritt durch die Einrichtung.

---

## ✍️ Deine Presence, dein Text

Du bestimmst, was andere in deinem Profil sehen — alles direkt in der App:

| Element | Beschreibung |
|---|---|
| **Haupttext** | Der große Text über deinem Status |
| **Status-Zeilen** | Bis zu 3 Zeilen, die sich automatisch abwechseln |
| **Kommentar** | Ein kurzer Text, der bei erkanntem Spiel erscheint |
| **Buttons** | Bis zu 2 Buttons mit eigenem Namen und Link |

**So bewirbst du deinen Discord-Server:**

1. **Einstellungen → Presence** öffnen
2. **Haupttext**: z. B. `Unser Discord — wo alles passiert`
3. **Status-Zeilen**: z. B. `Tägliche Events`, `Freundliche Community`, `Gaming & Chill`
4. **Buttons**: z. B. „Mein Server" mit deinem Einladungslink und „Mein Profil" mit deinem Link
5. **Speichern** — fertig.

> 💡 **Hinweis:** Deine Buttons siehst du in deinem eigenen Profil nicht
> (Discord-Einschränkung) — **andere Nutzer** sehen sie. Zum Testen schaue
> mit einem zweiten Konto oder frag einen Freund.

### 🔒 Erkennbar als FALLEN HEAVEN

Damit die App als Fallen-Heaven-Produkt erkennbar bleibt, sind diese Elemente
fest eingebaut und **nicht** änderbar:

- FH-Logo + „FALLEN HEAVEN PRESENCE CONTROL" (oben links)
- Animierter Glitch-Schriftzug „BY ₣₳ⱠⱠɆ₦ ĐɆVłⱠ"
- Buttons „DISCORD-SERVER" und „CREATOR-PROFIL" (unten)
- Verified-Badge in der Live-Aktivität

Alles andere gehört dir — Text, Status, Buttons und Bilder.

---

## Alle Features

- 🎮 **Automatische Spiele-Erkennung** — inkl. eigener Spielregeln
- ▶️ **YouTube & Twitch** — Titel, Kanal und Thumbnail als Presence
- 👤 **Eigene Client ID** — bis zu 2 Client IDs möglich
- 🔒 **Privacy-Modus** — bei OBS & Co. wird eine neutrale Presence gezeigt
- 🌍 **6 Sprachen** — jederzeit in der App wechselbar
- 🚀 **Automatische Updates** — lädt neue Versionen selbst und installiert sie
- 🪟 **Läuft im Hintergrund weiter** — im Tray, optional mit Windows-Start
- ✨ **Moderne Oberfläche** — mit animiertem Start
- 🎨 **Farb-Themes** — wähle deine Akzentfarbe: Violett, Neon-Cyan, Crimson oder Cyberpunk

### 🎨 Farb-Themes

Unter **Einstellungen → Erscheinungsbild** wählst du die Akzentfarbe deiner
App: **Violett**, **Neon-Cyan**, **Crimson** oder **Cyberpunk**. Tippe auf
eine Farbe, drücke **Speichern** — die App startet kurz neu und übernimmt
das neue Design. Du kannst jederzeit wechseln.

---

## Datenschutz

Alles läuft **lokal**. Die App verbindet sich nur mit **Discord** (für deine
Presence) und — nur wenn aktiviert — mit **YouTube/Twitch**. Update-Prüfungen
laufen über das öffentliche GitHub-Release.

---

## Updates

Die App prüft beim Start automatisch auf neue Versionen und installiert sie
**vollautomatisch** — du musst nichts tun. Ein Dialog zeigt den Fortschritt
live. Manuell kannst du jederzeit über **UPDATES SUCHEN** nachschauen.

---

## FAQ

**Warum sehe ich keine Presence?**
Fast immer fehlt die Client ID — siehe [Schnellstart](#schnellstart-2-minuten).

**Warum sehe ich meine Buttons nicht selbst?**
Discord zeigt Buttons nur anderen Nutzern. Teste mit einem zweiten Konto oder frag einen Freund.

**Die App erkennt mein Spiel nicht?**
Lege eine eigene Spielregel an: **Einstellungen → Spielerkennung**.

**Kann die App im Hintergrund laufen?**
Ja — über „Fenster ausblenden" läuft sie unsichtbar im Tray weiter.

**Wo werden meine Einstellungen gespeichert?**
Lokal im App-Ordner. Die App ist portabel — kopiere einfach den Ordner und nimm sie überallhin mit.

---

## 📜 Versionshistorie

**6.3.5** *(aktuell)*
- 🎧 **Spotify-Erkennung** — zeig, was du gerade hörst: Song, Interpret und Cover erscheinen jetzt in deinem Discord-Status. Die Option „YouTube" umfasst jetzt auch Spotify.

**6.3.4**
- 🖥️ **Passt auf jeden Bildschirm** — die App passt sich deiner Bildschirmgröße an: Auf kleineren Monitoren verkleinern sich die Fenster automatisch, damit jeder Button sichtbar bleibt und nichts abgeschnitten wird.
- 🔍 **Überall scharfer Text** — kein unscharfer Text mehr auf Laptops mit 125 %/150 % Vergrößerung; die App bleibt scharf, selbst wenn du sie zwischen zwei Monitoren verschiebst.

**6.3.3**
- 🎨 **Farb-Themes** — neues Menü „Erscheinungsbild" in den Einstellungen: wähle zwischen Violett, Neon-Cyan, Crimson und Cyberpunk — die App startet danach automatisch neu.
- 🚀 **Updates noch zuverlässiger** — neue Versionen installieren sich auch dann sauber, wenn Windows die App besonders streng prüft; die App startet danach automatisch neu.

**6.3.2**
- 🎮 **Erkennung repariert** — Spiele, Browser und YouTube (Titel + Thumbnail) werden wieder zuverlässig erkannt und angezeigt.

**6.3.1**
- 🐛 **Sofort gespeichert** — Änderungen (z. B. ein Button-Name) werden sofort übernommen; deine Presence bleibt ohne Stopp/Start aktiv.
- 🛠️ **Stabiler** — das App-Logo wird zuverlässig geladen; Einstellungen lassen sich immer speichern.

**6.3.0**
- 🚀 **Vollautomatische Updates** — neue Versionen werden automatisch geladen, geprüft und installiert; die App startet selbst neu.
- 🎆 **Glitch-Titel** — animierter Schriftzug „BY ₣₳ⱠⱠɆ₦ ĐɆVłⱠ" im Fenster.
- 🔘 **Buttons in der App** — Name und Link direkt in den Einstellungen änderbar.

**6.2.0**
- ✍️ **Eigener Presence-Text** — Haupttext, rotierende Status-Zeilen, Kommentar und bis zu 2 Buttons.

---

## Community & Support

Fragen, Feedback oder Ideen? Komm in die Community:

- 💬 [Discord-Server](https://discord.gg/fallen-heaven)
- 🎮 [Creator-Profil](https://guns.lol/fallendevil)

---

## Lizenz

**Alle Rechte vorbehalten** — siehe [LICENSE](LICENSE). Vervielfältigung,
Verbreitung oder Weiterverkauf nur mit ausdrücklicher schriftlicher Genehmigung.
