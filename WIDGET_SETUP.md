# Widget Setup Instructions

This guide will help you set up the Quick Add Widget for the Pockets app.

## Prerequisites

- iOS 17.0+
- Xcode 15.0+
- Widget Extension target needs to be added to the Xcode project

## Step 1: Add Widget Extension Target

1. Open `Pockets.xcodeproj` in Xcode
2. Go to **File** > **New** > **Target**
3. Select **Widget Extension**
4. Name it `PocketsWidget`
5. Make sure "Include Configuration Intent" is **unchecked** (we're using StaticConfiguration)
6. Click **Finish**

## Step 2: Configure App Groups (Optional but Recommended)

To share data between the app and widget:

1. Select the **Pockets** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Create a new group: `group.evank-wc.Pockets` (or use your bundle identifier)
6. Repeat for the **PocketsWidget** target with the same group name

## Step 3: Add Files to Widget Target

1. Select `Pockets/Intents/QuickAddExpenseIntent.swift`
2. In the File Inspector, check **PocketsWidget** target membership
3. Select `PocketsWidget/QuickAddWidget.swift`
4. Ensure it's only in **PocketsWidget** target

## Step 4: Share Code Between Targets

The widget needs access to:
- `StorageService`
- `AppFormatter`
- `CurrencyManager`
- `Expense`, `Category`, `ExpenseType` models

**Option A: Share files (Recommended)**
1. Select each file that needs to be shared
2. In File Inspector, check both **Pockets** and **PocketsWidget** targets

**Option B: Create a shared framework**
- More complex but better for larger projects

## Step 5: Update Widget Bundle

In `PocketsWidget/QuickAddWidget.swift`, ensure the `@main` attribute is on the widget:

```swift
@main
struct QuickAddWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickAddWidget()
    }
}
```

If the file doesn't exist, create it.

## Step 6: Build and Test

1. Build the project (⌘B)
2. Run the widget extension on a device/simulator
3. Long press on the home screen
4. Tap the **+** button
5. Search for "Pockets"
6. Add the widget

## Features

- **Small Widget**: Shows quick add buttons for Expense and Income
- **Medium Widget**: Shows budget progress + quick add buttons
- **Interactive Buttons**: Tap to open the app to add expense/income

## Troubleshooting

### Widget doesn't appear
- Make sure the widget extension target is built
- Check that `@main` is on the widget bundle
- Verify iOS 17.0+ deployment target

### "Cannot find StorageService"
- Ensure `StorageService.swift` is included in both targets
- Check that all dependencies are shared

### Widget shows old data
- Widgets update every hour by default
- You can force refresh by removing and re-adding the widget

## Next Steps

Consider adding:
- Preset amount buttons (e.g., $5, $10, $20)
- Last used category quick-add
- More widget sizes (systemLarge)
- Lock screen widgets

