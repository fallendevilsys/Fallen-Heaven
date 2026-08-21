; =====================================================================
;  Fallen Heaven - Windows Installer
;  Inno Setup 6 (Portable: tools/inno)
;
;  Aufruf:
;    tools/inno/ISCC.exe tools/installer/installer.iss
;
;  Erzeugt:
;    release/Fallen-Heaven-Setup-<Version>.exe
;
;  Merkmale:
;    - Lizenzseite (DE + EN, abhaengig von der Installer-Sprache)
;    - Zielordner frei waehlbar (Standard: per-Nutzer, schreibbar)
;    - Startmenue- + optionale Desktop-Verknuepfung
;    - Deinstaller
;    - Ueberschreibt niemals eine vorhandene Nutzer-Config
; =====================================================================
#define MyAppName "Fallen Heaven"
; Die Anzeige-Version (String) lesen - entspricht der Version in Releases/Manifest.
#define MyAppVersion GetStringFileInfo("..\..\Fallen-Heaven Discord App.exe", "FileVersion")
#define MyAppPublisher "Fallen Heaven"
#define MyAppExeName "Fallen-Heaven Discord App.exe"

[Setup]
AppId={{7A3F2C91-9B4E-4D6A-8F22-5E0B4C1D9A33}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=https://github.com/fallendevilsys/Fallen-Heaven
AppSupportURL=https://github.com/fallendevilsys/Fallen-Heaven
AppUpdatesURL=https://github.com/fallendevilsys/Fallen-Heaven
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\..\release
OutputBaseFilename=Fallen-Heaven-Setup-{#MyAppVersion}
SetupIconFile=..\..\fh-app.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName} {#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
; Keine Explorer-Pfad-Aenderung noetig (portable App, kein PATH-Eintrag)
ChangesAssociations=no
; Stille Updates: Wenn die App beim Installieren noch laeuft (z. B. Update,
; bevor sie sich selbst beendet hat), wird sie kontrolliert geschlossen und
; danach nicht automatisch neu gestartet (das macht der App-Neustart weiter
; unten nur bei /RESTARTAPP).
CloseApplications=force
RestartApplications=no

[Languages]
Name: "german";  MessagesFile: "compiler:Languages\German.isl";  LicenseFile: "license-de.txt"
Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "license-en.txt"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\{#MyAppExeName}";      DestDir: "{app}";            Flags: ignoreversion
Source: "..\..\lib\FH.YoutubeResolver.dll";  DestDir: "{app}\lib";  Flags: ignoreversion
Source: "..\..\lib\FH.SpotifyResolver.dll";  DestDir: "{app}\lib";  Flags: ignoreversion
Source: "..\..\fh-app.ico";            DestDir: "{app}";            Flags: ignoreversion
Source: "..\..\fh-ui-logo.png";        DestDir: "{app}";            Flags: ignoreversion
Source: "..\..\fh_logo.png";           DestDir: "{app}";            Flags: ignoreversion
Source: "..\..\README.md";             DestDir: "{app}";            Flags: ignoreversion
Source: "..\..\README-EN.md";          DestDir: "{app}";            Flags: ignoreversion
Source: "..\..\LICENSE";               DestDir: "{app}";            Flags: ignoreversion
; Config-Vorlage: Bei frischer Installation wird app-config.json angelegt.
; Bei einer Aktualisierung bleibt eine vorhandene Nutzer-Config unangetastet.
Source: "..\..\app-config.example.json"; DestDir: "{app}"; DestName: "app-config.example.json"; Flags: ignoreversion
Source: "..\..\app-config.example.json"; DestDir: "{app}"; DestName: "app-config.json";         Flags: onlyifdoesntexist

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}";  Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Code]
// Nur bei Updates (stiller Modus mit /RESTARTAPP): App nach der
// Installation automatisch wieder starten.
function ShouldRestartApp(): Boolean;
begin
  Result := ExpandConstant('{param:RESTARTAPP}') <> '';
end;

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
; Stiller Update-Modus: App neu starten (nur wenn /RESTARTAPP uebergeben wurde)
Filename: "{app}\{#MyAppExeName}"; Flags: nowait; Check: ShouldRestartApp
