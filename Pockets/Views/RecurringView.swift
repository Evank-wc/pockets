//
//  RecurringView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct RecurringView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingAddRecurring = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                if viewModel.recurringExpenses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "repeat")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.tertiaryText)
                        Text("No Recurring Expenses")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.secondaryText)
                        Text("Add subscriptions or recurring bills")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                } else {
                    List {
                        ForEach(viewModel.recurringExpenses) { recurring in
                            RecurringRowView(recurring: recurring, viewModel: viewModel)
                                .listRowBackground(AppTheme.cardBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Recurring")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Haptics.light()
                        showingAddRecurring = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecurring) {
                AddRecurringView(viewModel: viewModel)
            }
        }
    }
}

struct RecurringRowView: View {
    let recurring: RecurringExpense
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingDetailSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Text(viewModel.getCategoryIcon(for: recurring.categoryID))
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(16)
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(recurring.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    if !recurring.isActive {
                        Text("(Inactive)")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.tertiaryText)
                        
                        Text("•")
                            .foregroundColor(AppTheme.tertiaryText)
                            .font(.system(size: 11))
                    }
                    
                    Image(systemName: recurring.type == .income ? "arrow.up" : "arrow.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(recurring.type == .income ? AppTheme.success : AppTheme.error)
                    
                    Text("Day \(recurring.dayOfMonth)")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.secondaryText)
                    
                    Text("•")
                        .foregroundColor(AppTheme.tertiaryText)
                    
                    Text(viewModel.getCategoryName(for: recurring.categoryID))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: recurring.type == .income ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(recurring.type == .income ? AppTheme.success : AppTheme.error)
                    
                    Text(AppFormatter.currencyString(from: recurring.amount))
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
            RecurringDetailView(recurring: recurring, viewModel: viewModel)
        }
    }
}

struct AddRecurringView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var selectedCategoryID: UUID?
    @State private var dayOfMonth: Int = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Subscription Name")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("e.g., Netflix, Rent, Salary")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .foregroundColor(AppTheme.primaryText)
                        
                        Picker("Category", selection: Binding(
                            get: { selectedCategoryID ?? UUID() },
                            set: { selectedCategoryID = $0 }
                        )) {
                            Text("Select Category").tag(nil as UUID?)
                            ForEach(viewModel.categories) { category in
                                Text(category.name)
                                    .tag(category.id)
                            }
                        }
                        .foregroundColor(AppTheme.primaryText)
                        
                        Picker("Day of Month", selection: $dayOfMonth) {
                            ForEach(1...31, id: \.self) { day in
                                Text("Day \(day)").tag(day)
                            }
                        }
                        .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Details")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("The expense will be automatically created on this day each month.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Recurring")
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
                        saveRecurring()
                    }
                    .foregroundColor(AppTheme.accent)
                    .disabled(name.isEmpty || amountText.isEmpty || selectedCategoryID == nil)
                }
            }
        }
    }
    
    private func saveRecurring() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        if let number = formatter.number(from: amountText),
           let categoryID = selectedCategoryID {
            let recurring = RecurringExpense(
                name: name,
                amount: number.decimalValue,
                categoryID: categoryID,
                dayOfMonth: dayOfMonth,
                type: .expense // Default to expense
            )
            viewModel.addRecurringExpense(recurring)
            dismiss()
        }
    }
}

struct EditRecurringView: View {
    let recurring: RecurringExpense
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var amountText: String
    @State private var selectedCategoryID: UUID
    @State private var dayOfMonth: Int
    @State private var expenseType: ExpenseType
    @State private var isActive: Bool
    
