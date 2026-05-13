# 🔧 Release Build Google Sign-In Fix Guide

## ⚠️ CRITICAL ISSUES FOUND

### Issue 1: Wrong SHA Keys in Firebase Console
Your Firebase Console has **INCORRECT** SHA keys that don't match your release keystore!

### Issue 2: Multiple Firebase Projects
You have TWO different Firebase projects configured:
- `firebase_options.dart` → **dairy-56f99**
- `google-services.json` → **school-7b599**

---

## 📊 Your Actual Release Keystore SHA Keys

These are the **CORRECT** SHA keys from your `key.jks` file:

```
SHA-1:   31:8A:15:E9:78:80:89:D1:CA:1A:E5:C4:A7:94:8C:81:26:56:43:4F
SHA-256: 54:8B:2F:C5:46:B9:C7:B3:D8:BB:33:C0:34:8D:D7:8E:51:88:8F:43:83:36:2B:EA:A5:A9:94:27:7C:15:42:A4
```

**Keystore Location:** `D:\Gravity no front - Copy\school_diary_app\android\app\key.jks`
**Alias:** key
**Valid Until:** Sunday, April 13, 2053

---

## 🔨 STEP-BY-STEP FIX

### Step 1: Decide Which Firebase Project to Use

You need to choose ONE Firebase project. Based on your `google-services.json`, I recommend using **school-7b599**.

### Step 2: Update SHA Keys in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **school-7b599**
3. Go to **Project Settings** (gear icon) → **General**
4. Scroll down to **Your apps** section
5. Find your Android app (`com.dairy`)
6. Click **Add fingerprint** and add these SHA keys:

   **SHA-1:**
   ```
   31:8A:15:E9:78:80:89:D1:CA:1A:E5:C4:A7:94:8C:81:26:56:43:4F
   ```

   **SHA-256:**
   ```
   54:8B:2F:C5:46:B9:C7:B3:D8:BB:33:C0:34:8D:D7:8E:51:88:8F:43:83:36:2B:EA:A5:A9:94:27:7C:15:42:A4
   ```

7. **REMOVE** the old incorrect SHA keys:
   - ❌ SHA-1: `71:e0:75:53:7e:fe:df:a4:5c:f6:40:1e:73:37:24:76:02:55:05:2d`
   - ❌ SHA-256: `38:29:7a:a9:6b:53:80:cf:f9:2f:9e:7b:1a:ca:77:72:ea:1e:26:24:da:fb:e1:03:eb:ba:6f:e2:98:5b:ab:ea`

### Step 3: Download Updated google-services.json

1. In Firebase Console, after adding the correct SHA keys
2. Click **Download google-services.json**
3. Replace the file at: `android/app/google-services.json`

### Step 4: Update firebase_options.dart

Update the Firebase configuration to match the `school-7b599` project (this will be done automatically by the assistant).

### Step 5: Enable Google Sign-In in Firebase

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Google** sign-in provider
3. Add your support email

### Step 6: Configure OAuth Consent Screen (if not done)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project **school-7b599**
3. Go to **APIs & Services** → **OAuth consent screen**
4. Configure the consent screen with your app details

### Step 7: Build Release APK

After completing all steps above:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 💡 ANSWER TO YOUR QUESTION

### "If I compile the APK in release mode and Google login doesn't work due to SHA keys, can I change the SHA keys in Firebase? Will the app start working without recompiling?"

**YES! ✅** You can update SHA keys in Firebase Console without recompiling the app!

**How it works:**
- When you add/update SHA keys in Firebase Console and download the new `google-services.json`
- The changes take effect on **Google's servers** immediately
- **Already installed APKs will start working** without recompilation
- The APK's signature doesn't change - only Firebase's server-side validation is updated

**Important Notes:**
1. You don't need to rebuild the APK if you only update SHA keys in Firebase
2. However, if you download a new `google-services.json`, you need to rebuild
3. The APK you already distributed will work once Firebase recognizes the correct SHA keys

**Best Practice:**
- Always verify SHA keys BEFORE distributing the APK
- Keep a backup of your keystore file (`key.jks`) - if you lose it, you can't update your app!

---

## 🔍 Additional Checks

### Verify Package Name Matches
Ensure package name is consistent everywhere:
- ✅ `build.gradle.kts`: `com.dairy`
- ✅ `google-services.json`: `com.dairy`
- ✅ Firebase Console: `com.dairy`

### Verify Debug SHA Keys (for testing)
Your debug SHA keys (for `flutter run`):
```
SHA-1:   01:DE:60:EE:D4:7C:4B:5D:09:99:DD:E0:24:7D:1D:AC:1B:4D:02:AB
SHA-256: 04:55:56:5D:1F:72:4E:1C:E8:30:6F:63:19:3B:87:AB:1A:24:2C:78:D5:57:BE:05:CC:77:CC:50:D9:7F:03:28
```

Make sure these are also added to Firebase for debug builds to work!

---

## 🚀 Quick Command Reference

### Get SHA keys from keystore:
```bash
keytool -list -v -keystore android/app/key.jks -alias key -storepass dairy123 -keypass dairy123
```

### Get signing report:
```bash
cd android
./gradlew signingReport
```

### Clean build:
```bash
flutter clean
flutter pub get
```

### Build release APK:
```bash
flutter build apk --release
```

### Install release APK:
```bash
flutter install --release
```

---

## ⚠️ SECURITY WARNING

Your keystore passwords are visible in `build.gradle.kts`:
- Store Password: `dairy123`
- Key Password: `dairy123`

**Recommendations:**
1. Never commit keystore files to Git
2. Add to `.gitignore`: `*.jks`, `*.keystore`
3. Keep backup of `key.jks` in a secure location
4. Consider using stronger passwords for production apps

---

## 📝 Checklist Before Release

- [ ] Correct SHA-1 added to Firebase Console
- [ ] Correct SHA-256 added to Firebase Console
- [ ] Old incorrect SHA keys removed from Firebase
- [ ] Downloaded new `google-services.json`
- [ ] Replaced `android/app/google-services.json`
- [ ] Updated `firebase_options.dart` with correct project
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] OAuth consent screen configured
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build release APK: `flutter build apk --release`
- [ ] Test Google Sign-In on physical device with release APK
- [ ] Keystore backed up securely

---

**Good luck with your release! 🎉**
