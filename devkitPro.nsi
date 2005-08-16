; $Id: devkitPro.nsi,v 1.14 2005-08-16 08:07:49 wntrmute Exp $
; $Log: not supported by cvs2svn $
; Revision 1.13  2005/08/14 02:05:34  wntrmute
; don't select packages which haven't been installed
;
; Revision 1.12  2005/08/14 00:56:04  wntrmute
; default updater to remove downloads
;
; Revision 1.11  2005/08/13 06:38:28  wntrmute
; env vars removed on uninstall
;
; Revision 1.10  2005/08/12 10:43:35  wntrmute
; fixed pn2 file association
;
; Revision 1.9  2005/08/12 09:32:31  wntrmute
; set up default pn2 tools
; added nds examples
;
; Revision 1.8  2005/08/12 01:03:17  wntrmute
; only insert pn2 shortcut when installed
; hide devkitARM group when nothing to update
;
; Revision 1.7  2005/08/11 12:04:24  wntrmute
; added option to delete downloads
; fixed shortcut update
; delete old updaters
;
; Revision 1.6  2005/08/11 10:29:30  wntrmute
; added pn2 to shortcuts
; fixed new version download
;
; Revision 1.5  2005/08/10 13:54:12  wntrmute
; *** empty log message ***
;

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "devkitProUpdater"
!define PRODUCT_VERSION "1.0.5"
!define PRODUCT_PUBLISHER "devkitPro"
!define PRODUCT_WEB_SITE "http://www.devkitpro.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"
!define BUILD "6"

SetCompressor lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "zipdll.nsh"
!include "Sections.nsh"
!include "StrFunc.nsh"
${StrTok}
${StrRep}
${UnStrRep}

; MUI Settings
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "devkitPro.bmp" ; optional
!define MUI_ABORTWARNING "Are you sure you want to quit ${PRODUCT_NAME} ${PRODUCT_VERSION}?"
!define MUI_COMPONENTSPAGE_SMALLDESC

; Welcome page
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${PRODUCT_NAME}\r\nVersion ${PRODUCT_VERSION}"
!define MUI_WELCOMEPAGE_TEXT "${PRODUCT_NAME} automates the process of downloading, installing, and uninstalling devkitPro Components.\r\n\nClick Next to continue."
!insertmacro MUI_PAGE_WELCOME

Page custom ChooseMirrorPage
Page custom KeepFilesPage

var ChooseMessage

; Components page
!define MUI_PAGE_HEADER_SUBTEXT $ChooseMessage
!define MUI_PAGE_CUSTOMFUNCTION_PRE AbortComponents
!insertmacro MUI_PAGE_COMPONENTS

; Directory page
!define MUI_PAGE_HEADER_SUBTEXT "Choose the folder in which to install devkitPro."
!define MUI_DIRECTORYPAGE_TEXT_TOP "${PRODUCT_NAME} will install devkitPro components in the following directory. To install in a different folder click Browse and select another folder. Click Next to continue."
!define MUI_PAGE_CUSTOMFUNCTION_PRE AbortPage
!insertmacro MUI_PAGE_DIRECTORY

; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "devkitPro"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!define MUI_PAGE_CUSTOMFUNCTION_PRE AbortPage
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

var INSTALL_ACTION
; Instfiles page
!define MUI_PAGE_HEADER_SUBTEXT $INSTALL_ACTION 
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "Installation Aborted"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "The installation was not completed successfully."
!insertmacro MUI_PAGE_INSTFILES

var FINISH_TITLE
var FINISH_TEXT

; Finish page
!define MUI_FINISHPAGE_TITLE $FINISH_TITLE
!define MUI_FINISHPAGE_TEXT $FINISH_TEXT
!define MUI_FINISHPAGE_TEXT_LARGE $INSTALLED_TEXT
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
Caption "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${PRODUCT_NAME}-${PRODUCT_VERSION}.exe"
InstallDir "c:\devkitPro"
ShowInstDetails show
ShowUnInstDetails show

