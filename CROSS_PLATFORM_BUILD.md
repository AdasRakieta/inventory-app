# Cross-Platform Build Configuration

This document describes the cross-platform build configuration for the Inventory App Android project.

## Overview

The project now supports building and deploying on **Windows, Linux, and macOS** without any platform-specific configuration changes.

## What Changed

### 1. gradle.properties
- **Before:** Hardcoded Windows-specific Java home path
  ```properties
  org.gradle.java.home=C:\\Tools\\jdk-11.0.28+6
  ```
- **After:** Commented out, Gradle auto-detects JDK
  ```properties
  # Commented out Windows-specific path - Gradle will auto-detect JDK from JAVA_HOME or PATH
  # org.gradle.java.home=C:\\Tools\\jdk-11.0.28+6
  ```

### 2. app/build.gradle.kts - Custom Tasks

Added two helper functions for cross-platform compatibility:

```kotlin
fun isWindows(): Boolean {
    return System.getProperty("os.name").lowercase().contains("windows")
}

fun getAdbPath(): String {
    // Try ANDROID_HOME first (standard), then ANDROID_SDK_ROOT (legacy)
    val androidHome = System.getenv("ANDROID_HOME") ?: System.getenv("ANDROID_SDK_ROOT")
    
    if (androidHome != null) {
        val adbExecutable = if (isWindows()) "adb.exe" else "adb"
        val adbPath = "$androidHome${File.separator}platform-tools${File.separator}$adbExecutable"
        
        // Validate that the path exists before returning it
        if (File(adbPath).exists()) {
            return adbPath
        }
    }
    
    // Fallback: assume adb is in PATH
    return if (isWindows()) "adb.exe" else "adb"
}
```

Updated tasks:
- **deployDebug** - Build, install and launch debug APK
- **runOnDevice** - Launch app on connected device

Both tasks now:
- Detect the operating system
- Use appropriate command syntax (cmd /c on Windows, direct on Linux/Mac)
- Dynamically locate adb using environment variables
- Fall back to PATH if environment variables not set

## Usage

### Prerequisites

Ensure you have one of the following environment variables set:

- **ANDROID_HOME** (recommended) - Points to your Android SDK
- **ANDROID_SDK_ROOT** (legacy) - Points to your Android SDK

Example:
```bash
# Linux/Mac
export ANDROID_HOME=/path/to/android/sdk

# Windows
set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
```

If neither is set, ensure `adb` is in your system PATH.

### Available Commands

#### Build and Deploy (all platforms)
```bash
# Linux/Mac
./gradlew deployDebug

# Windows
.\gradlew.bat deployDebug
```

This will:
1. Build the debug APK
2. Install it on a connected device
3. Launch the app

#### Quick Deploy (no clean)
```bash
# Linux/Mac
./gradlew quickDeploy

# Windows
.\gradlew.bat quickDeploy
```

#### Run on Device (assumes app already installed)
```bash
# Linux/Mac
./gradlew runOnDevice

# Windows
.\gradlew.bat runOnDevice
```

#### Standard Build Commands
```bash
# Build debug APK
./gradlew assembleDebug          # Linux/Mac
.\gradlew.bat assembleDebug      # Windows

# Clean build
./gradlew clean assembleDebug    # Linux/Mac
.\gradlew.bat clean assembleDebug # Windows

# Install on device
./gradlew installDebug           # Linux/Mac
.\gradlew.bat installDebug       # Windows
```

## Platform-Specific Behavior

### Windows
- Uses `cmd /c` to execute commands
- Looks for `adb.exe`
- Example ADB path: `C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools\adb.exe`

### Linux/Mac
- Executes commands directly (no cmd wrapper)
- Looks for `adb`
- Example ADB path: `/home/user/Android/Sdk/platform-tools/adb`

## Troubleshooting

### "adb not found" Error

**Solution:** Set ANDROID_HOME environment variable or add adb to your PATH.

Linux/Mac:
```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

Windows:
```cmd
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set PATH=%PATH%;%ANDROID_HOME%\platform-tools
```

### "No devices found" Error

**Solution:** Ensure a device or emulator is connected and USB debugging is enabled.

Check connected devices:
```bash
adb devices
```

### Gradle JDK Issues

**Solution:** If Gradle can't find a JDK, set JAVA_HOME or uncomment and update the `org.gradle.java.home` line in `gradle.properties` with your JDK path.

Linux/Mac:
```bash
export JAVA_HOME=/path/to/jdk-11
```

Windows:
```cmd
set JAVA_HOME=C:\Program Files\Java\jdk-11
```

## Testing the Configuration

Run the following to verify everything works:

```bash
# Check available tasks
./gradlew tasks --group custom

# Should show:
#   deployDebug - Build, install and launch debug APK on connected device
#   quickDeploy - Quick build and install debug APK on connected device (no clean)
#   runOnDevice - Launch app on connected device (assumes app is already installed)
```

## Migration Notes

If you have an existing checkout with the old Windows-specific configuration:

1. **gradle.properties** - The Windows-specific path is now commented out. Gradle will auto-detect your JDK.
2. **No code changes needed** - The tasks automatically detect your OS and use the correct commands.
3. **Environment variables** - Set ANDROID_HOME for best results (recommended for all Android development).

## Benefits

✅ **No platform-specific configuration** - Same build files work on all platforms  
✅ **Automatic OS detection** - Tasks adapt to your operating system  
✅ **Environment variable support** - Uses standard Android SDK environment variables  
✅ **Fallback mechanism** - Works even without environment variables if adb is in PATH  
✅ **Maintainable** - Single source of truth for build configuration  

## Technical Details

### OS Detection
Uses `System.getProperty("os.name").lowercase().contains("windows")` to detect Windows. All other platforms (Linux, macOS, etc.) use Unix-style commands.

### ADB Path Resolution Priority
1. `ANDROID_HOME` environment variable (standard) - validated to exist
2. `ANDROID_SDK_ROOT` environment variable (legacy) - validated to exist
3. Fallback to `adb` in system PATH

The function uses `File.separator` for cross-platform path construction and validates that the resolved path exists before using it.

### Command Execution
- **Windows:** `commandLine("cmd", "/c", adbPath, ...)`
- **Linux/Mac:** `commandLine(adbPath, ...)`

This ensures proper process execution on each platform.
