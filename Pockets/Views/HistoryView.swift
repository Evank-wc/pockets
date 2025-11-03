//
//  HistoryView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

enum SortOption: String, CaseIterable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case amountHigh = "Amount (High)"
    case amountLow = "Amount (Low)"
    case category = "Category"
}

/// View showing expense history with search and filters
struct HistoryView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingFilters = false
    @State private var showingSortOptions = false
    @State private var sortOption: SortOption = .dateNewest
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.secondaryText)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search expenses...", text: $viewModel.searchText)
                            .foregroundColor(AppTheme.primaryText)
                            .font(.system(size: 16))
                        
                        if !viewModel.searchText.isEmpty {
                            Button {
                                withAnimation(AppTheme.springAnimation) {
                                    viewModel.searchText = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Expense List
                    if sortedExpenses.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.tertiaryText)
                            Text("No expenses found")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(groupedExpenses, id: \.key) { group in
                                Section(header: 
                                    Text(group.key)
                                        .foregroundColor(AppTheme.secondaryText)
                                        .font(.system(size: 14, weight: .semibold))
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                ) {
                                    ForEach(group.value) { expense in
                                        ExpenseRowView(expense: expense, viewModel: viewModel)
                                            .listRowBackground(AppTheme.cardBackground)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Sort Button
                        Button {
                            Haptics.light()
                            showingSortOptions = true
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        
                        // Filter Button
                        Button {
                            Haptics.light()
                            showingFilters = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(viewModel.hasActiveFilters ? .fill : .none)
                                .foregroundColor(viewModel.hasActiveFilters ? AppTheme.accent : AppTheme.secondaryText)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSortOptions) {
                SortOptionsView(sortOption: $sortOption)
            }
        }
    }
    
    private var sortedExpenses: [Expense] {
        let expenses = viewModel.filteredExpenses
        
        switch sortOption {
        case .dateNewest:
            return expenses.sorted { $0.date > $1.date }
        case .dateOldest:
            return expenses.sorted { $0.date < $1.date }
        case .amountHigh:
            return expenses.sorted { $0.amount > $1.amount }
        case .amountLow:
            return expenses.sorted { $0.amount < $1.amount }
        case .category:
            return expenses.sorted { expense1, expense2 in
                let cat1 = viewModel.getCategoryName(for: expense1.categoryID)
                let cat2 = viewModel.getCategoryName(for: expense2.categoryID)
                return cat1 < cat2
            }
        }
    }
    
    private var groupedExpenses: [(key: String, value: [Expense])] {
        let grouped = Dictionary(grouping: sortedExpenses) { expense in
            AppFormatter.dateString(from: expense.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingDetailSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Text(viewModel.getCategoryIcon(for: expense.categoryID))
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(16)
            
            // Details - Main content area
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.getCategoryName(for: expense.categoryID))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let note = expense.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                
                // Type only - date/time in detail view
                HStack(spacing: 6) {
                    Image(systemName: expense.isIncome ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(expense.isIncome ? AppTheme.success : AppTheme.error)
                    
                    Text(expense.type.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            
            Spacer(minLength: 8)
            
            // Amount - Right aligned, responsive
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: expense.isIncome ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(expense.isIncome ? AppTheme.success : AppTheme.error)
                    
                    Text(AppFormatter.currencyString(from: expense.amount))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .monospacedDigit()
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.light()
            showingDetailSheet = true
        }
        // No swipe actions - edit/delete only through detail view
        .sheet(isPresented: $showingDetailSheet) {
            ExpenseDetailView(expense: expense, viewModel: viewModel)
        }
    }
}

struct SortOptionsView: View {
    @Binding var sortOption: SortOption
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                            Haptics.selection()
                            dismiss()
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(AppTheme.primaryText)
                                    .font(.system(size: 17))
                                Spacer()
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.accent)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
    }
}

struct FilterView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var startDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var endDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var useDateRange: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Type", selection: Binding(
                            get: { viewModel.selectedTypeFilter ?? .expense },
                            set: { viewModel.selectedTypeFilter = $0 }
                        )) {
                            Text("All").tag(nil as ExpenseType?)
                            ForEach(ExpenseType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type as ExpenseType?)
                            }
                        }
                        .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Filter by Type")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        Picker("Category", selection: $viewModel.selectedCategoryFilter) {
                            Text("All Categories").tag(nil as UUID?)
                            ForEach(viewModel.categories) { category in
                                HStack {
                                    Text(category.icon)
                                    Text(category.name)
                                }
                                .tag(category.id as UUID?)
                            }
                        }
                        .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Filter by Category")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        Toggle("Use Date Range", isOn: $useDateRange)
                            .foregroundColor(AppTheme.primaryText)
                            .onChange(of: useDateRange) { oldValue, newValue in
                                if !newValue {
                                    viewModel.dateRangeFilter = nil
                                } else {
                                    updateDateRange()
                                }
                            }
                        
                        if useDateRange {
                            DateWheelPicker(date: $startDate, title: "Start Date")
                                .onChange(of: startDate) { _, _ in
                                    if startDate > endDate {
                                        endDate = startDate
                                    }
                                    updateDateRange()
                                }
                            
                            DateWheelPicker(date: $endDate, title: "End Date")
                                .onChange(of: endDate) { _, _ in
                                    if endDate < startDate {
                                        startDate = endDate
                                    }
                                    updateDateRange()
                                }
                            
                            if let range = viewModel.dateRangeFilter {
                                Text("Showing transactions from \(AppFormatter.dateString(from: range.lowerBound)) to \(AppFormatter.dateString(from: range.upperBound))")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    } header: {
                        Text("Filter by Date Range")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        if useDateRange {
                            Text("Only transactions within the selected date range will be shown.")
                                .foregroundColor(AppTheme.tertiaryText)
                        }
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        viewModel.selectedTypeFilter = nil
                        viewModel.selectedCategoryFilter = nil
                        viewModel.dateRangeFilter = nil
                        useDateRange = false
                        Haptics.medium()
                    }
                    .foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
            .onAppear {
                // Initialize state from existing filter
                if let existingRange = viewModel.dateRangeFilter {
                    useDateRange = true
                    startDate = existingRange.lowerBound
                    endDate = existingRange.upperBound
                }
            }
        }
    }
    
    private func updateDateRange() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        viewModel.dateRangeFilter = start...end
    }
}