var MirrorName
var MirrorHost
var MirrorURL
var Install
var Updating
var MSYS
var MSYS_VER
var DEVKITARM
var DEVKITARM_VER
var DEVKITPPC
var DEVKITPPC_VER
var DEVKITPSP
var DEVKITPSP_VER
var LIBGBA
var LIBGBA_VER
var LIBNDS
var LIBNDS_VER
var NDSEXAMPLES
var NDSEXAMPLES_VER
var LIBMIRKO
var LIBMIRKO_VER
var PNOTEPAD
var PNOTEPAD_VER
var INSIGHT
var INSIGHT_VER

var BASEDIR

var Updates

Section "msys 1.0.10" SecMsys
  SectionIn RO
SectionEnd

SectionGroup devkitARM SecdevkitARM
	; Application
	Section "devkitARM" SecdkARM
	SectionEnd

	Section "libgba" Seclibgba
        SectionEnd

	Section "libmirko" Seclibmirko
	SectionEnd

	Section "libnds" Seclibnds
	SectionEnd

	Section "nds examples" ndsexamples
	SectionEnd

SectionGroupEnd

Section "devkitPPC" SecdevkitPPC
SectionEnd

Section "devkitPSP" SecdevkitPSP
SectionEnd

Section "Programmer's Notepad" Pnotepad
SectionEnd

Section "Insight" Secinsight
SectionEnd

Section -installComponents

  StrCpy $R0 $INSTDIR 1
  StrLen $0 $INSTDIR
  IntOp $0 $0 - 2
  
  StrCpy $R1 $INSTDIR $0 2
  ${StrRep} $R1 $R1 "\" "/"
  StrCpy $BASEDIR /$R0$R1


  push ${SecMsys}
  push $MSYS
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${SecdkARM}
  push $DEVKITARM
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${SecdevkitPPC}
  push $DEVKITPPC
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${SecdevkitPSP}
  push $DEVKITPSP
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${Seclibgba}
  push $LIBGBA
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${Seclibnds}
  push $LIBNDS
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${Seclibmirko}
  push $LIBMIRKO
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${ndsexamples}
  push $NDSEXAMPLES
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  push ${pnotepad}
  push $PNOTEPAD
  push $MirrorURL/pnotepad
  Call DownloadIfNeeded

  push ${Secinsight}
  push $INSIGHT
  push $MirrorURL/devkitpro
  Call DownloadIfNeeded

  IntCmp $Install 1 +1 SkipInstall SkipInstall

  IntCmp $Updating 1 test_Msys +1 +1

  CreateDirectory $INSTDIR
  File /oname=$INSTDIR\installed.ini INIfiles\installed.ini

  WriteINIStr $INSTDIR\installed.ini mirror url $MirrorURL

test_Msys:
  !insertmacro SectionFlagIsSet ${SecMsys} ${SF_SELECTED} install_Msys SkipMsys
install_Msys:

  RMDir /r $INSTDIR\msys

  ExecWait '"$EXEDIR\$MSYS" -y -o$INSTDIR'
  WriteINIStr $INSTDIR\installed.ini msys Version $MSYS_VER
  push $MSYS
  call RemoveFile

SkipMsys:
  push ${SecdkARM}
  push "DEVKITARM"
  push $DEVKITARM
  push "$BASEDIR/devkitARM"
  push "devkitARM"
  push $DEVKITARM_VER
  call ExtractToolChain

  push ${SecdevkitPPC}
  push "DEVKITPPC"
  push $DEVKITPPC
  push "$BASEDIR/devkitPPC"
  push "devkitPPC"
  push $DEVKITPPC_VER
  call ExtractToolChain

  push ${SecdevkitPSP}
  push "DEVKITPSP"
  push $DEVKITPSP
  push "$BASEDIR/devkitPSP"
  push "devkitPSP"
  push $DEVKITPSP_VER
  call ExtractToolChain

  push ${Seclibgba}
  push "libgba"
  push $LIBGBA
  push "libgba"
  push $LIBGBA_VER
  call ExtractLib
  
  push ${Seclibnds}
  push "libnds"
  push $LIBNDS
  push "libnds"
  push $LIBNDS_VER
  call ExtractLib

  push ${Seclibmirko}
  push "libmirko"
  push $LIBMIRKO
  push "libmirko"
  push $LIBMIRKO_VER
  call ExtractLib

  push ${ndsexamples}
  push "examples\nds"
  push $NDSEXAMPLES
  push "ndsexamples"
  push $NDSEXAMPLES_VER
  call ExtractLib

  !insertmacro SectionFlagIsSet ${Secinsight} ${SF_SELECTED} +1 SkipInsight

  RMDir /r "$INSTDIR/Insight"

  ExecWait '"$EXEDIR/$INSIGHT" -y -o$INSTDIR'
  WriteINIStr $INSTDIR\installed.ini insight Version $INSIGHT_VER
  push $INSIGHT
  call RemoveFile

