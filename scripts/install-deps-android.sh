#!/bin/bash
set -euo pipefail

echo "Installing Android build dependencies..."

# Update package lists
sudo apt-get update

# Install essential packages
sudo apt-get install -y \
    clang \
    cmake \
    curl \
    git \
    ninja-build \
    openjdk-11-jdk \
    python3 \
    unzip \
    zip

# Download and setup Android SDK command line tools (if not already cached)
if [ ! -d "$HOME/Android/Sdk" ]; then
  mkdir -p "$HOME/Android/Sdk/cmdline-tools"
  curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
  unzip sdk-tools.zip -d "$HOME/Android/Sdk/cmdline-tools"
  rm sdk-tools.zip
  mv "$HOME/Android/Sdk/cmdline-tools/cmdline-tools" "$HOME/Android/Sdk/cmdline-tools/latest"
fi

export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/23.1.7779620
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH

# Accept licenses and install required SDK components
yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "ndk;23.1.7779620"

echo "Android dependencies installed."
