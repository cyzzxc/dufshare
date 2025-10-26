; Dufs Installer Script
; Compile this script with Inno Setup

#define MyAppName "Dufs"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Dufs Team"
#define MyAppURL "https://github.com/sigoden/dufs"
#define MyAppExeName "dufs.exe"

[Setup]
; Basic Information
AppId={{D3F8E9A1-5B2C-4E7D-9F3A-6C8D4E9B2A1F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
; Default installation path
DefaultDirName={autopf}\{#MyAppName}
; Start menu folder
DefaultGroupName={#MyAppName}
; Allow user to skip start menu folder creation
AllowNoIcons=yes
; Output settings
OutputDir=output
OutputBaseFilename=dufs-setup
; Compression settings
Compression=lzma
SolidCompression=yes
; Wizard style
WizardStyle=modern
; Require admin privileges for registry and environment variable changes
PrivilegesRequired=admin
; Architecture settings
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "dufs.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "dufs-launcher.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "favicon.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "config.yaml"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Registry]
; Add context menu - On folder
Root: HKCR; Subkey: "Directory\shell\DufsHere"; ValueType: string; ValueName: ""; ValueData: "Start Dufs Here"; Flags: uninsdeletekey
Root: HKCR; Subkey: "Directory\shell\DufsHere"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\favicon.ico"
Root: HKCR; Subkey: "Directory\shell\DufsHere\command"; ValueType: string; ValueName: ""; ValueData: """{app}\dufs-launcher.bat"" ""%1"""

; Add context menu - On folder background
Root: HKCR; Subkey: "Directory\Background\shell\DufsHere"; ValueType: string; ValueName: ""; ValueData: "Start Dufs Here"; Flags: uninsdeletekey
Root: HKCR; Subkey: "Directory\Background\shell\DufsHere"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\favicon.ico"
Root: HKCR; Subkey: "Directory\Background\shell\DufsHere\command"; ValueType: string; ValueName: ""; ValueData: """{app}\dufs-launcher.bat"" ""%V"""

; Add context menu - On drive
Root: HKCR; Subkey: "Drive\shell\DufsHere"; ValueType: string; ValueName: ""; ValueData: "Start Dufs Here"; Flags: uninsdeletekey
Root: HKCR; Subkey: "Drive\shell\DufsHere"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\favicon.ico"
Root: HKCR; Subkey: "Drive\shell\DufsHere\command"; ValueType: string; ValueName: ""; ValueData: """{app}\dufs-launcher.bat"" ""%1"""

[Code]
const
  EnvironmentKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

// Add installation directory to PATH environment variable
procedure AddToPath();
var
  Path: string;
  InstallDir: string;
begin
  InstallDir := ExpandConstant('{app}');

  // Read current PATH
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Path) then
  begin
    // Check if already in PATH
    if Pos(Uppercase(InstallDir), Uppercase(Path)) = 0 then
    begin
      // Add to PATH
      if Length(Path) > 0 then
      begin
        if Path[Length(Path)] <> ';' then
          Path := Path + ';';
      end;
      Path := Path + InstallDir;

      // Write to registry
      RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Path);
    end;
  end;
end;

// Remove installation directory from PATH environment variable
procedure RemoveFromPath();
var
  Path: string;
  InstallDir: string;
begin
  InstallDir := ExpandConstant('{app}');

  if RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Path) then
  begin
    // Remove installation directory (handle both with and without trailing semicolon)
    StringChangeEx(Path, InstallDir + ';', '', True);
    StringChangeEx(Path, InstallDir, '', True);

    // Clean up possible double semicolons
    StringChangeEx(Path, ';;', ';', True);

    // Remove trailing semicolon
    if (Length(Path) > 0) and (Path[Length(Path)] = ';') then
      Delete(Path, Length(Path), 1);

    RegWriteStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Path);
  end;
end;

// Post-install actions
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    AddToPath();

    // Show installation success message
    if not WizardSilent() then
    begin
      MsgBox('Dufs has been successfully installed!' + #13#10 + #13#10 +
             'You can now:' + #13#10 +
             '1. Use "dufs" command directly in command line' + #13#10 +
             '2. Right-click on any folder to start Dufs service' + #13#10 + #13#10 +
             'Note: You may need to restart your command prompt to use dufs command.',
             mbInformation, MB_OK);
    end;
  end;
end;

// Pre-uninstall actions
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    RemoveFromPath();
  end;
end;
