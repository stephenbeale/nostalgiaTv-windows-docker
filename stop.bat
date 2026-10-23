@echo off
cd /d "%~dp0"
docker compose down
echo NostalgiaTV stopped. Your settings are kept in the data and config folders.
timeout /t 5 >nul
