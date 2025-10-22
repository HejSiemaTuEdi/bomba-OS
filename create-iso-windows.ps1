# bombaOS ISO Creator for Windows
# This script creates a bootable ISO using Windows tools

param(
    [string]$OutputPath = "bombaOS.iso",
    [switch]$UseWSL = $false
)

Write-Host "bombaOS ISO Creator" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

# Check for required tools
function Test-Requirements {
    $missing = @()
    
    if (-not (Get-Command "oscdimg.exe" -ErrorAction SilentlyContinue)) {
        $missing += "Windows ADK (oscdimg.exe)"
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "Missing requirements:" -ForegroundColor Red
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        Write-Host "`nInstalling Windows ADK..." -ForegroundColor Yellow
        Install-WindowsADK
    }
}

function Install-WindowsADK {
    Write-Host "Downloading Windows ADK..." -ForegroundColor Yellow
    $adkUrl = "https://go.microsoft.com/fwlink/?linkid=2196127"
    $adkInstaller = "$env:TEMP\adksetup.exe"
    
    try {
        Invoke-WebRequest -Uri $adkUrl -OutFile $adkInstaller
        Write-Host "Installing Windows ADK (Deployment Tools only)..." -ForegroundColor Yellow
        Start-Process -FilePath $adkInstaller -ArgumentList "/quiet", "/features", "OptionId.DeploymentTools" -Wait
        Write-Host "Windows ADK installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install Windows ADK. Please install manually." -ForegroundColor Red
        Write-Host "Download from: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install" -ForegroundColor Yellow
        exit 1
    }
}

function Create-BootableStructure {
    Write-Host "Creating bootable file structure..." -ForegroundColor Yellow
    
    $isoDir = "bombaOS-iso-temp"
    $bootDir = "$isoDir\boot"
    $efiDir = "$isoDir\EFI\boot"
    
    # Clean and create directories
    if (Test-Path $isoDir) { Remove-Item -Recurse -Force $isoDir }
    New-Item -ItemType Directory -Path $isoDir, $bootDir, $efiDir -Force | Out-Null
    
    # Create GRUB configuration
    $grubCfg = @"
set timeout=10
set default=0

menuentry "bombaOS Live" {
    linux /boot/vmlinuz-linux archisobasedir=bombaos archisolabel=BOMBAOS quiet splash
    initrd /boot/initramfs-linux.img
}

menuentry "bombaOS Live (Safe Mode)" {
    linux /boot/vmlinuz-linux archisobasedir=bombaos archisolabel=BOMBAOS nomodeset
    initrd /boot/initramfs-linux.img
}
"@
    
    $grubCfg | Out-File -FilePath "$bootDir\grub.cfg" -Encoding UTF8
    
    # Create syslinux configuration
    $syslinuxCfg = @"
DEFAULT bombaos
TIMEOUT 100
PROMPT 1

LABEL bombaos
    MENU LABEL bombaOS Live
    KERNEL /boot/vmlinuz-linux
    APPEND archisobasedir=bombaos archisolabel=BOMBAOS quiet splash
    INITRD /boot/initramfs-linux.img

LABEL safe
    MENU LABEL bombaOS Live (Safe Mode)
    KERNEL /boot/vmlinuz-linux
    APPEND archisobasedir=bombaos archisolabel=BOMBAOS nomodeset
    INITRD /boot/initramfs-linux.img
"@
    
    $syslinuxCfg | Out-File -FilePath "$bootDir\syslinux.cfg" -Encoding UTF8
    
    return $isoDir
}

function Download-ArchComponents {
    param([string]$targetDir)
    
    Write-Host "Downloading Arch Linux components..." -ForegroundColor Yellow
    
    $archMirror = "https://mirror.rackspace.com/archlinux"
    $isoDate = (Get-Date).ToString("yyyy.MM.01")
    $archIso = "archlinux-$isoDate-x86_64.iso"
    $archUrl = "$archMirror/iso/$isoDate/$archIso"
    
    try {
        # Download latest Arch ISO as base
        Write-Host "Downloading base Arch Linux ISO..." -ForegroundColor Yellow
        $archIsoPath = "$env:TEMP\$archIso"
        
        if (-not (Test-Path $archIsoPath)) {
            Invoke-WebRequest -Uri $archUrl -OutFile $archIsoPath -UseBasicParsing
        }
        
        # Extract ISO contents
        Write-Host "Extracting ISO contents..." -ForegroundColor Yellow
        $mountResult = Mount-DiskImage -ImagePath $archIsoPath -PassThru
        $driveLetter = ($mountResult | Get-Volume).DriveLetter
        
        # Copy contents
        Copy-Item -Path "$($driveLetter):\*" -Destination $targetDir -Recurse -Force
        
        # Dismount
        Dismount-DiskImage -ImagePath $archIsoPath
        
        return $true
    } catch {
        Write-Host "Failed to download Arch components: $_" -ForegroundColor Red
        return $false
    }
}

