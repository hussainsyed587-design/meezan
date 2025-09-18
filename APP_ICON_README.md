README: App Icon Creation Guide

## 📱 App Icon Creation Instructions

The Meezan app requires custom app icons to be created. Here's how to generate them:

### Option 1: Online Icon Generator (Recommended)
1. Visit: https://appicon.co/ or https://easyappicon.com/
2. Upload a 1024x1024px PNG image with:
   - Islamic mosque silhouette
   - Green gradient background (#2D5A3D to #40916C)
   - Crescent moon accent in gold (#FFB300)
3. Generate all Android sizes
4. Download and replace files in:
   - `android/app/src/main/res/mipmap-*/ic_launcher.png`

### Option 2: Design Tool Creation
1. Create 1024x1024px canvas in Figma/Adobe Illustrator
2. Design mosque icon with specifications from BRANDING_GUIDE.md
3. Export in required sizes:
   - mdpi: 48x48px → `mipmap-mdpi/ic_launcher.png`
   - hdpi: 72x72px → `mipmap-hdpi/ic_launcher.png`
   - xhdpi: 96x96px → `mipmap-xhdpi/ic_launcher.png`
   - xxhdpi: 144x144px → `mipmap-xxhdpi/ic_launcher.png`
   - xxxhdpi: 192x192px → `mipmap-xxxhdpi/ic_launcher.png`

### Option 3: Flutter Launcher Icons Package
1. Add to pubspec.yaml:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1
   
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icons/app_icon.png"
     min_sdk_android: 21
   ```
2. Place 1024x1024px icon at `assets/icons/app_icon.png`
3. Run: `flutter pub run flutter_launcher_icons:main`

### Current Status
- ✅ App icon structure exists
- ✅ Notification icons created
- ⚠️  Need custom 1024px master icon design
- ⚠️  Need to replace default Flutter icons

### Icon Design Specifications
See BRANDING_GUIDE.md for complete design specifications including:
- Color palette
- Typography
- Visual elements
- Brand guidelines

The default Flutter launcher icons are currently in place. Replace them with custom Meezan-branded icons using one of the methods above.