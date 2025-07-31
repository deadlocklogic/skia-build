#!/bin/bash
set -euo pipefail

PLATFORM=$1
BUILD_TYPE=$2
LIBRARY_TYPE=$3

# Ensure we're running from repo root
cd "$(dirname "$0")/.."

# Clone Skia repo if not present
if [ ! -d skia ]; then
  echo "Cloning Skia repository..."
  git clone https://skia.googlesource.com/skia.git
fi

cd skia

echo "Syncing Skia dependencies..."
python3 tools/git-sync-deps

case "$PLATFORM" in
  windows)
    SKIA_TARGET=""
    ;;
  linux)
    SKIA_TARGET=""
    ;;
  android)
    SKIA_TARGET="ndk=\"$ANDROID_NDK_ROOT\""
    SKIA_TARGET+="target_os=\"android\""
    SKIA_TARGET+="target_cpu=\"arm64\""
    ;;
  *)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

# Build Type
if [[ "${BUILD_TYPE,,}" == "debug" ]]; then
  SKIA_IS_DEBUG="is_debug=true"
elif [[ "${BUILD_TYPE,,}" == "release" ]]; then
  SKIA_IS_DEBUG="is_debug=false"
else
  echo "Unsupported build type: $BUILD_TYPE"
  exit 1
fi

# Library Type
if [[ "${LIBRARY_TYPE,,}" == "static" ]]; then
  SKIA_IS_COMPONENT_BULD="is_component_build=false"  # static libs
elif [[ "${LIBRARY_TYPE,,}" == "dynamic" ]]; then
  SKIA_IS_COMPONENT_BULD="is_component_build=true"   # dynamic/shared libs
else
  echo "Unsupported library type: $LIBRARY_TYPE"
  exit 1
fi

# Compose GN args per platform
case "$PLATFORM" in
  linux|android)
    PLATFORM_ARGS="skia_use_gl=false"
    ;;
  windows)
    PLATFORM_ARGS="skia_use_direct3d=true"
    ;;
  *)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

echo "Generating build files in ../$BUILD_DIR..."
bin/gn gen ../"$BUILD_DIR" --args="$SKIA_TARGET $SKIA_IS_DEBUG $SKIA_IS_COMPONENT_BULD $PLATFORM_ARGS"

echo "Starting build with ninja..."
ninja -C ../"$BUILD_DIR"

echo "Build completed successfully."
