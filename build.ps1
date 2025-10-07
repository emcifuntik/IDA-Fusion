# Build script for IDA-Fusion on Windows
# Run with PowerShell

param(
    [switch]$Debug,
    [switch]$32bit,
    [switch]$Both,
    [switch]$Clean,
    [switch]$Install,
    [string]$Generator = "Visual Studio 17 2022",
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

if ($Help) {
    Write-ColorOutput "IDA-Fusion Build Script for Windows" "Cyan"
    Write-ColorOutput "====================================" "Cyan"
    Write-Host ""
    Write-Host "Usage: .\build.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Debug              Build in debug mode (default: Release)"
    Write-Host "  -32bit              Build 32-bit version only"
    Write-Host "  -Both               Build both 32-bit and 64-bit versions"
    Write-Host "  -Clean              Clean build directory before building"
    Write-Host "  -Install            Install to IDA plugins folder after building"
    Write-Host "  -Generator <name>   Specify CMake generator (default: 'Visual Studio 17 2022')"
    Write-Host "                      Other options: 'Visual Studio 16 2019', 'MinGW Makefiles', 'Ninja'"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build.ps1                    # Build 64-bit Release with Visual Studio"
    Write-Host "  .\build.ps1 -Debug             # Build 64-bit Debug"
    Write-Host "  .\build.ps1 -Both              # Build both 32-bit and 64-bit"
    Write-Host "  .\build.ps1 -Clean -Install    # Clean, build, and install"
    Write-Host "  .\build.ps1 -Generator 'MinGW Makefiles'  # Build with MinGW"
    exit 0
}

Write-ColorOutput "IDA-Fusion Build Script" "Green"
Write-ColorOutput "=======================" "Green"
Write-Host ""

# Determine build type
$BuildType = if ($Debug) { "Debug" } else { "Release" }

# Determine architectures
$Build64 = if ($32bit) { "OFF" } else { "ON" }
$Build32 = if ($32bit -or $Both) { "ON" } else { "OFF" }

# Clean if requested
if ($Clean) {
    Write-ColorOutput "Cleaning build directory..." "Yellow"
    if (Test-Path "build") {
        Remove-Item -Recurse -Force "build"
    }
}

# Create build directory
New-Item -ItemType Directory -Force -Path "build" | Out-Null

# Determine architecture flag for Visual Studio generators
$ArchFlag = @()
if ($Generator -like "Visual Studio*") {
    if ($32bit) {
        $ArchFlag = @("-A", "Win32")
    } else {
        $ArchFlag = @("-A", "x64")
    }
}

# Configure
Write-ColorOutput "Configuring CMake..." "Yellow"
$ConfigArgs = @(
    "-B", "build",
    "-G", $Generator,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DBUILD_64BIT=$Build64",
    "-DBUILD_32BIT=$Build32"
) + $ArchFlag

& cmake @ConfigArgs
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "CMake configuration failed!" "Red"
    exit 1
}

# Build
Write-ColorOutput "Building..." "Yellow"
$NumCores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
& cmake --build build --config $BuildType -j $NumCores
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Build failed!" "Red"
    exit 1
}

Write-ColorOutput "Build completed successfully!" "Green"
Write-Host ""
Write-ColorOutput "Output files:" "Cyan"
Get-ChildItem -Path "build\$BuildType\fusion*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  $($_.FullName)"
}

# Install if requested
if ($Install) {
    Write-Host ""
    Write-ColorOutput "Installing to IDA plugins folder..." "Yellow"
    & cmake --install build --config $BuildType
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Installation completed successfully!" "Green"
    } else {
        Write-ColorOutput "Installation failed! You may need to run as Administrator." "Red"
        exit 1
    }
} else {
    Write-Host ""
    Write-ColorOutput "To install to IDA plugins folder, run:" "Cyan"
    Write-Host "  cmake --install build --config $BuildType"
    Write-Host "  (You may need to run PowerShell as Administrator)"
}
