@echo off
REM Dufs Launcher - Change to target directory and start dufs service

if not "%~1"=="" (
    cd /d "%~1" 2>nul || (
        echo Failed to access directory: %~1
        echo Please check if the path exists and you have permission.
        pause
        exit /b 1
    )
)

where dufs >nul 2>&1 || (
    if exist "%~dp0dufs.exe" (
        "%~dp0dufs.exe"
        exit /b %errorlevel%
    )
    echo Error: dufs command not found.
    echo Please reinstall the application or check environment variables.
    pause
    exit /b 1
)

dufs
