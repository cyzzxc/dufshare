@echo off
REM Dufs Launcher - Start dufs service with auto-shutdown timer
setlocal enabledelayedexpansion

REM Default timeout in seconds
set "DEFAULT_TIMEOUT=1800"
set "TIMEOUT_SECONDS=%DEFAULT_TIMEOUT%"

REM Default port configuration
set "DEFAULT_PORT=5000"
set "PORT=%DEFAULT_PORT%"

REM Change to target directory if provided
if not "%~1"=="" (
    cd /d "%~1" 2>nul || (
        echo Failed to access directory: %~1
        echo Please check if the path exists and you have permission.
        pause
        exit /b 1
    )
)

REM Read timeout from config.yaml in install directory if exists
set "CONFIG_FILE=%~dp0config.yaml"
if exist "!CONFIG_FILE!" (
    for /f "tokens=2 delims=: " %%a in ('findstr /i "^auto_shutdown_seconds:" "!CONFIG_FILE!"') do (
        set "TIMEOUT_SECONDS=%%a"
    )
)

REM Find dufs executable
set "DUFS_CMD=dufs"
where dufs >nul 2>&1 || (
    if exist "%~dp0dufs.exe" (
        set "DUFS_CMD=%~dp0dufs.exe"
    ) else (
        echo Error: dufs command not found.
        echo Please reinstall the application or check environment variables.
        pause
        exit /b 1
    )
)

REM Check port availability and find free port
:CHECK_PORT
netstat -ano | findstr ":%PORT% " | findstr "LISTENING" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo Port !PORT! is already in use, trying next port...
    set /a PORT+=1
    if !PORT! gtr 65535 (
        echo Error: No available ports found.
        pause
        exit /b 1
    )
    goto CHECK_PORT
)

REM Display startup info
echo ================================================
echo Dufs Server Starting...
echo Working Directory: %CD%
echo Port: !PORT!
echo Auto-shutdown Timer: !TIMEOUT_SECONDS! seconds
echo ================================================
echo.

REM Start dufs in background with config file and port
start /b "" "!DUFS_CMD!" --port !PORT! --config "!CONFIG_FILE!"
set "DUFS_PID=!ERRORLEVEL!"

REM Wait for timeout then kill the process
timeout /t !TIMEOUT_SECONDS! /nobreak >nul

echo.
echo ================================================
echo Auto-shutdown triggered after !TIMEOUT_SECONDS! seconds
echo Stopping Dufs server...
echo ================================================

REM Kill dufs process by name (since we can't get PID reliably in batch)
taskkill /f /im dufs.exe >nul 2>&1

echo Server stopped. Window will close in 3 seconds...
timeout /t 3 >nul
exit /b 0