    init(recurring: RecurringExpense, viewModel: ExpenseViewModel) {
        self.recurring = recurring
        self.viewModel = viewModel
        _name = State(initialValue: recurring.name)
        _amountText = State(initialValue: String(describing: recurring.amount))
        _selectedCategoryID = State(initialValue: recurring.categoryID)
        _dayOfMonth = State(initialValue: recurring.dayOfMonth)
        _expenseType = State(initialValue: recurring.type)
        _isActive = State(initialValue: recurring.isActive)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Subscription Name")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .foregroundColor(AppTheme.primaryText)
                        
                        Picker("Category", selection: $selectedCategoryID) {
                            ForEach(viewModel.categories) { category in
                                Text(category.name)
                                    .tag(category.id)
                            }
                        }
                        .foregroundColor(AppTheme.primaryText)
                        
                        Picker("Day of Month", selection: $dayOfMonth) {
                            ForEach(1...31, id: \.self) { day in
                                Text("Day \(day)").tag(day)
                            }
                        }
                        .foregroundColor(AppTheme.primaryText)
                        
                        Toggle("Active", isOn: $isActive)
                            .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Details")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Recurring")
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        if let number = formatter.number(from: amountText) {
            var updated = recurring
            updated = RecurringExpense(
                id: updated.id,
                name: name,
                amount: number.decimalValue,
                categoryID: selectedCategoryID,
                dayOfMonth: dayOfMonth,
                type: expenseType,
                isActive: isActive,
                createdAt: updated.createdAt,
                updatedAt: Date(),
                lastProcessedDate: updated.lastProcessedDate
            )
            viewModel.updateRecurringExpense(updated)
            dismiss()
        }
    }
}

struct RecurringDetailView: View {
    let recurring: RecurringExpense
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Icon Card
                        VStack(spacing: 16) {
                            Text(viewModel.getCategoryIcon(for: recurring.categoryID))
                                .font(.system(size: 80))
                                .frame(width: 120, height: 120)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(Circle())
                            
                            Text(recurring.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            if !recurring.isActive {
                                Text("(Inactive)")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.tertiaryText)
                            }
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                        
                        // Amount Card
                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: recurring.type == .income ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(recurring.type == .income ? AppTheme.success : AppTheme.error)
                                    .frame(width: 40, height: 40)
                                    .background((recurring.type == .income ? AppTheme.success : AppTheme.error).opacity(0.15))
                                    .clipShape(Circle())
                                
                                Text(recurring.type.displayName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            
                            Text(AppFormatter.currencyString(from: recurring.amount))
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
                                // Category
                                HStack {
                                    Image(systemName: "folder")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Category")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.secondaryText)
                                        Text(viewModel.getCategoryName(for: recurring.categoryID))
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(AppTheme.primaryText)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(AppTheme.tertiaryText.opacity(0.3))
                                
                                // Day of Month
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Day of Month")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.secondaryText)
                                        Text("Day \(recurring.dayOfMonth)")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(AppTheme.primaryText)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(AppTheme.tertiaryText.opacity(0.3))
                                
                                // Status
                                HStack {
                                    Image(systemName: recurring.isActive ? "checkmark.circle.fill" : "pause.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Status")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.secondaryText)
                                        Text(recurring.isActive ? "Active" : "Inactive")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(AppTheme.primaryText)
                                    }
                                    
                                    Spacer()
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
                                Haptics.selection()
                                viewModel.toggleRecurringExpense(recurring)
                            } label: {
                                HStack {
                                    Image(systemName: recurring.isActive ? "pause.circle" : "play.circle")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(recurring.isActive ? "Deactivate" : "Activate")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(recurring.isActive ? AppTheme.warning.opacity(0.15) : AppTheme.success.opacity(0.15))
                                .cornerRadius(16)
                            }
                            
                            Button {
                                Haptics.warning()
                                showingDeleteSheet = true
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
            .navigationTitle("Recurring Expense")
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
                EditRecurringView(recurring: recurring, viewModel: viewModel)
            }
            .alert("Delete Recurring Expense", isPresented: $showingDeleteSheet) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteRecurringExpense(recurring)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(recurring.name)\"? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    RecurringView(viewModel: ExpenseViewModel())
        .preferredColorScheme(.dark)
}

