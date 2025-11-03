//
//  StorageService.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation
import CoreData

/// Manages CoreData persistence (local storage only, no CloudKit)
class StorageService: ObservableObject {
    static let shared = StorageService()
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        // Use lowercase name to match the actual file: pocketsdatamodel.xcdatamodeld
        let container = NSPersistentContainer(name: "pocketsdatamodel")
        
        var hasError = false
        container.loadPersistentStores { description, error in
            if let error = error {
                // Use deferred logging to prevent console flooding during initialization
                DispatchQueue.main.async {
                    AppLogger.error("Core Data failed to load: \(error.localizedDescription)")
                    if let url = description.url {
                        AppLogger.error("Store URL: \(url.absoluteString)")
                    }
                }
                hasError = true
            } else {
                // Defer success message to avoid console flooding
                DispatchQueue.main.async {
                    AppLogger.info("CoreData loaded successfully")
                }
                // Setup default categories after successful load
                DispatchQueue.main.async { [weak self] in
                    self?.setupDefaultCategoriesIfNeeded()
                }
            }
        }
        
        // Only configure if loaded successfully
        if !hasError {
            // Configure CoreData context
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        } else {
            DispatchQueue.main.async {
                AppLogger.warning("CoreData container loaded with errors, some features may not work")
            }
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // Check if CoreData entities are available
    private var areEntitiesAvailable: Bool {
        let context = viewContext
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            return false
        }
        return model.entitiesByName["CategoryEntity"] != nil && 
               model.entitiesByName["ExpenseEntity"] != nil
    }
    
    private init() {
        // Don't setup categories here - wait until persistent store is loaded
    }
    
    // MARK: - Save Context
    func save() {
        let context = viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Expense Operations
    func createExpense(amount: Decimal, categoryID: UUID, note: String?, date: Date, type: ExpenseType) {
        guard areEntitiesAvailable else {
            print("⚠️ Cannot create expense: CoreData entities not available. Please create PocketsDataModel.xcdatamodeld in Xcode.")
            return
        }
        
        let context = viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "ExpenseEntity", in: context) else {
            print("⚠️ ExpenseEntity not found in CoreData model")
            return
        }
        
        let expense = ExpenseEntity(entity: entityDescription, insertInto: context)
        expense.id = UUID()
        expense.amount = NSDecimalNumber(decimal: amount)
        expense.categoryID = categoryID
        expense.note = note
        expense.date = date
        expense.type = type.rawValue
        expense.createdAt = Date()
        expense.updatedAt = Date()
        
        save()
    }
    
