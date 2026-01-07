# How to Add Files to Xcode Project

The files `QuickAddExpenseIntent.swift` and `QuickAddWidget.swift` exist on your filesystem but need to be added to the Xcode project to be visible and compiled.

## Method 1: Drag and Drop (Easiest)

1. **Open Xcode** and open your `Pockets.xcodeproj` project
2. **Open Finder** and navigate to your project folder
3. **Drag the files** into Xcode:
   - For `Pockets/Intents/QuickAddExpenseIntent.swift`:
     - Drag it into the `Pockets` group in Xcode (left sidebar)
     - When prompted, check **"Copy items if needed"** (uncheck if files are already in the right location)
     - Check **"Add to targets: Pockets"** (and optionally `PocketsWidget` if you want to share it)
     - Click **Finish**
   
   - For `PocketsWidget/QuickAddWidget.swift`:
     - Drag it into the `PocketsWidget` group (or create the group if it doesn't exist)
     - Check **"Add to targets: PocketsWidget"**
     - Click **Finish**

## Method 2: Add Files Menu

1. **Right-click** on the `Pockets` group in Xcode's Project Navigator
2. Select **"Add Files to 'Pockets'..."**
3. Navigate to `Pockets/Intents/QuickAddExpenseIntent.swift`
4. Make sure:
   - **"Copy items if needed"** is unchecked (file is already in project folder)
   - **"Add to targets: Pockets"** is checked
5. Click **Add**

Repeat for `PocketsWidget/QuickAddWidget.swift`:
1. Right-click on `PocketsWidget` group (or create it)
2. Add the file to `PocketsWidget` target

## Method 3: Verify File Targets

After adding files, verify they're in the correct targets:

1. **Select the file** in Xcode
2. Open the **File Inspector** (right sidebar, first tab)
3. Under **"Target Membership"**, check:
   - `QuickAddExpenseIntent.swift` should be in **Pockets** target (and optionally **PocketsWidget** if you want to share it)
   - `QuickAddWidget.swift` should be in **PocketsWidget** target

## Troubleshooting

### Files still not visible?
- Make sure you're looking in the correct group/folder
- Try **File > Close Project** and reopen
- Clean build folder: **Product > Clean Build Folder** (⇧⌘K)

### Build errors after adding?
- Make sure all dependencies are shared between targets
- Check that `StorageService`, `AppFormatter`, etc. are accessible from the widget target

### Can't find the widget target?
- The widget extension target might be named `PocketsWidgetExtension` instead of `PocketsWidget`
- Check **File > Project Settings** or the target list in the project navigator

