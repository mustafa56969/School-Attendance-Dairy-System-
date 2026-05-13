# School Diary App

A comprehensive Flutter-based mobile application for managing school diaries, attendance, announcements, and student-teacher communication.

## Features

### Admin Dashboard
- Class and student management
- Teacher assignment and management
- View all diaries and announcements
- Attendance analytics and reporting
- Class promotion (promote students to next class)
- Student message viewing

### Teacher Features
- Create and manage daily diaries
- Mark student attendance
- View class analytics and attendance reports
- Export attendance to Excel format
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
- Push notifications for announcements
- Offline caching support
- Beautiful UI with playful theme
- Dark/Light theme support

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth, Cloud Messaging)
- **State Management**: Provider
- **Routing**: GoRouter
- **Charts**: fl_chart
- **Animations**: flutter_animate, Lottie

## Prerequisites

- Flutter SDK (3.5.0 or higher)
- Dart SDK (3.5.0 or higher)
- Firebase project
- Android SDK (for Android builds)
- Xcode (for iOS builds)

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd school_diary_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase

#### Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication** (Google & Email/Password)
4. Enable **Cloud Firestore**
5. Enable **Firebase Cloud Messaging**

#### Download Configuration Files

**For Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in: `android/app/google-services.json`

**For iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in: `ios/Runner/GoogleService-Info.plist`

**For Web:**
1. Download `firebase-config.js` or configure in `firebase_options.dart`

#### Update Firebase Options
Edit `lib/firebase_options.dart` with your Firebase project credentials:
- API Key
- Auth Domain
- Project ID
- Storage Bucket
- Messaging Sender ID
- App ID

### 4. Configure Android (Optional - for release builds)

Create `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../upload-keystore.jks
```

Create `android/local.properties`:
```properties
sdk.dir=C:\\path\\to\\android\\sdk
flutter.sdk=C:\\path\\to\\flutter
```

### 5. Run the App
```bash
# Debug build
flutter run

# Release build
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
├── screens/                  # UI screens
│   ├── admin/              # Admin screens
│   ├── teacher/           # Teacher screens
│   ├── student/           # Student screens
│   └── auth/              # Authentication screens
├── services/                # Business logic
├── widgets/                 # Reusable widgets
└── theme/                  # App theming
```

## Firebase Firestore Collections

- `users` - User profiles
- `diaries` - Daily diary entries
- `attendance` - Attendance records
- `announcements` - School announcements
- `subjects` - Subject definitions
- `classes` - Class information
- `notes` - Student notes

## Security Rules

Configure Firestore security rules in `firestore.rules` to control data access based on user roles (admin, teacher, student).

## Building for Release

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## Environment Variables

Create `.env` file for local development:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

## License

This project is private. All rights reserved.

## Support

For issues or questions, please contact the development team.