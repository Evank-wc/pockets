# Fix: CoreData Codegen Issue

If you can't find "Manual/None" in the Codegen dropdown (only seeing Swift/Objective-C options), here are the solutions:

## Solution 1: Remove Manual Files and Use Auto-Generation (Easiest)

Since you can't disable codegen, let's use Xcode's auto-generation:

1. **Delete these manual files** from your project:
   - `Models/ExpenseEntity+CoreDataClass.swift`
   - `Models/ExpenseEntity+CoreDataProperties.swift`
   - `Models/CategoryEntity+CoreDataClass.swift`
   - `Models/CategoryEntity+CoreDataProperties.swift`

2. **In the CoreData model** (`Pocketsdatamodel.xcdatamodeld`):
   - Select **ExpenseEntity**
   - In the **Data Model Inspector**, set:
     - **Codegen**: Choose **"Class Definition"** (if you see Swift/Objective-C options, this means Codegen is enabled)
     - **Class**: `ExpenseEntity`
     - **Module**: Leave as "Current Product Module"
   - Repeat for **CategoryEntity**:
     - **Codegen**: "Class Definition"
     - **Class**: `CategoryEntity`

3. **Clean and rebuild**:
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

4. **Update StorageService** if needed - it should work with auto-generated classes.

## Solution 2: Find the Right Setting Location

The Codegen setting might be in a different location:

1. Select the entity in the model editor
2. Open the **Data Model Inspector** (right sidebar - the third icon)
3. Look for these sections:
   - **Class**: Shows the class name
   - **Codegen**: Should be a dropdown with options
   - If you see **"Class Definition"** or **"Category/Extension"**, change it to **"Manual/None"**

If you're using an older Xcode version:
- In the **Class** field, you might need to manually enter the class name
- The Codegen dropdown might be in the **Class Configuration** section

## Solution 3: Use "Category/Extension" Instead

If "Manual/None" isn't available, try:
1. Set **Codegen** to **"Category/Extension"**
2. Keep the manual `+CoreDataClass.swift` files
3. Xcode will generate only the `+CoreDataProperties.swift` files
4. Delete your manual `+CoreDataProperties.swift` files

## Solution 4: Check Xcode Version

If you're using Xcode 14 or earlier, the Codegen options might be different:
- **Xcode 15+**: Codegen options include "Manual/None"
- **Xcode 14**: Might show "Class Definition" vs "Category/Extension"
- Try updating to Xcode 15.1+ for the latest CoreData features

## Recommended: Solution 1 (Use Auto-Generation)

Since you can't disable codegen, **Solution 1 is recommended** - just delete the manual files and let Xcode generate them. The auto-generated classes will work the same way.

**Note**: If you choose Solution 1, you can delete the manual entity files - they'll be recreated automatically by Xcode during build.

