#!/bin/bash

# Docker-based bombaOS build script for Windows users

echo "Building bombaOS using Docker..."

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM archlinux:latest

# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso git wget squashfs-tools libisoburn base-devel sudo

# Create build user (archiso requires non-root user for some operations)
RUN useradd -m -G wheel builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /bombaOS
COPY . .

# Fix permissions
RUN chmod +x setup.sh build.sh && \
    chown -R builder:builder /bombaOS

# Switch to builder user
USER builder

# Setup environment
RUN ./setup.sh

# Build command
CMD ["sudo", "./build.sh"]
EOF

# Build Docker image
echo "Building Docker image..."
docker build -t bombaos-builder .

# Run build in container with volume mount for output
echo "Starting build process..."
docker run --privileged -v "$(pwd)/build:/bombaOS/build" bombaos-builder

echo "Build completed! Check build/out/ for the ISO file."