SkipInsight:
  SectionGetFlags ${Pnotepad} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  IntCmp $R0 ${SF_SELECTED} +1 SkipPnotepad

  RMDir /r "$INSTDIR/Programmers Notepad"

  ZipDLL::extractall $EXEDIR/$PNOTEPAD "$INSTDIR/Programmers Notepad"
  push $PNOTEPAD
  call RemoveFile

  File "/oname=$APPDATA\Echo Software\PN2\UserTools.xml" pn2\UserTools.xml

  WriteRegStr HKCR ".pnproj" "" "PN2.pnproj.1"
  WriteRegStr HKCR "PN2.pnproj.1\shell\open\command" "" '"$INSTDIR\Programmers Notepad\pn.exe" "%1"'
  WriteINIStr $INSTDIR\installed.ini pnotepad Version $PNOTEPAD_VER

SkipPnotepad:

  Strcpy $R1 "${PRODUCT_NAME}-${PRODUCT_VERSION}.exe"

  Delete $INSTDIR\devkitProUpdater*.*
  StrCmp $EXEDIR $INSTDIR skip_copy

  CopyFiles $EXEDIR\$R1 $INSTDIR\$R1
skip_copy:

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetShellVarContext all ; Put stuff in All Users
  SetOutPath $INSTDIR
  IntCmp $Updating 1 CheckPN2
  WriteIniStr "$INSTDIR\devkitPro.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\devkitpro.lnk" "$INSTDIR\devkitPro.url"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  SetOutPath $INSTDIR\msys\bin
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\MSys.lnk" "$INSTDIR\msys\msys.bat" "-norxvt" "$INSTDIR\msys\m.ico"
CheckPN2:
  !insertmacro SectionFlagIsSet ${Pnotepad} ${SF_SELECTED} +1 SkipMenu
  SetOutPath "$INSTDIR\Programmers Notepad"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Programmers Notepad.lnk" "$INSTDIR\Programmers Notepad\pn.exe"
SkipMenu:
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Update.lnk" "$INSTDIR\$R1"
  !insertmacro MUI_STARTMENU_WRITE_END
  WriteUninstaller "$INSTDIR\uninst.exe"
  IntCmp $Updating 1 SkipInstall
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"

  WriteRegStr HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "DEVKITPRO" "$BASEDIR"
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  ReadRegStr $1 HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH"
  ; remove it to avoid multiple paths with separate installs
  ${StrRep} $1 $1 "$INSTDIR\msys\bin;" ""
  StrCpy $1 $INSTDIR\msys\bin;$1
  WriteRegExpandStr HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH" $1
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

SkipInstall:

SectionEnd

Section Uninstall
  SetShellVarContext all ; remove stuff from All Users
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  RMDir /r "$SMPROGRAMS\$ICONS_GROUP"
  RMDir /r $INSTDIR

  ReadRegStr $1 HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH"
  ${UnStrRep} $1 $1 "$INSTDIR\msys\bin;" ""
  WriteRegExpandStr HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH" $1
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  DeleteRegKey HKCR ".pnproj"
  DeleteRegKey HKCR "PN2.pnproj.1\shell\open\command"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  
  DeleteRegValue HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "DEVKITPPC"
  DeleteRegValue HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "DEVKITPSP"
  DeleteRegValue HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "DEVKITARM"
  DeleteRegValue HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "DEVKITPRO"
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  SetAutoClose true
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecMsys} "unix style tools for windows"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecdevkitARM} "toolchain for ARM platforms"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecdkARM} "toolchain for ARM platforms"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecdevkitPPC} "toolchain for powerpc platforms"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecdevkitPSP} "toolchain for psp"
  !insertmacro MUI_DESCRIPTION_TEXT ${Pnotepad} "a programmer's editor"
  !insertmacro MUI_DESCRIPTION_TEXT ${Seclibgba} "Nintendo GBA development library"
  !insertmacro MUI_DESCRIPTION_TEXT ${Seclibmirko} "Gamepark GP32 development library"
  !insertmacro MUI_DESCRIPTION_TEXT ${Seclibnds} "Nintendo DS development library"
  !insertmacro MUI_DESCRIPTION_TEXT ${ndsexamples} "Nintendo DS example code"
  !insertmacro MUI_DESCRIPTION_TEXT ${Secinsight} "GUI debugger"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

