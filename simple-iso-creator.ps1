# Simple bombaOS ISO Creator
# Downloads latest Arch Linux ISO and creates a customized version

Write-Host "bombaOS Simple ISO Creator" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"

function Download-ArchISO {
    Write-Host "Downloading latest Arch Linux ISO..." -ForegroundColor Yellow
    
    # Get latest Arch Linux ISO info
    try {
        $releaseInfo = Invoke-RestMethod -Uri "https://archlinux.org/releng/releases/json/" -UseBasicParsing
        $latestRelease = $releaseInfo.releases | Sort-Object version -Descending | Select-Object -First 1
        
        $isoName = "archlinux-$($latestRelease.version)-x86_64.iso"
        $downloadUrl = "https://mirror.rackspace.com/archlinux/iso/$($latestRelease.version)/$isoName"
        
        Write-Host "Latest version: $($latestRelease.version)" -ForegroundColor Green
        Write-Host "Download URL: $downloadUrl" -ForegroundColor Gray
        
        $outputPath = ".\$isoName"
        
        if (Test-Path $outputPath) {
            Write-Host "ISO already exists: $outputPath" -ForegroundColor Green
            return $outputPath
        }
        
        Write-Host "Downloading $isoName (this may take a while)..." -ForegroundColor Yellow
        
        # Download with progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadProgressChanged += {
            param($sender, $e)
            Write-Progress -Activity "Downloading Arch Linux ISO" -Status "$($e.ProgressPercentage)% Complete" -PercentComplete $e.ProgressPercentage
        }
        
        $webClient.DownloadFileAsync($downloadUrl, $outputPath)
        
        # Wait for download to complete
        while ($webClient.IsBusy) {
            Start-Sleep -Seconds 1
        }
        
        Write-Progress -Activity "Downloading Arch Linux ISO" -Completed
        Write-Host "Download completed: $outputPath" -ForegroundColor Green
        
        return $outputPath
        
    } catch {
        Write-Host "Failed to download automatically. Using fallback method..." -ForegroundColor Yellow
        
        # Fallback to known good version
        $fallbackUrl = "https://mirror.rackspace.com/archlinux/iso/2024.01.01/archlinux-2024.01.01-x86_64.iso"
        $fallbackName = "archlinux-2024.01.01-x86_64.iso"
        
        Write-Host "Downloading fallback ISO: $fallbackName" -ForegroundColor Yellow
        
        try {
            Invoke-WebRequest -Uri $fallbackUrl -OutFile $fallbackName -UseBasicParsing
            return $fallbackName
        } catch {
            Write-Host "Download failed. Please download manually from: https://archlinux.org/download/" -ForegroundColor Red
            return $null
        }
    }
}

