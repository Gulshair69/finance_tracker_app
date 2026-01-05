# Finance Tracker App - Complete Instructions

## 📱 Project Overview
A comprehensive finance management application built with Flutter and Firebase, featuring transaction tracking, budgets, goals, analytics, and real-time data synchronization.

## 📁 Folder Structure

```
finance_tracker_app/
│
├── android/                          # Android platform files
│   ├── app/
│   │   ├── build.gradle.kts        # App-level build configuration
│   │   ├── google-services.json     # Firebase configuration (IMPORTANT)
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml
│   ├── build.gradle.kts            # Project-level build configuration
│   └── gradle/                      # Gradle wrapper files
│
├── ios/                              # iOS platform files
│   └── Runner/
│       └── Info.plist
│
├── lib/                              # Main application code
│   ├── constants/
│   │   └── app_colors.dart          # App color constants
│   ├── models/                      # Data models
│   │   ├── transaction_model.dart
│   │   ├── category_model.dart
│   │   ├── budget_model.dart
│   │   ├── goal_model.dart
│   │   ├── recurring_transaction_model.dart
│   │   └── user_profile_model.dart
│   ├── providers/                   # State management (Provider pattern)
│   │   ├── auth_provider.dart
│   │   ├── transaction_provider.dart
│   │   ├── category_provider.dart
│   │   ├── budget_provider.dart
│   │   ├── goal_provider.dart
│   │   ├── analytics_provider.dart
│   │   └── user_profile_provider.dart
│   ├── routes/
│   │   └── app_routes.dart         # Navigation routes
│   ├── screens/                     # UI screens
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── initial_balance_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── history_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── budget_screen.dart
│   │   ├── goals_screen.dart
│   │   ├── category_management_screen.dart
│   │   ├── recurring_transactions_screen.dart
│   │   └── profile_screen.dart
│   ├── services/                    # Backend services
│   │   ├── firebase_services.dart   # Firebase Firestore operations
│   │   └── local_db_service.dart
│   ├── widgets/                     # Reusable widgets
│   │   ├── transaction_card.dart
│   │   ├── summary_card.dart
│   │   ├── chart_widgets.dart
│   │   ├── budget_card.dart
│   │   ├── goal_card.dart
│   │   ├── category_chip.dart
│   │   ├── transaction_type_selector.dart
│   │   ├── date_range_picker.dart
│   │   ├── export_dialog.dart
│   │   └── budget_warning_banner.dart
│   └── main.dart                    # App entry point
│
├── assets/                          # App assets
│   ├── fonts/                      # Custom fonts
│   │   ├── Poppins-Bold.ttf
│   │   └── Poppins-Regular.ttf
│   └── images/                      # Images
│       └── onboarding.png
│
├── test/                            # Unit tests
│   └── widget_test.dart
│
├── pubspec.yaml                     # Flutter dependencies
├── README.md                        # Project documentation
└── INSTRUCTIONS.md                  # This file
```

## 🚀 Setup Instructions

