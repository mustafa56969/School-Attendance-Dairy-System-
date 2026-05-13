# 🎯 IMMEDIATE ACTION REQUIRED - Update Firebase SHA Keys

## ✅ What I've Fixed

1. ✅ Updated `firebase_options.dart` to use the correct Firebase project (`school-7b599`)
2. ✅ Added missing iOS configuration to prevent compilation errors
3. ✅ Verified your release keystore and extracted correct SHA keys

## ⚠️ CRITICAL: You MUST Do This NOW

### Step 1: Update SHA Keys in Firebase Console

Go to Firebase Console and update your SHA keys:

**Firebase Console Link:** https://console.firebase.google.com/project/school-7b599/settings/general

1. Click on **Project Settings** (gear icon)
2. Scroll to **Your apps** → Find Android app `com.dairy`
3. **ADD these correct SHA keys:**

```
SHA-1:
31:8A:15:E9:78:80:89:D1:CA:1A:E5:C4:A7:94:8C:81:26:56:43:4F

SHA-256:
54:8B:2F:C5:46:B9:C7:B3:D8:BB:33:C0:34:8D:D7:8E:51:88:8F:43:83:36:2B:EA:A5:A9:94:27:7C:15:42:A4
```

4. **REMOVE these WRONG SHA keys:**
```
❌ SHA-1: 71:e0:75:53:7e:fe:df:a4:5c:f6:40:1e:73:37:24:76:02:55:05:2d
❌ SHA-256: 38:29:7a:a9:6b:53:80:cf:f9:2f:9e:7b:1a:ca:77:72:ea:1e:26:24:da:fb:e1:03:eb:ba:6f:e2:98:5b:ab:ea
```

### Step 2: Also Add Debug SHA Keys (for testing)

While you're there, also add these debug SHA keys so `flutter run` works:

```
Debug SHA-1:
01:DE:60:EE:D4:7C:4B:5D:09:99:DD:E0:24:7D:1D:AC:1B:4D:02:AB

Debug SHA-256:
04:55:56:5D:1F:72:4E:1C:E8:30:6F:63:19:3B:87:AB:1A:24:2C:78:D5:57:BE:05:CC:77:CC:50:D9:7F:03:28
```

### Step 3: Download Updated google-services.json

After adding the SHA keys:
1. Click **Download google-services.json** button
2. Replace the file at: `android/app/google-services.json`

### Step 4: Verify Google Sign-In is Enabled

1. Go to **Authentication** → **Sign-in method**
2. Make sure **Google** is enabled
3. Add your support email if required

## 🚀 Build Release APK

After completing the above steps, run these commands:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Test the Release APK

Install and test:
```bash
flutter install --release
```

Or manually install the APK on your device.

## 💡 ANSWER TO YOUR QUESTIONS

### Q: "Are these SHA keys correct?"
**NO!** ❌ The SHA keys you have in Firebase are WRONG. I've provided the correct ones above.

### Q: "Can I change SHA keys in Firebase after building the APK?"
**YES!** ✅ You can update SHA keys in Firebase Console without rebuilding the APK!

**How it works:**
- SHA keys are validated on Google's servers, not in the APK
- When you update SHA keys in Firebase, the changes take effect immediately
- Already installed APKs will start working without reinstalling
- However, if you download a NEW `google-services.json`, you MUST rebuild

**Important:**
- Updating SHA keys only → No rebuild needed ✅
- Downloading new `google-services.json` → Rebuild required ❌

### Q: "Will the previous APK work after changing SHA keys?"
**YES!** ✅ The previously distributed APK will work once you add the correct SHA keys to Firebase.

## 🔐 Your Keystore Information

**Location:** `D:\Gravity no front - Copy\school_diary_app\android\app\key.jks`
**Alias:** key
**Store Password:** dairy123
**Key Password:** dairy123
**Valid Until:** April 13, 2053

⚠️ **BACKUP THIS FILE!** If you lose it, you can't update your app on Play Store!

## 📋 Quick Checklist

- [ ] Add correct release SHA-1 to Firebase
- [ ] Add correct release SHA-256 to Firebase
- [ ] Add debug SHA-1 to Firebase (for testing)
- [ ] Add debug SHA-256 to Firebase (for testing)
- [ ] Remove wrong SHA keys from Firebase
- [ ] Download new google-services.json
- [ ] Replace android/app/google-services.json
- [ ] Verify Google Sign-In is enabled in Firebase Auth
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter build apk --release`
- [ ] Test on physical device

## 🎉 After This

Once you complete these steps:
1. Google Sign-In will work in release builds
2. You can distribute your APK
3. Users can sign in with Google successfully

---

**Need help?** Check the detailed guide in `RELEASE_BUILD_FIX.md`
