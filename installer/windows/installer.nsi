SetCompressor /SOLID lzma

; Most of this is borrowed from the dub installer.

;--------------------------------------------------------
; Defines
;--------------------------------------------------------

; Options
!ifndef Version
    !define /ifndef Version "0.2.3"
!endif
!define DashExecPath "..\..\bin\"

;--------------------------------------------------------
; Includes
;--------------------------------------------------------

!include "MUI.nsh"
!include "EnvVarUpdate.nsh"

;--------------------------------------------------------
; General definitions
;--------------------------------------------------------

; Name of the installer
Name "Dash Command Line Utility ${Version}"

; Name of the output file of the installer
OutFile "dash-cli-${Version}-setup.exe"

; Where the program will be installed
InstallDir "$PROGRAMFILES\Dash"

; Take the installation directory from the registry, if possible
InstallDirRegKey HKLM "Software\Dash" ""

; Prevent installation of a corrupt installer
CRCCheck force

RequestExecutionLevel admin

;--------------------------------------------------------
; Interface settings
;--------------------------------------------------------

;!define MUI_ICON "installer-icon.ico"
;!define MUI_UNICON "uninstaller-icon.ico"

;--------------------------------------------------------
; Installer pages
;--------------------------------------------------------

!define MUI_WELCOMEFINISHPAGE_BITMAP "banner.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------------------------------
; The languages
;--------------------------------------------------------

!insertmacro MUI_LANGUAGE "English"


;--------------------------------------------------------
; Required section: main program files,
; registry entries, etc.
;--------------------------------------------------------
;
Section "Dash" DashFiles

    ; This section is mandatory
    SectionIn RO

    SetOutPath $INSTDIR

    ; Create installation directory
    CreateDirectory "$INSTDIR"

	  File "${DashExecPath}\dash.exe"
    File "${DashExecPath}\empty-game.zip"

    ; Create command line batch file
    FileOpen $0 "$INSTDIR\dashvars.bat" w
    FileWrite $0 "@echo.$\n"
    FileWrite $0 "@echo Setting up environment for using Dash from %~dp0$\n"
    FileWrite $0 "@set PATH=%~dp0;%PATH%$\n"
    FileClose $0

    ; Write installation dir in the registry
    WriteRegStr HKLM SOFTWARE\Dash "Install_Dir" "$INSTDIR"

    ; Write registry keys to make uninstall from Windows
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Dash" "DisplayName" "Dash Command Line Utility"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Dash" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Dash" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Dash" "NoRepair" 1
    WriteUninstaller "uninstall.exe"

SectionEnd

Section "Add to PATH" AddDashToPath

    ; Add Dash directory to path (for all users)
    ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR"

SectionEnd

Section /o "Start menu shortcuts" StartMenuShortcuts
    CreateDirectory "$SMPROGRAMS\Dash"

    ; install Dash command prompt
    CreateShortCut "$SMPROGRAMS\Dash\Dash Command Prompt.lnk" '%comspec%' '/k ""$INSTDIR\dashvars.bat""' "" "" SW_SHOWNORMAL "" "Open Dash Command Prompt"

    CreateShortCut "$SMPROGRAMS\Dash\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
SectionEnd

;--------------------------------------------------------
; Uninstaller
;--------------------------------------------------------

Section "Uninstall"

    ; Remove directories to path (for all users)
    ; (if for the current user, use HKCU)
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR"

    ; Remove stuff from registry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Dash"
    DeleteRegKey HKLM SOFTWARE\Dash
    DeleteRegKey /ifempty HKLM SOFTWARE\Dash

    ; This is for deleting the remembered language of the installation
    DeleteRegKey HKCU Software\Dash
    DeleteRegKey /ifempty HKCU Software\Dash

    ; Remove the uninstaller
    Delete $INSTDIR\uninstall.exe

    ; Remove shortcuts
    Delete "$SMPROGRAMS\Dash\Dash Command Prompt.lnk"

    ; Remove used directories
    RMDir /r /REBOOTOK "$INSTDIR"
    RMDir /r /REBOOTOK "$SMPROGRAMS\Dash"

SectionEnd
