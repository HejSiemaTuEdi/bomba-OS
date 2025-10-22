@echo off
echo bombaOS Quick Setup
echo ==================
echo.

echo This script will help you set up bombaOS building environment.
echo.
echo Choose your option:
echo 1. Download pre-built Arch Linux ISO and customize it
echo 2. Set up WSL2 for proper building (Recommended)
echo 3. Create installation guide
echo 4. Exit
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" (
    echo Starting simple ISO download and customization...
    powershell -ExecutionPolicy Bypass -File "simple-iso-creator.ps1"
) else if "%choice%"=="2" (
    echo Setting up WSL2 environment...
    powershell -ExecutionPolicy Bypass -File "setup-wsl.ps1"
) else if "%choice%"=="3" (
    echo Creating installation guide...
    powershell -ExecutionPolicy Bypass -File "create-guide.ps1"
) else if "%choice%"=="4" (
    echo Goodbye!
    exit /b 0
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

echo.
echo Process completed!
pause