# PowerShell script to build bombaOS using WSL2

Write-Host "bombaOS WSL2 Build Script" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Check if WSL is installed
try {
    $wslVersion = wsl --version
    Write-Host "WSL is installed" -ForegroundColor Green
} catch {
    Write-Host "WSL is not installed. Please install WSL2 first:" -ForegroundColor Red
    Write-Host "Run: wsl --install" -ForegroundColor Yellow
    exit 1
}

# Check if Arch Linux is available in WSL
$archAvailable = wsl -l -q | Select-String "Arch"
if (-not $archAvailable) {
    Write-Host "Arch Linux not found in WSL. Please install ArchWSL:" -ForegroundColor Red
    Write-Host "Download from: https://github.com/yuk7/ArchWSL" -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting up build environment in WSL..." -ForegroundColor Yellow

# Copy bombaOS to WSL
$currentDir = Get-Location
$wslPath = $currentDir.Path -replace "C:", "/mnt/c" -replace "\\", "/"

wsl -d Arch -- bash -c @"
# Update system
sudo pacman -Syu --noconfirm

# Install dependencies
sudo pacman -S --needed --noconfirm archiso git wget squashfs-tools libisoburn base-devel

# Copy bombaOS to home directory
cp -r '$wslPath/bombaOS' ~/bombaOS-build
cd ~/bombaOS-build

# Make scripts executable
chmod +x setup.sh build.sh

# Run setup
./setup.sh

# Build ISO
echo 'Starting bombaOS build...'
sudo ./build.sh

# Copy ISO back to Windows
mkdir -p '$wslPath/bombaOS-output'
cp build/out/*.iso '$wslPath/bombaOS-output/' 2>/dev/null || echo 'No ISO files found'

echo 'Build completed!'
echo 'ISO location: $wslPath/bombaOS-output/'
"@

Write-Host "Build process completed!" -ForegroundColor Green
Write-Host "Check the bombaOS-output folder for your ISO file." -ForegroundColor Yellow