var INI

;-----------------------------------------------------------------------------------------------------------------------
Function .onInit
;-----------------------------------------------------------------------------------------------------------------------
  InitPluginsDir
  ifFileExists $EXEDIR\$R1 skipextract
  ; extract built in ini file
  File /oname=$EXEDIR\devkitProUpdate.ini INIfiles\devkitProUpdate.ini

skipextract:
  ; save the current ini file in case download fails
  Rename $EXEDIR\devkitProUpdate.ini $EXEDIR\devkitProUpdate.ini.old
  ; Quietly download the latest devkitProUpdate.ini file
  NSISdl::download_quiet "http://devkitpro.sourceforge.net/devkitProUpdate.ini" "$EXEDIR\devkitProUpdate.ini"

  Pop $0
  StrCmp $0 "success" gotINI

  ; download failed so retrieve old file
  Rename $EXEDIR\devkitProUpdate.ini.old $EXEDIR\devkitProUpdate.ini

gotINI:
  Delete $EXEDIR\devkitProUpdate.ini.old

  ; Read devkitProUpdate build info from INI file
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "devkitProUpdate" "Build"

  IntCmp ${BUILD} $R0 Finish newVersion Finish

  newVersion:
    MessageBox MB_YESNO|MB_ICONINFORMATION|MB_DEFBUTTON1 "A newer version of devkitProUpdater is available. Would you like to upgrade now?" IDYES upgradeMe IDNO Finish

  upgradeMe:
    Call UpgradedevkitProUpdate
  Finish:

  StrCpy $Updating 0

  StrCpy $ChooseMessage "Choose the devkitPro components you would like to install."

  ReadRegStr $1 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation"
  StrCmp $1 "" installing
  
  StrCpy $INSTDIR $1
  StrCpy $Updating 1

  StrCpy $ChooseMessage "Choose the devkitPro components you would like to update."

