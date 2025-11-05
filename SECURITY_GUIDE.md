# Security Configuration Guide

## ⚠️ IMPORTANT: Before pushing to GitHub

This project contains sensitive keys that **MUST** be secured before making the repository public.

### 🔴 Critical Security Issues Found:

1. **Google Maps API Key** - Exposed in `android/app/src/main/AndroidManifest.xml`
2. **Firebase Configuration** - `android/app/google-services.json` contains API keys and project IDs

### ✅ Steps to Secure Your Keys:

#### 1. **Google Maps API Key**
   - ✅ Removed hardcoded key from `AndroidManifest.xml` (now uses `${GOOGLE_MAPS_API_KEY}`)
   - **Action Required:** Configure Gradle to pass the key from environment variable
   - Implement key restrictions in Google Cloud Console:
     - Restrict by Android app package name: `com.example.travel_guide_app`
     - Restrict by API (Maps SDK for Android only)
     - Set usage quotas

#### 2. **Firebase Configuration**
   - ✅ The `google-services.json` file is now in `.gitignore`
   - **Action Required:** Each developer should download their own copy from Firebase Console
   - Never commit this file to version control

#### 3. **Backend API URL**
   - Currently exposed in `lib/core/constants/api_endpoints.dart`
   - This is acceptable if it's a public API
   - Consider adding rate limiting if not already implemented

### 🔐 How to Build with API Key:

**Option 1: Using local.properties (Recommended for local development)**

Create `android/local.properties`:
```properties
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

**Option 2: Using environment variable**
```bash
export GOOGLE_MAPS_API_KEY=your_actual_api_key_here
flutter build apk --release
```

### 📝 Next Steps:

1. ✅ Updated `.gitignore` to exclude sensitive files
2. ✅ Removed hardcoded API key from AndroidManifest.xml
3. ⚠️ **Configure Gradle** to read from `local.properties` or environment variable
4. ⚠️ **Remove google-services.json** from git history if already committed:
   ```bash
   git rm --cached android/app/google-services.json
   ```
5. ⚠️ **Revoke and regenerate** any exposed API keys
6. ⚠️ **Set up API key restrictions** in Google Cloud Console

### 🚨 If Keys Are Already Exposed:

1. **Immediately revoke** the exposed keys in Google Cloud Console
2. **Generate new keys** with proper restrictions
3. **Review access logs** for any unauthorized usage
4. **Consider using Firebase App Check** for additional security

### 📋 Checklist Before Pushing:

- [ ] API keys removed from source code
- [ ] `google-services.json` in `.gitignore`
- [ ] `local.properties` added to `.gitignore` (if using it)
- [ ] Old keys revoked and regenerated
- [ ] API key restrictions configured
- [ ] Team members have their own `google-services.json` files

