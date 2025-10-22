# bombaOS Makefile

.PHONY: all build clean install-deps check-deps help

# Default target
all: build

# Build the ISO
build: check-deps
	@echo "Building bombaOS ISO..."
	sudo ./build.sh

# Install build dependencies
install-deps:
	@echo "Installing build dependencies..."
	sudo pacman -S --needed archiso git wget squashfs-tools libisoburn

# Check if dependencies are installed
check-deps:
	@echo "Checking build dependencies..."
	@command -v mkarchiso >/dev/null 2>&1 || { echo "archiso not found. Run 'make install-deps' first."; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "git not found. Run 'make install-deps' first."; exit 1; }
	@command -v wget >/dev/null 2>&1 || { echo "wget not found. Run 'make install-deps' first."; exit 1; }

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	sudo rm -rf build/

# Create USB bootable drive (requires USB_DEVICE variable)
usb:
ifndef USB_DEVICE
	@echo "Error: USB_DEVICE not specified"
	@echo "Usage: make usb USB_DEVICE=/dev/sdX"
	@exit 1
endif
	@echo "Creating bootable USB on $(USB_DEVICE)..."
	@echo "WARNING: This will erase all data on $(USB_DEVICE)!"
	@read -p "Continue? [y/N] " -n 1 -r; echo; if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then exit 1; fi
	sudo dd if=build/out/bombaOS-*.iso of=$(USB_DEVICE) bs=4M status=progress oflag=sync

# Show help
help:
	@echo "bombaOS Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build        - Build the bombaOS ISO (default)"
	@echo "  install-deps - Install required build dependencies"
	@echo "  check-deps   - Check if dependencies are installed"
	@echo "  clean        - Clean build artifacts"
	@echo "  usb          - Create bootable USB (requires USB_DEVICE=/dev/sdX)"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make usb USB_DEVICE=/dev/sdb"