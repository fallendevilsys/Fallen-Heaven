# FALLEN HEAVEN — Discord Rich Presence

> "Where fallen angels land" — turn your Discord status into something that's
> truly yours. Show games, write your own text, or advertise your Discord
> server right in your presence. Simple, local, no installation required.

[![Version](https://img.shields.io/badge/Version-6.2.0-9665ff)](https://github.com/fallendevilsys/Fallen-Heaven/releases)
![Languages](https://img.shields.io/badge/Languages-6-blue)
![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-black)

*Deutsche Version: [README.md](README.md)*

---

## What is FALLEN HEAVEN?

FALLEN HEAVEN is a small, portable Windows desktop app that styles your Discord
status automatically and live:

- 🎮 **Games** — launch a game and it appears in your profile with its icon
- ✍️ **Your own text** — write your own presence: a motto, a message, or an ad for your Discord server
- 🔘 **Buttons with links** — up to 2 clickable buttons in your presence, e.g. "My Server" with your invite link
- ▶️ **YouTube** — playing videos are shown with title and channel art
- 🔴 **Twitch** — watching a stream? The channel shows up as your status

No manual configuration needed — everything runs **locally** on your PC;
nothing is stored, uploaded, or shared.

---

## Quick start (2 minutes)

1. **Download and launch the app** — the latest version is available under
   [Releases](https://github.com/fallendevilsys/Fallen-Heaven/releases).
   The app is **portable**: no installation required, just run the EXE.

2. **Enter your Client ID** (once, about 2 minutes):
   - Open the [Discord Developer Portal](https://discord.com/developers/applications)
   - Click **New Application**, enter a name (e.g. "My Presence") and confirm
   - Under **General Information**, copy the **Application ID (Client ID)**
   - Paste it into the app: **Settings → Client ID**

3. **Press START** — your presence appears in your Discord profile instantly.

> 💡 **Without your own Client ID, Discord won't show a rich presence status.**
> The app walks you through the steps right in its settings.

---

## ✍️ Your own text — make your presence your banner

The heart of FALLEN HEAVEN: you decide what others see in your Discord profile.
The presence is **fully customizable** — no pre-set text, only **your** text.

### What you can set

| Element | Description | Example |
|---|---|---|
| **Main text** | The large text above your status | "Fallen Heaven – Where fallen angels land" |
| **Status lines** | Up to 3 lines that rotate automatically | "German-speaking community", "Gaming • Voice • Events", "No drama • No pressure • Good vibes" |
| **Comment** | A short text shown when a game is detected | ":)" |
| **Button 1 + 2** | Up to 2 buttons with your own name and link | "My Server" → `https://discord.gg/your-server` |

### Example: Advertise your Discord server

Here's how to promote your server directly in your presence — no bot, no ads:

1. Open **Settings → Presence Settings**
2. **Main text**: Your slogan, e.g. `Our Discord — where it all happens`
3. **Status lines**: What makes your server special, e.g.
   `Daily events`, `Friendly community`, `Gaming & chill`
4. **Button 1**: Name `My Server`, link your invite (e.g. `https://discord.gg/your-server`)
5. **Button 2**: e.g. `My profile` → `https://guns.lol/yourname`
6. **Save** — done. Everyone who opens your profile sees your text and can
   click straight through to your server.

> 💡 **Important to know:** You won't see the buttons in your own profile
> (that's a Discord limitation) — **other users** see them. You can still test
> them right away with a second account or by asking a friend.

---

## All features at a glance

- ✍️ **Your own presence text** — main text, rotating status lines, comment, and
  2 buttons with links (e.g. Discord server advertising).
- 🎮 **Automatic game detection** — Steam games and other apps are detected
  automatically. You can also create **your own game rules** (up to 50) —
  just enter a process name and a display name.
- ▶️ **YouTube title & thumbnail** — detects the video currently playing and
  shows title + channel art as your presence.
- 🔴 **Twitch detection** — watching a stream? The channel appears.
- 👤 **Your own Client ID** — link your presence to your Discord account.
  Up to **2 Client IDs** possible (e.g. for different purposes), including a
  hide option for screen sharing.
- 🔒 **Privacy mode** — as soon as OBS, Streamlabs & co. are running, the app
  shows a neutral presence instead of the real window title. Perfect for streamers.
- 🌍 **6 languages** — English, Deutsch, Русский, Français, Español, العربية
  (including RTL support for Arabic). Switch at any time.
- ✨ **Modern interface** — glassmorphism design with animated startup.
- 🚀 **Automatic updates** — the app checks for updates on startup and
  installs them. Manual: **CHECK FOR UPDATES**.
- 🛡️ **Safety features** — stop confirmation to prevent accidental quitting,
  and single-instance protection against duplicate windows.
- 🪟 **Keep running in the background** — hide the window, the presence keeps
  running in the tray. Optionally start with Windows.

---

## The app in detail — every setting explained

### Presence settings (your text)
Design your presence completely yourself here — see
["Your own text"](#your-own-text--make-your-presence-your-banner).
Everything is saved locally in `app-config.json` in the app folder.

### Game detection
- **Automatic game detection** — detects games and apps on your PC.
- **Custom game rules** — add your own rules: process name → display name
  (e.g. `MyGame.exe = My Game`). Up to 50 rules.
- **Scan interval** — how often the app scans for games (3–60 seconds).

### Privacy mode
As soon as streaming software (OBS, Streamlabs …) is running, the app
automatically shows a neutral presence — your real window title stays hidden.
That way you avoid accidental spoilers on stream.

### Client ID / Second Client ID
- **Client ID** — your Application ID from the Discord Developer Portal
  (required for rich presence).
- **Second Client ID** — optional, e.g. a second presence for another purpose.
  The hide option lets you control which presence is visible during screen sharing.

### Timing & sync
- **Status rotation** — how long each status line is shown (min. 15 seconds).
- **Synchronization** — how often the presence syncs with Discord (5–300 seconds).

### Language
6 languages selectable right in the app — including Arabic with RTL layout.
The switch takes effect immediately.

### Autostart & tray
- **Start with Windows** — the app starts automatically at login.
- **Hide window** — the app keeps running invisibly in the tray; your presence stays active.

---

## Privacy & locality

- Everything runs **locally** on your PC — no server, no account, no tracking.
- The app only connects to **Discord** (for your presence) and — only when
  enabled — to **YouTube/Twitch** to load video/stream info.
- For update checks, it queries the public **GitHub release** — no token, no background service.

---

## Updates

The app automatically checks for a new version on startup and installs it by
itself. You don't need to do anything. You can also check manually at any time
using the **CHECK FOR UPDATES** button.

---

## FAQ

**Why don't I see a presence?**
Almost always a missing Client ID. Without your own Application ID, Discord
shows no rich presence. Enter your Client ID in the settings (see
[Quick start](#quick-start-2-minutes)).

**Why can't I see my own buttons?**
Discord only shows buttons to **other users** in your profile. To test, look
with a second account or ask a friend.

**The app doesn't detect my game?**
Create a custom game rule: **Settings → Game detection → add rule**
(process name + display name). Make sure the scan interval isn't too large.

**Can I run the app in the background?**
Yes — "Hide window" keeps it running invisibly in the tray. Optionally it
starts with Windows.

**How do I change the language?**
Settings → Language → choose your language. Done.

**Where are my settings stored?**
Locally in the app folder (`app-config.json`). The app is portable — you can
copy the whole folder and take it anywhere.

---

## Community & support

Questions, feedback or ideas? Join the community:

- 💬 [Discord server](https://discord.gg/fallen-heaven)
- 🎮 [Creator profile](https://guns.lol/fallendevil)

---

## License

**All rights reserved** — see [LICENSE](LICENSE). The software is proprietary;
copying, distribution or resale only with explicit written permission.
