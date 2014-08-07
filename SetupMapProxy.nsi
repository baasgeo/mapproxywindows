/**
 * Copyright (c) 2014 Baas geo-information
 * 
 * MapProxy Windows installer creation file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Bart Baas <info@baasgeo.com>
 */

; Define your application name
!define APPNAME "MapProxy"
!define COMPANY "Baas geo-information"
!define VERSION 1.7.1
!define SEQ 0
!define APPNAMEANDVERSION "${APPNAME} ${VERSION}"
!define GITPAGE "http://github.com/bartbaas/mapproxywindows"
!define SETTINGSREGPATH "Software\Baasgeo\${APPNAME}"
!define UNINSTALLREGPATH "Software\Microsoft\Windows\CurrentVersion\Uninstall"

; Main Install settings
Name "${APPNAMEANDVERSION}"
BrandingText "${GITPAGE}"
InstallDir "$PROGRAMFILES\${APPNAME}-${VERSION}"
OutFile "${APPNAME}-${VERSION}-RC2.exe"

; Compression options
CRCCheck on

; For Vista
RequestExecutionLevel admin

; Plugins
!include ConfigWrite.nsh
!include ShellLinkRunAs.nsh
 
; Modern interface settings
!include "MUI.nsh" ; Modern interface
!include "StrFunc.nsh" ; String functions
!include "LogicLib.nsh" ; ${If} ${Case} etc.
!include "nsDialogs.nsh" ; For Custom page layouts (Radio buttons etc)

; Macro's
!define FindRegSetting "!insertmacro FindRegSetting"
!macro FindRegSetting _Key _Result
	Push ${_Key}
	
	StrCpy $0 0
	loop:
	  EnumRegKey $1 HKLM "${SETTINGSREGPATH}" $0
	  StrCmp $1 "" done
	  ReadRegStr ${_Result} HKLM "${SETTINGSREGPATH}\$1" ${_Key}
	  IntOp $0 $0 + 1
	  goto loop
	done:
	StrCpy $0 ""
	StrCpy $1 ""
	Push ${_Result}
!macroend

; Might be the same as !define
Var StartMenuFolder
Var DataDir
Var DataDirTemp
Var DataDirHWND
Var BrowseDataDirHWND
Var DataDirPathCheck
Var IsExisting
Var DefaultDataDir
Var ExistingDataDir
Var IsManual
Var Manual
Var Service
Var Port
Var PortHWND

; Version Information (Version tab for EXE properties)
VIProductVersion "${VERSION}.${SEQ}"
VIAddVersionKey ProductName "${APPNAME}"
VIAddVersionKey FileDescription "${APPNAME} Installer"
VIAddVersionKey ProductVersion "${VERSION}.${SEQ}"
VIAddVersionKey FileVersion "${VERSION}.${SEQ}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey LegalCopyright "${COMPANY}"
VIAddVersionKey Comments "${GITPAGE}"

; Install options page headers
LangString TEXT_DATADIR_TITLE ${LANG_ENGLISH} "${APPNAME} Data Directory"
LangString TEXT_DATADIR_SUBTITLE ${LANG_ENGLISH} "${APPNAME} Data Directory path selection"
LangString TEXT_TYPE_TITLE ${LANG_ENGLISH} "Type of Installation"
LangString TEXT_TYPE_SUBTITLE ${LANG_ENGLISH} "Select the type of installation"
LangString TEXT_READY_TITLE ${LANG_ENGLISH} "Ready to Install"
LangString TEXT_READY_SUBTITLE ${LANG_ENGLISH} "${APPNAME} is ready to be installed"
LangString TEXT_CREDS_TITLE ${LANG_ENGLISH} "${APPNAME} Administrator"
LangString TEXT_CREDS_SUBTITLE ${LANG_ENGLISH} "Set administrator credentials"
LangString TEXT_PORT_TITLE ${LANG_ENGLISH} "${APPNAME} Web Server Port"
LangString TEXT_PORT_SUBTITLE ${LANG_ENGLISH} "Set the port that ${APPNAME} will respond on"

; Interface Settings
!define MUI_ICON "mapproxy.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP header.bmp
!define MUI_WELCOMEFINISHPAGE_BITMAP side_left.bmp

; Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${SETTINGSREGPATH}\${VERSION}" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

; "Are you sure you wish to cancel" popup.
!define MUI_ABORTWARNING

