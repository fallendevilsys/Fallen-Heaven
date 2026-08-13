# Theme-Builds & Sicherheitskopien

Dieser Ordner enthält Sicherheitskopien der App-EXE und die Theme-Builds.

## Stand

- **`Fallen-Heaven Discord App.exe`** (Haupt-EXE) ist seit 14.08.2026
  **der Theme-Build**: Themes funktionieren jetzt direkt ohne Launcher.
- **`plain-6.3.3.exe`** = Sicherheitskopie der alten 6.3.3 **ohne** Themes
  (falls je zurückgesetzt werden muss).
- **`theme-build-6.3.3.exe`** = der gefixte Theme-Build (identisch mit der
  Haupt-EXE) — wird vom `FH-Theme-Launcher.exe` im Speicher geladen, falls
  Smart App Control den direkten Start einmal blockiert.

## Der Fix (wichtig für künftige Builds)

Beim Theme-Build gab es einen Bug: `ThemeManager::AccentOf` hatte den
Rückgabetyp `System.Drawing.Color` als **ClassSig** statt **ValueTypeSig**
geschrieben → `TypeLoadException` (Werttypenkonflikt) beim Öffnen des
Theme-Dialogs. Behoben mit:

- `tools/fixcolorsig.cs/.exe` — korrigiert den Rückgabetyp in einer EXE
  (surgical fix, reproduzierbar).
- `tools/patch_themesettings.cs` — Quellcode jetzt mit
  `new ValueTypeSig(fromArgb3.DeclaringType)` statt `ToTypeSig()`.

## Was die Theme-Builds enthalten

- Einstellungs-Bereich **„Erscheinungsbild"**
- 4 Farb-Themes: Violett, Neon-Cyan, Crimson, Cyberpunk
- Auswahl-Raster mit **Speichern-Button** und **Schließen-Button**
- Texte in den App-Sprachen (DE/EN/RU/FR/ES/AR)

## Hinweise

- `FH-Theme-Launcher.exe` startet die Theme-App **im Speicher** (umgeht
  Smart App Control). Quellcode: `tools/theme_launcher.cs`.
- Reproduzierbar sind die Builds über die Patch-Quellen
  `tools/patch_theme.cs`, `tools/patch_themeui.cs` und
  `tools/patch_themesettings.cs`.
