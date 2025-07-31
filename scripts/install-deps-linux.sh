#!/bin/bash
set -euo pipefail

echo "Installing dependencies for Linux..."

# Update package lists
sudo apt-get update

# Install essential build tools and libraries sorted alphabetically
sudo apt-get install -y \
    build-essential \
    clang \
    cmake \
    curl \
    git \
    libfontconfig1 \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    ninja-build \
    python3 \
    python3-pip \
    unzip \
    zip

echo "Dependencies installed successfully."
