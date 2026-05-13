# School Diary App

A comprehensive Flutter-based mobile application for managing school diaries, attendance, announcements, and student-teacher communication.

## Features

### Admin Dashboard
- Class and student management
- Teacher assignment and management
- View all diaries and announcements
- Attendance analytics and reporting
- Class promotion
- Student message viewing

### Teacher Features
- Create and manage daily diaries
- Mark student attendance
- View class analytics and attendance reports
- Export attendance to Excel
- Manage assigned subjects

### Student Features
- View daily diaries and homework
- Track attendance records
- View announcements and notices
- Personal notes management
- Subject performance tracking
- Profile management
- Send messages to admin

### Additional Features
- Firebase authentication (Google Sign-In & Email/Password)
- Push notifications
- Offline caching support
- Beautiful UI with playful theme
- Dark/Light theme support

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Frontend framework |
| Firebase | Backend (Firestore, Auth, Cloud Messaging) |
| Provider | State management |
| GoRouter | Navigation |
| fl_chart | Charts and analytics |
| flutter_animate | Animations |

## Prerequisites

- Flutter SDK 3.5.0+
- Dart SDK 3.5.0+
- Firebase project
- Android SDK / Xcode

## Setup

```bash
# Clone the repository
git clone <repository-url>
cd school_diary_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication**, **Cloud Firestore**, and **Firebase Cloud Messaging**
4. Download `google-services.json` and place it in `android/app/`
5. Copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart` and fill in your credentials

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/           # Data models
├── screens/          # UI screens
│   ├── admin/
│   ├── teacher/
│   ├── student/
│   └── auth/
├── services/         # Business logic
├── widgets/          # Reusable widgets
└── theme/           # App theming
```

## Building

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## License

Private - All rights reserved