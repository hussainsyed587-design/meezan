# 🕌 Meezan App Icon Setup

## Quick Setup Instructions:

### Option 1: Use the Icon Generator (Recommended)
1. **Open the HTML generator**: Open `meezan_icon_generator.html` in your web browser
2. **Generate icons**: Click "Generate PNG Icons" to see all sizes
3. **Download**: Click "Download 1024px" to get the main icon
4. **Save**: Save as `app_icon.png` in the `assets/icons/` folder
5. **Generate**: Run the commands below

### Option 2: Online Icon Generator
1. Visit: https://appicon.co/ or https://easyappicon.com/
2. Upload the SVG file from `assets/icons/app_icon.svg`
3. Generate all sizes and download
4. Place `app_icon.png` (1024x1024) in `assets/icons/`

### Option 3: Use Design Tool
1. Open `assets/icons/app_icon.svg` in Figma/Adobe Illustrator
2. Export as 1024x1024 PNG
3. Save as `assets/icons/app_icon.png`

## Final Steps:
```bash
# Install dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Verify installation
flutter analyze
```

## What This Does:
- Creates custom app icons for Android (all densities)
- Creates adaptive icons with proper background
- Updates Android manifest automatically
- Replaces default Flutter icons with Meezan branding

## Icon Design:
- **Background**: Islamic green gradient (#2D5A3D to #40916C)
- **Foreground**: Mosque silhouette with minarets
- **Accent**: Golden crescent moon and star
- **Style**: Modern, clean, recognizable at all sizes

The generated icon will perfectly represent your Islamic app with professional branding!