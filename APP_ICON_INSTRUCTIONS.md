# How to Add Your App Icon

## Step 1: Prepare Your Icon Images

You'll need to create your app icon in multiple sizes. Here's what you need:

### Required Sizes:
- **20pt @2x, @3x** (40x40, 60x60) - Notification icons
- **29pt @2x, @3x** (58x58, 87x87) - Settings icons  
- **40pt @2x, @3x** (80x80, 120x120) - Spotlight icons
- **60pt @2x, @3x** (120x120, 180x180) - App icon
- **1024x1024** - App Store icon

### Quick Method:
1. Create a 1024x1024 pixel square image of your logo
2. Use an online tool like [AppIcon.co](https://www.appicon.co/) or [IconKitchen](https://icon.kitchen/) to generate all sizes automatically

## Step 2: Add Icons to Xcode

1. Open Xcode
2. Navigate to: `Pockets/Assets.xcassets/AppIcon.appiconset/`
3. You'll see slots for different icon sizes
4. Drag and drop your prepared images into the corresponding slots:
   - **20pt** → 40x40, 60x60
   - **29pt** → 58x58, 87x87
   - **40pt** → 80x80, 120x120
   - **60pt** → 120x120, 180x180
   - **1024pt** → 1024x1024

## Step 3: Verify

After adding the icons, you should see them in the AppIcon set. The app icon will appear on your home screen when you build and run the app.

---

# How to Add Your Logo Image

## Step 1: Add Logo to Assets

1. Open Xcode
2. Right-click on `Assets.xcassets` folder
3. Select "New Image Set"
4. Name it `AppLogo`
5. Drag your logo image (preferably @1x, @2x, @3x versions, or just one high-resolution version) into the image set

## Recommended Logo Sizes:
- **@1x**: 120x120 (or larger)
- **@2x**: 240x240 (or larger)  
- **@3x**: 360x360 (or larger)

Or just use one high-resolution image (at least 360x360px) - iOS will scale it automatically.

## Step 2: Usage

The logo is now referenced in:
- **SplashScreenView.swift** - Shows on app launch
- **SettingsView.swift** - Shows in the settings footer

Both use `Image("AppLogo")` to display your logo.

