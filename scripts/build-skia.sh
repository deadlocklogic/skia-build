#!/bin/bash
set -euo pipefail

# Ensure we're running from repo root
cd "$(dirname "$0")/.."

case "$ENV_PLATFORM" in
  wasm)
    cd emsdk
    ./emsdk install latest
    ./emsdk activate latest
    source ./emsdk_env.sh
    cd ..
    ;;
esac

# Clone Skia repo if not present
if [ ! -d skia ]; then
  echo "Cloning Skia repository..."
  git clone https://skia.googlesource.com/skia.git
fi

cd skia

echo "Syncing Skia dependencies..."
python3 tools/git-sync-deps

case "$ENV_PLATFORM" in
  windows)
    SKIA_TARGET=""
    ;;
  linux)
    SKIA_TARGET=""
    ;;
  android)
    SKIA_TARGET="ndk=\"$ANDROID_NDK_ROOT\""
    SKIA_TARGET+=" "
    SKIA_TARGET+="target_os=\"android\""
    SKIA_TARGET+=" "
    SKIA_TARGET+="target_cpu=\"$ENV_ARCHITECTURE\""
    ;;
  wasm)
    SKIA_TARGET="cc=\"emcc\""
    SKIA_TARGET+=" "
    SKIA_TARGET="extra_cflags_cc=[\"-frtti\",\"-s\",\"USE_FREETYPE=1\",\"-s\",\"USE_PTHREADS=0\"]"
    SKIA_TARGET+=" "
    SKIA_TARGET+="cxx=\"em++\""
    SKIA_TARGET+=" "
    SKIA_TARGET+="extra_cflags=[\"-Wno-unknown-warning-option\",\"-s\",\"USE_FREETYPE=1\",\"-s\",\"USE_PTHREADS=0\"]"
    SKIA_TARGET+=" "
    SKIA_TARGET+="target_cpu=\"wasm\""
    ;;
  *)
    echo "Unsupported platform: $ENV_PLATFORM"
    exit 1
    ;;
esac

# Build Type
if [[ "${ENV_BUILD_TYPE,,}" == "debug" ]]; then
  SKIA_IS_DEBUG="is_debug=true"
elif [[ "${ENV_BUILD_TYPE,,}" == "release" ]]; then
  SKIA_IS_DEBUG="is_debug=false"
else
  echo "Unsupported build type: $ENV_BUILD_TYPE"
  exit 1
fi

# Library Type
if [[ "${ENV_LIBRARY_TYPE,,}" == "static" ]]; then
  SKIA_IS_COMPONENT_BULD="is_component_build=false"  # static libs
elif [[ "${ENV_LIBRARY_TYPE,,}" == "dynamic" ]]; then
  SKIA_IS_COMPONENT_BULD="is_component_build=true"   # dynamic/shared libs
else
  echo "Unsupported library type: $ENV_LIBRARY_TYPE"
  exit 1
fi

# Compose GN args per platform
case "$ENV_PLATFORM" in
  linux|android)
    PLATFORM_ARGS="skia_use_gl=false"
    ;;
  windows)
    PLATFORM_ARGS="skia_use_direct3d=true"
    ;;
  wasm)
    PLATFORM_ARGS="skia_use_libwebp=true"
    PLATFORM_ARGS+=" "
    PLATFORM_ARGS+="skia_use_freetype=true"
    PLATFORM_ARGS+=" "
    PLATFORM_ARGS+="skia_enable_tools=false"
    ;;
  *)
    echo "Unsupported platform: $ENV_PLATFORM"
    exit 1
    ;;
esac

echo "Generating build files in ../$ENV_BUILD_DIR...: bin/gn gen ../$ENV_BUILD_DIR --args=$SKIA_TARGET $SKIA_IS_DEBUG $SKIA_IS_COMPONENT_BULD $PLATFORM_ARGS"
bin/gn gen ../"$ENV_BUILD_DIR" --args="$SKIA_TARGET $SKIA_IS_DEBUG $SKIA_IS_COMPONENT_BULD $PLATFORM_ARGS"

echo "Starting build with ninja..."
ninja -C ../"$ENV_BUILD_DIR"

echo "Build completed successfully."
