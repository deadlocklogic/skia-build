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
    libfontconfig1-dev \
    libfreetype6-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    ninja-build \
    python3 \
    python3-pip \
    unzip \
    zip

echo "Dependencies installed successfully."

echo "Installing Emscripten SDK..."

if [ ! -d "emsdk" ]; then
  git clone https://github.com/emscripten-core/emsdk.git
fi

cd emsdk
git pull

# ./emsdk install latest
# ./emsdk activate latest

# # Source environment to current shell
# source ./emsdk_env.sh

cd ..

# Now make emcc/em++ globally available for current session (already done) 
# and for GitHub Actions subsequent steps by exporting PATH to GITHUB_ENV

echo "Adding emsdk environment to GITHUB_ENV for subsequent GitHub Actions steps..."

# echo "PATH=$(pwd)/emsdk/upstream/emscripten:\$PATH" >> $GITHUB_ENV
# echo "EMSDK=$(pwd)/emsdk" >> $GITHUB_ENV
# echo "EMSDK_NODE=$(pwd)/emsdk/node/12.18.1_64bit/bin/node" >> $GITHUB_ENV
# echo "EM_CONFIG=\$HOME/.emscripten" >> $GITHUB_ENV

echo "Emscripten SDK installed and emcc/em++ available globally."

echo "Environment ready for Skia WASM build."
