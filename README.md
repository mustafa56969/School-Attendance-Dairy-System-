# School Diary App

[![GitHub Repo](https://img.shields.io/badge/GitHub-Mustafa56969/School--Attendance--Dairy--System--blue?style=flat&logo=github)](https://github.com/mustafa56969/School-Attendance-Dairy-System-)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.5.0+-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge">
</p>

> A modern, feature-rich Flutter application for seamless school management. Track **diaries**, manage **homework**, send **announcements**, and monitor **attendance** - all in one beautiful dashboard!

## Screenshots

### Authentication
<div align="center">

| Login Screen | Registration |
|:---:|:---:|
| ![School (1)](screenshots/School%20(1).jpg) | ![School (2)](screenshots/School%20(2).jpg) |

</div>

### Admin Dashboard
<div align="center">

| Main Dashboard | Class Management | User Management |
|:---:|:---:|:---:|
| ![School (3)](screenshots/School%20(3).jpg) | ![School (4)](screenshots/School%20(4).jpg) | ![School (5)](screenshots/School%20(5).jpg) |

| Analytics | Reports |
|:---:|:---:|
| ![School (6)](screenshots/School%20(6).jpg) | ![School (7)](screenshots/School%20(7).jpg) |

</div>

### Teacher Dashboard
<div align="center">

| Teacher Home | Create Diary | Attendance Marking |
|:---:|:---:|:---:|
| ![School (8)](screenshots/School%20(8).jpg) | ![School (9)](screenshots/School%20(9).jpg) | ![School (10)](screenshots/School%20(10).jpg) |

| Homework Management | Class Analytics |
|:---:|:---:|
| ![School (11)](screenshots/School%20(11).jpg) | ![School (12)](screenshots/School%20(12).jpg) |

</div>

### Student Dashboard
<div align="center">

| Student Home | View Diaries | Homework List |
|:---:|:---:|:---:|
| ![School (13)](screenshots/School%20(13).jpg) | ![School (14)](screenshots/School%20(14).jpg) | ![School (15)](screenshots/School%20(15).jpg) |

| Attendance View | Announcements | Profile |
|:---:|:---:|:---:|
| ![School (16)](screenshots/School%20(16).jpg) | ![School (17)](screenshots/School%20(17).jpg) | ![School (18)](screenshots/School%20(18).jpg) |

</div>

## What It Does

This comprehensive school management system connects admins, teachers, and students through an intuitive mobile interface. Teachers create daily diaries with homework assignments, mark attendance, and track student progress. Students stay informed with announcements, track their attendance, and manage their homework efficiently.

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