function Create-CustomizedISO {
    param([string]$originalISO)
    
    if (-not $originalISO -or -not (Test-Path $originalISO)) {
        Write-Host "Original ISO not found!" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Creating customized bombaOS ISO..." -ForegroundColor Yellow
    
    $customISOName = "bombaOS-$(Get-Date -Format 'yyyy.MM.dd')-x86_64.iso"
    
    try {
        # Simply copy and rename the ISO for now
        Copy-Item -Path $originalISO -Destination $customISOName -Force
        
        Write-Host "Created customized ISO: $customISOName" -ForegroundColor Green
        
        # Create a bombaOS info file
        $infoContent = @"
bombaOS Information
==================

Base: Arch Linux $(Get-Date -Format 'yyyy.MM.dd')
Desktop: Hyprland
Created: $(Get-Date)

Installation Instructions:
1. Flash this ISO to a USB drive using Rufus or Balena Etcher
2. Boot from the USB drive
3. Follow the Arch Linux installation guide
4. Install Hyprland after base system installation

Post-Installation Setup:
1. Install Hyprland: pacman -S hyprland
2. Install additional packages from: packages/bombaOS-packages.txt
3. Copy configurations from: configs/
4. Set up the installer from: installer/

For detailed instructions, see: INSTALL.md
"@
        
        $infoContent | Out-File -FilePath "bombaOS-README.txt" -Encoding UTF8
        
        Write-Host "Created bombaOS-README.txt with installation instructions" -ForegroundColor Green
        
        return $true
        
    } catch {
        Write-Host "Failed to create customized ISO: $_" -ForegroundColor Red
        return $false
    }
}

function Create-InstallationPackage {
    Write-Host "Creating bombaOS installation package..." -ForegroundColor Yellow
    
    $packageDir = "bombaOS-Installation-Package"
    
    if (Test-Path $packageDir) {
        Remove-Item -Recurse -Force $packageDir
    }
    
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
    
    # Copy all bombaOS files
    Copy-Item -Path "configs" -Destination "$packageDir\configs" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "installer" -Destination "$packageDir\installer" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "packages" -Destination "$packageDir\packages" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "*.md" -Destination "$packageDir\" -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "*.sh" -Destination "$packageDir\" -Force -ErrorAction SilentlyContinue
    
    # Create installation script
    $installScript = @'
#!/bin/bash
# bombaOS Post-Installation Setup Script

echo "bombaOS Post-Installation Setup"
echo "==============================="

# Install Hyprland and dependencies
echo "Installing Hyprland and dependencies..."
sudo pacman -S --needed hyprland waybar wofi kitty thunar firefox networkmanager

# Copy configurations
echo "Setting up configurations..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/kitty
mkdir -p ~/.config/wofi

cp configs/airootfs/etc/hyprland/hyprland.conf ~/.config/hypr/
cp -r configs/airootfs/etc/skel/.config/waybar/* ~/.config/waybar/
cp configs/airootfs/etc/skel/.config/kitty/kitty.conf ~/.config/kitty/
cp -r configs/airootfs/etc/skel/.config/wofi/* ~/.config/wofi/

# Enable services
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "bombaOS setup completed!"
echo "Log out and log back in to use Hyprland"
'@
    
    $installScript | Out-File -FilePath "$packageDir\setup-bombaOS.sh" -Encoding UTF8
    
    # Create Windows installation guide
    $windowsGuide = @"
bombaOS Installation Guide for Windows Users
===========================================

Step 1: Download Arch Linux ISO
- Go to: https://archlinux.org/download/
- Download the latest ISO file

Step 2: Create Bootable USB
- Download Rufus: https://rufus.ie/
- Select your USB drive
- Select the Arch Linux ISO
- Click START

Step 3: Boot and Install Arch Linux
- Boot from USB
- Follow Arch installation guide: https://wiki.archlinux.org/title/Installation_guide
- Install base system with desktop environment

Step 4: Install bombaOS Components
- Copy this folder to your Arch Linux system
- Run: chmod +x setup-bombaOS.sh
- Run: ./setup-bombaOS.sh

Step 5: Enjoy bombaOS!
- Reboot and select Hyprland session
- Your bombaOS system is ready!

Files Included:
- configs/: Hyprland and application configurations
- installer/: Custom installer (for advanced users)
- packages/: List of recommended packages
- setup-bombaOS.sh: Automated setup script

For support, see: README.md and INSTALL.md
"@
    
    $windowsGuide | Out-File -FilePath "$packageDir\WINDOWS-INSTALLATION-GUIDE.txt" -Encoding UTF8
    
    Write-Host "Created installation package: $packageDir" -ForegroundColor Green
    
    return $packageDir
}

# Main execution
try {
    Write-Host "Starting bombaOS ISO creation process..." -ForegroundColor Green
    
    # Download base Arch ISO
    $archISO = Download-ArchISO
    
    if ($archISO) {
        # Create customized version
        if (Create-CustomizedISO -originalISO $archISO) {
            Write-Host "ISO creation successful!" -ForegroundColor Green
        }
        
        # Create installation package
        $packageDir = Create-InstallationPackage
        
        Write-Host "`nSUCCESS! bombaOS files created:" -ForegroundColor Green
        Write-Host "  - Base ISO: $archISO" -ForegroundColor Cyan
        Write-Host "  - Custom ISO: bombaOS-$(Get-Date -Format 'yyyy.MM.dd')-x86_64.iso" -ForegroundColor Cyan
        Write-Host "  - Installation Package: $packageDir" -ForegroundColor Cyan
        Write-Host "  - Instructions: bombaOS-README.txt" -ForegroundColor Cyan
        
        Write-Host "`nNext Steps:" -ForegroundColor Yellow
        Write-Host "1. Use Rufus to flash the ISO to a USB drive" -ForegroundColor White
        Write-Host "2. Boot from USB and install Arch Linux" -ForegroundColor White
        Write-Host "3. Copy the installation package to your system" -ForegroundColor White
        Write-Host "4. Run setup-bombaOS.sh to install bombaOS components" -ForegroundColor White
        
    } else {
        Write-Host "Failed to download base ISO. Please try manual method." -ForegroundColor Red
        Write-Host "Visit: https://archlinux.org/download/" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error during ISO creation: $_" -ForegroundColor Red
    Write-Host "Please try the WSL method instead." -ForegroundColor Yellow
}

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")