; Optional text settings here
!define MUI_FINISHPAGE_LINK " Installer created and maintained by B. Baas $\n ${GITPAGE}"
!define MUI_FINISHPAGE_LINK_LOCATION "${GITPAGE}"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${APPNAMEANDVERSION}. \r\n\r\n\
	It is recommended that you close all other applications before starting Setup.\
	This will make it possible to update relevant system files without having to reboot your computer.\r\n\r\n\
	Please report any problems or suggestions to the ${APPNAME} Users mailing list: mapproxy@lists.osgeo.org. \r\n\r\n\
	Click Next to continue."

; Install Page order
; This is the main list of installer things to do 
!insertmacro MUI_PAGE_WELCOME                                 ; Hello
Page custom CheckUserType                                     ; Die if not admin
!insertmacro MUI_PAGE_LICENSE "license.txt"                   ; Show license
!insertmacro MUI_PAGE_DIRECTORY                               ; Where to install
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder ; Start menu location
Page custom GetDataDir                                        ; Look for existing data_dir
Page custom DataDir DataDirLeave                              ; Set the data directory
Page custom Port                                              ; Set web server port
Page custom InstallType InstallTypeLeave                      ; Manual/Service
Page custom Ready                                             ; Summary page
!insertmacro MUI_PAGE_INSTFILES                               ; Actually do the install
!insertmacro MUI_PAGE_FINISH                                  ; Done

; Uninstall Page order
!insertmacro MUI_UNPAGE_CONFIRM   ; Are you sure you wish to uninstall?
!insertmacro MUI_UNPAGE_INSTFILES ; Do the uninstall

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

; Check the user type, and quit if it's not an administrator.
; Taken from Examples/UserInfo that ships with NSIS.
Function CheckUserType
  ClearErrors
  UserInfo::GetName
  IfErrors Win9x
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  StrCmp $1 "Admin" Admin NoAdmin

  NoAdmin:
    MessageBox MB_ICONSTOP "Sorry, you must have administrative rights in order to install ${APPNAME}."
    Quit

  Win9x:
    MessageBox MB_ICONSTOP "This installer is not supported on Windows 9x/ME."
    Quit
		
  Admin:
  StrCpy $1 "" ; zero out variable
	
FunctionEnd

; Find the %MAPPROXY_DATA_DIR% used on the system, and put the result on the top of the stack
Function FindDataDirPath

  ClearErrors
  ; First check for variable
  ReadEnvStr $1 MAPPROXY_DATA_DIR
  ; Otherwise check for registry setting
  ${If} $1 == ""
    ${FindRegSetting} "DataDir" $1
  ${EndIf}
  IfFileExists $1 NoErrors Errors

  NoErrors:
    ClearErrors
    StrCpy $IsExisting 1
    Goto End

  Errors:
    ClearErrors
    StrCpy $1 "" ; not found
    StrCpy $IsExisting 0
    Goto End

  End:
    ClearErrors
    Push $1

FunctionEnd

; Runs before the page is loaded to ensure that the better value (if any) is always reset
Function GetDataDir

  ${If} $DataDir == ""
    Call FindDataDirPath
	Pop $DataDir
  ${EndIf}

FunctionEnd