installing:

  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "msys" "Size"
  ReadINIStr $MSYS "$EXEDIR\devkitProUpdate.ini" "msys" "File"
  ReadINIStr $MSYS_VER "$EXEDIR\devkitProUpdate.ini" "msys" "Version"
  SectionSetSize ${SecMsys} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "devkitARM" "Size"
  ReadINIStr $DEVKITARM "$EXEDIR\devkitProUpdate.ini" "devkitARM" "File"
  ReadINIStr $DEVKITARM_VER "$EXEDIR\devkitProUpdate.ini" "devkitARM" "Version"
  SectionSetSize ${SecdkARM} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "devkitPPC" "Size"
  ReadINIStr $DEVKITPPC "$EXEDIR\devkitProUpdate.ini" "devkitPPC" "File"
  ReadINIStr $DEVKITPPC_VER "$EXEDIR\devkitProUpdate.ini" "devkitPPC" "Version"
  SectionSetSize ${SecdevkitPPC} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "devkitPSP" "Size"
  ReadINIStr $DEVKITPSP "$EXEDIR\devkitProUpdate.ini" "devkitPSP" "File"
  ReadINIStr $DEVKITPSP_VER "$EXEDIR\devkitProUpdate.ini" "devkitPSP" "Version"
  SectionSetSize ${SecdevkitPSP} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "libgba" "Size"
  ReadINIStr $LIBGBA "$EXEDIR\devkitProUpdate.ini" "libgba" "File"
  ReadINIStr $LIBGBA_VER "$EXEDIR\devkitProUpdate.ini" "libgba" "Version"
  SectionSetSize ${Seclibgba} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "libnds" "Size"
  ReadINIStr $LIBNDS "$EXEDIR\devkitProUpdate.ini" "libnds" "File"
  ReadINIStr $LIBNDS_VER "$EXEDIR\devkitProUpdate.ini" "libnds" "Version"
  SectionSetSize ${Seclibnds} $R0

  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "ndsexamples" "Size"
  ReadINIStr $NDSEXAMPLES "$EXEDIR\devkitProUpdate.ini" "ndsexamples" "File"
  ReadINIStr $NDSEXAMPLES_VER "$EXEDIR\devkitProUpdate.ini" "ndsexamples" "Version"
  SectionSetSize ${ndsexamples} $R0

  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "libmirko" "Size"
  ReadINIStr $LIBMIRKO "$EXEDIR\devkitProUpdate.ini" "libmirko" "File"
  ReadINIStr $LIBMIRKO_VER "$EXEDIR\devkitProUpdate.ini" "libmirko" "Version"
  SectionSetSize ${Seclibmirko} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "pnotepad" "Size"
  ReadINIStr $PNOTEPAD "$EXEDIR\devkitProUpdate.ini" "pnotepad" "File"
  ReadINIStr $PNOTEPAD_VER "$EXEDIR\devkitProUpdate.ini" "pnotepad" "Version"
  SectionSetSize ${Pnotepad} $R0
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "insight" "Size"
  ReadINIStr $INSIGHT "$EXEDIR\devkitProUpdate.ini" "insight" "File"
  ReadINIStr $INSIGHT_VER "$EXEDIR\devkitProUpdate.ini" "insight" "Version"
  SectionSetSize ${Secinsight} $R0

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "Dialogs\PickMirror.ini" "PickMirror.ini"


  GetTempFileName $INI $PLUGINSDIR
  File /oname=$INI "Dialogs\keepfiles.ini"

  ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "Dialogs\keepfiles.ini" "keepfiles.ini"

  IntCmp $Updating 1 +1 first_install

  ReadINIStr $MirrorURL "$INSTDIR\installed.ini" "mirror" "url"

  StrCpy $Updates 0

  !insertmacro SetSectionFlag SecdevkitARM SF_EXPAND
  !insertmacro SetSectionFlag SecdevkitARM SF_TOGGLED

  ReadINIStr $0 "$INSTDIR\installed.ini" "devkitARM" "Version"

  push $0
  push $DEVKITARM_VER
  push ${SecdkARM}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "libmirko" "Version"

  push $0
  push $LIBMIRKO_VER
  push ${Seclibmirko}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "libgba" "Version"

  push $0
  push $LIBGBA_VER
  push ${Seclibgba}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "libnds" "Version"

  push $0
  push $LIBNDS_VER
  push ${Seclibnds}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "ndsexamples" "Version"

  push $0
  push $NDSEXAMPLES_VER
  push ${ndsexamples}
  call checkVersion

  IntCmp $Updates 0 +1 dkARMupdates dkARMupdates

  SectionSetText ${SecdevkitARM} ""

dkARMupdates:
  ReadINIStr $0 "$INSTDIR\installed.ini" "msys" "Version"

  push $0
  push $MSYS_VER
  push ${SecMsys}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "devkitPPC" "Version"

  push $0
  push $DEVKITPPC_VER
  push ${SecdevkitPPC}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "devkitPSP" "Version"

  push $0
  push $DEVKITPSP_VER
  push ${SecdevkitPSP}
  call checkVersion


  ReadINIStr $0 "$INSTDIR\installed.ini" "pnotepad" "Version"

  push $0
  push $PNOTEPAD_VER
  push ${Pnotepad}
  call checkVersion

  ReadINIStr $0 "$INSTDIR\installed.ini" "insight" "Version"

  push $0
  push $INSIGHT_VER
  push ${Secinsight}
  call checkVersion

first_install:

FunctionEnd

