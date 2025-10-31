# Getting Started with Flutter for webOS

Flutter-webOS is an extension to the Flutter SDK for developing Flutter applications for webOS. It provides the necessary tools and libraries to build, package, and run Flutter apps on webOS-powered devices.

## Quick Start

```bash
# 1. Check your environment
flutter-webos doctor -v

# 2. Download necessary artifacts
flutter-webos precache -f

# 3. Check for connected devices
flutter-webos devices

# 4. Create a new native webOS app
flutter-webos create --platforms webos --native-app helloworld

# 5. Build the app package (.ipk)
cd helloworld
flutter-webos build webos --ipk

# 6. Run the app on your device as debug mode
flutter-webos run --debug -d webos_tv
```

---

## Part 1: Environment Setup

This section covers the initial setup required for your development machine.

### 1.1. Prerequisites

#### Git Setup

Ensure your Git version is **2.23 or higher**.

```bash
git --version
# Example output: git version 2.49.0
```

Configure your global Git user settings:

```bash
git config --global user.name "{Your Name}"
git config --global user.email "{Your Email}"
cat ~/.gitconfig
```

### 1.2. OS-Specific Installation

#### For Linux (Ubuntu)

Supported versions: 18.04, 22.04, 24.04.

```bash
sudo apt-get upgrade -y
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install curl unzip cmake pkg-config file libgtk-3-0 libgtk-3-dev git ninja-build clang git-lfs -y
```

#### For macOS & Windows

For macOS and Windows, it is recommended to use a Linux environment like **WSL2 (Windows Subsystem for Linux)**. Once you have a Linux shell, follow the **Linux (Ubuntu)** instructions above.

### 1.3. Flutter-webOS SDK Installation

You will need to re-run this export command for each new terminal session.

#### 1. Clone the SDK Repository

```bash
cd flutter-webos-sdk/flutter-webos
# Add the CLI to your system's PATH
export PATH="$PATH:$(pwd)/bin"
```

#### 2. Set Engine Base URL

Create a [GitHub personal access token](https://github.com/settings/tokens) with `repo` scope. Then, set the environment variable:

```bash
export WEBOS_ENGINE_BASE_URL="https://<YOUR_GITHUB_TOKEN>@raw.githubusercontent.com/LGE-Univ-Sogang/flutter-webos-sdk/main/flutter-webos/releases"
```

#### 3. Install webOS NDK

```bash
cd NDK/
cat webos-ndk-basic-starfish-x86_64-ponytail-14.tar.gz.* | tar -xzvpf -
./webos-ndk-basic-starfish-x86_64-ponytail-14.sh -y
```

Source the environment setup script. **Note:** You may need to do this for each new terminal session.

```bash
export WEBOS_FLUTTER_NDK_ENV="/usr/local/starfish-bdk-x86_64/environment-setup-ca9v1-starfishmllib32-linux-gnueabi"
```

### 1.4. Verify Installation

Check that everything is configured correctly.

Upon running flutter-webos for the first time, you will be presented with a notice and a prompt:

`  This software is intended for educational purposes during the training period and must not be distributed.
  Do you agree to these terms? (Y/N):
 `

You must enter Y to agree and proceed. This notice will only be shown once.

- **Check Version:**
  ```bash
  flutter-webos --version
  ```
- **Run Doctor:**
  ```bash
  flutter-webos doctor -v
  ```
  A successful check will show `[✓]` next to all components.
- **Pre-cache Artifacts:**
  ```bash
  flutter-webos precache
  ```

---

## Part 2: Project Development

### 2.1. Create a Flutter-webOS Project

Create a new project with webOS support.

```bash
flutter-webos create --platforms webos --native-app helloworld
```

> _️ **Note:** The `--native-app` flag is crucial. It includes the native runner, ensuring your app works across different webOS versions._

You can also create a multi-platform project for both **webOS and Linux**:

```bash
flutter-webos create --platforms webos,linux --native-app helloworld
```

### 2.2. Build and Package

Navigate to your project directory and build the application.

```bash
cd helloworld
flutter-webos clean
```

#### Build Modes

Build an installable package (`.ipk`) in different modes:

```bash
# For development with debugging features
flutter-webos build webos --ipk --debug

# For performance profiling
flutter-webos build webos --ipk --profile

# For production release
flutter-webos build webos --ipk --release
```

> _️ **Note:** The `--ipk` flag is required to generate the webOS installation file._

#### Building for Linux (Optional)

If you added Linux support, you can build and run for the desktop:

```bash
flutter-webos build linux
flutter-webos run -d linux
```

---

## Part 3: Running and Debugging

### 3.1. Device Setup

#### Enable Developer Mode on TV

1.  Enable **Developer Mode** on your webOS TV.
2.  Turn on the **Key Server**.
3.  Note your **Passphrase**.
    For details, see the [webOS Developer Guide](https://webostv.developer.lge.com/develop/tools/webos-studio-dev-guide#webos-studio-developer-guide).

#### Register Your Device

First, enable the custom devices feature:

```bash
flutter-webos config --enable-custom-devices
```

Then, add your TV as a custom device:

```bash
flutter-webos custom-devices add
# Follow the prompts to enter ID, user, IP address, and port.
```

Retrieve the key from your TV:

```bash
flutter-webos custom-devices get-key -d <your_device_id>
# You will be prompted for the passphrase from Developer Mode.
```

Verify that the device is listed:

```bash
flutter-webos devices
```

### 3.2. Install and Run the App

Deploy and run your app on the configured device:

```bash
# Example for a debug build on a device named 'webos_tv'
flutter-webos run --debug -d webos_tv
```

A successful launch will show output like this:

```
Launching lib/main.dart on webOS in debug mode...
Syncing files to device webOS...

Flutter run key commands:
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
q Quit (terminate the application on the device).

A Dart VM Service on webOS is available at: http://127.0.0.1:<port>/<token>/
The Flutter DevTools debugger and profiler on webOS is available at: http://12gco.co/devtools-for-flutter
```

### 3.3. Debugging

To debug your application, open the **second URL** from the `flutter run` output in your web browser. This will launch the Flutter DevTools, providing tools for performance profiling, widget inspection, and more.

### **WARNING: `--home` Option Usage**

Building with the `--home` option will **overwrite the default home application** with your app. Use this option only when you intend to permanently replace the default home application.

After the patch applied, you can now build your application with the `--home` flag.

```bash
# Clean previous builds
flutter-webos clean

# Build the app with the --home flag (example with debug mode)
flutter-webos build webos --ipk --debug --home
```