    func updateExpense(_ expense: Expense) {
        let context = viewContext
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                entity.amount = NSDecimalNumber(decimal: expense.amount)
                entity.categoryID = expense.categoryID
                entity.note = expense.note
                entity.date = expense.date
                entity.type = expense.type.rawValue
                entity.updatedAt = Date()
                save()
            }
        } catch {
            print("Error updating expense: \(error.localizedDescription)")
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        let context = viewContext
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                context.delete(entity)
                try context.save() // Force immediate save
                print("✅ Successfully deleted expense with ID: \(expense.id)")
            } else {
                print("⚠️ No expense found with ID: \(expense.id)")
            }
        } catch {
            print("❌ Error deleting expense: \(error.localizedDescription)")
            // Try to save anyway in case delete worked but save failed
            do {
                try context.save()
            } catch {
                print("❌ Error saving context after delete: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchExpenses(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]) -> [Expense] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { entity in
                Expense(
                    id: entity.id ?? UUID(),
                    amount: entity.amount as Decimal? ?? 0,
                    categoryID: entity.categoryID ?? UUID(),
                    note: entity.note,
                    date: entity.date ?? Date(),
                    type: ExpenseType(rawValue: entity.type ?? "expense") ?? .expense,
                    createdAt: entity.createdAt ?? Date(),
                    updatedAt: entity.updatedAt ?? Date()
                )
            }
        } catch {
            print("Error fetching expenses: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Category Operations
    func createCategory(name: String, icon: String, color: String? = nil, isDefault: Bool = false) {
        guard areEntitiesAvailable else {
            print("⚠️ Cannot create category: CoreData entities not available. Please create PocketsDataModel.xcdatamodeld in Xcode.")
            return
        }
        
        let context = viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "CategoryEntity", in: context) else {
            print("⚠️ CategoryEntity not found in CoreData model")
            return
        }
        
        let category = CategoryEntity(entity: entityDescription, insertInto: context)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.color = color
        category.isDefault = isDefault
        category.createdAt = Date()
        category.updatedAt = Date()
        
        save()
    }
    
    func updateCategory(_ category: Category) {
        let context = viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                entity.name = category.name
                entity.icon = category.icon
                entity.color = category.color
                entity.updatedAt = Date()
                save()
            }
        } catch {
            print("Error updating category: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(_ category: Category) {
        // Don't delete default categories
        if category.isDefault {
            print("⚠️ Cannot delete default category: \(category.name)")
            return
        }
        
        let context = viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                context.delete(entity)
                try context.save() // Force immediate save
                print("✅ Successfully deleted category with ID: \(category.id)")
            } else {
                print("⚠️ No category found with ID: \(category.id)")
            }
        } catch {
            print("❌ Error deleting category: \(error.localizedDescription)")
            // Try to save anyway in case delete worked but save failed
            do {
                try context.save()
            } catch {
                print("❌ Error saving context after delete: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchCategories() -> [Category] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { entity in
                Category(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "Unknown",
                    icon: entity.icon ?? "📦",
                    color: entity.color,
                    createdAt: entity.createdAt ?? Date(),
                    updatedAt: entity.updatedAt ?? Date(),
                    isDefault: entity.isDefault
                )
            }
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Reset All Data
    func deleteAllExpenses() {
        let context = viewContext
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        
        do {
            let expenses = try context.fetch(fetchRequest)
            expenses.forEach { context.delete($0) }
            save()
        } catch {
            print("Error deleting all expenses: \(error.localizedDescription)")
        }
    }
    
    func deleteAllCategories() {
        let context = viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            categories.forEach { context.delete($0) }
            save()
            // Reset default categories after deletion
            setupDefaultCategoriesIfNeeded()
        } catch {
            print("Error deleting all categories: \(error.localizedDescription)")
        }
    }
    
    func getCategory(by id: UUID) -> Category? {
        let context = viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                return Category(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "Unknown",
                    icon: entity.icon ?? "📦",
                    color: entity.color,
                    createdAt: entity.createdAt ?? Date(),
                    updatedAt: entity.updatedAt ?? Date(),
                    isDefault: entity.isDefault
                )
            }
        } catch {
            print("Error fetching category: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Setup
    private func setupDefaultCategoriesIfNeeded() {
        // Only setup if entities are available
        guard areEntitiesAvailable else {
            print("⚠️ CoreData model not loaded. Skipping default categories setup.")
            return
        }
        
        let categories = fetchCategories()
        if categories.isEmpty {
            // Create default categories
            for defaultCategory in Category.defaultCategories {
                createCategory(name: defaultCategory.name, icon: defaultCategory.icon, isDefault: true)
            }
        }
    }
    
    // MARK: - Statistics
    func getMonthlyTotal(for month: Date, type: ExpenseType? = nil) -> Decimal {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        var predicate: NSPredicate
        if let type = type {
            predicate = NSPredicate(format: "date >= %@ AND date < %@ AND type == %@", startOfMonth as NSDate, endOfMonth as NSDate, type.rawValue)
        } else {
            predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        }
        
        let expenses = fetchExpenses(predicate: predicate)
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    func getMonthlyExpensesByCategory(for month: Date) -> [UUID: Decimal] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@ AND type == %@", startOfMonth as NSDate, endOfMonth as NSDate, ExpenseType.expense.rawValue)
        let expenses = fetchExpenses(predicate: predicate)
        
        var categoryTotals: [UUID: Decimal] = [:]
        for expense in expenses {
            categoryTotals[expense.categoryID, default: 0] += expense.amount
        }
        
        return categoryTotals
    }
    
    func getMonthlyIncomeByCategory(for month: Date) -> [UUID: Decimal] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@ AND type == %@", startOfMonth as NSDate, endOfMonth as NSDate, ExpenseType.income.rawValue)
        let expenses = fetchExpenses(predicate: predicate)
        
        var categoryTotals: [UUID: Decimal] = [:]
        for expense in expenses {
            categoryTotals[expense.categoryID, default: 0] += expense.amount
        }
        
        return categoryTotals
    }
    
    func getDailyTotal(for date: Date, type: ExpenseType? = nil) -> Decimal {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        var predicate: NSPredicate
        if let type = type {
            predicate = NSPredicate(format: "date >= %@ AND date < %@ AND type == %@", startOfDay as NSDate, endOfDay as NSDate, type.rawValue)
        } else {
            predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        }
        
        let expenses = fetchExpenses(predicate: predicate)
        return expenses.reduce(0) { $0 + $1.amount }
    }
}

