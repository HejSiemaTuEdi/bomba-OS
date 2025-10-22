# WSL2 Setup for bombaOS Building

Write-Host "bombaOS WSL2 Setup" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

function Test-WSLInstalled {
    try {
        $wslVersion = wsl --version 2>$null
        return $true
    } catch {
        return $false
    }
}

function Install-WSL {
    Write-Host "Installing WSL2..." -ForegroundColor Yellow
    
    try {
        # Enable WSL feature
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        
        Write-Host "WSL features enabled. Please restart your computer." -ForegroundColor Yellow
        Write-Host "After restart, run this script again to continue setup." -ForegroundColor Yellow
        
        $restart = Read-Host "Restart now? (y/n)"
        if ($restart -eq 'y' -or $restart -eq 'Y') {
            Restart-Computer
        }
        
        return $false
    } catch {
        Write-Host "Failed to install WSL. Please install manually:" -ForegroundColor Red
        Write-Host "1. Open PowerShell as Administrator" -ForegroundColor Yellow
        Write-Host "2. Run: wsl --install" -ForegroundColor Yellow
        Write-Host "3. Restart computer" -ForegroundColor Yellow
        return $false
    }
}

function Install-ArchWSL {
    Write-Host "Setting up Arch Linux in WSL..." -ForegroundColor Yellow
    
    # Check if Arch is already installed
    $distros = wsl -l -q
    if ($distros -match "Arch") {
        Write-Host "Arch Linux already installed in WSL!" -ForegroundColor Green
        return $true
    }
    
    Write-Host "Arch Linux not found. Please install ArchWSL:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://github.com/yuk7/ArchWSL/releases" -ForegroundColor Cyan
    Write-Host "2. Extract and run Arch.exe" -ForegroundColor Cyan
    Write-Host "3. Follow the setup instructions" -ForegroundColor Cyan
    
    $continue = Read-Host "Have you installed ArchWSL? (y/n)"
    return ($continue -eq 'y' -or $continue -eq 'Y')
}

function Setup-ArchEnvironment {
    Write-Host "Setting up Arch Linux build environment..." -ForegroundColor Yellow
    
    $setupScript = @'
#!/bin/bash
echo "Setting up bombaOS build environment in Arch Linux..."

# Initialize pacman keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux

# Update system
sudo pacman -Syu --noconfirm

# Install build dependencies
sudo pacman -S --needed --noconfirm archiso git wget squashfs-tools libisoburn base-devel

echo "Arch Linux build environment ready!"
echo "You can now build bombaOS by running:"
echo "  cd ~/bombaOS"
echo "  sudo ./build.sh"
'@
    
    # Save setup script
    $setupScript | Out-File -FilePath "wsl-setup.sh" -Encoding UTF8
    
    try {
        # Copy files to WSL
        wsl -d Arch -- mkdir -p /home/bombaos-build
        wsl -d Arch -- cp -r /mnt/c/bosinnOS/bombaOS /home/bombaos-build/
        
        # Run setup
        wsl -d Arch -- chmod +x /home/bombaos-build/bombaOS/wsl-setup.sh
        wsl -d Arch -- /home/bombaos-build/bombaOS/wsl-setup.sh
        
        Write-Host "Arch Linux environment setup completed!" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "Failed to setup Arch environment: $_" -ForegroundColor Red
        return $false
    }
}

function Build-bombaOS {
    Write-Host "Building bombaOS ISO..." -ForegroundColor Yellow
    
    try {
        wsl -d Arch -- bash -c "cd /home/bombaos-build/bombaOS && chmod +x build.sh && sudo ./build.sh"
        
        # Copy ISO back to Windows
        wsl -d Arch -- cp /home/bombaos-build/bombaOS/build/out/*.iso /mnt/c/bosinnOS/bombaOS/
        
        Write-Host "bombaOS ISO built successfully!" -ForegroundColor Green
        Write-Host "ISO location: $(Get-Location)\bombaOS-*.iso" -ForegroundColor Cyan
        
        return $true
        
    } catch {
        Write-Host "Failed to build bombaOS: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "This script will set up WSL2 with Arch Linux for building bombaOS." -ForegroundColor White
Write-Host ""

# Check if WSL is installed
if (-not (Test-WSLInstalled)) {
    Write-Host "WSL2 not found. Installing..." -ForegroundColor Yellow
    if (-not (Install-WSL)) {
        exit 1
    }
}

Write-Host "WSL2 is available!" -ForegroundColor Green

# Check if Arch Linux is installed
if (-not (Install-ArchWSL)) {
    Write-Host "Please install ArchWSL first, then run this script again." -ForegroundColor Yellow
    exit 1
}

# Setup build environment
if (Setup-ArchEnvironment) {
    Write-Host "Environment setup completed!" -ForegroundColor Green
    
    $buildNow = Read-Host "Build bombaOS ISO now? (y/n)"
    if ($buildNow -eq 'y' -or $buildNow -eq 'Y') {
        Build-bombaOS
    } else {
        Write-Host "To build later, run:" -ForegroundColor Yellow
        Write-Host "  wsl -d Arch" -ForegroundColor Cyan
        Write-Host "  cd /home/bombaos-build/bombaOS" -ForegroundColor Cyan
        Write-Host "  sudo ./build.sh" -ForegroundColor Cyan
    }
} else {
    Write-Host "Setup failed. Please check the errors above." -ForegroundColor Red
}

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")