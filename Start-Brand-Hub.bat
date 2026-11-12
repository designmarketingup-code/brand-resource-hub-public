@echo off
setlocal EnableExtensions

REM This BAT file belongs in the OUTER project folder:
REM   brand-resource-hub\Start-Brand-Hub.bat
REM Expected layout:
REM   brand-resource-hub\website-server.js
REM   brand-resource-hub\backend\server.js
REM   brand-resource-hub\backend\.env
REM   brand-resource-hub\brand-resource-hub\index.html

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "SITE_DIR=%ROOT%\brand-resource-hub"
set "BACKEND_DIR=%ROOT%\backend"

 echo.
echo ==========================================
echo       Starting Brand Resource Hub
echo ==========================================
echo.
echo Project folder: %ROOT%

echo Checking project files...
if not exist "%SITE_DIR%\index.html" (
  echo.
  echo ERROR: Website file not found:
  echo   %SITE_DIR%\index.html
  echo.
  echo Expected index.html inside the inner brand-resource-hub folder.
  pause
  exit /b 1
)

if not exist "%BACKEND_DIR%\server.js" (
  echo.
  echo ERROR: Backend file not found:
  echo   %BACKEND_DIR%\server.js
  pause
  exit /b 1
)

if not exist "%BACKEND_DIR%\node_modules" (
  echo.
  echo ERROR: Backend node_modules folder was not found:
  echo   %BACKEND_DIR%\node_modules
  echo.
  echo The backend dependencies may not be installed.
  pause
  exit /b 1
)

if not exist "%ROOT%\website-server.js" (
  echo.
  echo ERROR: website-server.js was not found:
  echo   %ROOT%\website-server.js
  pause
  exit /b 1
)

where node >nul 2>&1
if errorlevel 1 (
  echo.
  echo ERROR: Node.js was not found in PATH. Install or repair Node.js first.
  pause
  exit /b 1
)

where docker >nul 2>&1
if errorlevel 1 (
  echo.
  echo ERROR: Docker CLI was not found. Please open or repair Docker Desktop.
  pause
  exit /b 1
)

REM Open Docker Desktop if it is not already running.
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if errorlevel 1 (
  if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    echo Opening Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
  ) else (
    echo Docker Desktop was not found at its usual location.
    echo Trying the Docker CLI anyway...
  )
) else (
  echo Docker Desktop is already open.
)

REM Wait up to two minutes for the Docker engine.
echo Waiting for Docker engine...
set /a COUNT=0
:WAIT_DOCKER
docker info >nul 2>&1
if not errorlevel 1 goto DOCKER_READY
set /a COUNT+=1
if %COUNT% GEQ 40 (
  echo.
  echo ERROR: Docker engine did not become ready within 2 minutes.
  echo Open Docker Desktop, wait until it is running, then double-click this file again.
  pause
  exit /b 1
)
timeout /t 3 /nobreak >nul
goto WAIT_DOCKER

:DOCKER_READY
echo Docker engine is ready.
echo Starting n8n container...
docker start n8n >nul 2>&1
if errorlevel 1 (
  echo WARNING: Could not start a container named n8n.
  echo Check the container name in Docker Desktop.
) else (
  echo n8n container is running.
)

REM Start backend only if port 3000 is not already listening.
powershell -NoProfile -Command "if (Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }" >nul 2>&1
if errorlevel 1 (
  echo Backend already appears to be running on port 3000.
) else (
  echo Starting backend...
  start "Brand Hub Backend" /min cmd /k "cd /d ""%BACKEND_DIR%"" && node server.js"
)

REM Start website server only if port 5500 is not already listening.
powershell -NoProfile -Command "if (Get-NetTCPConnection -LocalPort 5500 -State Listen -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }" >nul 2>&1
if errorlevel 1 (
  echo Website server already appears to be running on port 5500.
) else (
  echo Starting website server...
  start "Brand Hub Website" /min cmd /k "cd /d ""%ROOT%"" && node website-server.js"
)

REM Open VS Code at the OUTER project folder.
where code >nul 2>&1
if not errorlevel 1 (
  start "" code "%ROOT%"
) else (
  echo VS Code command 'code' is not on PATH. You can open the project manually.
)

echo.
echo Opening Brand Resource Hub and n8n...
timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:5500/brand-resource-hub/index.html"
start "" "http://localhost:5678"

echo.
echo ==========================================
echo Startup commands completed.
echo Keep Docker Desktop and the backend/website server windows running.
echo ==========================================
echo.
timeout /t 5 >nul
exit /b 0
