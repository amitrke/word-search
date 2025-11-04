# App Icon Generation Guide

This guide explains how to generate app icons for Android and iOS platforms from a single source image.

## Quick Start

Your app is already configured! To regenerate icons:

```bash
# Install/update dependencies
flutter pub get

# Generate icons
dart run flutter_launcher_icons
```

That's it! Icons will be automatically generated for both Android and iOS.

---

## What Was Set Up

### 1. Package Installed

Added to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### 2. Configuration Added

At the end of `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "docs/icon.png"
  min_sdk_android: 21
  remove_alpha_ios: true
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "docs/icon.png"
```

### 3. Source Icon

Your source icon is located at: `docs/icon.png`

**Requirements for source icon:**
- Minimum size: 1024x1024 pixels (recommended)
- Format: PNG with transparency
- Square aspect ratio
- Clear design that works at small sizes

---

## Generated Icons

### Android Icons

**Standard Icons** (all densities):
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

**Adaptive Icons** (Android 8.0+):
- Foreground and background layers
- Supports different device shapes (circle, square, rounded square)
- Generated in all density buckets

**Configuration File**:
- `android/app/src/main/res/values/colors.xml` (background color)

### iOS Icons

**All Required Sizes**:
- 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5
- Each in @1x, @2x, @3x variants
- 1024x1024 for App Store

**Location**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**Files Generated**: 21 PNG files + `Contents.json` configuration

---

## Updating Icons

### When to Regenerate

- After changing your app icon design
- Before submitting to app stores
- After rebranding

### How to Update

1. **Replace source image**:
   ```bash
   # Replace docs/icon.png with your new icon
   cp /path/to/new-icon.png docs/icon.png
   ```

2. **Regenerate icons**:
   ```bash
   dart run flutter_launcher_icons
   ```

3. **Test the new icons**:
   ```bash
   # Android
   flutter run

   # iOS (macOS only)
   flutter run -d ios
   ```

---

## Customization Options

### Using Different Icons Per Platform

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path_android: "docs/icon-android.png"
  image_path_ios: "docs/icon-ios.png"
```

### Adaptive Icon Customization (Android)

```yaml
flutter_launcher_icons:
  android: true
  adaptive_icon_background: "#FFA500"  # Orange background
  adaptive_icon_foreground: "docs/icon-foreground.png"
```

### Web Icons

```yaml
flutter_launcher_icons:
  web:
    generate: true
    image_path: "docs/icon.png"
    background_color: "#FFFFFF"
    theme_color: "#5A5CF0"
```

### Windows Icons

```yaml
flutter_launcher_icons:
  windows:
    generate: true
    image_path: "docs/icon.png"
    icon_size: 48
```

### macOS Icons

```yaml
flutter_launcher_icons:
  macos:
    generate: true
    image_path: "docs/icon.png"
```

---

## Alternative Methods

### Option 1: Online Tools

If you prefer not to use the package:

1. **Visit**: https://appicon.co/
2. **Upload**: Your 1024x1024 PNG icon
3. **Download**: Generated icon sets
4. **Manual replacement**:
   - Android: Replace files in `android/app/src/main/res/mipmap-*/`
   - iOS: Replace in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Android Studio / Xcode

**Android Studio**:
1. Right-click `res` folder
2. New → Image Asset
3. Configure icon → Finish

**Xcode**:
1. Open `ios/Runner.xcworkspace`
2. Navigate to Assets.xcassets → AppIcon
3. Drag & drop icons into slots

---

## Best Practices

### Source Image Guidelines

✅ **Do**:
- Use 1024x1024 or larger
- Use PNG format with transparency
- Design for visibility at 48x48 pixels
- Use high contrast colors
- Keep design simple and recognizable
- Test on light and dark backgrounds

❌ **Don't**:
- Use text (won't be readable at small sizes)
- Use gradients excessively
- Use photos (usually don't scale well)
- Include rounded corners (platform handles this)
- Add drop shadows (can cause artifacts)

### Testing Icons

1. **Check all sizes**:
   ```bash
   flutter run
   ```

2. **Test on real devices**:
   - Check home screen appearance
   - Verify in app drawer/list
   - Check settings/about page
   - Test light and dark mode

3. **Verify adaptive icons** (Android):
   - Try different launcher shapes
   - Check icon animations

---

## Troubleshooting

### Icons Not Updating

**Problem**: App still shows old icon after regeneration

**Solution**:
```bash
# Clean build
flutter clean

# Rebuild
flutter pub get
flutter run
```

For stubborn cases (Android):
```bash
# Uninstall app from device
adb uninstall com.yourcompany.wordsearch

# Reinstall
flutter run
```

### Adaptive Icons Look Wrong

**Problem**: Icon appears clipped or misaligned

**Solution**:
- Ensure foreground has padding (safe zone)
- Use adaptive icon guidelines (66dp safe zone)
- Test with different launcher shapes

### iOS Icons Not Showing

**Problem**: White/blank icon in iOS

**Solution**:
1. Check `Contents.json` is present
2. Verify all required sizes exist
3. Clean iOS build:
   ```bash
   cd ios
   rm -rf build
   pod install
   cd ..
   flutter run
   ```

### Package Version Issues

**Problem**: `flutter_launcher_icons` fails to run

**Solution**:
```bash
# Update to latest version
flutter pub upgrade flutter_launcher_icons

# Or specify version in pubspec.yaml
flutter_launcher_icons: ^0.13.1
```

---

## Icon Size Reference

### Android

| Density | Size | Folder |
|---------|------|--------|
| mdpi    | 48x48 | mipmap-mdpi |
| hdpi    | 72x72 | mipmap-hdpi |
| xhdpi   | 96x96 | mipmap-xhdpi |
| xxhdpi  | 144x144 | mipmap-xxhdpi |
| xxxhdpi | 192x192 | mipmap-xxxhdpi |

### iOS

| Purpose | Size | Scale |
|---------|------|-------|
| iPhone Notification | 20x20 | @2x, @3x |
| iPhone Settings | 29x29 | @2x, @3x |
| iPhone Spotlight | 40x40 | @2x, @3x |
| iPhone App | 60x60 | @2x, @3x |
| iPad Settings | 29x29 | @1x, @2x |
| iPad Spotlight | 40x40 | @1x, @2x |
| iPad App | 76x76 | @1x, @2x |
| iPad Pro | 83.5x83.5 | @2x |
| App Store | 1024x1024 | @1x |

---

## Resources

- **flutter_launcher_icons**: https://pub.dev/packages/flutter_launcher_icons
- **Android Icon Guidelines**: https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher
- **iOS Icon Guidelines**: https://developer.apple.com/design/human-interface-guidelines/app-icons
- **Adaptive Icons**: https://developer.android.com/develop/ui/views/launch/icon_design_adaptive
- **Online Generator**: https://appicon.co/
- **Icon Testing Tool**: https://adapticon.tooo.io/

---

## Summary

Your app is configured to automatically generate all required icons from `docs/icon.png`. Simply run:

```bash
dart run flutter_launcher_icons
```

Whenever you need to update your app icons, replace the source file and run the command again!
