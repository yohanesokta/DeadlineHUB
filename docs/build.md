# Build Instructions for DeadlineAI

DeadlineAI is built using **Flutter Desktop** and runs natively on Linux, Windows, and macOS.

---

## 1. Prerequisites

Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your development machine.

Ensure desktop support is enabled:
```bash
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
```

Verify your environment configuration using:
```bash
flutter doctor
```

---

## 2. Platform-Specific Setup

### Linux
To build on Linux (Ubuntu/Debian-based systems), install the required build dependencies:
```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

### Windows
To build on Windows:
1. Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/).
2. Select the **Desktop development with C++** workload during installation.

### macOS
To build on macOS:
1. Install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store.
2. Configure command-line tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
---

## 3. Compilation Commands

Before compiling, fetch the packages and build code generators:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Development Execution (Run Hot Reload)
Run the application in debug mode on your desktop:
```bash
flutter run
```

### Release Compilations
Build the production-ready standalone executable for your target OS:

* **Linux**:
  ```bash
  flutter build linux --release
  ```
  *Output binary locates at:* `build/linux/x64/release/bundle/deadlinehub`

* **Windows**:
  ```bash
  flutter build windows --release
  ```
  *Output folder locates at:* `build/windows/x64/release/runner/`

* **macOS**:
  ```bash
  flutter build macos --release
  ```
  *Output app bundle locates at:* `build/macos/Build/Products/Release/deadlinehub.app`
