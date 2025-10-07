#!/bin/bash
# Build script for IDA-Fusion on Linux/macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}IDA-Fusion Build Script${NC}"
echo "======================="

# Parse command line arguments
BUILD_TYPE="Release"
BUILD_64=ON
BUILD_32=OFF
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --32bit)
            BUILD_32=ON
            shift
            ;;
        --both)
            BUILD_64=ON
            BUILD_32=ON
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --debug     Build in debug mode (default: Release)"
            echo "  --32bit     Build 32-bit version only"
            echo "  --both      Build both 32-bit and 64-bit versions"
            echo "  --clean     Clean build directory before building"
            echo "  --help      Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf build
fi

# Create build directory
mkdir -p build

# Configure
echo -e "${YELLOW}Configuring CMake...${NC}"
cmake -B build \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_64BIT=$BUILD_64 \
    -DBUILD_32BIT=$BUILD_32

# Build
echo -e "${YELLOW}Building...${NC}"
cmake --build build --config $BUILD_TYPE -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo -e "${GREEN}Build completed successfully!${NC}"
echo ""
echo "Output files:"
ls -lh build/fusion* 2>/dev/null || true

echo ""
echo "To install to IDA plugins folder, run:"
echo "  sudo cmake --install build --config $BUILD_TYPE"
