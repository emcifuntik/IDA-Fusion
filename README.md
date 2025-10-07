![Logo](https://user-images.githubusercontent.com/89423559/170590973-86a0c0dd-2052-49a6-bf03-b2178754c3f6.png)

# IDA-Fusion

[![CI Build](https://github.com/senator715/IDA-Fusion/actions/workflows/ci.yml/badge.svg)](https://github.com/senator715/IDA-Fusion/actions/workflows/ci.yml)
[![Release](https://github.com/senator715/IDA-Fusion/actions/workflows/release.yml/badge.svg)](https://github.com/senator715/IDA-Fusion/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/senator715/IDA-Fusion)](LICENSE)

IDA-Fusion is an ULTRA Fast Signature scanner & creator for IDA7 & IDA8+, now with cross-platform support for Windows, Linux, and macOS.

# Why IDA-Fusion?
This project was written due to the lack of stable and working signature scanners/creators available for IDA as a whole, Many of these projects are filled with bugs and create signatures that are not guaranteed to be unique. They are slow and tend to have trouble generating signatures in binaries where parts of the binary have been duplicated to prevent reverse engineering and reliable signature creation.

Some of the highlights of IDA-Fusion project:
- Uses GCC
- Very efficient creation and search algorithms.
- Signatures are guaranteed to be unique while delivering minimal size.
- Search for signatures quickly through large binaries.
- The ability to search using IDA & Code signatures.
- Auto jump to signatures found in a binary.
- Created signatures are automatically copied to the clipboard.
- Minimal bloat to increase productivity and speed when using IDA-Fusion.

# How does IDA-Fusion's signature creation work?
IDA-Fusion works by wild-carding any operand that contains an IMM (Immediate value), For instance, IDA-Fusion will signature the following instruction `lea rax, [rbx+10h]` explicitly as `lea rax, [rbx+?]`, However this does not work entirely the same way a usual signature creator would.

Highlighted in blue, demonstrates what is ommitted when a signature is created:
![yb2E5w5](https://user-images.githubusercontent.com/89423559/170587870-133ff3c1-e95a-4a20-a9ca-deb1390cbd40.png)

Creating signatures like this ensures that only the opcodes themselves are sigged, this process IDA-Fusion does differ greatly from other signature creation plugins. And is very good at creating reliable signatures for programs that are specifically attempting to implement anti-signature environments.

# Whats planned next?
We plan to work on many other features and further enhance and optimise IDA-Fusion as much as physically possible. We are always looking for those who are willing to contribute to the project.

Some of the future features planned are:
- CRC Signature generation.
- Reverse searching to create even smaller signatures. (Would be an option)
- Reference based signatures. (Would be an option)
- ~~Configuration dialog for toggling future and experimental features.~~
- Many other features.

# Requirements
- IDA 7.5 And above
- Windows, Linux, or macOS

# How to install

## Pre-built Binaries (Recommended)

1. Download the latest release from the [Releases page](https://github.com/senator715/IDA-Fusion/releases)
2. Choose the appropriate file for your platform:
   - **Windows 64-bit**: `fusion64-windows-x64.dll` → Rename to `fusion64.dll`
   - **Windows 32-bit**: `fusion-windows-x86.dll` → Rename to `fusion.dll`
   - **Linux 64-bit**: `fusion64-linux-x64.so` → Rename to `fusion64.so`
   - **macOS ARM64**: `fusion64-macos-arm64.dylib` → Rename to `fusion64.dylib`
   - **macOS Intel**: `fusion64-macos-x86_64.dylib` → Rename to `fusion64.dylib`
3. Copy the file(s) to your IDA installation's `plugins` folder
4. Restart IDA
5. Access via `Edit > Plugins > Fusion` or press `Ctrl+Alt+S`

## Build from Source

See the [How to compile](#how-to-compile) section below.

# How to compile

## Using CMake (Recommended - Cross-platform)
The project now uses CMake for cross-platform building supporting Windows, Linux, and macOS.

### Prerequisites
- CMake 3.15 or higher
- C++20 compatible compiler (Visual Studio 2019+, GCC 10+, or Clang 11+)
- Git (for cloning with submodules)

### Clone with Submodules

**First time clone:**
```bash
git clone --recursive https://github.com/senator715/IDA-Fusion.git
cd IDA-Fusion
```

**If already cloned, initialize submodules:**
```bash
git submodule update --init --recursive
```

### Quick Build

**Windows (PowerShell):**
```powershell
.\build.ps1
```

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

### Manual Build

**Windows:**
```powershell
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

**Linux/macOS:**
```bash
cmake -B build
cmake --build build
```

### Build Options
- Build both 32-bit and 64-bit: `.\build.ps1 -Both` (Windows) or `./build.sh --both` (Linux/macOS)
- Debug build: `.\build.ps1 -Debug` or `./build.sh --debug`
- Clean and build: `.\build.ps1 -Clean` or `./build.sh --clean`

See [BUILD.md](BUILD.md) for detailed build instructions and customization options.

## Legacy Build Methods (Deprecated)

<details>
<summary>Using make (deprecated - use CMake instead)</summary>

1. Download GCC (Preferably MSYS2)
2. Drag your IDA's `idasdk7.x.zip` contents into the `sdk` folder in IDA-Fusion
3. To avoid confusion, it is advisable to modify the copy directories in the following files: `compile32.bat` and `compile64.bat`
4. To compile IDA-Fusion for x86 & x64 IDA. run `compile.bat`
</details>

<details>
<summary>Using Visual Studio (deprecated - use CMake instead)</summary>

**Initial support cannot compile for x86 and has not been tested for IDA SDK versions lower to 9.0!**
1. Drag your IDA's `idasdk90.7z` contents into the `sdk` folder in IDA-Fusion
2. Set platform to x64 and compile
3. Compiled files will be written to the `out` folder
</details>

# Continuous Integration & Releases

This project uses GitHub Actions for automated building and releases:

- **CI Builds**: Every push and pull request is automatically built for all platforms
- **Automated Releases**: Pushing a version tag automatically creates a release with binaries
- **Multi-Platform**: Builds for Windows (x64, x86), Linux (x64), and macOS (ARM64, Intel)

See [.github/WORKFLOWS.md](.github/WORKFLOWS.md) for detailed workflow documentation.

## Creating a Release

Maintainers can create a new release by pushing a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will automatically build binaries for all platforms and create a GitHub release.

# Contributions

You are welcome to contribute to IDA-Fusion project and any help and advice would be greatly appreciated.

## Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all platforms build successfully (CI will verify)
5. Submit a pull request

All pull requests are automatically built and tested on Windows, Linux, and macOS.

