# bombaOS Bootable USB Creator for Windows

param(
    [Parameter(Mandatory=$true)]
    [string]$USBDrive,
    [string]$ISOPath = "bombaOS.iso"
)

Write-Host "bombaOS Bootable USB Creator" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Validate USB drive
if (-not (Get-Volume -DriveLetter $USBDrive -ErrorAction SilentlyContinue)) {
    Write-Host "USB drive $USBDrive not found!" -ForegroundColor Red
    Write-Host "Available drives:" -ForegroundColor Yellow
    Get-Volume | Where-Object {$_.DriveType -eq 'Removable'} | Format-Table DriveLetter, FileSystemLabel, Size -AutoSize
    exit 1
}

# Check if ISO exists
if (-not (Test-Path $ISOPath)) {
    Write-Host "ISO file not found: $ISOPath" -ForegroundColor Red
    Write-Host "Please create the ISO first using: .\create-iso-windows.ps1" -ForegroundColor Yellow
    exit 1
}

# Warning about data loss
Write-Host "WARNING: This will erase all data on drive $USBDrive!" -ForegroundColor Red
$confirmation = Read-Host "Type 'YES' to continue"
if ($confirmation -ne 'YES') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "Creating bootable USB drive..." -ForegroundColor Yellow

try {
    # Get disk number for the USB drive
    $disk = Get-Partition -DriveLetter $USBDrive | Get-Disk
    $diskNumber = $disk.Number
    
    Write-Host "Preparing USB drive (Disk $diskNumber)..." -ForegroundColor Yellow
    
    # Clean the disk
    Clear-Disk -Number $diskNumber -RemoveData -Confirm:$false
    
    # Create new partition table
    Initialize-Disk -Number $diskNumber -PartitionStyle MBR
    
    # Create primary partition
    $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -IsActive
    
    # Format as FAT32
    Format-Volume -Partition $partition -FileSystem FAT32 -NewFileSystemLabel "BOMBAOS" -Confirm:$false
    
    # Assign drive letter
    $partition | Set-Partition -NewDriveLetter $USBDrive
    
    Write-Host "Copying ISO contents to USB..." -ForegroundColor Yellow
    
    # Mount ISO
    $mountResult = Mount-DiskImage -ImagePath (Resolve-Path $ISOPath).Path -PassThru
    $isoVolume = $mountResult | Get-Volume
    $isoDriveLetter = $isoVolume.DriveLetter
    
    # Copy all files from ISO to USB
    $source = "${isoDriveLetter}:\*"
    $destination = "${USBDrive}:\"
    
    Copy-Item -Path $source -Destination $destination -Recurse -Force
    
    # Dismount ISO
    Dismount-DiskImage -ImagePath (Resolve-Path $ISOPath).Path
    
    # Make USB bootable using bootsect (if available)
    $bootsectPath = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\BCDBoot\bootsect.exe"
    
    if (Test-Path $bootsectPath) {
        Write-Host "Making USB bootable..." -ForegroundColor Yellow
        & $bootsectPath /nt60 "${USBDrive}:" /mbr
    }
    
    Write-Host "Bootable USB created successfully!" -ForegroundColor Green
    Write-Host "USB Drive: $USBDrive" -ForegroundColor Cyan
    Write-Host "Label: BOMBAOS" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "You can now boot from this USB drive to:" -ForegroundColor Yellow
    Write-Host "  1. Try bombaOS in live mode" -ForegroundColor Cyan
    Write-Host "  2. Install bombaOS to your computer" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "Boot Instructions:" -ForegroundColor Yellow
    Write-Host "  1. Insert USB into target computer" -ForegroundColor White
    Write-Host "  2. Restart and enter BIOS/UEFI settings (usually F2, F12, or Del)" -ForegroundColor White
    Write-Host "  3. Set USB as first boot device" -ForegroundColor White
    Write-Host "  4. Save and restart" -ForegroundColor White
    Write-Host "  5. Select 'bombaOS Live' from boot menu" -ForegroundColor White
    
} catch {
    Write-Host "Error creating bootable USB: $_" -ForegroundColor Red
    Write-Host "You can also use third-party tools like:" -ForegroundColor Yellow
    Write-Host "  - Rufus: https://rufus.ie/" -ForegroundColor Cyan
    Write-Host "  - Balena Etcher: https://www.balena.io/etcher/" -ForegroundColor Cyan
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")