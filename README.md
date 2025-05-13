# 🎓 Students Service App – Faculty of Science.

---

## 📘 Project Overview

A cross-platform Flutter application designed to support Faculty of Science students at Ain Shams University by providing GPA calculation, course management, and academic tools — all in one place. It runs on Android, iOS, and can be tested on Windows/macOS via emulators.

## 📱 Features

- 📢 Faculty news feed with real-time notifications  
- 🧮 GPA Calculator (term and cumulative)  
- 📝 Personal Notes with local storage (save, edit, delete) and integrated reminder functionality.
- 📅 Custom Weekly Schedule: students can create, edit, and save their personal class timetable  
- 🔐 Secure Login with OTP-based password reset  
- 🌐 Quick access to UMS, ASU2Learn, Microsoft tools  
- 📨 Submit complaints directly to the university  
- 👤 Student Profile with basic information

---

## 📋 Prerequisites

Make sure the following requirements are met before running the application:

| Component        | Required Version           |
| -----------------| -------------------------- |
| Operating System | Android 5.0+ or iOS 12+    |
| Flutter SDK      | Version 3.22.2 or higher   |
| Dart SDK         | Comes bundled with Flutter |
| Device Storage   | At least 1.06 GB available |
| Xcode (for iOS)  | Latest version for macOS   |

---

## 🚀 Pre-built Executable Setup

If you don’t want to build the project from source, you can run the ready-to-use version of the app by following the steps below:


### 📅 Download & Installation

#### 🔹 For Android (APK file)

1. Download the **APK** file from the [Releases](https://github.com/Mahaismailelsayed/Students-Service/releases) section of the GitHub repository.
2. Transfer the APK file to your Android device.
3. On the device:

   * Go to **Settings > Security**, and enable **“Install from unknown sources”** if not already enabled.
   * Open the APK file and install it.

#### 🔹 For iOS (via Xcode or TestFlight)

1. Open the project using **Xcode** on a macOS device.
2. Connect your iPhone or use the iOS Simulator.
3. Run the app directly from Xcode.

#### 🔹 For Windows/macOS (via Emulator/Simulator)

1. If you are on **Windows/macOS** and would like to run the app, ensure that you have an Android/iOS emulator installed.
2. Open the project in **Flutter** and run it on the emulator using the following command:
   ```bash
   flutter run

---

### ▶️ Launching the App

#### On Android:

* After installation, open the **Students Service** app from the home screen or app drawer.

#### On iOS:

* After installation via Xcode , tap the app icon to launch it.

### On Windows/macOS:

* If running through an emulator, open the emulator and launch the app from the Flutter environment.

---

### 🛠️ Development Setup (Build and Run from Source)

To build and run the app from source, follow these steps:

🔹 For Windows

1. Install Prerequisites:
  * Download and install Git from git-scm.com.
  *  Install Android Studio from developer.android.com.
  *   Install Flutter SDK:
  **      Download from flutter.dev.
  **      Extract to C:\flutter and add C:\flutter\bin to your system PATH.
  * Install JDK 11 from oracle.com.

2. Clone the Repository:
   ```bash
    git clone https://github.com/Mahaismailelsayed/Students-Service.git
   cd Students-Service

3. Install Dependencies:
   ```bash
   flutter pub get

4. Set Up Emulator:

  * Open Android Studio, go to Device Manager, and create an Android Virtual Device (AVD).

5. Run the App:
   ```bash
   flutter run
  
  * Select the emulator or connected device when prompted.


🔹 For macOS

1. Install Prerequisites:

* Install Git using Homebrew: brew install git.
* Install Android Studio from developer.android.com.

* Install Xcode from the Mac App Store.

* Install Flutter SDK:

  ** Download from flutter.dev.

  ** Extract to ~/flutter and add ~/flutter/bin to your PATH (edit ~/.zshrc or ~/.bashrc).

* Install JDK 11 using Homebrew: brew install openjdk@11.

2. Clone the Repository:
   ```bash
   git clone https://github.com/Mahaismailelsayed/Students-Service.git
   cd Students-Service

3. Install Dependencies:
   ```bash
   flutter pub get

4. Set Up Emulator:

 * For Android: Open Android Studio, go to Device Manager, and create an Android Virtual Device (AVD).

 * For iOS: Open Xcode, select a simulator from the device list.

5. Run the App:
   ```bash
   flutter run

 * Select the emulator or connected device when prompted.

---

## ⚙️ Configuration Steps



---

## 🛠️ Troubleshooting Tips

| Problem                         | Suggested Solution                                                     |
| --------------------------------| --------------------------------------------------------------         |
| App not installing on Android   | Make sure “Install from unknown sources” is enabled.                   |
| Flutter build errors            | Run `flutter doctor` to diagnose and fix SDK/setup issues.             |
| iOS build fails in Xcode        | Ensure you have a valid development certificate and profile.           |
| API not responding              | Check internet connection and confirm the API URL is correct.          |
| White screen after launch       | Likely a failed API call — check server availability and logs.         |
| Emulator not showing in Flutter | Ensure Android Studio/Xcode is installed and emulators are configured. |
|Flutter SDK not found            | Verify Flutter path in system PATH and run flutter doctor.             |

---
