//
//  QuickAddExpenseIntent.swift
//  Pockets
//
//  Created on 2/11/2025.
//

import Foundation
import AppIntents
import CoreData
import WidgetKit

@available(iOS 17.0, *)
struct QuickAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Add Expense"
    static var description = IntentDescription("Quickly add an expense from the widget")
    // openAppWhenRun will be determined dynamically based on amount
    static var openAppWhenRun: Bool {
        // This is evaluated statically, so we'll handle it in perform()
        return false
    }
    
    @Parameter(title: "Amount", default: 0.0)
    var amount: Double
    
    @Parameter(title: "Category ID", default: "")
    var categoryID: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add expense")
    }
    
    func perform() async throws -> some IntentResult {
        // If amount is 0, just return - widget buttons with amount 0 should open app
        // For now, we'll just return .result() and handle app opening in the widget
        guard amount > 0 else {
            return .result()
        }
        
        // Access CoreData through StorageService
        let storageService = StorageService.shared
        
        // Get "Other" category, or create it if it doesn't exist
        let categories = storageService.fetchCategories()
        var finalCategoryID: UUID
        
        // Try to find "Other" category first
        if let otherCategory = categories.first(where: { $0.name == "Other" }) {
            finalCategoryID = otherCategory.id
        } else if let firstCategory = categories.first {
            // Fallback to first category if "Other" doesn't exist
            finalCategoryID = firstCategory.id
        } else {
            // Create "Other" category if no categories exist
            storageService.createCategory(name: "Other", icon: "📦", isDefault: true)
            let updatedCategories = storageService.fetchCategories()
            finalCategoryID = updatedCategories.first(where: { $0.name == "Other" })?.id ?? UUID()
        }
        
        // Create the expense with "Quick Added Expense" note
        let expenseAmount = Decimal(amount)
        storageService.createExpense(
            amount: expenseAmount,
            categoryID: finalCategoryID,
            note: "Quick Added Expense",
            date: Date(),
            type: .expense
        )
        
        // Save context and ensure it completes
        storageService.save()
        
        // Force CoreData to persist to disk before refreshing widget
        // This ensures the widget sees the updated data
        let context = storageService.viewContext
        if context.hasChanges {
            do {
                try context.save()
                // Also save parent context if it exists
                if let parentContext = context.parent {
                    try parentContext.save()
                }
            } catch {
                print("Error saving context in intent: \(error.localizedDescription)")
            }
        }
        
        // Small delay to ensure data is persisted before widget refresh
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Refresh widgets on main thread
        await MainActor.run {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuickAddWidget")
            }
        }
        
        return .result()
    }
}

@available(iOS 17.0, *)
struct AddExpenseAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // This will open the app
        return .result()
    }
}

@available(iOS 17.0, *)
struct QuickAddIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Add Income"
    static var description = IntentDescription("Quickly add income from the widget")
    // openAppWhenRun will be determined dynamically based on amount
    static var openAppWhenRun: Bool {
        // This is evaluated statically, so we'll handle it in perform()
        return false
    }
    
    @Parameter(title: "Amount", default: 0.0)
    var amount: Double
    
    @Parameter(title: "Category ID", default: "")
    var categoryID: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add income")
    }
    
    func perform() async throws -> some IntentResult {
        // If amount is 0, just return - widget buttons with amount 0 should open app
        // For now, we'll just return .result() and handle app opening in the widget
        guard amount > 0 else {
            return .result()
        }
        
        // Access CoreData through StorageService
        let storageService = StorageService.shared
        
        // Get "Other" category, or create it if it doesn't exist
        let categories = storageService.fetchCategories()
        var finalCategoryID: UUID
        
        // Try to find "Other" category first
        if let otherCategory = categories.first(where: { $0.name == "Other" }) {
            finalCategoryID = otherCategory.id
        } else if let firstCategory = categories.first {
            // Fallback to first category if "Other" doesn't exist
            finalCategoryID = firstCategory.id
        } else {
            // Create "Other" category if no categories exist
            storageService.createCategory(name: "Other", icon: "📦", isDefault: true)
            let updatedCategories = storageService.fetchCategories()
            finalCategoryID = updatedCategories.first(where: { $0.name == "Other" })?.id ?? UUID()
        }
        
        // Create the income with "Quick Added Income" note
        let incomeAmount = Decimal(amount)
        storageService.createExpense(
            amount: incomeAmount,
            categoryID: finalCategoryID,
            note: "Quick Added Income",
            date: Date(),
            type: .income
        )
        
        // Save context and ensure it completes
        storageService.save()
        
        // Force CoreData to persist to disk before refreshing widget
        // This ensures the widget sees the updated data
        let context = storageService.viewContext
        if context.hasChanges {
            do {
                try context.save()
                // Also save parent context if it exists
                if let parentContext = context.parent {
                    try parentContext.save()
                }
            } catch {
                print("Error saving context in intent: \(error.localizedDescription)")
            }
        }
        
        // Small delay to ensure data is persisted before widget refresh
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Refresh widgets on main thread
        await MainActor.run {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuickAddWidget")
            }
        }
        
        return .result()
    }
}

@available(iOS 17.0, *)
struct AddIncomeAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Income"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // This will open the app
        return .result()
    }
}

