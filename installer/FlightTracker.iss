; Installer for KrabbzDev's Porch Radar (Inno Setup 6, https://jrsoftware.org/isinfo.php).
; Installs for the current user WITHOUT admin rights, into C:\Users\Public\Apps\Krabbz9999-FlightTracker.
; Built and signed on the maintainer's PC by build-installer.cmd (scripts\build-installer.ps1), which stages everything
; under build\base first:
;   Krabbz9999-FlightTracker.exe         the launcher (launcher\Launcher.cs), signed
;   Krabbz9999-FlightTracker-Tray.exe    the tray helper (tray\Tray.cs), signed
;   runtime\node.exe                     Node.js's own signed binary, copied unmodified
;   app\server.js, index.html, version.json   the app's code
; Only the files in app\ ever change after install: the app updates them itself from GitHub Releases
; (a code bundle, see server.js), so the signed files above are not replaced by a normal update.
; The app keeps its settings and data next to the launcher, which is why it goes in a folder the user can write to.
;   ISCC.exe /DAppVersion=1.0.70 [/DSigned=1 /Sstsign=...] installer\FlightTracker.iss  ->  dist\Krabbz9999-FlightTracker-Setup.exe

#define AppName "KrabbzDev's Porch Radar"
#define AppExe "Krabbz9999-FlightTracker.exe"
#define TrayExe "Krabbz9999-FlightTracker-Tray.exe"
#ifndef AppVersion
  #define AppVersion "1.0"
#endif

[Setup]
AppId={{E2A74E37-D4A9-45B6-8BF0-E53E078A78CA}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=KrabbzDev
AppPublisherURL=https://flighttracker.loves3d.com
AppSupportURL=https://github.com/krabbzdev/KrabbzDev-PorchRadar/wiki
AppUpdatesURL=https://github.com/krabbzdev/KrabbzDev-PorchRadar/releases
; no admin: installs for this user only, into the shared Public folder (writable without admin)
PrivilegesRequired=lowest
DefaultDirName={%PUBLIC|C:\Users\Public}\Apps\Krabbz9999-FlightTracker
DisableDirPage=auto
DisableProgramGroupPage=yes
UsePreviousAppDir=yes
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName=KrabbzDev-PorchRadar
OutputDir=..\dist
OutputBaseFilename=Krabbz9999-FlightTracker-Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; close a running copy before replacing it (the tray helper is closed by the app as it exits)
CloseApplications=force
RestartApplications=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#ifdef Signed
; sign the installer and its uninstaller; the "stsign" command is passed to ISCC by build-installer.ps1 (/Sstsign=...)
SignTool=stsign
SignedUninstaller=yes
#endif

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
Name: "startup"; Description: "Start Porch Radar when I sign in to Windows (runs in the tray)"; Flags: unchecked

[Files]
Source: "..\build\base\{#AppExe}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\base\{#TrayExe}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\base\runtime\node.exe"; DestDir: "{app}\runtime"; Flags: ignoreversion
; the installer's own version of the base: new code that needs a newer base refuses to install over an older one
Source: "base.json"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\base\app\server.js"; DestDir: "{app}\app"; Flags: ignoreversion
Source: "..\build\base\app\index.html"; DestDir: "{app}\app"; Flags: ignoreversion
Source: "..\build\base\app\version.json"; DestDir: "{app}\app"; Flags: ignoreversion

[Icons]
Name: "{userprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"
Name: "{userdesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; WorkingDir: "{app}"; Tasks: desktopicon
; --background: start quietly in the tray without opening the browser
Name: "{userstartup}\{#AppName}"; Filename: "{app}\{#AppExe}"; Parameters: "--background"; WorkingDir: "{app}"; Tasks: startup

[InstallDelete]
; left over from the single-file builds (before 70), which replaced the .exe in place
Type: files; Name: "{app}\{#AppExe}.old"
Type: files; Name: "{app}\{#AppExe}.new"
; the app used to be called "Krabbz9999 - FlightTracker": remove shortcuts under the old name when upgrading
Type: files; Name: "{userprograms}\Krabbz9999 - FlightTracker.lnk"
Type: files; Name: "{userdesktop}\Krabbz9999 - FlightTracker.lnk"
Type: files; Name: "{userstartup}\Krabbz9999 - FlightTracker.lnk"
; ...and under "Krabbz9999 - Look A Plane!", before it became "KrabbzDev's Porch Radar"
Type: files; Name: "{userprograms}\Krabbz9999 - Look A Plane!.lnk"
Type: files; Name: "{userdesktop}\Krabbz9999 - Look A Plane!.lnk"
Type: files; Name: "{userstartup}\Krabbz9999 - Look A Plane!.lnk"

[Run]
Filename: "{app}\{#AppExe}"; Description: "Start {#AppName} now"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; stop the app, its runtime and its tray icon so their files can be removed: only the processes running FROM THIS FOLDER
; (matching by name alone would also close a separate copy running somewhere else, or any other Node.js program)
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -NonInteractive -Command ""Get-Process -ErrorAction SilentlyContinue | Where-Object {{ $_.Path -like '{app}\*' } | Stop-Process -Force"""; Flags: runhidden waituntilterminated; RunOnceId: "StopApp"

[UninstallDelete]
; files the app creates itself. Your settings, daily log, cruise sightings and FAA data are left in place,
; so reinstalling picks up where you left off; delete the folder to remove them too.
Type: files; Name: "{app}\{#TrayExe}"
; the code and runtime: the app replaces files in app\ when it updates itself, and keeps the previous ones as .old
Type: filesandordirs; Name: "{app}\app"
Type: filesandordirs; Name: "{app}\runtime"
Type: files; Name: "{app}\{#AppExe}.old"
Type: files; Name: "{app}\{#AppExe}.new"
Type: files; Name: "{app}\airports-cache.json"
Type: files; Name: "{app}\aircraft-types-cache.json"
Type: files; Name: "{app}\airport-details-cache.json"
Type: files; Name: "{app}\app.log"
Type: files; Name: "{app}\app.old.log"
; the dashboard window's own browser profile (cache and page settings)
Type: filesandordirs; Name: "{app}\browser-window"
Type: files; Name: "{app}\cruise-fleet.json"
