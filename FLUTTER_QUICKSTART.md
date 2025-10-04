# Flutter Quick Start Guide

Get the Flutter version of Beauty LMS running in minutes!

## Prerequisites

### 1. Install Flutter SDK

**Windows:**
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin
```

**macOS:**
```bash
# Install using Homebrew
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install/macos
```

**Linux:**
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz

# Extract
tar xf flutter_linux_3.24.5-stable.tar.xz

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Installation

```bash
flutter doctor
```

This will check for any missing dependencies.

### 3. Install Platform-Specific Tools

**For Android:**
- Install Android Studio
- Install Android SDK
- Accept Android licenses: `flutter doctor --android-licenses`

**For iOS (macOS only):**
- Install Xcode from App Store
- Install CocoaPods: `sudo gem install cocoapods`
- Accept Xcode license: `sudo xcodebuild -license`

**For Web:**
- Chrome browser is automatically detected

## Running the App

### 1. Get Dependencies

```bash
cd flutter_app
flutter pub get
```

### 2. Run on Your Platform

**Web (Easiest to get started):**
```bash
flutter run -d chrome
```

**Android:**
```bash
# Connect Android device or start emulator
flutter devices              # List available devices
flutter run -d <device-id>   # Run on specific device
# or simply
flutter run                  # Auto-selects device
```

**iOS (macOS only):**
```bash
# Connect iOS device or start simulator
flutter devices              # List available devices
flutter run -d <device-id>   # Run on specific device
```

### 3. Hot Reload

While the app is running:
- Press `r` to hot reload (instant updates)
- Press `R` to hot restart (full restart)
- Press `q` to quit

## Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

### Web
```bash
flutter build web --release
# Output: build/web/
# Deploy this folder to any web server
```

## Common Issues & Solutions

### Issue: "Flutter SDK not found"
**Solution:** Add Flutter to your PATH or run `flutter doctor` to diagnose

### Issue: "No devices found"
**Solution:** 
- For web: Make sure Chrome is installed
- For Android: Start an emulator or connect a device with USB debugging
- For iOS: Start a simulator or connect a device

### Issue: "Gradle build failed" (Android)
**Solution:** 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: "CocoaPods not installed" (iOS)
**Solution:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Issue: Package version conflicts
**Solution:**
```bash
flutter clean
flutter pub get
```

## IDE Setup (Optional but Recommended)

### VS Code
1. Install VS Code
2. Install "Flutter" extension
3. Install "Dart" extension
4. Run `Flutter: New Project` to test

### Android Studio
1. Install Android Studio
2. Go to Plugins → Install "Flutter" plugin
3. Install "Dart" plugin
4. Restart Android Studio

### IntelliJ IDEA
1. Install IntelliJ IDEA
2. Go to Plugins → Install "Flutter" plugin
3. Install "Dart" plugin
4. Restart IntelliJ

## Development Tips

### Enable Debug Mode Features
- **DevTools**: Run `flutter pub global activate devtools` then `flutter pub global run devtools`
- **Inspector**: Press `i` while app is running to open widget inspector
- **Performance**: Press `p` to show performance overlay

### Useful Commands
```bash
flutter analyze          # Check for issues
flutter test            # Run tests
flutter format .        # Format code
flutter upgrade         # Update Flutter SDK
flutter pub outdated    # Check for package updates
```

### Hot Tips
- Use `const` constructors when possible for better performance
- Use `ListView.builder` for long lists (already implemented)
- Enable null safety (already enabled in this project)

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart              # Entry point
│   ├── models/                # Data models
│   ├── services/              # API and Socket services
│   ├── screens/               # Full screens
│   └── widgets/               # Reusable widgets
├── android/                   # Android-specific files
├── ios/                       # iOS-specific files
├── web/                       # Web-specific files
├── pubspec.yaml              # Dependencies
└── README.md                 # Documentation
```

## Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Run `flutter run -d chrome` to test on web
3. ✅ Explore the app features
4. ✅ Try the API testing tool
5. ✅ Check out the code in `lib/` directory

## Need Help?

- Flutter Documentation: https://flutter.dev/docs
- Flutter Community: https://flutter.dev/community
- Flutter on Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Dart Language Tour: https://dart.dev/guides/language/language-tour

## Backend Connection

Make sure the backend is running and accessible:
- Backend URL: `https://krishnabarasiya.space/api`
- Socket.IO: `https://krishnabarasiya.space`

You can test connectivity using the built-in API tester in the app!

Happy Fluttering! 🚀
