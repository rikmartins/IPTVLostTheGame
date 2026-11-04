; Instalador Windows (Inno Setup 6). Compilado pelo workflow de release:
;   ISCC.exe /DAppVersion=1.2.3 windows\installer\iptv.iss
; depois de `flutter build windows --release`.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppName "IPTV"
#define AppExe "iptv_app.exe"

[Setup]
; Nunca mudar: é o que liga cada versão nova à instalação anterior.
AppId={{700E03DA-B317-4316-AED4-98745E712D00}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=rikmartins
AppPublisherURL=https://github.com/rikmartins/IPTVLostTheGame
; Instalação por utilizador (%LOCALAPPDATA%\Programs): as atualizações
; automáticas correm sem UAC. Quem quiser pode instalar para todos.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
OutputDir=..\..\build\installer
; O "Setup" no nome é o que a app procura na release (ver pickAsset).
OutputBaseFilename=IPTV-Setup-{#AppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern
; Se a app ainda estiver aberta, o instalador fecha-a.
CloseApplications=yes
RestartApplications=no
UninstallDisplayIcon={app}\{#AppExe}

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
