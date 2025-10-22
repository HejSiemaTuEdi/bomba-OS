# Create bombaOS Installation Guide

Write-Host "Creating bombaOS Installation Guide..." -ForegroundColor Cyan

$guideContent = @"
# bombaOS - Complete Installation Guide

## What is bombaOS?

bombaOS is a custom Arch Linux distribution featuring:
- **Hyprland**: Modern Wayland tiling compositor
- **Waybar**: Beautiful status bar
- **Custom installer**: Easy installation process
- **Pre-configured**: Ready to use out of the box

## Installation Methods

### Method 1: Simple Installation (Recommended for beginners)

1. **Download Arch Linux ISO**
   - Go to: https://archlinux.org/download/
   - Download the latest ISO (about 800MB)

2. **Create Bootable USB**
   - Download Rufus: https://rufus.ie/
   - Insert USB drive (8GB+)
   - Select Arch Linux ISO in Rufus
   - Click "START" and wait

3. **Boot and Install**
   - Boot from USB
   - Connect to internet: `iwctl` (for WiFi) or ethernet
   - Run: `archinstall`
   - Follow the guided installer
   - Choose "Hyprland" as desktop environment

4. **Post-Installation bombaOS Setup**
   - Copy bombaOS files to your system
   - Run: `./setup-bombaOS.sh`
   - Reboot and enjoy bombaOS!

### Method 2: Advanced Installation (Custom ISO)

1. **Build Custom ISO** (requires WSL2 on Windows)
   - Install WSL2: `wsl --install`
   - Install ArchWSL: https://github.com/yuk7/ArchWSL
   - Run bombaOS build scripts
   - Flash custom ISO to USB

2. **Boot Custom ISO**
   - Boot from bombaOS USB
   - Use built-in installer
   - Automatic bombaOS setup

## System Requirements

### Minimum Requirements
- **CPU**: x86_64 (64-bit) processor
- **RAM**: 2GB (4GB recommended)
- **Storage**: 20GB free space (50GB recommended)
- **Graphics**: Any modern GPU (Intel/AMD/NVIDIA)
- **Boot**: UEFI or Legacy BIOS

### Recommended Specifications
- **CPU**: Multi-core x86_64 processor
- **RAM**: 8GB or more
- **Storage**: SSD with 100GB+ free space
- **Graphics**: Dedicated GPU for best Hyprland performance
- **Network**: Ethernet or WiFi adapter

## Step-by-Step Installation

### Phase 1: Preparation

1. **Backup Important Data**
   - bombaOS installation will format the target disk
   - Backup all important files first

2. **Download Required Files**
   - Arch Linux ISO: https://archlinux.org/download/
   - Rufus (for Windows): https://rufus.ie/
   - bombaOS package (from this folder)

3. **Create Installation Media**
   - Insert USB drive (8GB minimum)
   - Open Rufus
   - Select Arch Linux ISO
   - Select USB drive
   - Click "START"
   - Wait for completion

### Phase 2: Installation

1. **Boot from USB**
   - Insert USB into target computer
   - Restart computer
   - Enter BIOS/UEFI (usually F2, F12, or Delete)
   - Set USB as first boot device
   - Save and exit

2. **Start Installation**
   - Select "Arch Linux" from boot menu
   - Wait for system to load
   - You'll see a terminal prompt

3. **Connect to Internet**
   
   **For Ethernet:**
   ```bash
   # Should connect automatically
   ping google.com
   ```
   
   **For WiFi:**
   ```bash
   iwctl
   station wlan0 scan
   station wlan0 get-networks
   station wlan0 connect "YourWiFiName"
   exit
   ```

4. **Run Installer**
   ```bash
   archinstall
   ```

5. **Configure Installation**
   - **Language**: Select your language
   - **Mirrors**: Choose closest mirror
   - **Disk**: Select target disk (⚠️ will be erased!)
   - **Partitioning**: Use guided partitioning
   - **Filesystem**: ext4 recommended
   - **Bootloader**: GRUB
   - **Hostname**: Enter computer name
   - **User**: Create your user account
   - **Profile**: Select "Desktop" → "Hyprland"
   - **Audio**: PipeWire
   - **Network**: NetworkManager

6. **Start Installation**
   - Review settings
   - Confirm installation
   - Wait for completion (15-30 minutes)

### Phase 3: bombaOS Setup

1. **First Boot**
   - Remove USB drive
   - Restart computer
   - Login with your user account

2. **Install bombaOS Components**
   ```bash
   # Copy bombaOS files (from USB or download)
   cd bombaOS-Installation-Package
   chmod +x setup-bombaOS.sh
   ./setup-bombaOS.sh
   ```

3. **Reboot and Enjoy**
   ```bash
   reboot
   ```
   - Select "Hyprland" session at login
   - Welcome to bombaOS!

## Post-Installation Configuration

### Essential Setup

1. **Update System**
   ```bash
   sudo pacman -Syu
   ```

