@echo off
cd /d "%~dp0"
echo Showing NostalgiaTV logs - press Ctrl+C to exit.
docker compose logs -f --tail 200