### Prerequisites
1. **Flutter SDK** (3.10.4 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio** or **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code: https://code.visualstudio.com/

3. **Firebase Account**
   - Create account at: https://firebase.google.com/
   - Create a new Firebase project

4. **Android SDK** (for building APK)
   - Install via Android Studio SDK Manager
   - Set ANDROID_HOME environment variable

### Step 1: Clone/Download Project
```bash
# If using git
git clone <repository-url>
cd finance_tracker_app

# Or extract the downloaded ZIP file
```

### Step 2: Install Dependencies
```bash
# Navigate to project directory
cd finance_tracker_app

# Get Flutter packages
flutter pub get
```

### Step 3: Firebase Setup

#### 3.1 Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: "Finance Tracker App"
4. Enable Google Analytics (optional)
5. Click "Create project"

#### 3.2 Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method
4. Click "Save"

#### 3.3 Create Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Select **Start in test mode** (for development)
4. Choose a location (closest to your users)
5. Click "Enable"

#### 3.4 Add Android App to Firebase
1. In Firebase Console, click the Android icon
2. Register app:
   - **Package name**: Check `android/app/build.gradle.kts` for `applicationId`
   - **App nickname**: Finance Tracker App
   - **Debug signing certificate**: Optional
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### 3.5 Add iOS App (if needed)
1. In Firebase Console, click the iOS icon
2. Register app with Bundle ID
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### Step 4: Configure Firebase in Code
The Firebase initialization is already set up in `lib/main.dart`:
```dart
await Firebase.initializeApp();
```

### Step 5: Run the App

#### For Development (Debug Mode)
```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d <device-id>
```

#### For Android Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run app
flutter run
```

## 📦 Building APK

### Option 1: Debug APK (For Testing)
```bash
# Build debug APK
flutter build apk --debug

# Output location:
# build/app/outputs/flutter-apk/app-debug.apk
```

### Option 2: Release APK (For Distribution)
```bash
# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Option 3: Split APKs by ABI (Smaller Size)
```bash
# Build split APKs (recommended)
flutter build apk --split-per-abi

# Output locations:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### Option 4: App Bundle (For Play Store)
```bash
# Build App Bundle (for Google Play Store)
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

## 🔐 Signing APK for Release

### Step 1: Generate Keystore
```bash
# Windows
keytool -genkey -v -keystore C:\Users\YourName\finance-tracker-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias finance-tracker

# Mac/Linux
keytool -genkey -v -keystore ~/finance-tracker-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias finance-tracker
```

### Step 2: Create key.properties
Create file: `android/key.properties`
```
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=finance-tracker
storeFile=C:\\Users\\YourName\\finance-tracker-key.jks
```

### Step 3: Configure build.gradle.kts
The signing configuration should be added to `android/app/build.gradle.kts`:
```kotlin
android {
    ...
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## 📱 Installing APK on Device

### Method 1: Direct Install
```bash
# Install via ADB
flutter install

# Or manually
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: Transfer and Install
1. Copy APK to your Android device
2. Enable "Install from Unknown Sources" in device settings
3. Open APK file on device
4. Tap "Install"

## 🗄️ Database Schema

The Firestore database structure is automatically created when users interact with the app:

```
users/
  └── {userId}/
      ├── transactions/
      │   └── {transactionId}/
      │       ├── id: string
      │       ├── title: string
      │       ├── amount: number
      │       ├── type: string (income/expense/transfer)
      │       ├── category: string
      │       ├── date: timestamp
      │       ├── description: string (optional)
      │       ├── userId: string
      │       └── createdAt: timestamp
      │
      ├── categories/
      │   └── {categoryId}/
      │       ├── id: string
      │       ├── name: string
      │       ├── icon: string
      │       ├── color: number
      │       ├── type: string (income/expense)
      │       ├── isDefault: boolean
      │       └── userId: string
      │
      ├── budgets/
      │   └── {budgetId}/
      │       ├── id: string
      │       ├── category: string
      │       ├── amount: number
      │       ├── period: string (weekly/monthly)
      │       ├── startDate: timestamp
      │       ├── endDate: timestamp (optional)
      │       └── userId: string
      │
      ├── goals/
      │   └── {goalId}/
      │       ├── id: string
      │       ├── title: string
      │       ├── targetAmount: number
      │       ├── currentAmount: number
      │       ├── deadline: timestamp
      │       ├── userId: string
      │       └── createdAt: timestamp
      │
      ├── recurringTransactions/
      │   └── {recurringId}/
      │       ├── id: string
      │       ├── title: string
      │       ├── amount: number
      │       ├── type: string
      │       ├── category: string
      │       ├── frequency: string (daily/weekly/monthly)
      │       ├── startDate: timestamp
      │       ├── endDate: timestamp (optional)
      │       ├── isActive: boolean
      │       ├── userId: string
      │       └── createdAt: timestamp
      │
      └── (user profile data)
          ├── userId: string
          ├── initialBalance: number
          ├── createdAt: timestamp
          └── updatedAt: timestamp
```

## 🎯 Features

### Core Features
- ✅ User Authentication (Email/Password)
- ✅ Transaction Management (Income/Expense/Transfer)
- ✅ Category Management
- ✅ Budget Tracking
- ✅ Financial Goals
- ✅ Analytics & Charts
- ✅ Data Export (CSV/JSON)
- ✅ Initial Balance Setup
- ✅ Budget Warnings
- ✅ Real-time Data Sync

### Transaction Types
- **Income**: Adds to balance
- **Expense**: Subtracts from balance
- **Transfer**: Neutral (doesn't affect balance)

## 🐛 Troubleshooting

### Common Issues

#### 1. Firebase Not Initialized
**Error**: `FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created`
**Solution**: 
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean` then `flutter pub get`

#### 2. Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

#### 3. Gradle Sync Failed
```bash
# Update Gradle
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 4. APK Installation Failed
- Enable "Install from Unknown Sources"
- Check device storage space
- Verify APK is not corrupted

#### 5. Firebase Authentication Not Working
- Verify Email/Password is enabled in Firebase Console
- Check `google-services.json` is correct
- Ensure internet connection

## 📝 Environment Variables

No environment variables required. All configuration is in:
- `android/app/google-services.json` (Firebase Android config)
- `ios/Runner/GoogleService-Info.plist` (Firebase iOS config)

## 🔄 Updating Dependencies

```bash
# Check for updates
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Update to latest versions
flutter pub upgrade --major-versions
```

## 📊 App Information

- **Package Name**: Check `android/app/build.gradle.kts` for `applicationId`
- **Version**: Check `pubspec.yaml` for `version`
- **Min SDK**: Android 21 (Android 5.0)
- **Target SDK**: Latest Android version

## 🚀 Deployment Checklist

Before releasing:
- [ ] Test on multiple devices
- [ ] Verify Firebase rules are secure
- [ ] Update app version in `pubspec.yaml`
- [ ] Generate signed APK
- [ ] Test APK installation
- [ ] Verify all features work
- [ ] Check analytics are working
- [ ] Test offline functionality
- [ ] Review security rules in Firestore

## 📞 Support

For issues or questions:
1. Check Firebase Console for errors
2. Review Flutter logs: `flutter logs`
3. Check device logs: `adb logcat`

## 📄 License

This project is for educational/personal use.

---

**Last Updated**: 2024
**Flutter Version**: 3.10.4+
**Firebase Version**: Latest

