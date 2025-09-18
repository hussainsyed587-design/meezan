# 🔑 Production API Keys Setup Guide

## Required API Keys for Meezan App

### 1. Firebase Cloud Messaging (FCM) - for Push Notifications
**Steps to setup FCM:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add Android app with package name: `com.meezan.prayer_quran`
4. Download `google-services.json` → place in `android/app/`
5. Add iOS app with bundle ID
6. Download `GoogleService-Info.plist` → place in `ios/Runner/`

**Required files:**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 3. Environment Configuration

Create environment files for different build configurations:

**File: `.env.development`**
```
ENVIRONMENT=development
```

**File: `.env.production`**
```
ENVIRONMENT=production
```

### 4. Security Best Practices

1. **Never commit API keys to version control**
2. **Use different keys for development and production**
3. **Restrict API keys to specific bundle IDs**
4. **Monitor API usage and set quotas**
5. **Regenerate keys if compromised**

## Current Status:
- ✅ App structure ready for API integration
- ✅ Notification service implemented
- ✅ Google Maps integration code ready
- ⚠️ Need to add actual API keys
- ⚠️ Need to configure Firebase project

## Next Steps:
1. Set up Firebase project
2. Add configuration files
3. Test with real API keys
4. Configure app signing for production

## Environment Variables in Code:
The app is already set up to use environment variables. Once you add the API keys, they will be automatically integrated into:
- Push notification delivery