# GetFit

A cross-platform Flutter fitness application made for a university Project.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Mock Accounts](#mock-accounts)
- [Project Structure](#project-structure)
- [Use Cases Implemented](#use-cases-implemented)
- [Known Limitations](#known-limitations)

---

## Features

| List | - |
|---|---|
| **Authentication** | Log in with mock accounts or register through a 6-step onboarding flow |
| **Fitness Profile** | BMI & TDEE auto-calculation, goal setting (lose / maintain / gain), activity level, body-fat %, location |
| **Dashboard** | Quick-access cards for Get a Coach, Meal Recommendations and Find a Workout Place |
| **Workout Logging** | Build a session from a catalogue of strength and cardio exercises; review a summary before saving |
| **Progress Tracking** | Log weight & body-fat measurements over time; daily/weekly trend cards; tracking streak |
| **Meal Recommendations** | Personalised meal suggestions ranked by remaining daily macros, city-aware (Greek, UK, German, French, Italian, Spanish menus and more) |
| **Barcode Scanner** | Scan any food product barcode to instantly view and log its nutritional values |
| **Food Search** | Search a built-in mock food database and log servings manually |
| **Log Store Meal** | Browse local restaurant menus (McDonald's, KFC, Goody's, Everest, Subway, Nando's and more) and log a meal in one tap |
| **Daily Diary** | Every logged item updates remaining calories, protein, carbs and fat in real time |
| **Google Fit Sync** | Connect to Health Connect / HealthKit for live steps, active minutes, calories burned and heart rate; falls back to demo data on unsupported devices |
| **Weekly Goal Planner** | System-suggested or custom weekly targets for steps, active minutes, calorie burn and workout sessions |
| **Workout Places** | Find nearby gyms, CrossFit boxes and outdoor tracks that are open right now, based on the user's profile city |
| **Coach System** | Premium users can browse coaches, request a personalised plan, and receive updated plans in-app |
| **Shopping List** | Ingredients from saved meal recommendations are automatically added to a checkable shopping list |

---

## Tech Stack

- **Framework:** Flutter 3 / Dart 3
- **State management:** Provider (`ChangeNotifier`)
- **Barcode scanning:** `mobile_scanner ^6.0.0`
- **Health data:** `health ^12.0.0` (Google Health Connect / Apple HealthKit)
- **URL launching:** `url_launcher ^6.3.1`
- **Data:** 100 % local mock data — no backend or network calls required

---

## Prerequisites

| Tool | Minimum version | Notes |
|---|---|---|
| Flutter SDK | **3.x** | Includes Dart 3 |
| Dart SDK | **^3.11.5** | Bundled with Flutter |
| Android Studio / Xcode | Latest stable | For emulator / simulator |
| A physical device or emulator | Android 6+ or iOS 13+ | Barcode scanning and Health require a real device for full functionality |

> **Check your Flutter installation:**
> ```bash
> flutter doctor
> ```
> All items should show a green tick (or an acceptable warning for unused platforms).

---

## Installation

### 1 · Clone the repository

```bash
git clone https://github.com/Hypereides/getfit.git
cd getfit/mobile/getfit
```

### 2 · Install dependencies

```bash
flutter pub get
```

### 3 · (Android only) Health Connect permissions

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` tag if not already present:

```xml
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_DISTANCE"/>

<queries>
    <package android:name="com.google.android.apps.healthdata"/>
</queries>
```

### 4 · (iOS only) HealthKit permissions

Add the following keys to `ios/Runner/Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>GetFit reads your activity data to track steps and calories.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>GetFit does not write health data.</string>
```

And enable the **HealthKit** capability in Xcode → **Signing & Capabilities**.

### 5 · Camera permission (barcode scanner)

**Android** — already declared by the `mobile_scanner` package.

**iOS** — add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>GetFit needs camera access to scan food barcodes.</string>
```

---

## Running the App

```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run

# Run in release mode (faster, no debug overlay)
flutter run --release

# Build a debug APK
flutter build apk --debug

# Build a release APK
flutter build apk --release
```

---

## Mock Accounts

The app ships with a pre-seeded `assets/mock/users.json` file. Use any of the credentials below to log in immediately — no registration required.

| Role | Email | Password |
|---|---|---|
| Regular user | `user@getfit.com` | `password123` |
| Regular user (premium) | `premium@getfit.com` | `password123` |
| Coach | `coach@getfit.com` | `password123` |

> You can also tap **"Create a new account"** on the login screen and go through the full 6-step onboarding flow to register a custom profile.

---

## Project Structure

```
lib/
├── app/                        # App entry point & theme
├── core/
│   ├── data/                   # Country / city data
│   ├── state/                  # SessionController (global auth state)
│   └── widgets/                # Shared UI components
└── features/
    ├── auth/                   # Login, registration, AppUser domain
    ├── barcode/                # Barcode scanner, food database, food log
    ├── coach_plans/            # Coach plan creation & client management
    ├── coach_selection/        # Browse & request a coach
    ├── dashboard/              # Dashboard screen
    ├── health_sync/            # Google Fit / HealthKit integration
    ├── home/                   # HomeShell navigation wrapper
    ├── meals/                  # Meal recommendations, shopping list, My Meals
    ├── onboarding/             # 6-step registration flow
    ├── plans/                  # My Plan placeholder screen
    ├── profile/                # Profile screen, premium toggle
    ├── progress/               # Weight tracking, trend analysis
    ├── store_meals/            # Log Store Meal — restaurant menus
    ├── workout_places/         # Nearby gym finder
    └── workouts/               # Workout session logging
```

---

## Use Cases Implemented
It should be noted that some of these use-case

| # | Use Case | Entry Point |
|---|---|---|
| UC-01 | Register & Onboarding | Login screen → "Create a new account" |
| UC-02 | Log a Workout Session | My Plan tab |
| UC-03 | Track Body Measurements | Progress tab |
| UC-04 | Set Weekly Activity Goal | Google Fit screen → Create Weekly Plan |
| UC-05 | Scan Barcode & Log Food | Meals tab → Scan a Barcode |
| UC-06 | Get Meal Recommendations | Meals tab → Meal Recommendations |
| UC-07 | Log Store Meal | Meals tab → Log Store Meal |
| UC-08 | Find a Workout Place | Places tab / Dashboard card |
| UC-09 | Request a Coach (Premium) | Dashboard → Get a Coach |
| UC-10 | Coach Creates / Updates Plan | Coach role → Clients tab |

---

## Known Limitations

- **No backend.** All data is held in memory and resets when the app is closed. You can always use rest api or such to implement it properly. Might do that in the future.
- **Barcode database is limited.** Only 15 products are included in `MockFoodDatabase`. Unrecognised barcodes show a "Product Not Found" dialog, will add a "create" product" shortly.
- **Health data on emulators.** The Google Fit / HealthKit integration falls back to demo data (`7 842 steps, 54 active min`) on emulators and devices without Health Connect installed.
- **Coach plans are in-memory.** Plans disappear on app restart; they would need persistent storage in a production build.
- **Store menus are mock data.** Restaurant nutritional values are approximations for demonstration purposes.

---

## License

This project was developed for academic purposes. All third-party brand names and logos referenced in mock data belong to their respective owners.
Statistics like expenditure and such have all been "gathered" from sources like WHO and online webpages, I can not guarantee their accuracy.