; Data_dir page display
Function DataDir
        
  !insertmacro MUI_HEADER_TEXT "$(TEXT_DATADIR_TITLE)" "$(TEXT_DATADIR_SUBTITLE)"
  
  SetShellVarContext all
  
  StrCpy $DataDirTemp $DataDir

  Call DataDirPathValidInit
  Pop $8

  nsDialogs::Create 1018
  ; ${NSD_Create*} x y width height text

  ${NSD_CreateLabel} 0 0 100% 24u "If you have an existing data directory, please select its path.  \
                                   Otherwise, the default data directory will be used."

  ${NSD_CreateRadioButton} 10u 36u 10u 10u
  Pop $DefaultDataDir

  ${NSD_CreateLabel} 25u 37u 250u 24u "Default data directory. Will be located at: \
                                       $\r$\n$APPDATA\${APPNAME}"

  ${NSD_CreateRadioButton} 10u 80u 10u 10u
  Pop $ExistingDataDir

  ${NSD_CreateLabel} 25u 81u 250u 12u "Existing data directory:"

  ${NSD_CreateDirRequest} 25u 94u 215u 13u $DataDirTemp
  Pop $DataDirHWND
  ${NSD_OnChange} $DataDirHWND DataDirPathValid
  Pop $9

  ${NSD_CreateBrowseButton} 242u 94u 50u 13u "Browse..."
  Pop $BrowseDataDirHWND
  ${NSD_OnClick} $BrowseDataDirHWND BrowseDataDir

  ${NSD_CreateLabel} 26u 108u 100% 12u " "
  Pop $DataDirPathCheck

  ${If} $8 == "validDataDir"
    ${NSD_SetText} $DataDirPathCheck "This path contains a valid data directory"
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 1 ; Turns on
  ${EndIf}
  ${If} $8 == "novalidDataDir"
    ${If} $IsExisting == 1  ; Dont' turn off unless the radio box is checked!
      ${NSD_SetText} $DataDirPathCheck "This path does not contain a valid data directory"
      GetDlgItem $0 $HWNDPARENT 1 ; Next
      EnableWindow $0 0 ; Turns off
    ${EndIf}
  ${EndIf}

  ; default check box
  ${If} $IsExisting == 1
    ${NSD_Check} $ExistingDataDir
  ${Else}
    ${NSD_Check} $DefaultDataDir
  ${EndIf}


  ${NSD_OnClick} $ExistingDataDir CheckBoxDataDirExisting
  ${NSD_OnClick} $DefaultDataDir CheckBoxDataDirDefault
   
  nsDialogs::Show
  
FunctionEnd

; Runs when page is initialized
Function DataDirPathValidInit

    IfFileExists "$DataDir\mapproxy.yaml" NoErrors Errors

    NoErrors:
    StrCpy $8 "validDataDir"
    Goto End

    Errors:
    StrCpy $8 "novalidDataDir"
    
    End:
    Push $8

FunctionEnd

; Runs in real time
Function DataDirPathValid

    Pop $8
    ${NSD_GetText} $8 $DataDirTemp

    IfFileExists "$DataDirTemp\mapproxy.yaml" NoErrors Errors

    NoErrors:
      ${NSD_SetText} $DataDirPathCheck "This path contains a valid data directory"
      GetDlgItem $0 $HWNDPARENT 1 ; Next
      EnableWindow $0 1 ; Enable
      Goto End

    Errors:
      ${NSD_SetText} $DataDirPathCheck "This path does not contain a valid data directory"
      GetDlgItem $0 $HWNDPARENT 1 ; Next
      EnableWindow $0 0 ; Disable

    End:
      StrCpy $8 ""
      ClearErrors

FunctionEnd

; When Existing check box is checked
Function CheckBoxDataDirExisting

  ${NSD_GetText} $DataDirHWND $DataDirTemp
  IfFileExists "$DataDirTemp\*.yaml" NoErrors Errors

  NoErrors:
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 1 ; Enable
    Goto End

  Errors:
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 0 ; Disable

  End:
    ClearErrors
    StrCpy $IsExisting 1

FunctionEnd

; When Default check box is checked
Function CheckBoxDataDirDefault

  GetDlgItem $0 $HWNDPARENT 1 ; Next
  EnableWindow $0 1 ; Turns on
  StrCpy $IsExisting 0

FunctionEnd

; Brings up folder dialog
Function BrowseDataDir

  nsDialogs::SelectFolderDialog "Please select the location of your data directory..." $PROGRAMFILES
  Pop $1

  ${If} $1 != "error" ; i.e. didn't hit cancel
    ${NSD_SetText} $DataDirHWND $1 ; populate the field
    ${NSD_Check} $ExistingDataDir ; change the check box
    ${NSD_UnCheck} $DefaultDataDir ; change the check box
    StrCpy $IsExisting 1 ; now using existing datadir
  ${EndIf}  

FunctionEnd

; When done, set variable permanently
Function DataDirLeave

  ${If} $IsExisting == 0 ; use the default
    StrCpy $DataDir "$APPDATA\${APPNAME}"
  ${ElseIf} $IsExisting == 1
    StrCpy $DataDir $DataDirTemp
  ${EndIf}

FunctionEnd

