# bombaOS - Windows Build Guide

## Quick Start (3 Easy Steps)

### Step 1: Choose Your Method
Right-click `quick-build.bat` → "Run as Administrator"

### Step 2: Select Build Option
- **Option 1**: WSL2 (Recommended) - Full Arch Linux environment
- **Option 2**: Windows Native (Experimental) - Uses Windows tools
- **Option 3**: Create USB from existing ISO

### Step 3: Boot and Install
Flash the ISO to USB and boot from it!

---

## Detailed Methods

### Method 1: WSL2 (Recommended) ⭐

**Requirements:**
- Windows 10/11 with WSL2
- Arch Linux WSL distribution

**Steps:**
1. Install WSL2: `wsl --install`
2. Install ArchWSL from: https://github.com/yuk7/ArchWSL
3. Run: `.\build-wsl.ps1`

**Pros:** ✅ Full compatibility, ✅ All features work
**Cons:** ❌ Requires WSL2 setup

### Method 2: Windows Native (Experimental) 🧪

**Requirements:**
- Windows 10/11
- Administrator privileges
- Internet connection

**Steps:**
1. Run: `.\create-iso-windows.ps1`
2. Script downloads base Arch Linux ISO
3. Customizes with bombaOS components

**Pros:** ✅ No WSL needed, ✅ Pure Windows
**Cons:** ❌ Experimental, ❌ May have limitations

### Method 3: Docker 🐳

**Requirements:**
- Docker Desktop for Windows
- WSL2 backend enabled

**Steps:**
1. Run: `.\build-docker.sh`
2. Docker builds in Arch Linux container

**Pros:** ✅ Isolated environment, ✅ Reproducible
**Cons:** ❌ Requires Docker setup

---

## Creating Bootable USB

### Automatic Method
```powershell
.\create-bootable-usb.ps1 -USBDrive E -ISOPath bombaOS.iso
```

### Manual Method (Recommended)
1. Download **Rufus**: https://rufus.ie/
2. Select your bombaOS ISO
3. Select USB drive
4. Click "START"

### Alternative Tools
- **Balena Etcher**: https://www.balena.io/etcher/
- **Ventoy**: https://www.ventoy.net/

---

## Output Files

After building, you'll get:
```
bombaOS-YYYY.MM.DD-x86_64.iso    # Main bootable ISO
bombaOS-output/                   # WSL build output
build/out/                        # Native build output
```

---

## Troubleshooting

### "WSL not found"
```powershell
# Install WSL2
wsl --install
# Restart computer
# Install ArchWSL from GitHub
```

### "Permission denied"
- Run PowerShell as Administrator
- Right-click scripts → "Run as Administrator"

### "ISO creation failed"
- Try WSL method instead
- Check available disk space (need 2GB+)
- Disable antivirus temporarily

### "USB creation failed"
- Use Rufus instead of built-in script
- Check USB drive is not write-protected
- Try different USB port

---

## What's Included in bombaOS

### 🖥️ Desktop Environment
- **Hyprland**: Modern Wayland compositor
- **Waybar**: Beautiful status bar
- **Wofi**: Application launcher
- **Kitty**: GPU-accelerated terminal

### 🌐 Applications
- **Firefox**: Web browser
- **Thunar**: File manager
- **NetworkManager**: Network configuration
- **PipeWire**: Modern audio system

### ⚙️ System
- **Arch Linux**: Rolling release base
- **GRUB**: Universal bootloader
- **Custom installer**: Easy installation process
- **Live environment**: Try before installing

---

## Boot Instructions

1. **Create USB**: Use any method above
2. **Insert USB**: Into target computer
3. **Enter BIOS**: Usually F2, F12, or Delete key
4. **Boot Order**: Set USB as first boot device
5. **Save & Exit**: Restart computer
6. **Select**: "bombaOS Live" from boot menu

### First Boot Options
- **Try bombaOS**: Test without installing
- **Install bombaOS**: Permanent installation
- **Safe Mode**: If graphics issues occur

---

## System Requirements

### Minimum
- **CPU**: x86_64 (64-bit)
- **RAM**: 2GB
- **Storage**: 20GB
- **Graphics**: Any modern GPU

### Recommended
- **CPU**: Multi-core x86_64
- **RAM**: 4GB+
- **Storage**: 50GB+ SSD
- **Graphics**: Dedicated GPU for best Hyprland experience

---

## Support

### Documentation
- `INSTALL.md` - Installation guide
- `build-on-windows.md` - Detailed Windows build info
- `README.md` - General information

### Common Issues
- **Black screen**: Try safe mode boot option
- **No WiFi**: Use ethernet for initial setup
- **Graphics glitches**: Update GPU drivers after install

### Getting Help
- Check log files in `/var/log/`
- Use `journalctl` for system logs
- Join bombaOS community forums

---

**Enjoy your new bombaOS system!** 🚀