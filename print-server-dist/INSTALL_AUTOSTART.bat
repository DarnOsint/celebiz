@echo off
title Installing Celebiz Print Server
echo Copying files to C:\CelebizPrint...
mkdir "C:\CelebizPrint" 2>nul
copy "%~dp0CelebizPrint.exe" "C:\CelebizPrint\CelebizPrint.exe" /Y
copy "%~dp0START_PRINT_SERVER.bat" "C:\CelebizPrint\START_PRINT_SERVER.bat" /Y
echo Creating auto-start shortcut...
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\s.vbs"
echo sLinkFile = oWS.SpecialFolders("Startup") ^& "\CelebizPrint.lnk" >> "%TEMP%\s.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\s.vbs"
echo oLink.TargetPath = "C:\CelebizPrint\CelebizPrint.exe" >> "%TEMP%\s.vbs"
echo oLink.WindowStyle = 7 >> "%TEMP%\s.vbs"
echo oLink.Save >> "%TEMP%\s.vbs"
cscript "%TEMP%\s.vbs"
echo.
echo Done! Starting print server now...
start "" "C:\CelebizPrint\CelebizPrint.exe"
echo.
echo Test it: open Chrome and go to http://localhost:6543/health
pause