; Set the web server port
Function Port

  !insertmacro MUI_HEADER_TEXT "$(TEXT_PORT_TITLE)" "$(TEXT_PORT_SUBTITLE)"
  nsDialogs::Create 1018

  ; Find the port used on the system
  ; First check for variable
  ReadEnvStr $Port MAPPROXY_PORT
  ; Otherwise check for registry setting
  ${If} $Port == ""
    ${FindRegSetting} "Port" $Port
  ${EndIf}
  ; Populates defaults on first display, and resets to default user blanked any of the values
  
  StrCmp $Port "" 0 +2
    StrCpy $Port "8080"

  ;Syntax: ${NSD_*} x y width height text
  ${NSD_CreateLabel} 0 0 100% 36u "Set the web server port that ${APPNAME} will respond on."

  ${NSD_CreateLabel} 20u 40u 20u 14u "Port"  
  ${NSD_CreateNumber} 50u 38u 50u 14u $Port
  Pop $PortHWND
  ${NSD_OnChange} $PortHWND PortCheck

  ${NSD_CreateLabel} 110u 40u 120u 14u "Valid range is 1024-65535." 

  nsDialogs::Show

FunctionEnd

; When port value is changed (realtime)
Function PortCheck

  ; Check for illegal values of $Port and fix immediately

  ${NSD_GetText} $PortHWND $Port

  ; Check for illegal values of $Port
  ${If} $Port < 1024        ; Too low
  ${OrIf} $Port > 65535     ; Too high
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 0 ; Disable
  ${Else}
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 1 ; Enable
  ${EndIf}

FunctionEnd

; Manual vs service selection
Function InstallType

  nsDialogs::Create 1018
  !insertmacro MUI_HEADER_TEXT "$(TEXT_TYPE_TITLE)" "$(TEXT_TYPE_SUBTITLE)"

  ;Syntax: ${NSD_*} x y width height text
  ${NSD_CreateLabel} 0 0 100% 24u 'Select the type of installation for ${APPNAME}.  If you are unsure of which option to choose, select the "Run manually" option.'
  ${NSD_CreateRadioButton} 10u 28u 50% 12u "Run manually"
  Pop $Manual

  ${NSD_CreateLabel} 10u 44u 90% 24u "Installed for the current user.  Must be manually started and stopped."
  ${NSD_CreateRadioButton} 10u 72u 50% 12u "Install as a service"
  Pop $Service

  ${If} $IsManual == 1
    ${NSD_Check} $Manual ; Default
  ${Else}
    ${NSD_Check} $Service
  ${EndIf}

  ${NSD_CreateLabel} 10u 88u 90% 24u "Installed for all users.  Will run as as a Windows Service for greater security."

  nsDialogs::Show

FunctionEnd

; Records the final state of manual vs service
Function InstallTypeLeave

  ${NSD_GetState} $Manual $IsManual
  ; $IsManual = 1 -> Run manually
  ; $IsManual = 0 -> Run as service

FunctionEnd

; Summary page before install
Function Ready

  nsDialogs::Create 1018
  !insertmacro MUI_HEADER_TEXT "$(TEXT_READY_TITLE)" "$(TEXT_READY_SUBTITLE)"

  ;Syntax: ${NSD_*} x y width height text
  ${NSD_CreateLabel} 0 0 100% 24u "Please review the settings below and click the Back button if \
                                   changes need to be made.  Click the Install button to continue."

  ; Directory
  ${NSD_CreateLabel} 10u 25u 35% 24u "Installation directory:"
  ${NSD_CreateLabel} 40% 25u 60% 24u "$INSTDIR"

  ; Install type
  ${NSD_CreateLabel} 10u 45u 35% 24u "Installation type:"
  ${If} $IsManual == 1
    ${NSD_CreateLabel} 40% 45u 60% 24u "Run manually"
  ${Else}
    ${NSD_CreateLabel} 40% 45u 60% 24u "Installed as a service"
  ${EndIf}

  ; Data dir
  ${NSD_CreateLabel} 10u 65u 35% 24u "Data Directory:"
  ${If} $IsExisting == 1
    ${NSD_CreateLabel} 40% 65u 60% 24u "Using existing data directory:$\r$\n$DataDir"
  ${Else}
    ${NSD_CreateLabel} 40% 65u 60% 24u "Using default data directory:$\r$\n$DataDir"
  ${EndIf}

  ; Port
  ${NSD_CreateLabel} 10u 95u 35% 24u "Port:"
  ${NSD_CreateLabel} 40% 95u 60% 24u "$Port"

  nsDialogs::Show

