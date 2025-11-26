# Google Sign-In Setup Guide

## Error Code 10 Fix

If you're encountering `PlatformException(s, 10)` error, follow these steps:

### 1. Get SHA-1 Fingerprint

**Debug Keystore (for development):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Your current debug SHA-1:**
```
7E:02:2C:91:8C:DD:F7:C0:5B:7F:5B:14:9F:98:63:74:DA:BA:A9:87
```

**Release Keystore (for production):**
```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

### 2. Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Click on your Android app (or add one if it doesn't exist)
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### 3. Add SHA-1 to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Find your **OAuth 2.0 Client ID** for Android
5. Click to edit it
6. Add your SHA-1 fingerprint in the **SHA-1 certificate fingerprint** field
7. Click **Save**

### 4. Configure OAuth Consent Screen

1. In Google Cloud Console, go to **APIs & Services** → **OAuth consent screen**
2. Ensure the following are configured:
   - App name
   - User support email
   - Developer contact information
   - Scopes (email, drive.file should be added)
3. Add test users if your app is in testing mode

### 5. Verify Package Name

Ensure your package name matches in all places:
- **App package name:** `com.gt.spare_management`
- **Firebase Android app:** Should match exactly
- **OAuth Client ID:** Should match exactly

### 6. Download google-services.json (if using Firebase)

If you're using Firebase, download `google-services.json` and place it in:
```
android/app/google-services.json
```

### 7. Rebuild the App

After making changes:
```bash
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

- **Still getting error 10?** Wait a few minutes after adding SHA-1 - it can take time to propagate
- **Error persists?** Double-check that the package name matches exactly in all configurations
- **Release build issues?** Make sure you've added the release keystore SHA-1, not just debug

## Additional Resources

- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android/start-integrating)
- [Firebase Authentication Setup](https://firebase.google.com/docs/auth/android/google-signin)

