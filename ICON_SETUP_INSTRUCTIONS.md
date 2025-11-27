# App Icon Instructions

## Current Setup:
- Added flutter_launcher_icons package to pubspec.yaml
- Configured automatic icon generation
- Created icon generator HTML file

## To complete the setup:

1. **Create your green "M" icon:**
   - Open: megacess/icon_generator.html in your browser
   - Download the generated icon
   - Save as: assets/images/app_icon.png

2. **Generate app icons:**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

3. **Rebuild your app:**
   ```bash
   flutter clean
   flutter build apk
   ```

## Icon Specs:
- Background: Green circle (#43C463)
- Letter: White "M" 
- Size: 1024x1024px (will be auto-resized)
- Format: PNG

The icon will be automatically generated for:
- Android (all densities)
- iOS 
- Web
- Windows

After running the command, your app will have the green "M" icon!