FunctionEnd

; The main install section
Section "Main" SectionMain
	
  SectionIn RO ; Makes this install mandatory
  SetOverwrite on

  ; Section Files and Shortcuts
  CreateDirectory "$INSTDIR"
  SetOutPath "$INSTDIR"
  File /a license.txt
  File /a mapproxy.ico
  File /r eggs
  File /r PortablePython\App
  
  ; Install mapproxy
  nsExec::ExecToLog '"$INSTDIR\App\Scripts\easy_install.exe" -f "eggs" mapproxy==${VERSION} Shapely pyproj cherrypy>=3.2'
  nsExec::ExecToLog '"$INSTDIR\App\Scripts\mapproxy-util.exe" --version'
  ${If} $IsExisting == 1
    Detailprint "Using existing data directory: $\r$\n$DataDir"
  ${Else}
	CreateDirectory "$DataDir"
    nsExec::ExecToLog '"$INSTDIR\App\Scripts\mapproxy-util.exe" create -t base-config "$DataDir"'
	nsExec::ExecToLog '"$INSTDIR\App\Scripts\mapproxy-util.exe" create -t log-ini "$DataDir\log.ini"'
  ${EndIf}

  ${If} $IsManual == 0 ; service
  
    File /a mapproxy_srv.py
	${ConfigWrite} "$INSTDIR\mapproxy_srv.py" "version=" "'${VERSION}'" $R0
	${ConfigWrite} "$INSTDIR\mapproxy_srv.py" "subkey=" "r'${SETTINGSREGPATH}\${VERSION}'" $R0
	${ConfigWrite} "$INSTDIR\mapproxy_srv.py" "server_ip=" "'0.0.0.0'" $R0
  
	nsExec::ExecToLog '"$INSTDIR\App\python.exe" "$INSTDIR\mapproxy_srv.py" install'
	
  ${ElseIf} $IsManual == 1 ; manual
  
    File /a app.py
	${ConfigWrite} "$INSTDIR\app.py" "subkey=" "r'${SETTINGSREGPATH}\${VERSION}'" $R0
	${ConfigWrite} "$INSTDIR\app.py" "server_ip=" "'0.0.0.0'" $R0

  ${EndIf}

SectionEnd