var CurrentVer
var InstalledVer
var PackageSection
var PackageFlags
;-----------------------------------------------------------------------------------------------------------------------
Function checkVersion
;-----------------------------------------------------------------------------------------------------------------------
  pop $PackageSection
  pop $CurrentVer
  pop $InstalledVer

  SectionGetFlags $PackageSection $PackageFlags

  IntOp $R1 ${SF_RO} ~
  IntOp $PackageFlags $PackageFlags & $R1
  IntOp $PackageFlags $PackageFlags & ${SECTION_OFF}

  StrCmp $CurrentVer $InstalledVer noupdate
  
  Intop $Updates $Updates + 1
  
  ; don't select if not installed
  StrCmp $InstalledVer 0 done
  
  IntOp $PackageFlags $PackageFlags | ${SF_SELECTED}

  Goto done

noupdate:

  SectionSetText $PackageSection ""

done:
  SectionSetFlags $PackageSection $PackageFlags

FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------
Function .onVerifyInstDir
;-----------------------------------------------------------------------------------------------------------------------
  StrCpy $R0 $INSTDIR 1 1
;  IfFileExists $INSTDIR\Winamp.exe PathGood
;    Abort ;
;PathGood:
FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------
Function un.onUninstSuccess
;-----------------------------------------------------------------------------------------------------------------------
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "devkitPro was successfully removed from your computer."
FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------
Function un.onInit
;-----------------------------------------------------------------------------------------------------------------------
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove devkitPro and all of its components?" IDYES +2
  Abort
FunctionEnd


;-----------------------------------------------------------------------------------------------------------------------
Function UpgradedevkitProUpdate
;-----------------------------------------------------------------------------------------------------------------------
  ReadINIStr $R0 "$EXEDIR\devkitProUpdate.ini" "devkitProUpdate" "URL"
  ReadINIStr $R1 "$EXEDIR\devkitProUpdate.ini" "devkitProUpdate" "Filename"

  DetailPrint "Downloading new version of devkitProUpdater..."
  NSISdl::download $R0/$R1 "$EXEDIR\$R1"
  Pop $0
  StrCmp $0 success success
    ; Failure
    SetDetailsView show
    DetailPrint "Download failed: $0"
    Abort

  success:
    MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to run the new version of devkitProUpdater now?" IDYES runNew
    return

  runNew:
    Exec "$EXEDIR\$R1"
    Quit
FunctionEnd


;-----------------------------------------------------------------------------------------------------------------------
Function AbortComponents
;-----------------------------------------------------------------------------------------------------------------------

  IntCmp $Updating 1 +1 ShowPage ShowPage

  IntCmp $Updates 0 +1 Showpage Showpage
  
  StrCpy $FINISH_TEXT "${PRODUCT_NAME} found no updates to install."
  Abort

ShowPage:

FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------
Function AbortPage
;-----------------------------------------------------------------------------------------------------------------------

  IntCmp $Updating 1 +1 TestInstall TestInstall
    Abort

TestInstall:
  IntCmp $Install 1 ShowPage +1 +1
    Abort

ShowPage:
FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------
Function DownloadIfNeeded
;-----------------------------------------------------------------------------------------------------------------------
  pop $R0  ; URL
  pop $R1  ; Filename
  pop $R3  ; section flags

  SectionGetFlags $R3 $0
  IntOp $0 $0 & ${SF_SELECTED}
  IntCmp $0 ${SF_SELECTED} +1 SkipDL

  ifFileExists $EXEDIR\$R1 FileFound

  nsisdl::download $R0/$R1 $EXEDIR\$R1
  Pop $0
  StrCmp $0 success FileFound
  Abort "Could not download $R1!"
SkipDL:
FileFound:
FunctionEnd

var LIB
var FOLDER


;-----------------------------------------------------------------------------------------------------------------------
Function ExtractToolChain
;-----------------------------------------------------------------------------------------------------------------------
  pop $R5  ; version
  pop $R4  ; section name
  pop $R3  ; path
  pop $R2  ; 7zip sfx
  pop $R1  ; env variable
  pop $R0  ; section flags

  SectionGetFlags $R0 $0
  IntOp $0 $0 & ${SF_SELECTED}
  IntCmp $0 ${SF_SELECTED} +1 SkipExtract

  RMDir /r $INSTDIR\$R4

  ExecWait '"$EXEDIR\$R2" -y -o$INSTDIR'

  WriteRegStr HKLM "System\CurrentControlSet\Control\Session Manager\Environment" $R1 $R3
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  WriteINIStr $INSTDIR\installed.ini $R4 Version $R5

  push $R2
  call RemoveFile