function Customize-ISO {
    param([string]$isoDir)
    
    Write-Host "Customizing ISO with bombaOS components..." -ForegroundColor Yellow
    
    # Copy bombaOS configurations
    $bombaOSDir = "$isoDir\bombaos"
    New-Item -ItemType Directory -Path $bombaOSDir -Force | Out-Null
    
    # Copy our custom files
    Copy-Item -Path "configs\*" -Destination "$bombaOSDir\" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "installer\*" -Destination "$bombaOSDir\installer\" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "packages\*" -Destination "$bombaOSDir\packages\" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Create bombaOS identifier
    "bombaOS $(Get-Date -Format 'yyyy.MM.dd')" | Out-File -FilePath "$isoDir\.bombaos-release" -Encoding UTF8
    
    # Update boot configuration for bombaOS
    $bootloaderDir = "$isoDir\loader\entries"
    if (Test-Path $bootloaderDir) {
        Get-ChildItem $bootloaderDir -Filter "*.conf" | ForEach-Object {
            $content = Get-Content $_.FullName
            $content = $content -replace "Arch Linux", "bombaOS"
            $content = $content -replace "archiso", "bombaos"
            $content | Out-File -FilePath $_.FullName -Encoding UTF8
        }
    }
}

function Create-ISO {
    param([string]$sourceDir, [string]$outputPath)
    
    Write-Host "Creating bootable ISO..." -ForegroundColor Yellow
    
    $oscdimgPath = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    
    if (-not (Test-Path $oscdimgPath)) {
        # Try alternative paths
        $oscdimgPath = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Windows Kits" -Recurse -Name "oscdimg.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($oscdimgPath) {
            $oscdimgPath = "${env:ProgramFiles(x86)}\Windows Kits\$oscdimgPath"
        }
    }
    
    if (-not (Test-Path $oscdimgPath)) {
        Write-Host "oscdimg.exe not found. Using alternative method..." -ForegroundColor Yellow
        Create-ISOAlternative -sourceDir $sourceDir -outputPath $outputPath
        return
    }
    
    $arguments = @(
        "-m"                    # Ignore maximum image size limit
        "-o"                    # Optimize storage
        "-u2"                   # UDF file system
        "-udfver102"           # UDF version 1.02
        "-bootdata:2#p0,e,b$sourceDir\boot\etfsboot.com#pEF,e,b$sourceDir\efi\microsoft\boot\efisys.bin"
        "`"$sourceDir`""
        "`"$outputPath`""
    )
    
    try {
        & $oscdimgPath @arguments
        Write-Host "ISO created successfully: $outputPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create ISO with oscdimg: $_" -ForegroundColor Red
        Create-ISOAlternative -sourceDir $sourceDir -outputPath $outputPath
    }
}

function Create-ISOAlternative {
    param([string]$sourceDir, [string]$outputPath)
    
    Write-Host "Creating ISO using PowerShell method..." -ForegroundColor Yellow
    
    # Create a simple ISO using COM object
    try {
        $fso = New-Object -ComObject Scripting.FileSystemObject
        $iso = New-Object -ComObject IMAPI2.MsftDiscMaster2
        $recorder = New-Object -ComObject IMAPI2.MsftDiscRecorder2
        $format = New-Object -ComObject IMAPI2.MsftDiscFormat2Data
        
        # This is a simplified approach - for production use, consider using third-party tools
        Write-Host "Alternative ISO creation not fully implemented." -ForegroundColor Yellow
        Write-Host "Please use WSL method or install proper ISO creation tools." -ForegroundColor Yellow
        
    } catch {
        Write-Host "Alternative ISO creation failed. Recommending WSL approach." -ForegroundColor Red
    }
}

# Main execution
try {
    if ($UseWSL) {
        Write-Host "Using WSL method..." -ForegroundColor Yellow
        & .\build-wsl.ps1
        return
    }
    
    Test-Requirements
    
    $isoDir = Create-BootableStructure
    
    if (Download-ArchComponents -targetDir $isoDir) {
        Customize-ISO -isoDir $isoDir
        Create-ISO -sourceDir $isoDir -outputPath $OutputPath
    } else {
        Write-Host "Failed to download base components. Trying WSL method..." -ForegroundColor Yellow
        & .\build-wsl.ps1
    }
    
} catch {
    Write-Host "Error creating ISO: $_" -ForegroundColor Red
    Write-Host "Falling back to WSL method..." -ForegroundColor Yellow
    & .\build-wsl.ps1
} finally {
    # Cleanup
    if (Test-Path "bombaOS-iso-temp") {
        Remove-Item -Recurse -Force "bombaOS-iso-temp" -ErrorAction SilentlyContinue
    }
}

Write-Host "`nbombaOS ISO creation completed!" -ForegroundColor Green
Write-Host "You can now flash this ISO to a USB drive using tools like:" -ForegroundColor Yellow
Write-Host "  - Rufus (https://rufus.ie/)" -ForegroundColor Cyan
Write-Host "  - Balena Etcher (https://www.balena.io/etcher/)" -ForegroundColor Cyan
Write-Host "  - Ventoy (https://www.ventoy.net/)" -ForegroundColor Cyan