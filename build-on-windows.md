# Building bombaOS on Windows

## Method 1: WSL2 with Arch Linux (Recommended)

1. **Install WSL2 and Arch Linux:**
   ```powershell
   # In PowerShell as Administrator
   wsl --install
   # Download Arch Linux WSL from: https://github.com/yuk7/ArchWSL
   ```

2. **Setup Arch Linux in WSL:**
   ```bash
   # Initialize pacman keyring
   sudo pacman-key --init
   sudo pacman-key --populate archlinux
   
   # Update system
   sudo pacman -Syu
   
   # Install build dependencies
   sudo pacman -S archiso git wget squashfs-tools libisoburn base-devel
   ```

3. **Copy bombaOS to WSL:**
   ```bash
   # Access Windows files from WSL
   cp -r /mnt/c/bosinnOS/bombaOS ~/bombaOS
   cd ~/bombaOS
   ```

4. **Build the ISO:**
   ```bash
   chmod +x setup.sh build.sh
   ./setup.sh
   sudo ./build.sh
   ```

## Method 2: Virtual Machine

1. **Download Arch Linux ISO:**
   - Get from: https://archlinux.org/download/

2. **Create VM with:**
   - VirtualBox, VMware, or Hyper-V
   - 4GB+ RAM, 50GB+ disk
   - Enable virtualization features

3. **Install Arch Linux in VM**
4. **Copy bombaOS files to VM**
5. **Build ISO in VM**

## Method 3: Docker (Advanced)

```dockerfile
# Create Dockerfile for Arch Linux build environment
FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git wget squashfs-tools libisoburn base-devel

WORKDIR /build
COPY . .
RUN chmod +x setup.sh build.sh && ./setup.sh

CMD ["./build.sh"]
```

## Output Location

After building, the ISO will be at:
- WSL: `~/bombaOS/build/out/bombaOS-YYYY.MM.DD-x86_64.iso`
- Copy back to Windows: `cp ~/bombaOS/build/out/*.iso /mnt/c/Users/YourName/Desktop/`