2. **Install Additional Software**
   ```bash
   # Development tools
   sudo pacman -S code git nodejs python
   
   # Media tools
   sudo pacman -S vlc gimp inkscape
   
   # Gaming
   sudo pacman -S steam lutris
   ```

3. **Configure Graphics Drivers**
   
   **For NVIDIA:**
   ```bash
   sudo pacman -S nvidia nvidia-utils
   ```
   
   **For AMD:**
   ```bash
   sudo pacman -S mesa vulkan-radeon
   ```

### Hyprland Customization

1. **Edit Configuration**
   ```bash
   nano ~/.config/hypr/hyprland.conf
   ```

2. **Key Bindings** (default)
   - `Super + Q`: Terminal
   - `Super + R`: App launcher
   - `Super + E`: File manager
   - `Super + C`: Close window
   - `Super + 1-9`: Switch workspaces

3. **Customize Waybar**
   ```bash
   nano ~/.config/waybar/config
   nano ~/.config/waybar/style.css
   ```

## Troubleshooting

### Boot Issues

**Problem**: Computer won't boot from USB
**Solution**: 
- Disable Secure Boot in BIOS
- Try different USB port
- Recreate USB with different tool

**Problem**: Black screen after boot
**Solution**:
- Try "Safe Mode" boot option
- Add `nomodeset` to kernel parameters

### Installation Issues

**Problem**: No internet connection
**Solution**:
- Check cable connections
- Use `iwctl` for WiFi setup
- Try different network

**Problem**: Disk partitioning fails
**Solution**:
- Use `fdisk -l` to check disk
- Ensure disk is not mounted
- Try manual partitioning

### Graphics Issues

**Problem**: Poor performance or glitches
**Solution**:
- Install proper GPU drivers
- Check Hyprland logs: `journalctl -u hyprland`
- Try different compositor settings

**Problem**: Screen tearing
**Solution**:
- Enable VSync in Hyprland config
- Update graphics drivers
- Check monitor refresh rate

### Audio Issues

**Problem**: No sound
**Solution**:
- Check PipeWire status: `systemctl --user status pipewire`
- Use `pavucontrol` for audio settings
- Restart audio: `systemctl --user restart pipewire`

## Getting Help

### Documentation
- Arch Wiki: https://wiki.archlinux.org/
- Hyprland Wiki: https://wiki.hyprland.org/
- bombaOS README files

### Community Support
- Arch Linux Forums: https://bbs.archlinux.org/
- Hyprland Discord: https://discord.gg/hQ9XvMUjjr
- Reddit: r/archlinux, r/hyprland

### Log Files
- System logs: `journalctl -xe`
- Hyprland logs: `~/.cache/hyprland/hyprland.log`
- X11 logs: `~/.local/share/xorg/Xorg.0.log`

## Advanced Topics

### Custom Packages
Add your own packages to `packages/bombaOS-packages.txt`

### Configuration Backup
```bash
# Backup configs
tar -czf bombaos-backup.tar.gz ~/.config/hypr ~/.config/waybar

# Restore configs
tar -xzf bombaos-backup.tar.gz -C ~/
```

### System Maintenance
```bash
# Clean package cache
sudo pacman -Sc

# Update mirrors
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Check system health
sudo systemctl --failed
```

## Conclusion

Congratulations! You now have bombaOS running with:
- ✅ Modern Hyprland compositor
- ✅ Beautiful Waybar status bar
- ✅ Optimized Arch Linux base
- ✅ Custom configurations
- ✅ Ready-to-use environment

Enjoy your new bombaOS system!

---

**Need help?** Check the troubleshooting section or visit the community forums.
**Want to contribute?** bombaOS is open source - contributions welcome!
"@

# Save the guide
$guideContent | Out-File -FilePath "bombaOS-COMPLETE-INSTALLATION-GUIDE.md" -Encoding UTF8

# Create a simple text version too
$simpleGuide = @"
bombaOS Quick Installation Guide
===============================

EASY METHOD (Recommended):
1. Download Arch Linux ISO from: https://archlinux.org/download/
2. Use Rufus to flash ISO to USB: https://rufus.ie/
3. Boot from USB and run: archinstall
4. Choose Hyprland as desktop environment
5. After installation, copy bombaOS files and run: ./setup-bombaOS.sh

REQUIREMENTS:
- 64-bit computer
- 4GB+ RAM
- 20GB+ free disk space
- USB drive (8GB+)

SUPPORT:
- Full guide: bombaOS-COMPLETE-INSTALLATION-GUIDE.md
- Arch Wiki: https://wiki.archlinux.org/
- Community: r/archlinux

Enjoy bombaOS!
"@

$simpleGuide | Out-File -FilePath "QUICK-START.txt" -Encoding UTF8

Write-Host "Installation guides created!" -ForegroundColor Green
Write-Host "  - Complete guide: bombaOS-COMPLETE-INSTALLATION-GUIDE.md" -ForegroundColor Cyan
Write-Host "  - Quick start: QUICK-START.txt" -ForegroundColor Cyan

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")