; What happens at the end of the install.
Section -FinishSection

  ; Fix to have pythonservice.exe find the python dll's
  CopyFiles "$INSTDIR\App\python27.dll" "$INSTDIR\App\Lib\site-packages\win32"
  CopyFiles "$INSTDIR\App\pywintypes27.dll" "$INSTDIR\App\Lib\site-packages\win32"

  ; Start Menu
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

  ; Create shortcuts
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APPNAME} Homepage.lnk" "http://mapproxy.org"
  
  ; Link to web admin page
  FileOpen $9 open_admin.bat w ; Opens a Empty File and fills it
  FileWrite $9 '@ECHO OFF'
  FileWrite $9 '$\r$\n'
  FileWrite $9 `FOR /f "tokens=2*" %%a IN ('reg query "HKLM\${SETTINGSREGPATH}\${VERSION}" /v Port 2^>^&1^|find "REG_"') DO @set PORT=%%b`
  FileWrite $9 '$\r$\n'
  FileWrite $9 'start "MapProxy admin" "http://localhost:%PORT%/mapproxy"'
  FileClose $9 ; Closes the file
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APPNAME} Web Admin Page.lnk" "$INSTDIR\open_admin.bat" \
			 "" "%SystemRoot%\system32\shell32.dll" 72
			 
  ; Link to data directory		 
  FileOpen $9 open_data.bat w ; Opens a Empty File and fills it
  FileWrite $9 '@ECHO OFF'
  FileWrite $9 '$\r$\n'
  FileWrite $9 `FOR /f "tokens=2*" %%a IN ('reg query "HKLM\${SETTINGSREGPATH}\${VERSION}" /v DataDir 2^>^&1^|find "REG_"') DO @set DATADIR=%%b`
  FileWrite $9 '$\r$\n'
  FileWrite $9 'start "MapProxy data" %DATADIR%'
  FileClose $9 ; Closes the file
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APPNAME} Data Directory.lnk" "$INSTDIR\open_data.bat" \
			 "" "%SystemRoot%\system32\shell32.dll" 4

  ${If} $IsManual == 0  ; service
  
    SetOutPath "$INSTDIR"

	FileOpen $9 start_mapproxy.bat w ; Opens a Empty File and fills it
	FileWrite $9 'call "$INSTDIR\App\python.exe" "$INSTDIR\mapproxy_srv.py" start' 
    FileClose $9 ; Closes the file
	
	FileOpen $9 stop_mapproxy.bat w ; Opens a Empty File and fills it
	FileWrite $9 'call "$INSTDIR\App\python.exe" "$INSTDIR\mapproxy_srv.py" stop' 
    FileClose $9 ; Closes the file

	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Start ${APPNAME}.lnk" "$INSTDIR\start_mapproxy.bat" \
				 "" "$INSTDIR\mapproxy.ico" 0
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Stop ${APPNAME}.lnk" "$INSTDIR\stop_mapproxy.bat" \
				 "" "$INSTDIR\mapproxy.ico" 0

	; Must run as admin
    ${ShellLinkSetRunAs} "$SMPROGRAMS\$StartMenuFolder\Start ${APPNAME}.lnk" $R0
	${ShellLinkSetRunAs} "$SMPROGRAMS\$StartMenuFolder\Stop ${APPNAME}.lnk" $R0

  ${ElseIf} $IsManual == 1 ; manual

    FileOpen $9 start_mapproxy.bat w ; Opens a Empty File and fills it
	FileWrite $9 '@ECHO OFF'
	FileWrite $9 '$\r$\n'
	FileWrite $9 '"$INSTDIR\App\python.exe" "$INSTDIR\app.py"' 
    FileClose $9 ; Closes the file
	
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Start ${APPNAME}.lnk" "$INSTDIR\start_mapproxy.bat" \
				 "" "$INSTDIR\mapproxy.ico" 0

  ${EndIf}

  !insertmacro MUI_STARTMENU_WRITE_END

  ; Registry
  WriteRegStr HKLM "${SETTINGSREGPATH}\${VERSION}" "" "$INSTDIR"
  WriteRegStr HKLM "${SETTINGSREGPATH}\${VERSION}" "Version" "${VERSION}"
  WriteRegStr HKLM "${SETTINGSREGPATH}\${VERSION}" "Port" "$Port"
  WriteRegStr HKLM "${SETTINGSREGPATH}\${VERSION}" "DataDir" "$DataDir"

  ; For the Add/Remove programs area
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "DisplayName" "${APPNAMEANDVERSION}"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "Version" "${VERSION}"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "DisplayIcon" "$INSTDIR\mapproxy.ico"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "HelpLink" "http://mapproxy.org"
  WriteRegDWORD HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "NoModify" "1"
  WriteRegDWORD HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "NoRepair" "1"

  WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

; Uninstall section
Section Uninstall

  ; Stop
  IfFileExists "$INSTDIR\mapproxy_srv.py" StopService StopManual
  StopService:
    nsExec::ExecToLog '"$INSTDIR\App\python.exe" "$INSTDIR\mapproxy_srv.py" stop"'
    Sleep 2000 ; to make sure it's fully stopped
    nsExec::ExecToLog '"$INSTDIR\App\python.exe" "$INSTDIR\mapproxy_srv.py" remove"'
    Goto Continue
  StopManual:
    ; Nothing to do here
  Continue:

  ; Do not remove env var MAPPROXY_DATA_DIR and MAPPROXY_PORT

  SetShellVarContext all
	
  ; Delete Shortcuts
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  RMDir /r "$SMPROGRAMS\$StartMenuFolder"
  
  ;Remove from registry...
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAMEANDVERSION}"
  DeleteRegKey HKLM "${SETTINGSREGPATH}\${VERSION}"

  ; Delete self
  Delete "$INSTDIR\uninstall.exe"

  ; Delete files/folders
  Delete license.txt
  Delete mapproxy.ico
  Delete mapproxy_srv.py
  RMDir /r "$INSTDIR\eggs"
  RMDir /r "$INSTDIR\App"
  Delete "$INSTDIR\*.*"

  RMDir "$INSTDIR\" ; no /r!

  IfFileExists "$INSTDIR\*.*" 0 +2
    MessageBox MB_OK|MB_ICONEXCLAMATION "Warning: Some files and folders could not be removed from:$\r$\n  $INSTDIR."  

SectionEnd

; The End
