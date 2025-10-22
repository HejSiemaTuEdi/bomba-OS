#!/bin/bash

# bombaOS Build Script
# Creates a complete Arch-based distribution with Hyprland

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
ISO_DIR="$BUILD_DIR/iso"
WORK_DIR="$BUILD_DIR/work"
OUT_DIR="$BUILD_DIR/out"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[bombaOS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_dependencies() {
    log "Checking build dependencies..."
    
    local deps=("archiso" "git" "wget" "squashfs-tools" "libisoburn")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null && ! pacman -Qi "$dep" &> /dev/null; then
            error "Missing dependency: $dep. Please install it first."
        fi
    done
    
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
    fi
}

setup_build_environment() {
    log "Setting up build environment..."
    
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR" "$ISO_DIR" "$WORK_DIR" "$OUT_DIR"
    
    # Copy archiso profile as base
    cp -r /usr/share/archiso/configs/releng/* "$WORK_DIR/"
    
    # Copy our custom configurations
    cp -r "$SCRIPT_DIR/configs/"* "$WORK_DIR/"
    cp -r "$SCRIPT_DIR/packages/"* "$WORK_DIR/"
    cp -r "$SCRIPT_DIR/installer" "$WORK_DIR/airootfs/usr/local/"
}

customize_packages() {
    log "Customizing package lists..."
    
    # Add our custom packages to packages.x86_64
    cat "$SCRIPT_DIR/packages/bombaOS-packages.txt" >> "$WORK_DIR/packages.x86_64"
    
    # Sort and remove duplicates
    sort -u "$WORK_DIR/packages.x86_64" -o "$WORK_DIR/packages.x86_64"
}

build_iso() {
    log "Building bombaOS ISO..."
    
    cd "$WORK_DIR"
    
    # Set custom ISO label and filename
    sed -i 's/iso_label="ARCH_.*"/iso_label="BOMBAOS"/' profiledef.sh
    sed -i 's/iso_name=.*/iso_name="bombaOS"/' profiledef.sh
    sed -i 's/iso_version=.*/iso_version="$(date +%Y.%m.%d)"/' profiledef.sh
    
    # Build the ISO
    mkarchiso -v -w "$BUILD_DIR/tmp" -o "$OUT_DIR" "$WORK_DIR"
    
    log "ISO build complete!"
    log "Output: $OUT_DIR/bombaOS-$(date +%Y.%m.%d)-x86_64.iso"
}

main() {
    log "Starting bombaOS build process..."
    
    check_dependencies
    setup_build_environment
    customize_packages
    build_iso
    
    log "bombaOS build completed successfully!"
    log "ISO location: $OUT_DIR/"
    
    # Make ISO bootable info
    echo
    echo "To create a bootable USB:"
    echo "sudo dd if=$OUT_DIR/bombaOS-*.iso of=/dev/sdX bs=4M status=progress"
    echo "Replace /dev/sdX with your USB device"
}

main "$@"