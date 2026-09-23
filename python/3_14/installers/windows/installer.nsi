; Windows installer for the command-line tool (https://nsis.sourceforge.io).
; installers/build.py compiles it with makensis and these defines:
;   APP_NAME, VERSION, VI_VERSION (X.Y.Z.W), PUBLISHER, SOURCE_DIR, OUTFILE
; The installer works per user: it needs no administrator rights, installs into
; %LOCALAPPDATA%\Programs\<APP_NAME> and adds that folder to the user's PATH.
; It runs no scripts or other programs - installers that launch PowerShell are
; a pattern antivirus heuristics flag - so PATH is edited in NSIS itself.
; Silent install: <setup>.exe /S   (optionally /D=<folder> as the last argument)

Unicode true
SetCompressor /SOLID lzma
RequestExecutionLevel user

!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "WinMessages.nsh"

!macro REQUIRE NAME
  !ifndef ${NAME}
    !error "${NAME} is not defined; build the installer with installers/build.py"
  !endif
!macroend
!insertmacro REQUIRE APP_NAME
!insertmacro REQUIRE VERSION
!insertmacro REQUIRE VI_VERSION
!insertmacro REQUIRE PUBLISHER
!insertmacro REQUIRE SOURCE_DIR
!insertmacro REQUIRE OUTFILE

!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
!define ENV_KEY "Environment"

Name "${APP_NAME} ${VERSION}"
OutFile "${OUTFILE}"
InstallDir "$LOCALAPPDATA\Programs\${APP_NAME}"
InstallDirRegKey HKCU "${UNINSTALL_KEY}" "InstallLocation"
ShowInstDetails show
ShowUninstDetails show

VIProductVersion "${VI_VERSION}"
VIFileVersion "${VI_VERSION}"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "FileDescription" "${APP_NAME} ${VERSION} installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "CompanyName" "${PUBLISHER}"
VIAddVersionKey "LegalCopyright" "${PUBLISHER}"

!define MUI_ABORTWARNING
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

; ---- User PATH -------------------------------------------------------------
; NSIS strings hold at most ${NSIS_MAX_STRLEN} characters and silently cut
; longer ones. A PATH that does not fit is therefore left alone: writing back a
; truncated copy would delete the user's other entries.

Var PathValue  ; the stored user PATH, %VARIABLE% references unexpanded
Var PathState  ; "ok", or "too-long" if it does not fit in an NSIS string
Var PathKept   ; PathValue without the install folder
Var PathFound  ; 1 if PathValue contains the install folder

!macro PATH_FUNCTIONS UN
  ; Reads the user PATH into $PathValue and sets $PathState.
  Function ${UN}ReadUserPath
    StrCpy $PathState "ok"
    ClearErrors
    ReadRegStr $PathValue HKCU "${ENV_KEY}" "Path"
    ${If} ${Errors}
      ; There is either no user PATH yet or one too long to read; the value
      ; names tell the two apart.
      StrCpy $PathValue ""
      StrCpy $R0 0
      ${Do}
        ClearErrors
        EnumRegValue $R1 HKCU "${ENV_KEY}" $R0
        ${If} ${Errors}
        ${OrIf} $R1 == ""
          ${ExitDo}
        ${EndIf}
        ${If} $R1 == "Path"
          StrCpy $PathState "too-long"
          ${ExitDo}
        ${EndIf}
        IntOp $R0 $R0 + 1
      ${Loop}
    ${EndIf}
  FunctionEnd

  ; Sets $PathKept to $PathValue without the install folder, comparing entries
  ; case-insensitively and ignoring a trailing backslash, and sets $PathFound.
  Function ${UN}SplitUserPath
    StrCpy $PathKept ""
    StrCpy $PathFound 0
    StrLen $R0 $PathValue
    StrCpy $R1 0   ; position in $PathValue
    StrCpy $R2 ""  ; the entry being read
    ${Do}
      ${If} $R1 < $R0
        StrCpy $R3 $PathValue 1 $R1
      ${Else}
        StrCpy $R3 ";"  ; the end of the value ends the last entry
      ${EndIf}
      ${If} $R3 != ";"
        StrCpy $R2 "$R2$R3"
      ${ElseIf} $R2 != ""
        StrCpy $R4 $R2
        StrCpy $R5 $R2 1 -1
        ${IfThen} $R5 == "\" ${|} StrCpy $R4 $R2 -1 ${|}
        ${If} $R4 == $INSTDIR
          StrCpy $PathFound 1
        ${ElseIf} $PathKept == ""
          StrCpy $PathKept $R2
        ${Else}
          StrCpy $PathKept "$PathKept;$R2"
        ${EndIf}
        StrCpy $R2 ""
      ${EndIf}
      ${IfThen} $R1 >= $R0 ${|} ${ExitDo} ${|}
      IntOp $R1 $R1 + 1
    ${Loop}
  FunctionEnd
!macroend
!insertmacro PATH_FUNCTIONS ""
!insertmacro PATH_FUNCTIONS "un."

; Stores VALUE as the user PATH (deleting the value when it is empty) and tells
; running programs, so that terminals opened from now on see the change.
!macro WRITE_USER_PATH VALUE
  ${If} "${VALUE}" == ""
    DeleteRegValue HKCU "${ENV_KEY}" "Path"
  ${Else}
    WriteRegExpandStr HKCU "${ENV_KEY}" "Path" "${VALUE}"
  ${EndIf}
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=5000
!macroend

Section "Install"
  ; Remove the runtime of a previous version so that no stale files remain.
  RMDir /r "$INSTDIR\_internal"
  SetOutPath "$INSTDIR"
  File /r "${SOURCE_DIR}\*"
  WriteUninstaller "$INSTDIR\uninstall.exe"

  ; Entry in Settings > Apps > Installed apps
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "${PUBLISHER}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\${APP_NAME}.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKCU "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /S'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1

  ; Put the install folder on the user's PATH, unless it is already there.
  Call ReadUserPath
  ${If} $PathState != "ok"
    DetailPrint "PATH is too long to change safely; add $INSTDIR to it yourself."
  ${Else}
    Call SplitUserPath
    ${If} $PathFound == 0
      ${Do}  ; drop trailing separators so that no empty entry appears
        StrCpy $R0 $PathValue 1 -1
        ${IfThen} $R0 != ";" ${|} ${ExitDo} ${|}
        StrCpy $PathValue $PathValue -1
      ${Loop}
      StrLen $R0 $PathValue
      StrLen $R1 $INSTDIR
      IntOp $R0 $R0 + $R1
      IntOp $R0 $R0 + 1  ; the separator
      ${If} $R0 >= ${NSIS_MAX_STRLEN}
        DetailPrint "PATH would get too long to change safely; add $INSTDIR to it yourself."
      ${ElseIf} $PathValue == ""
        !insertmacro WRITE_USER_PATH "$INSTDIR"
      ${Else}
        !insertmacro WRITE_USER_PATH "$PathValue;$INSTDIR"
      ${EndIf}
    ${EndIf}
  ${EndIf}
SectionEnd

Section "Uninstall"
  ; Take the install folder off the user's PATH.
  Call un.ReadUserPath
  ${If} $PathState != "ok"
    DetailPrint "PATH is too long to change safely; remove $INSTDIR from it yourself."
  ${Else}
    Call un.SplitUserPath
    ${If} $PathFound == 1
      !insertmacro WRITE_USER_PATH "$PathKept"
    ${EndIf}
  ${EndIf}

  ; Delete only what the installer created - never the whole folder
  ; recursively, in case it was installed into a folder with other files.
  RMDir /r "$INSTDIR\_internal"
  Delete "$INSTDIR\${APP_NAME}.exe"
  Delete "$INSTDIR\uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "${UNINSTALL_KEY}"
SectionEnd
