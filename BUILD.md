# Building IDA-Fusion with CMake

This project uses CMake for cross-platform building. CMake will automatically detect your platform and compiler.

## Prerequisites

- CMake 3.15 or higher
- Git (for cloning with submodules)
- IDA SDK (included as a Git submodule)
- A C++20 compatible compiler:
  - **Windows**: Visual Studio 2019+ or MinGW-w64
  - **Linux**: GCC 10+ or Clang 11+
  - **macOS**: Xcode 12+ (Clang)

## First Time Setup

If you haven't cloned the repository with submodules, initialize them:

```bash
git submodule update --init --recursive
```

## Quick Start

### Windows (Visual Studio)

```powershell
# Configure
cmake -B build -G "Visual Studio 17 2022" -A x64

# Build
cmake --build build --config Release

# Install (optional - copies to IDA plugins folder)
cmake --install build --config Release
```

### Windows (MinGW)

```powershell
# Configure
cmake -B build -G "MinGW Makefiles"

# Build
cmake --build build

# Install (optional)
cmake --install build
```

### Linux

```bash
# Configure
cmake -B build

# Build
cmake --build build

# Install (optional)
cmake --install build
```

### macOS

```bash
# Configure
cmake -B build

# Build
cmake --build build

# Install (optional)
cmake --install build
```

## Build Options

You can customize the build using the following CMake options:

- `BUILD_64BIT` - Build 64-bit plugin (default: ON)
- `BUILD_32BIT` - Build 32-bit plugin (default: OFF)
- `IDA_INSTALL_DIR` - IDA installation directory for installing the plugin
- `CMAKE_BUILD_TYPE` - Build type: Release or Debug (default: Release)

### Examples

Build both 32-bit and 64-bit versions:
```bash
cmake -B build -DBUILD_32BIT=ON -DBUILD_64BIT=ON
cmake --build build
```

Specify custom IDA installation directory:
```bash
cmake -B build -DIDA_INSTALL_DIR="/path/to/ida"
cmake --build build
cmake --install build
```

Build in Debug mode:
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

## Manual Installation

After building, the plugin files will be in:
- `build/fusion64.dll` (Windows 64-bit)
- `build/fusion.dll` (Windows 32-bit)
- `build/fusion64.so` (Linux 64-bit)
- `build/fusion64.dylib` (macOS 64-bit)

Copy these files to your IDA installation's `plugins` folder.

## Cleaning Build Files

To clean the build:
```bash
# Remove build directory
rm -rf build  # Linux/macOS
rmdir /s /q build  # Windows CMD
Remove-Item -Recurse -Force build  # Windows PowerShell
```

## Troubleshooting

### IDA SDK Not Found
Make sure the IDA SDK is extracted to the `sdk` folder in the project root.

### Library Linking Errors
Ensure you're using the correct IDA SDK version that matches your IDA installation.

### 32-bit Build on 64-bit System (Linux)
Install 32-bit development libraries:
```bash
sudo apt-get install gcc-multilib g++-multilib
```

### macOS Code Signing
For macOS, you may need to sign the plugin:
```bash
codesign -s - build/fusion64.dylib
```
