# bombaOS Installation Guide

## Building bombaOS

### Prerequisites

You need an Arch Linux system to build bombaOS. The build process uses `archiso` which is specific to Arch Linux.

### Quick Start

1. **Clone and setup:**
   ```bash
   cd bombaOS
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Install dependencies:**
   ```bash
   sudo make install-deps
   ```

3. **Build the ISO:**
   ```bash
   sudo make build
   ```

4. **Create bootable USB:**
   ```bash
   sudo make usb USB_DEVICE=/dev/sdX
   ```
   Replace `/dev/sdX` with your USB device (e.g., `/dev/sdb`)

### Manual Build Process

If you prefer to build manually:

```bash
# Install dependencies
sudo pacman -S archiso git wget squashfs-tools libisoburn

# Make scripts executable
chmod +x build.sh setup.sh

# Build ISO
sudo ./build.sh
```

### What Gets Built

The build process creates:
- **Base System**: Arch Linux with latest kernel
- **Window Manager**: Hyprland compositor with Waybar
- **Applications**: Firefox, Kitty terminal, Thunar file manager
- **Network**: NetworkManager with GUI applet
- **Audio**: PipeWire with PulseAudio compatibility
- **Bootloader**: GRUB with UEFI support
- **Installer**: Custom graphical installer

### ISO Output

The final ISO will be located at:
```
build/out/bombaOS-YYYY.MM.DD-x86_64.iso
```

## Installing bombaOS

### System Requirements

- **Architecture**: x86_64 (64-bit)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 20GB minimum, 50GB recommended
- **Boot**: UEFI or Legacy BIOS support
- **Graphics**: Any modern GPU (Intel, AMD, NVIDIA)

### Installation Process

1. **Boot from USB/DVD**
   - Boot your computer from the bombaOS media
   - Select "bombaOS" from the boot menu

2. **Live Environment**
   - The system will boot into a live Hyprland session
   - You can test bombaOS before installing
   - Network should connect automatically via NetworkManager

3. **Start Installation**
   - Click "Install bombaOS" from the welcome screen
   - Or run: `sudo bombaOS-installer`

4. **Follow Installation Wizard**
   - **Disk Selection**: Choose target disk (⚠️ will be erased!)
   - **User Account**: Create your user account
   - **System Settings**: Configure timezone, locale, keyboard
   - **Installation**: Review and confirm installation

5. **Reboot**
   - Remove installation media when prompted
   - System will boot into your new bombaOS installation

### Post-Installation

After installation, bombaOS includes:

- **Hyprland**: Tiling Wayland compositor
- **Waybar**: Status bar with system information
- **Kitty**: GPU-accelerated terminal
- **Firefox**: Web browser
- **Thunar**: File manager with thumbnails
- **NetworkManager**: Network configuration
- **PipeWire**: Modern audio system

### Default Keybindings

- `Super + Q`: Open terminal
- `Super + R`: Application launcher (Wofi)
- `Super + E`: File manager
- `Super + C`: Close window
- `Super + M`: Exit Hyprland
- `Super + 1-9`: Switch workspaces
- `Super + Shift + 1-9`: Move window to workspace
- `Print`: Screenshot selection
- `Shift + Print`: Screenshot full screen

### Troubleshooting

**Boot Issues:**
- Ensure Secure Boot is disabled in BIOS/UEFI
- Try different USB ports or creation tools
- Verify ISO integrity with checksums

**Graphics Issues:**
- bombaOS includes drivers for Intel, AMD, and NVIDIA
- For older NVIDIA cards, you may need to install legacy drivers
- Use `nvidia-settings` for NVIDIA configuration

**Network Issues:**
- Use `nmtui` for text-based network configuration
- WiFi passwords are stored in NetworkManager
- Ethernet should work automatically

**Audio Issues:**
- Use `pavucontrol` for audio configuration
- Check `pipewire` and `wireplumber` services are running
- Restart audio: `systemctl --user restart pipewire`

### Getting Help

- **Documentation**: Check `/usr/share/doc/bombaOS/`
- **Logs**: Use `journalctl` to view system logs
- **Community**: Join the bombaOS community forums
- **Issues**: Report bugs on the bombaOS GitHub repository

### Customization

bombaOS is designed to be customizable:

- **Hyprland Config**: `~/.config/hypr/hyprland.conf`
- **Waybar Config**: `~/.config/waybar/`
- **Terminal Config**: `~/.config/kitty/kitty.conf`
- **Application Launcher**: `~/.config/wofi/`

Enjoy your new bombaOS system!