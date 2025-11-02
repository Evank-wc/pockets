# CoreData Model Setup Instructions

To complete the CoreData setup for Pockets, you need to create the CoreData model file in Xcode.

## Steps:

1. **Create the Data Model File:**
   - In Xcode, right-click on the `Pockets` folder
   - Select "New File..."
   - Choose "Data Model" under "Core Data"
   - Name it `PocketsDataModel.xcdatamodeld`
   - Make sure it's added to the Pockets target

2. **Create ExpenseEntity:**
   - Click the "+" button at the bottom to add a new entity
   - Name it `ExpenseEntity`
   - Add the following attributes:
     - `id` (UUID, Optional)
     - `amount` (Decimal/NSDecimalNumber, Optional)
     - `categoryID` (UUID, Optional)
     - `note` (String, Optional)
     - `date` (Date, Optional)
     - `type` (String, Optional)
     - `createdAt` (Date, Optional)
     - `updatedAt` (Date, Optional)
   - Set the "Codegen" to "Manual/None" in the Data Model Inspector

3. **Create CategoryEntity:**
   - Add another entity named `CategoryEntity`
   - Add the following attributes:
     - `id` (UUID, Optional)
     - `name` (String, Optional)
     - `icon` (String, Optional)
     - `color` (String, Optional)
     - `createdAt` (Date, Optional)
     - `updatedAt` (Date, Optional)
     - `isDefault` (Boolean, Default: NO)
   - Set the "Codegen" to "Manual/None" in the Data Model Inspector

4. **Build the Project:**
   - The entity classes are already created manually in:
     - `Models/ExpenseEntity+CoreDataClass.swift`
     - `Models/ExpenseEntity+CoreDataProperties.swift`
     - `Models/CategoryEntity+CoreDataClass.swift`
     - `Models/CategoryEntity+CoreDataProperties.swift`

## Notes:

- The CoreData entities use manual code generation (we've created the classes manually)
- Data is stored locally only (no iCloud sync - no paid developer account required)
- First launch will create default categories automatically
- All data persists locally on your device

