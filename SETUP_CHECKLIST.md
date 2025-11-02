# Pockets Setup Checklist

## ✅ Completed

- [x] Project folder structure created
- [x] Data models (Expense, Category)
- [x] CoreData entity classes
- [x] StorageService with CoreData (local storage only)
- [x] ExpenseViewModel with MVVM pattern
- [x] Utility classes (Haptics, Formatter)
- [x] Dashboard view with charts
- [x] Add Expense view with numeric keypad
- [x] History view with search and filters
- [x] Categories management view
- [x] Settings view
- [x] Main app navigation structure
- [x] Floating add button

## 🔧 Required Setup (In Xcode)

### 1. Create CoreData Model File
- [ ] Right-click `Pockets` folder → New File → Data Model
- [ ] Name: `PocketsDataModel.xcdatamodeld`
- [ ] Add to Pockets target

### 2. Create ExpenseEntity
- [ ] Add entity: `ExpenseEntity`
- [ ] Attributes:
  - `id` (UUID, Optional)
  - `amount` (Decimal, Optional)
  - `categoryID` (UUID, Optional)
  - `note` (String, Optional)
  - `date` (Date, Optional)
  - `type` (String, Optional)
  - `createdAt` (Date, Optional)
  - `updatedAt` (Date, Optional)
- [ ] Set Codegen: Manual/None

### 3. Create CategoryEntity
- [ ] Add entity: `CategoryEntity`
- [ ] Attributes:
  - `id` (UUID, Optional)
  - `name` (String, Optional)
  - `icon` (String, Optional)
  - `color` (String, Optional)
  - `createdAt` (Date, Optional)
  - `updatedAt` (Date, Optional)
  - `isDefault` (Boolean, Default: NO)
- [ ] Set Codegen: Manual/None

### 4. Update Project File References
- [ ] Ensure all new Swift files are added to the Xcode project
- [ ] Add files to "Pockets" target in Build Phases → Compile Sources

### 5. Add Files to Xcode Project
The following files need to be added to the Xcode project:

**Models:**
- `Models/Expense.swift`
- `Models/Category.swift`
- `Models/ExpenseEntity+CoreDataClass.swift`
- `Models/ExpenseEntity+CoreDataProperties.swift`
- `Models/CategoryEntity+CoreDataClass.swift`
- `Models/CategoryEntity+CoreDataProperties.swift`

**ViewModels:**
- `ViewModels/ExpenseViewModel.swift`

**Views:**
- `Views/DashboardView.swift`
- `Views/AddExpenseView.swift`
- `Views/HistoryView.swift`
- `Views/CategoriesView.swift`
- `Views/SettingsView.swift`
- `Views/Components/AmountKeypadView.swift`

**Services:**
- `Services/StorageService.swift`

**Utils:**
- `Utils/Haptics.swift`
- `Utils/Formatter.swift`

## 🚀 Build & Test

1. Build the project (⌘+B)
2. Fix any import or compilation errors
3. Run on simulator or device
4. Test adding expenses
5. Verify default categories are created
6. Test adding and viewing expenses

## 📝 Notes

- First launch automatically creates default categories
- App works completely offline - no internet required
- All data stored locally on device
- Budget is stored in UserDefaults

## 🐛 Troubleshooting

**"Cannot find ExpenseEntity in scope":**
- Ensure CoreData model file is created
- Check that entity classes are added to target
- Clean build folder (⌘+Shift+K)

**Data not persisting:**
- Verify CoreData model file is created
- Check that entities are properly configured
- Ensure entity attributes match the expected types

**Charts not showing:**
- Charts require iOS 17.0+
- Fallback UI is provided for iOS 16
- Check deployment target in project settings

