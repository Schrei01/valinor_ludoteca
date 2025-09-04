[Setup]
AppName=Valinor Ludoteca
AppVersion=1.0
DefaultDirName={autopf}\Valinor Ludoteca
DefaultGroupName=Valinor Ludoteca
OutputBaseFilename=ValinorLudotecaInstaller
Compression=lzma
SolidCompression=yes

[Files]
; Copia todos los archivos del release
Source: "C:\Users\Vale\Desktop\Valinor\valinor_ludoteca_desktop\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
; Acceso directo en el menú inicio
Name: "{autoprograms}\Valinor Ludoteca"; Filename: "{app}\valinor_ludoteca_desktop.exe"

; Acceso directo en el escritorio
Name: "{commondesktop}\Valinor Ludoteca"; Filename: "{app}\valinor_ludoteca_desktop.exe"
