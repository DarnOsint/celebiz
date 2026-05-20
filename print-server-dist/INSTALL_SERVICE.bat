@echo off
title Celebiz Print Server - Background Service Install
echo ============================================
echo   Celebiz - Print Server Installer
echo ============================================
echo.
echo Installing print server as background service...
echo.

mkdir "C:\CelebizPrint" 2>nul
copy "%~dp0CelebizPrint.exe" "C:\CelebizPrint\CelebizPrint.exe" /Y >nul

echo [1/3] Files copied to C:\CelebizPrint
echo.

REM Remove old scheduled task if exists
schtasks /delete /tn "CelebizPrintServer" /f >nul 2>&1

REM Create scheduled task that runs at system startup (before login)
schtasks /create /tn "CelebizPrintServer" /tr "C:\CelebizPrint\CelebizPrint.exe" /sc onstart /ru SYSTEM /rl highest /f >nul 2>&1

echo [2/3] Auto-start service created (runs on boot, no window)
echo.

REM Also create logon task as backup
schtasks /create /tn "CelebizPrintServerLogon" /tr "C:\CelebizPrint\CelebizPrint.exe" /sc onlogon /rl highest /f >nul 2>&1

REM Start it now
taskkill /f /im CelebizPrint.exe >nul 2>&1
start "" /min "C:\CelebizPrint\CelebizPrint.exe"

echo [3/3] Print server started!
echo.
echo ============================================
echo   DONE! The print server will now:
echo   - Run silently in the background
echo   - Auto-start when Windows boots
echo   - Listen on port 6543
echo   - Forward prints to 192.168.0.10
echo.
echo   Test: open Chrome and go to
echo   http://localhost:6543/health
echo ============================================
echo.
pause
