# School Diary App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.5.0+-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge">
</p>

> A modern, feature-rich Flutter application for seamless school management. Track **diaries**, manage **homework**, send **announcements**, and monitor **attendance** - all in one beautiful dashboard.

## What It Does

This comprehensive school management system connects admins, teachers, and students through an intuitive mobile interface. Teachers create daily diaries with homework assignments, mark attendance, and publish announcements. Students view their assignments, track attendance records, and stay updated with school notices. Admins manage all classes, teachers, and students from a powerful dashboard with analytics and reporting capabilities.

### Dashboard Highlights

- **Admin Panel** - Full control over classes, teachers, students, and system-wide analytics
- **Teacher Dashboard** - Create diaries, manage attendance, view analytics, export reports
- **Student Dashboard** - View homework, track attendance, read announcements, manage notes

### Key Features

| Feature | Description |
|---------|-------------|
| 📓 **Diary Management** | Create, edit, and publish daily school diaries with homework |
| ✅ **Attendance Tracking** | Mark and track student attendance with analytics |
| 📢 **Announcements** | Broadcast important notices to students and staff |
| 📊 **Analytics Dashboard** | Visual reports on attendance, performance, and trends |
| 📝 **Notes System** | Students can create and manage personal notes |
| 🔔 **Push Notifications** | Real-time alerts for new announcements |
| 🎨 **Beautiful UI** | Modern, playful design with dark/light theme support |
| 🔐 **Secure Auth** | Firebase authentication with Google & Email login |

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