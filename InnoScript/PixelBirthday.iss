; Script generated by the Inno Setup Script Wizard.
; This is the     === Pixel Birthday ===  script 2013-08-17
; Change all "Cosmic Rays" to "CosmicRays"
; Add PixelBirthday.ini file
; Fixed 'On the Web'
; Change output directory to C:\wamp\public_html\SETINet\Operation
; Add Palette files
; Add AppDetails.ini for Twitter

#pragma verboselevel 9
#define AppName "Pixel Birthday"
#define AppVersion GetFileVersion("C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\Debug\Win32\PixelBirthday.exe")
                                   
[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{3D26C3F7-6DC6-4877-ADFA-6AA56EBF263C}

;PrivilegesRequired=admin

AppName= PixelBirthday {#AppName} 
AppVersion={#AppVersion}
VersionInfoVersion={#AppVersion}


AppPublisher=SETI Net
AppPublisherURL=http://www.SETI.Net/
AppSupportURL=http://www.SETI.Net/
AppUpdatesURL=http://www.SETI.Net/
DefaultDirName={pf}\SETI Net\PixelBirthday
DefaultGroupName=SETI Net\PixelBirthday
;LicenseFile=D:\Engineering\ControlPanel\InnoScript\ControlPanel License File.rtf
InfoBeforeFile=C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\InnoScript\PixelBirthday Information File Before Installation.rtf
InfoAfterFile=C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\InnoScript\PixelBirthday Information File After Installation.rtf
OutputBaseFilename=SetUp PixelBirthday
; OutputDir=\\SAGAN\SETI Data
; OutputDir=C:\UwAmp\www\SETINet\Operation
OutputDir=C:\wamp\public_html\CosmicRays\Operation
SetupIconFile=C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\InnoScript\PixelBirthday.ico
Compression=lzma
SolidCompression=yes
TouchTime=current

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
;Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked  
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; 
 
[Files]
Source: "C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\Debug\Win32\PixelBirthday.exe"; DestDir: "{app}"; Flags: replacesameversion Touch
Source: "C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\Debug\Win32\PixelBirthday.ini"; DestDir: "{app}"; Flags: replacesameversion Touch
;        C:\Users\James Brown\Documents\RAD Studio\Projects\PixelBirthday\Debug\Win32
; Source: "D:\Engineering\ControlPanel\Build\Hits.csv"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
;  Problem here.  Works alright when OCXs are installed via other modules
; Source: "C:\UwAmp\www\SETINet\Operation\ControlPanel\Build\FoundET.wav"; DestDir: "{app}"; Flags: restartreplace sharedfile
;

[Icons]
Name: "{group}\PixelBirthday"; Filename: "{app}\PixelBirthday.exe"
Name: "{group}\{cm:ProgramOnTheWeb,PixelBirthday}"; Filename: "http://www.seti.net/CosmicRays/Operation/operation.htm"
Name: "{group}\{cm:UninstallProgram,PixelBirthday}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\PixelBirthday"; Filename: "{app}\PixelBirthday.exe"; Tasks: desktopicon


[Run]
Filename: "{app}\PixelBirthday.exe"; Description: "{cm:LaunchProgram,PixelBirthday}"; Flags: nowait postinstall skipifsilent

[Registry]
; Start "Software\My Company\My Program" keys under HKEY_CURRENT_USER and HKEY_LOCAL_MACHINE. The flags tell it to always delete the
; "My Program" keys upon uninstall, and delete the "My Company" keys if there is nothing left in them.
; Root: HKCU; Subkey: "Software\SETI Net"; Flags: uninsdeletekeyifempty
; Root: HKCU; Subkey: "Software\SETI Net\ControlPanel"; Flags: uninsdeletekey
; Root: HKCU; Subkey: "Software\SETI Net\Clock"; Flags: uninsdeletekey eName: "Path"; ValueData: "{app}"