struct EditExpenseView: View {
    let expense: Expense
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: Decimal
    @State private var selectedCategoryID: UUID
    @State private var note: String
    @State private var selectedDate: Date
    @State private var expenseType: ExpenseType
    
    init(expense: Expense, viewModel: ExpenseViewModel) {
        self.expense = expense
        self.viewModel = viewModel
        _amount = State(initialValue: expense.amount)
        _selectedCategoryID = State(initialValue: expense.categoryID)
        _note = State(initialValue: expense.note ?? "")
        _selectedDate = State(initialValue: expense.date)
        _expenseType = State(initialValue: expense.type)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Type", selection: $expenseType) {
                            ForEach(ExpenseType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text("Amount")
                                .foregroundColor(AppTheme.primaryText)
                            Spacer()
                            TextField("Amount", value: $amount, format: .currency(code: CurrencyManager.shared.selectedCurrencyCode))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(AppTheme.primaryText)
                        }
                        
                        HStack {
                            Text("Category")
                                .foregroundColor(AppTheme.primaryText)
                            Spacer()
                            if let category = viewModel.getCategory(for: selectedCategoryID) {
                                HStack {
                                    Text(category.icon)
                                    Text(category.name)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                        }
                        
                        TextField("Note (optional)", text: $note)
                            .foregroundColor(AppTheme.primaryText)
                        
                        DateWheelPicker(date: $selectedDate, title: "Date")
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedExpense = expense
        updatedExpense.amount = amount
        updatedExpense.categoryID = selectedCategoryID
        updatedExpense.note = note.isEmpty ? nil : note
        updatedExpense.date = selectedDate
        updatedExpense.type = expenseType
        updatedExpense.updatedAt = Date()
        
        viewModel.updateExpense(updatedExpense)
        dismiss()
    }
}

struct ExpenseDetailView: View {
    let expense: Expense
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Icon Card
                        VStack(spacing: 16) {
                            Text(viewModel.getCategoryIcon(for: expense.categoryID))
                                .font(.system(size: 80))
                                .frame(width: 120, height: 120)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(Circle())
                            
                            Text(viewModel.getCategoryName(for: expense.categoryID))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                        
                        // Amount Card
                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: expense.isIncome ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(expense.isIncome ? AppTheme.success : AppTheme.error)
                                    .frame(width: 40, height: 40)
                                    .background((expense.isIncome ? AppTheme.success : AppTheme.error).opacity(0.15))
                                    .clipShape(Circle())
                                
                                Text(expense.type.displayName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            
                            Text(AppFormatter.currencyString(from: expense.amount))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.primaryText)
                                .monospacedDigit()
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                        
                        // Details Card
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Details")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            VStack(spacing: 16) {
                                // Date
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Date")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.secondaryText)
                                        Text(AppFormatter.dateString(from: expense.date))
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(AppTheme.primaryText)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(AppTheme.tertiaryText.opacity(0.3))
                                
                                // Time
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Time")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.secondaryText)
                                        Text(AppFormatter.timeFormatter.string(from: expense.date))
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(AppTheme.primaryText)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Note (if exists)
                                if let note = expense.note, !note.isEmpty {
                                    Divider()
                                        .background(AppTheme.tertiaryText.opacity(0.3))
                                    
                                    HStack(alignment: .top) {
                                        Image(systemName: "note.text")
                                            .font(.system(size: 18))
                                            .foregroundColor(AppTheme.accent)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Note")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppTheme.secondaryText)
                                            Text(note)
                                                .font(.system(size: 17, weight: .medium))
                                                .foregroundColor(AppTheme.primaryText)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button {
                                Haptics.light()
                                showingEditSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Edit")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.accent)
                                .cornerRadius(16)
                            }
                            
                            Button {
                                Haptics.warning()
                                showingDeleteAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Delete")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.error)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.error.opacity(0.15))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditExpenseView(expense: expense, viewModel: viewModel)
            }
            .alert("Delete Expense", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteExpense(expense)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this expense? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Extensions
extension ExpenseViewModel {
    var hasActiveFilters: Bool {
        selectedCategoryFilter != nil || selectedTypeFilter != nil || dateRangeFilter != nil
    }
}

#Preview {
    HistoryView(viewModel: ExpenseViewModel())
        .preferredColorScheme(.dark)
}
