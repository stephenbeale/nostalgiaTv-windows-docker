@echo off
setlocal
title NostalgiaTV
cd /d "%~dp0"

set "URL=http://localhost:19850"

rem --- 1. Docker installed? -------------------------------------------------
where docker >nul 2>&1
if errorlevel 1 (
    echo Docker Desktop is not installed.
    echo.
    choice /m "Install it now with winget"
    if errorlevel 2 goto :nodocker
    winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
    echo.
    echo Docker Desktop installed. Restart your PC, open Docker Desktop once to
    echo accept its terms, then double-click start.bat again.
    pause
    exit /b 0
)

rem --- 2. Docker running? ---------------------------------------------------
docker info >nul 2>&1
if not errorlevel 1 goto :running
echo Starting Docker Desktop...
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
    start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
)
set /a tries=0
:waitdocker
timeout /t 3 /nobreak >nul
docker info >nul 2>&1
if not errorlevel 1 goto :running
set /a tries+=1
if %tries% lss 60 goto :waitdocker
echo Docker did not start after 3 minutes. Open Docker Desktop manually and try again.
pause
exit /b 1

:running
rem --- 3. Data folder: one fixed place, whichever copy of this folder runs ---
if exist ".env" for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
    if /i "%%a"=="NTV_DATA_DIR" set "NTV_DATA_DIR=%%b"
)
if not defined NTV_DATA_DIR set "NTV_DATA_DIR=%LOCALAPPDATA%\NostalgiaTV"
rem First time only: copy data\, config\ and logos\ from this folder across.
rem The originals are left in place as a backup.
if exist "%NTV_DATA_DIR%\config\profiles.json" goto :datadone
if not exist "config\profiles.json" goto :datadone
echo Moving your NostalgiaTV data to %NTV_DATA_DIR%...
docker stop nostalgiatv-server >nul 2>&1
for %%f in (data config logos) do (
    if exist "%%f" robocopy "%%f" "%NTV_DATA_DIR%\%%f" /E /NFL /NDL /NJH /NJS /NP >nul
)
if not exist "%NTV_DATA_DIR%\config\profiles.json" (
    echo Couldn't copy your data to %NTV_DATA_DIR%. Nothing was changed.
    pause
    exit /b 1
)
echo Done. The old data\ and config\ folders here are kept as a backup.
:datadone

rem --- 4. Pull latest image (skipped quietly if offline) and start -----------
echo Checking for updates...
docker compose pull -q >nul 2>&1
docker compose up -d
if errorlevel 1 (
    echo Failed to start the container - see the message above.
    pause
    exit /b 1
)

rem --- 5. Wait until the server answers, then offer to open the browser ----
echo Waiting for NostalgiaTV to come up...
set /a tries=0
:waitapp
curl -fs "%URL%/health" >nul 2>&1
if not errorlevel 1 goto :ready
set /a tries+=1
if %tries% geq 60 goto :notready
timeout /t 2 /nobreak >nul
goto :waitapp

:ready
rem --- 6. First run (no Jellyfin server saved yet): show its address ---------
set "FIRSTRUN="
if not exist "%NTV_DATA_DIR%\config\jellyfin_servers.json" set "FIRSTRUN=1"
if defined FIRSTRUN (
    echo.
    echo First-time setup: when NostalgiaTV asks for your Jellyfin server, paste this address.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0jellyfin-address.ps1"
)
echo.
echo NostalgiaTV is running at %URL%
echo.
rem Defaults to Yes after 30 seconds so an unattended start still opens it
choice /c YN /t 30 /d Y /m "Open NostalgiaTV in your browser now"
if not errorlevel 2 start "" "%URL%"
echo.
echo It keeps running in the background (and restarts with Docker Desktop).
echo Use stop.bat to shut it down.
if defined FIRSTRUN (
    echo.
    pause
) else (
    timeout /t 8 >nul
)
exit /b 0

:notready
echo.
echo NostalgiaTV did not respond after 2 minutes. Run logs.bat to see what
echo went wrong, or try opening %URL% in your browser in a minute.
pause
exit /b 1

:nodocker
echo Install Docker Desktop from https://www.docker.com/products/docker-desktop/ then run this again.
pause
exit /b 1
