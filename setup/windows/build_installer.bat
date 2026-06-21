@echo off
echo =======================================================
echo Building Flutter Windows Release...
echo =======================================================
REM Navigate to the project root relative to this script directory
cd /d "%~dp0..\.."
call flutter build windows --release

echo.
echo =======================================================
echo Compiling Inno Setup Installer...
echo =======================================================
cd /d "%~dp0"

set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %ISCC% set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
if not exist %ISCC% (
    where ISCC.exe >nul 2>nul
    if %errorlevel% equ 0 (
        set ISCC=ISCC.exe
    ) else (
        echo [ERROR] Inno Setup compiler (ISCC.exe) was not found in PATH or standard install paths.
        echo Please install Inno Setup 6 or add it to your PATH.
        pause
        exit /b 1
    )
)

%ISCC% installer.iss
echo.
echo =======================================================
echo Success! Windows Installer created in:
echo build\windows\installer\
echo =======================================================
pause
