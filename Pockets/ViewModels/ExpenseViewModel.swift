//
//  ExpenseViewModel.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

/// ViewModel managing expense tracking state and business logic
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var categories: [Category] = []
    @Published var recurringExpenses: [RecurringExpense] = []
    @Published var monthlyBudget: Decimal = 0
    @Published var selectedMonth: Date = Date()
    @Published var searchText: String = ""
    @Published var selectedCategoryFilter: UUID?
    @Published var selectedTypeFilter: ExpenseType?
    @Published var dateRangeFilter: ClosedRange<Date>? = nil
    
    private let storageService = StorageService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load data with error handling to prevent crashes
        loadDataSafely()
        setupObservers()
        setupCurrencyObserver()
    }
    
    /// Safely loads data with comprehensive error handling
    private func loadDataSafely() {
        do {
            loadData()
        } catch {
            print("⚠️ Critical error loading data: \(error)")
            // Initialize with empty data to prevent crash
            expenses = []
            categories = []
            recurringExpenses = []
            monthlyBudget = 0
        }
    }
    
    private func setupCurrencyObserver() {
        NotificationCenter.default.publisher(for: .currencyDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadData() {
        expenses = storageService.fetchExpenses()
        categories = storageService.fetchCategories()
        
        // Load budget from UserDefaults (simple storage for MVP)
        let budgetValue = UserDefaults.standard.double(forKey: "monthlyBudget")
        monthlyBudget = Decimal(budgetValue)
        
        // Load recurring expenses from UserDefaults with error recovery
        // Use async dispatch to prevent blocking app startup
        DispatchQueue.main.async { [weak self] in
            self?.loadRecurringExpenses()
            // Process recurring expenses after loading
            self?.processRecurringExpenses()
        }
    }
    
    private func setupObservers() {
        // Observe CoreData changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Expense Operations
    func addExpense(amount: Decimal, categoryID: UUID, note: String?, date: Date, type: ExpenseType) {
        storageService.createExpense(amount: amount, categoryID: categoryID, note: note, date: date, type: type)
        loadData()
        checkBudgetNotification()
        Haptics.success()
    }
    
    func updateExpense(_ expense: Expense) {
        storageService.updateExpense(expense)
        loadData()
        checkBudgetNotification()
        Haptics.medium()
    }
    
    private func checkBudgetNotification() {
        let settingsManager = NotificationSettingsManager.shared
        if settingsManager.budgetAlertEnabled && monthlyBudget > 0 {
            NotificationService.shared.checkBudgetThreshold(
                currentSpending: currentMonthExpenses,
                budget: monthlyBudget,
                threshold: settingsManager.budgetThreshold,
                enabled: true
            )
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        storageService.deleteExpense(expense)
        loadData()
        Haptics.light()
    }
    
    // MARK: - Category Operations
    func addCategory(name: String, icon: String, color: String? = nil) {
        storageService.createCategory(name: name, icon: icon, color: color)
        loadData()
        Haptics.success()
    }
    
    func updateCategory(_ category: Category) {
        storageService.updateCategory(category)
        loadData()
        Haptics.medium()
    }
    
    func deleteCategory(_ category: Category) {
        storageService.deleteCategory(category)
        loadData()
        Haptics.light()
    }
    
    // MARK: - Budget
    func setMonthlyBudget(_ budget: Decimal) {
        monthlyBudget = budget
        UserDefaults.standard.set(budget.doubleValue, forKey: "monthlyBudget")
        Haptics.medium()
    }
    
    // MARK: - Reset All Data
    func resetAllData() {
        // Delete all expenses and categories from CoreData
        storageService.deleteAllExpenses()
        storageService.deleteAllCategories()
        
        // Clear recurring expenses - cancel notifications first
        for recurring in recurringExpenses {
            let identifier = "subscription_" + recurring.id.uuidString
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier, identifier + "_reminder"])
        }
        recurringExpenses = []
        
        // Clear UserDefaults data
        UserDefaults.standard.removeObject(forKey: "monthlyBudget")
        UserDefaults.standard.removeObject(forKey: "recurringExpenses")
        
        // Clear notification preferences
        UserDefaults.standard.removeObject(forKey: "notificationDailyReminder")
        UserDefaults.standard.removeObject(forKey: "notificationDailyReminderTime")
        UserDefaults.standard.removeObject(forKey: "notificationBudgetAlert")
        UserDefaults.standard.removeObject(forKey: "notificationBudgetThreshold")
        UserDefaults.standard.removeObject(forKey: "notificationSubscriptionAlerts")
        
        // Cancel all notifications
        NotificationService.shared.cancelAllNotifications()
        
        // Reset notification settings manager
        NotificationSettingsManager.shared.dailyReminderEnabled = false
        NotificationSettingsManager.shared.budgetAlertEnabled = false
        NotificationSettingsManager.shared.subscriptionAlertsEnabled = false
        
        // Reload data to refresh UI
        loadData()
        
        Haptics.warning()
    }
    
    // MARK: - Filtered Expenses
    var filteredExpenses: [Expense] {
        var filtered = expenses
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { expense in
                let category = getCategory(for: expense.categoryID)
                let categoryName = category?.name.lowercased() ?? ""
                let note = expense.note?.lowercased() ?? ""
                return categoryName.contains(searchText.lowercased()) || note.contains(searchText.lowercased())
            }
        }
        
        // Apply category filter
        if let categoryID = selectedCategoryFilter {
            filtered = filtered.filter { $0.categoryID == categoryID }
        }
        
        // Apply type filter
        if let type = selectedTypeFilter {
            filtered = filtered.filter { $0.type == type }
        }
        
        // Apply date range filter
        if let dateRange = dateRangeFilter {
            filtered = filtered.filter { expense in
                let calendar = Calendar.current
                let expenseStartOfDay = calendar.startOfDay(for: expense.date)
                let rangeStart = calendar.startOfDay(for: dateRange.lowerBound)
                let rangeEnd = calendar.startOfDay(for: dateRange.upperBound)
                return expenseStartOfDay >= rangeStart && expenseStartOfDay <= rangeEnd
            }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    // MARK: - Monthly Statistics
    var currentMonthTotal: Decimal {
        storageService.getMonthlyTotal(for: selectedMonth)
    }
    
    var currentMonthExpenses: Decimal {
        storageService.getMonthlyTotal(for: selectedMonth, type: .expense)
    }
    
    var currentMonthIncome: Decimal {
        storageService.getMonthlyTotal(for: selectedMonth, type: .income)
    }
    
    var monthlyBalance: Decimal {
        currentMonthIncome - currentMonthExpenses
    }
    
    var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        let progress = (currentMonthExpenses / monthlyBudget).doubleValue
        return min(progress, 1.0)
    }
    
    var isOverBudget: Bool {
        monthlyBudget > 0 && currentMonthExpenses > monthlyBudget
    }
    
    var monthlyExpensesByCategory: [(category: Category, amount: Decimal)] {
        let categoryTotals = storageService.getMonthlyExpensesByCategory(for: selectedMonth)
        return categoryTotals.compactMap { categoryID, amount in
            guard let category = getCategory(for: categoryID) else { return nil }
            return (category: category, amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var monthlyIncomeByCategory: [(category: Category, amount: Decimal)] {
        let categoryTotals = storageService.getMonthlyIncomeByCategory(for: selectedMonth)
        return categoryTotals.compactMap { categoryID, amount in
            guard let category = getCategory(for: categoryID) else { return nil }
            return (category: category, amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    // MARK: - Daily Statistics
    func getDailyTotal(for date: Date) -> Decimal {
        storageService.getDailyTotal(for: date)
    }
    
    func getDailyExpenses(for month: Date) -> [(date: Date, expense: Decimal, income: Decimal)] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        var dailyData: [(date: Date, expense: Decimal, income: Decimal)] = []
        var currentDate = startOfMonth
        
        while currentDate < endOfMonth {
            let expense = storageService.getDailyTotal(for: currentDate, type: .expense)
            let income = storageService.getDailyTotal(for: currentDate, type: .income)
            dailyData.append((date: currentDate, expense: expense, income: income))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dailyData
    }
    
    func getExpensesForDate(_ date: Date) -> [Expense] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return expenses.filter { expense in
            expense.date >= startOfDay && expense.date < endOfDay
        }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Helpers
    func getCategory(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }
    
    func getCategoryName(for id: UUID) -> String {
        getCategory(for: id)?.name ?? "Unknown"
    }
    
    func getCategoryIcon(for id: UUID) -> String {
        getCategory(for: id)?.icon ?? "📦"
    }
    
    // MARK: - Navigation
    func changeMonth(by direction: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: direction, to: selectedMonth) {
            selectedMonth = newMonth
            Haptics.selection()
        }
    }
    
    // MARK: - Recurring Expenses
    private func loadRecurringExpenses() {
        // Ensure we're accessing UserDefaults on main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.loadRecurringExpenses()
            }
            return
        }
        
        // Wrap everything in a do-catch to prevent any crashes
        do {
            // Safely access UserDefaults
            let userDefaults = UserDefaults.standard
            guard let data = userDefaults.data(forKey: "recurringExpenses") else {
                recurringExpenses = []
                return
            }
            
            // Validate data is not empty and has valid size
            guard !data.isEmpty, data.count > 0, data.count < 10_000_000 else { // 10MB max limit
                print("⚠️ Recurring expenses data is invalid (empty or too large), clearing...")
                clearRecurringExpensesData()
                return
            }
            
            // Validate data looks like JSON by checking for opening bracket
            // Check if data has at least one byte before accessing first
            guard data.count > 0, data.first == 0x5B || data.first == 0x7B else { // '[' or '{'
                print("⚠️ Recurring expenses data doesn't appear to be valid JSON, clearing...")
                clearRecurringExpensesData()
                return
            }
            
            // First, validate that the data can be parsed as JSON using JSONSerialization
            // This helps catch corrupted data before it reaches JSONDecoder
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                print("⚠️ Data is not valid JSON: \(error.localizedDescription)")
                print("⚠️ Clearing corrupted data...")
                clearRecurringExpensesData()
                return
            }
            
            // Create decoder with defensive settings
            let decoder = JSONDecoder()
            
            // Safely decode with error handling
            do {
                let decoded = try decoder.decode([RecurringExpense].self, from: data)
                recurringExpenses = decoded
                print("✅ Successfully loaded \(decoded.count) recurring expenses")
            } catch let decodingError {
                print("⚠️ Error decoding recurring expenses: \(decodingError.localizedDescription)")
                print("⚠️ Error details: \(decodingError)")
                print("⚠️ Clearing corrupted data...")
                // Clear corrupted data
                clearRecurringExpensesData()
            }
        } catch {
            // Catch any unexpected errors during the process
            print("⚠️ Unexpected error in loadRecurringExpenses: \(error)")
            clearRecurringExpensesData()
        }
    }
    
    /// Clears corrupted recurring expenses data from UserDefaults
    private func clearRecurringExpensesData() {
        UserDefaults.standard.removeObject(forKey: "recurringExpenses")
        UserDefaults.standard.synchronize()
        recurringExpenses = []
    }
    
    private func saveRecurringExpenses() {
        do {
            let encoded = try JSONEncoder().encode(recurringExpenses)
            UserDefaults.standard.set(encoded, forKey: "recurringExpenses")
            UserDefaults.standard.synchronize()
        } catch {
            print("⚠️ Error encoding recurring expenses: \(error.localizedDescription)")
            // Don't crash if encoding fails - just log the error
        }
    }
    
    func addRecurringExpense(_ recurring: RecurringExpense) {
        var newRecurring = recurring
        newRecurring = RecurringExpense(
            id: newRecurring.id,
            name: newRecurring.name,
            amount: newRecurring.amount,
            categoryID: newRecurring.categoryID,
            dayOfMonth: newRecurring.dayOfMonth,
            type: newRecurring.type,
            isActive: newRecurring.isActive,
            createdAt: newRecurring.createdAt,
            updatedAt: Date(),
            lastProcessedDate: newRecurring.lastProcessedDate
        )
        recurringExpenses.append(newRecurring)
        saveRecurringExpenses()
        processRecurringExpenses()
        
        // Update subscription notifications
        let settingsManager = NotificationSettingsManager.shared
        if settingsManager.subscriptionAlertsEnabled {
            NotificationService.shared.scheduleSubscriptionAlert(recurring: newRecurring, enabled: true)
        }
        
        Haptics.success()
    }
    
    func updateRecurringExpense(_ recurring: RecurringExpense) {
        if let index = recurringExpenses.firstIndex(where: { $0.id == recurring.id }) {
            var updated = recurring
            updated = RecurringExpense(
                id: updated.id,
                name: updated.name,
                amount: updated.amount,
                categoryID: updated.categoryID,
                dayOfMonth: updated.dayOfMonth,
                type: updated.type,
                isActive: updated.isActive,
                createdAt: updated.createdAt,
                updatedAt: Date(),
                lastProcessedDate: updated.lastProcessedDate
            )
            recurringExpenses[index] = updated
            saveRecurringExpenses()
            processRecurringExpenses()
            
            // Update subscription notifications
            let settingsManager = NotificationSettingsManager.shared
            if settingsManager.subscriptionAlertsEnabled {
                NotificationService.shared.scheduleSubscriptionAlert(recurring: updated, enabled: true)
            }
            
            Haptics.medium()
        }
    }
    
    func deleteRecurringExpense(_ recurring: RecurringExpense) {
        let initialCount = recurringExpenses.count
        recurringExpenses.removeAll { $0.id == recurring.id }
        let finalCount = recurringExpenses.count
        
        if finalCount < initialCount {
            saveRecurringExpenses()
            print("✅ Successfully deleted recurring expense with ID: \(recurring.id)")
        } else {
            print("⚠️ No recurring expense found with ID: \(recurring.id)")
        }
        
        // Remove subscription notification
        let identifier = "subscription_" + recurring.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier, identifier + "_reminder"])
        
        Haptics.light()
    }
    
    func toggleRecurringExpense(_ recurring: RecurringExpense) {
        if let index = recurringExpenses.firstIndex(where: { $0.id == recurring.id }) {
            var updated = recurring
            updated = RecurringExpense(
                id: updated.id,
                name: updated.name,
                amount: updated.amount,
                categoryID: updated.categoryID,
                dayOfMonth: updated.dayOfMonth,
                type: updated.type,
                isActive: !updated.isActive,
                createdAt: updated.createdAt,
                updatedAt: Date(),
                lastProcessedDate: updated.lastProcessedDate
            )
            recurringExpenses[index] = updated
            saveRecurringExpenses()
            
            // Update subscription notifications
            let settingsManager = NotificationSettingsManager.shared
            if settingsManager.subscriptionAlertsEnabled {
                NotificationService.shared.scheduleSubscriptionAlert(recurring: updated, enabled: updated.isActive)
            }
            
            Haptics.selection()
        }
    }
    
    // Process recurring expenses - check if any need to create actual expenses
    private func processRecurringExpenses() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayDay = calendar.component(.day, from: today)
        
        for recurring in recurringExpenses where recurring.isActive {
            // Check if this recurring expense should be processed today
            let shouldProcess: Bool
            
            if let lastProcessed = recurring.lastProcessedDate {
                let lastProcessedDay = calendar.component(.day, from: lastProcessed)
                let lastProcessedMonth = calendar.component(.month, from: lastProcessed)
                let lastProcessedYear = calendar.component(.year, from: lastProcessed)
                
                let currentMonth = calendar.component(.month, from: today)
                let currentYear = calendar.component(.year, from: today)
                
                // Only process if we haven't processed this month yet
                shouldProcess = (lastProcessedMonth != currentMonth || lastProcessedYear != currentYear) && todayDay >= recurring.dayOfMonth
            } else {
                // Never processed, process if today is >= the day of month
                shouldProcess = todayDay >= recurring.dayOfMonth
            }
            
            if shouldProcess {
                // Check if expense already exists for this recurring item this month
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
                
                let existingExpense = expenses.first { expense in
                    expense.categoryID == recurring.categoryID &&
                    expense.amount == recurring.amount &&
                    expense.type == recurring.type &&
                    expense.date >= monthStart && expense.date < monthEnd &&
                    expense.note?.contains(recurring.name) == true
                }
                
                if existingExpense == nil {
                    // Create the expense for this month
                    var components = calendar.dateComponents([.year, .month], from: today)
                    components.day = recurring.dayOfMonth
                    let expenseDate = calendar.date(from: components) ?? today
                    
                    addExpense(
                        amount: recurring.amount,
                        categoryID: recurring.categoryID,
                        note: recurring.name,
                        date: expenseDate,
                        type: recurring.type
                    )
                    
                    // Update last processed date
                    if let index = recurringExpenses.firstIndex(where: { $0.id == recurring.id }) {
                        var updated = recurring
                        updated = RecurringExpense(
                            id: updated.id,
                            name: updated.name,
                            amount: updated.amount,
                            categoryID: updated.categoryID,
                            dayOfMonth: updated.dayOfMonth,
                            type: updated.type,
                            isActive: updated.isActive,
                            createdAt: updated.createdAt,
                            updatedAt: Date(),
                            lastProcessedDate: today
                        )
                        recurringExpenses[index] = updated
                        saveRecurringExpenses()
                    }
                } else if let index = recurringExpenses.firstIndex(where: { $0.id == recurring.id }) {
                    // Update last processed date even if expense exists
                    var updated = recurring
                    updated = RecurringExpense(
                        id: updated.id,
                        name: updated.name,
                        amount: updated.amount,
                        categoryID: updated.categoryID,
                        dayOfMonth: updated.dayOfMonth,
                        type: updated.type,
                        isActive: updated.isActive,
                        createdAt: updated.createdAt,
                        updatedAt: Date(),
                        lastProcessedDate: today
                    )
                    recurringExpenses[index] = updated
                    saveRecurringExpenses()
                }
            }
        }
    }
}

// MARK: - Extensions
extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}

