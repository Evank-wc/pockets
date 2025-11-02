# Build Error Fix: Duplicate CoreData Entity Files

## Problem
The error `Multiple commands produce 'ExpenseEntity+CoreDataProperties.o'` occurs because Xcode is auto-generating CoreData entity classes while we also have manual versions.

## Solution (If Codegen "Manual/None" is not available)

**If you can't find "Manual/None" in the Codegen dropdown**, use this approach:

### Remove Manual Files and Use Auto-Generation

1. **Delete these manual files** from your project:
   - `Models/ExpenseEntity+CoreDataClass.swift` ❌
   - `Models/ExpenseEntity+CoreDataProperties.swift` ❌
   - `Models/CategoryEntity+CoreDataClass.swift` ❌
   - `Models/CategoryEntity+CoreDataProperties.swift` ❌

2. **In the CoreData model** (`Pocketsdatamodel.xcdatamodeld`):
   - Select **ExpenseEntity**
   - In **Data Model Inspector**, ensure:
     - **Codegen**: Set to **"Class Definition"** (if you only see Swift/Obj-C options, that's fine - means codegen is on)
     - **Class**: `ExpenseEntity`
   - Repeat for **CategoryEntity**:
     - **Codegen**: "Class Definition"
     - **Class**: `CategoryEntity`

3. **Clean and rebuild**:
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

Xcode will auto-generate the entity classes during build, which will work perfectly with StorageService.

## Alternative: If Codegen "Manual/None" IS Available

1. Open `Pocketsdatamodel.xcdatamodeld`
2. Select each entity
3. In **Data Model Inspector** → Set **Codegen** to **"Manual/None"**
4. Keep your manual files

## Verify

After fixing, the build should succeed. The CoreData model should:
- Be in **Sources** build phase (correct)
- Have entities configured with proper Codegen setting
- Match the name in StorageService: `Pocketsdatamodel`

**See CODEGEN_FIX.md for more detailed troubleshooting if needed.**