SkipExtract:

FunctionEnd

;-----------------------------------------------------------------------------------------------------------------------
Function ExtractLib
;-----------------------------------------------------------------------------------------------------------------------
  pop $R3  ; version
  pop $R2  ; section name
  pop $LIB ; filename
  pop $FOLDER ; extract to
  pop $R0  ; section flags

  SectionGetFlags $R0 $0
  IntOp $0 $0 & ${SF_SELECTED}
  IntCmp $0 ${SF_SELECTED} +1 SkipExtract


  RMDir /r $INSTDIR\$FOLDER

  untgz::extract -d "$INSTDIR/$FOLDER" -zbz2 "$EXEDIR/$LIB"

  WriteINIStr $INSTDIR\installed.ini $R2 Version $R3
  push $LIB
  call RemoveFile

SkipExtract:

FunctionEnd

var keepfiles

;-----------------------------------------------------------------------------------------------------------------------
Function KeepFilesPage
;-----------------------------------------------------------------------------------------------------------------------
  StrCpy $keepfiles 0
  IntCmp $Install 0 nodisplay

  IntCmp $Updating 1 +1 defaultkeep

  WriteINIStr $INI "Field 3" "State" 0
  WriteINIStr $INI "Field 2" "State" 1
  FlushINI $INI

defaultkeep:

  InstallOptions::initDialog /NOUNLOAD "$INI"
  InstallOptions::show

  ReadINIStr $keepfiles $INI "Field 3" "State"

nodisplay:
FunctionEnd

var filename

;-----------------------------------------------------------------------------------------------------------------------
Function RemoveFile
;-----------------------------------------------------------------------------------------------------------------------
  pop $filename
  IntCmp $keepfiles 1 keepit

  Delete $EXEDIR\$filename

keepit:

FunctionEnd
;-----------------------------------------------------------------------------------------------------------------------
; faking an array using separators
;-----------------------------------------------------------------------------------------------------------------------
!define hosts "jaist|keihanna|nchc|puzzle|heanet|mesh|kent|switch|citkit|ovh|peterhost|internap|umn|easynews|ufpr"
;-----------------------------------------------------------------------------------------------------------------------
Function ChooseMirrorPage
;-----------------------------------------------------------------------------------------------------------------------
  IntCmp $Updating 1 update +1


  ; Display the page.
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "PickMirror.ini"
  ; Get the user entered values.
  !insertmacro MUI_INSTALLOPTIONS_READ $MirrorName "PickMirror.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $Install "PickMirror.ini" "Field 2" "State"

  ; first two digits of the field are an array index
  StrCpy $0 $MirrorName 2
  IntOp $0 $0 - 1
  
  ${StrTok} $MirrorHost ${hosts} "|" $0 0
  StrCpy $MirrorURL "http://$MirrorHost.dl.sourceforge.net/sourceforge"

  IntCmp $Install 1 install +1 +1

  StrCpy $INSTALL_ACTION "Please wait while ${PRODUCT_NAME} downloads the components you selected."
  StrCpy $FINISH_TITLE "Download complete."
  StrCpy $FINISH_TEXT "${PRODUCT_NAME} has finished downloading the components you selected. To install the package please run the installer again and select the download and install option."

  Goto done
  
install:
  StrCpy $INSTALL_ACTION "Please wait while ${PRODUCT_NAME} downloads and installs the components you selected."
  StrCpy $FINISH_TITLE "Installation complete."
  StrCpy $FINISH_TEXT "${PRODUCT_NAME} has finished installing the components you selected."

  Goto done

update:
  StrCpy $INSTALL_ACTION "Please wait while ${PRODUCT_NAME} downloads and installs the components you selected."
  StrCpy $FINISH_TITLE "Update complete."
  StrCpy $FINISH_TEXT "${PRODUCT_NAME} has finished updating the installed components."
  StrCpy $Install 1
done:

FunctionEnd
