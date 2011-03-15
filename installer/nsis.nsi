;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "SmarterMeter (${VERSION})"
  OutFile "../pkg/smartermeter-${VERSION}.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\SmarterMeter"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\SmarterMeter" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_ICON "../icons/smartermeter.ico"

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "..\LICENSE"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "SmarterMeter Base" SecBase

  SetOutPath "$INSTDIR"

  ;ADD YOUR OWN FILES HERE...
  File /r "../pkg/base/*"

  CreateDirectory "$SMPROGRAMS\SmarterMeter"
  CreateShortCut "$SMPROGRAMS\SmarterMeter\SmarterMeter.lnk" "$INSTDIR\smartermeter.exe"
  CreateShortCut "$SMPROGRAMS\SmarterMeter\Uninstall.lnk" "$INSTDIR\uninstall.exe"

  ;Store installation folder
  WriteRegStr HKCU "Software\SmarterMeter" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecBase ${LANG_ENGLISH} "The SmarterMeter application."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecBase} $(DESC_SecBase)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...

  Delete "$INSTDIR\*.rb"
  Delete "$INSTDIR\*.jar"
  Delete "$INSTDIR\*.exe"
  RMDIR  /r "$INSTDIR\gems"
  RMDIR  /r "$INSTDIR\icons"
  RMDIR  /r "$INSTDIR\smartermeter"

  Delete "$SMPROGRAMS\SmarterMeter\SmarterMeter.lnk"
  Delete "$SMPROGRAMS\SmarterMeter\Uninstall.lnk"
  RMDIR "$SMPROGRAMS\SmarterMeter"

  RMDir "$INSTDIR"

  DeleteRegKey /ifempty HKCU "Software\SmarterMeter"

SectionEnd
