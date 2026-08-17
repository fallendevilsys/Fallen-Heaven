# Code-Signing für Fallen Heaven

Damit Windows (Smart App Control & SmartScreen) die App **ohne Blockierung**
startet — bei dir und bei allen Nutzern — braucht die EXE eine **echte
Code-Signatur**.

> ⚠️ Ein selbst erstelltes Zertifikat reicht **nicht**. Windows vertraut nur
> Zertifikaten einer öffentlichen Zertifizierungsstelle. Ohne echte Signatur
> blockiert Smart App Control jede neu gebaute EXE.

---

## 1. Warum überhaupt signieren?

| Ohne Signatur | Mit Signatur (OV/EV) |
|---|---|
| Smart App Control blockiert neue Builds | Builds starten sofort |
| SmartScreen warnt „Windows hat Ihren PC geschützt" | Keine Warnung |
| Jede neue Version wird wieder als „unbekannt" geblockt | Auto-Updates laufen sauber durch |

---

## 2. Welches Zertifikat du brauchst

| Typ | Kosten (ca.) | Für wen |
|---|---|---|
| **OV** (Organization Validation) | ~200–400 €/Jahr | Standard — reicht für diese App |
| **EV** (Extended Validation) | ~600–900 €/Jahr | Sofort voller SmartScreen-Trust (nur nötig bei sehr vielen Downloads) |

Anbieter: **DigiCert**, **Sectigo**, **GlobalSign**, **SSL.com**.

Kaufablauf (OV reicht):
1. Zertifikat bestellen und Firma/Identität verifizieren (1–3 Tage).
2. Du bekommst eine **.pfx-Datei** (mit Passwort) — oder das Zertifikat
   landet auf einem USB-Token.

---

## 3. Einmalige Einrichtung

### 3.1 Windows SDK installieren (für `signtool`)

Lade das SDK herunter und installiere nur die Komponente
**„Signing Tools for Desktop Apps"**:

https://developer.microsoft.com/windows/downloads/windows-sdk/

### 3.2 Signieren

**Variante A — .pfx-Datei:**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\sign.ps1 `
  -PfxPath C:\certs\dein-zertifikat.pfx -PfxPassword "DEIN-PASSWORT"
```

**Variante B — Zertifikat im Speicher (z. B. USB-Token):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\sign.ps1 `
  -Thumbprint A1B2C3D4E5F6...
```

Das Skript signiert automatisch:
- `Fallen-Heaven Discord App.exe`
- `FH.YoutubeResolver.dll`
- `FH.SpotifyResolver.dll`

und prüft danach jede Signatur.

---

## 4. In den Release-Ablauf einbauen

Die Reihenfolge ist wichtig:

1. App lokal bauen/patchten (neue EXE)
2. **`tools\sign.ps1` ausführen** (EXE signieren)
3. Signierte EXE/DLL **committen + pushen**
4. Tag erstellen (`git tag vX.Y.Z && git push origin vX.Y.Z`)

Der bestehende Release-Workflow verpackt dann automatisch die
**signierte** EXE — deine Nutzer bekommen die Signatur mit dem
Auto-Update.

---

## 5. Wichtige Hinweise

- **Nach dem Signieren nicht mehr neu bauen.** Jeder Neuaufbau erzeugt
  einen neuen Hash und zerstört die Signatur → neu signieren.
- **SmartScreen-Reputation:** Ein brandneues OV-Zertifikat kann in den
  ersten Tagen/Wochen noch seltene SmartScreen-Hinweise zeigen. Das legt
  sich, sobald genug Nutzer die signierte App geladen haben. Smart App
  Control akzeptiert die OV-Signatur dagegen sofort.
- **Passwort geheim halten** — die .pfx-Datei gehört **nicht** ins Repo
  (in `.gitignore` aufnehmen, z. B. `*.pfx`).
