# Deployment Guide

This guide covers deploying the Word Search app to Google Play Store (Android) and Apple App Store (iOS).

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Android - Google Play Store](#android---google-play-store)
3. [iOS - Apple App Store](#ios---apple-app-store)
4. [Post-Deployment](#post-deployment)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### General Requirements

- **Flutter SDK** installed and configured
- **Git** for version control
- **Firebase project** set up (see `TECHNICAL_SETUP.md`)
- App icons and screenshots prepared
- Privacy policy URL (required by both stores)
- App store developer accounts (see below)

### Google Play Store Account

- **Cost**: $25 one-time registration fee
- **Sign up**: https://play.google.com/console/signup
- **Requirements**:
  - Google account
  - Credit/debit card for payment
  - Valid phone number

### Apple Developer Account

- **Cost**: $99/year subscription
- **Sign up**: https://developer.apple.com/programs/
- **Requirements**:
  - Apple ID
  - Two-factor authentication enabled
  - Credit/debit card for payment
  - Enrolled in Apple Developer Program

### Firebase Configuration

Ensure your Firebase project is configured for production:

```bash
# Verify Firebase configuration
flutterfire configure
```

---

## Android - Google Play Store

### Step 1: Configure App Signing

#### Create a Keystore

1. **Generate keystore file** (run from project root):

```bash
keytool -genkey -v -keystore C:\Users\amitr\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> **Note**: Replace `C:\Users\amitr\upload-keystore.jks` with your desired path. On macOS/Linux, use `~/upload-keystore.jks`

2. **Answer the prompts**:
   - Enter keystore password (SAVE THIS!)
   - Re-enter password
   - Enter your name and organization details
   - Confirm with `yes`

3. **Save credentials securely**:
   - Store password
   - Store alias (`upload`)
   - Keep keystore file safe (NEVER commit to git!)

#### Configure Signing in Android

1. **Create key properties file**:

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:/Users/amitr/upload-keystore.jks
```

> **IMPORTANT**: Add `android/key.properties` to `.gitignore`!

2. **Update `android/app/build.gradle`**:

```gradle
// Add before 'android {' block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    // Add signing configs
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... existing config ...
        }
    }
}
```

### Step 2: Update App Configuration

1. **Update `android/app/build.gradle`**:

```gradle
android {
    namespace "com.yourcompany.wordsearch"  // Update this
    compileSdkVersion 34  // Use latest

    defaultConfig {
        applicationId "com.yourcompany.wordsearch"  // Update this (must be unique)
        minSdkVersion 21  // Minimum Android version
        targetSdkVersion 34  // Use latest
        versionCode 1  // Increment for each release
        versionName "1.0.0"  // User-visible version
    }
}
```

2. **Update `android/app/src/main/AndroidManifest.xml`**:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="Word Search"  <!-- App name -->
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">  <!-- App icon -->
        <!-- ... -->
    </application>
</manifest>
```

### Step 3: Prepare App Icons

1. **Generate Android icons**:
   - Use https://appicon.co/ or Android Studio's Image Asset Studio
   - Required sizes: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
   - Place in: `android/app/src/main/res/mipmap-*/`

2. **Update icon reference** in `AndroidManifest.xml` if needed

### Step 4: Build Release APK/AAB

1. **Build App Bundle (recommended for Play Store)**:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

2. **Or build APK** (for testing or alternative stores):

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Create Play Store Listing

1. **Go to Google Play Console**: https://play.google.com/console

2. **Create app**:
   - Click "Create app"
   - Enter app name: "Word Search"
   - Select default language
   - Choose app/game type: "Game"
   - Select free/paid

3. **Complete store listing**:
   - **App details**:
     - Short description (80 chars)
     - Full description (4000 chars max)
   - **Graphics**:
     - App icon (512x512 PNG)
     - Feature graphic (1024x500 PNG)
     - Screenshots (minimum 2):
       - Phone: 16:9 or 9:16 aspect ratio
       - Tablet: 16:9 or 9:16 aspect ratio
   - **Categorization**:
     - App category: "Puzzle" or "Word"
     - Content rating: Complete questionnaire
   - **Contact details**:
     - Email address
     - Privacy policy URL

4. **Set up pricing & distribution**:
   - Select countries
   - Confirm content guidelines
   - US export laws compliance

### Step 6: Upload and Release

1. **Create release**:
   - Navigate to "Production" → "Create new release"
   - Upload `app-release.aab` file
   - Add release notes
   - Review and roll out

2. **App review**:
   - Google reviews app (usually 1-7 days)
   - Fix any issues if rejected
   - Once approved, app goes live

---

## iOS - Apple App Store

### Step 1: Xcode Configuration

1. **Open iOS project in Xcode**:

```bash
open ios/Runner.xcworkspace
```

2. **Update project settings**:
   - Click on "Runner" in project navigator
   - Select "Runner" under TARGETS
   - **General tab**:
     - Display Name: "Word Search"
     - Bundle Identifier: `com.yourcompany.wordsearch` (must be unique)
     - Version: `1.0.0`
     - Build: `1`
   - **Signing & Capabilities**:
     - Team: Select your Apple Developer team
     - Provisioning Profile: Automatic
     - Check "Automatically manage signing"

### Step 2: Configure App Icons

1. **Generate iOS icons**:
   - Use https://appicon.co/
   - Download iOS icon set
   - Replace icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

2. **Verify in Xcode**:
   - Assets.xcassets → AppIcon
   - Ensure all sizes are present

### Step 3: Update Info.plist

Edit `ios/Runner/Info.plist`:

```xml
<dict>
    <key>CFBundleDisplayName</key>
    <string>Word Search</string>

    <key>CFBundleName</key>
    <string>word_search</string>

    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>

    <key>CFBundleVersion</key>
    <string>1</string>

    <!-- Add privacy usage descriptions if needed -->
    <key>NSCameraUsageDescription</key>
    <string>This app does not use the camera</string>
</dict>
```

### Step 4: Configure Firebase for iOS

1. **Verify Firebase setup**:

```bash
flutterfire configure
```

2. **Ensure `GoogleService-Info.plist` is in `ios/Runner/`**

3. **Update iOS bundle ID** in Firebase Console to match Xcode

### Step 5: Build iOS App

1. **Build for release**:

```bash
flutter build ios --release
```

2. **Archive in Xcode**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device" or a real device
   - Product → Archive
   - Wait for archive to complete

### Step 6: App Store Connect Setup

1. **Go to App Store Connect**: https://appstoreconnect.apple.com

2. **Create new app**:
   - Click "My Apps" → "+"
   - Select "New App"
   - Platform: iOS
   - Name: "Word Search"
   - Primary Language: English
   - Bundle ID: Select your configured bundle ID
   - SKU: `wordsearch-001` (unique identifier)

3. **Complete app information**:
   - **App Information**:
     - Privacy Policy URL
     - Category: Games → Puzzle
     - Subcategory: Word
   - **Pricing and Availability**:
     - Price: Free
     - Availability: All countries

4. **Prepare app version**:
   - **Screenshots** (use iPhone 6.7" and iPad Pro):
     - iPhone: 1290 x 2796 (minimum 3)
     - iPad: 2048 x 2732 (minimum 3)
   - **Promotional text** (170 chars)
   - **Description** (4000 chars max)
   - **Keywords** (100 chars, comma-separated)
   - **Support URL**
   - **Marketing URL** (optional)

### Step 7: Upload Build

1. **From Xcode Organizer**:
   - Window → Organizer
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Upload

2. **In App Store Connect**:
   - Wait for processing (5-30 minutes)
   - Once processed, select build for your version
   - Add "What's New in This Version"

### Step 8: Submit for Review

1. **Complete App Review Information**:
   - Contact information
   - Demo account (if login required)
   - Notes for reviewer

2. **Content Rights**:
   - Confirm you have rights to use content

3. **Submit**:
   - Review all information
   - Click "Submit for Review"
   - Wait for approval (1-7 days typically)

---

## Post-Deployment

### Monitor App Performance

#### Google Play Console

- **Track metrics**:
  - Installs and uninstalls
  - Ratings and reviews
  - Crash reports (via Firebase Crashlytics)
  - ANRs (Application Not Responding)

- **Dashboard**: https://play.google.com/console

#### App Store Connect

- **Track metrics**:
  - Downloads and sales
  - Ratings and reviews
  - Crash reports
  - App Analytics

- **Dashboard**: https://appstoreconnect.apple.com

### Release Updates

#### Android Updates

1. **Increment version**:
   - Update `versionCode` (e.g., 1 → 2)
   - Update `versionName` (e.g., 1.0.0 → 1.1.0)

2. **Build and upload**:
```bash
flutter build appbundle --release
```

3. **Create new release** in Play Console

#### iOS Updates

1. **Increment version**:
   - Update `CFBundleShortVersionString` (e.g., 1.0.0 → 1.1.0)
   - Update `CFBundleVersion` (e.g., 1 → 2)

2. **Build and upload**:
```bash
flutter build ios --release
# Then archive in Xcode
```

3. **Create new version** in App Store Connect

### Versioning Strategy

Follow semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features, backwards compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes only

---

## Troubleshooting

### Android Common Issues

#### Build fails with signing errors

- Verify `key.properties` exists and has correct values
- Check keystore file path is correct
- Ensure passwords match

#### "Duplicate class" errors

- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Try build again

#### App rejected for policy violations

- Review Google Play policies: https://play.google.com/about/developer-content-policy/
- Ensure privacy policy is comprehensive
- Check all permissions are justified

### iOS Common Issues

#### Code signing errors

- Verify Apple Developer account is active ($99/year)
- Check bundle identifier is unique and registered
- Ensure "Automatically manage signing" is enabled
- Try cleaning build folder: Product → Clean Build Folder

#### Archive fails or grayed out

- Select "Any iOS Device (arm64)"
- Ensure no errors in scheme
- Check all required icons are present

#### App rejected in review

- Common reasons:
  - Missing functionality
  - Crashes on startup
  - Privacy policy issues
  - Incomplete App Store information
- Address feedback and resubmit

### Firebase Issues

#### App can't connect to Firebase

- Verify `google-services.json` (Android) is up to date
- Verify `GoogleService-Info.plist` (iOS) is up to date
- Check bundle ID/package name matches Firebase Console
- Run `flutterfire configure` to regenerate

#### Cloud Functions not working in production

- Ensure functions are deployed: `firebase deploy --only functions`
- Check billing is enabled (Blaze plan required for external API calls)
- Verify API keys are set: `firebase functions:config:get`

---

## Checklists

### Pre-Release Checklist

- [ ] All features tested on physical devices
- [ ] No debug code or console logs in production
- [ ] Privacy policy created and hosted
- [ ] App icons generated for all sizes
- [ ] Screenshots captured (Android & iOS)
- [ ] App descriptions written
- [ ] Keywords researched
- [ ] Firebase configuration verified
- [ ] Version numbers updated
- [ ] Release notes written
- [ ] Keystore/certificates backed up securely

### Android Release Checklist

- [ ] Keystore created and secured
- [ ] `key.properties` configured (not in git)
- [ ] `applicationId` is unique
- [ ] `versionCode` and `versionName` updated
- [ ] App signed with release keystore
- [ ] APK/AAB tested on physical device
- [ ] Play Store listing complete
- [ ] Content rating completed
- [ ] Privacy policy URL added
- [ ] Screenshots uploaded (phone + tablet)
- [ ] Release notes added

### iOS Release Checklist

- [ ] Apple Developer account active
- [ ] Bundle ID configured in Xcode
- [ ] Team selected in signing settings
- [ ] App icons added to Assets.xcassets
- [ ] Info.plist updated
- [ ] Version and build numbers updated
- [ ] Archive built successfully
- [ ] App Store Connect listing complete
- [ ] Screenshots uploaded (iPhone + iPad)
- [ ] Privacy policy URL added
- [ ] Build uploaded and processed
- [ ] What's New text added
- [ ] App submitted for review

---

## Additional Resources

### Documentation

- **Flutter deployment**: https://docs.flutter.dev/deployment
- **Google Play Console**: https://support.google.com/googleplay/android-developer
- **App Store Connect**: https://developer.apple.com/app-store-connect/
- **Firebase Console**: https://console.firebase.google.com

### Tools

- **App Icon Generator**: https://appicon.co/
- **Screenshot Generator**: https://www.applaunchpad.com/
- **Privacy Policy Generator**: https://app-privacy-policy-generator.firebaseapp.com/

### Support

- **Flutter Discord**: https://discord.com/invite/flutter
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/flutter
- **GitHub Issues**: Create issues in your repository

---

## Notes

- **First release takes longest**: Subsequent updates are faster
- **App review times vary**: Plan releases accordingly
- **Keep credentials secure**: Never commit keystores or API keys
- **Test on real devices**: Emulators don't catch all issues
- **Monitor after release**: Watch for crashes and user feedback
- **Update regularly**: Keep dependencies and Flutter SDK updated

Good luck with your deployment!
