# bombaOS

Please read WINDOWS-INSTALLATION-GUIDE.txt

A modern Arch-based Linux distribution featuring Hyprland compositor and a streamlined installation experience.

## Features

- **Base**: Arch Linux
- **Window Manager**: Hyprland (Wayland compositor)
- **Network**: NetworkManager
- **Bootloader**: GRUB
- **Installation**: Custom graphical installer
- **Target**: Modern systems with focus on performance and aesthetics

## Build System

- `build.sh` - Main build script
- `installer/` - Custom installer application
- `configs/` - System configurations
- `packages/` - Package lists and dependencies
- `iso/` - ISO generation scripts

## Quick Start

```bash
sudo ./build.sh
```


This will create a bootable ISO ready for USB installation.
