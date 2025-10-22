#!/bin/bash

# bombaOS Setup Script
# Makes all scripts executable and sets up the build environment

echo "Setting up bombaOS build environment..."

# Make scripts executable
chmod +x build.sh
chmod +x installer/bombaOS-installer
chmod +x installer/bombaOS-welcome
chmod +x configs/airootfs/root/.automated_script.sh
chmod +x configs/airootfs/usr/local/bin/bombaOS-installer
chmod +x configs/airootfs/usr/local/bin/bombaOS-welcome

echo "bombaOS setup completed!"
echo ""
echo "To build bombaOS:"
echo "1. Run: sudo make install-deps"
echo "2. Run: sudo make build"
echo ""
echo "The ISO will be created in build/out/"