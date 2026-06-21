; Inno Setup Script for DeadlineHUB
; Developer: yohanesoktanio
; Organization: Octa-OSS ( Octanio Open Source Software )
; GitHub: github.com/yohanesokta

[Setup]
AppId={{C6D2B1A8-7B8B-4F7F-9B6C-12A34F56E789}
AppName=DeadlineHUB
AppVersion=1.0.0
AppPublisher=Octa-OSS
AppPublisherURL=https://github.com/yohanesokta
AppSupportURL=https://github.com/yohanesokta/deadlinehub
AppUpdatesURL=https://github.com/yohanesokta/deadlinehub/releases
DefaultDirName={autopf}\DeadlineHUB
DefaultGroupName=DeadlineHUB
DisableProgramGroupPage=yes
LicenseFile=..\..\LICENSE
OutputDir=..\..\build\windows\installer
OutputBaseFilename=deadlinehub-windows-installer
SetupIconFile=icons.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\DeadlineHUB"; Filename: "{app}\deadlinehub.exe"
Name: "{autodesktop}\DeadlineHUB"; Filename: "{app}\deadlinehub.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\deadlinehub.exe"; Description: "{cm:LaunchProgram,DeadlineHUB}"; Flags: nowait postinstall skipifsilent
