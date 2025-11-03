//
//  AddExpenseView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

/// View for adding new expenses or income
struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: Decimal = 0
    @State private var selectedCategoryID: UUID?
    @State private var note: String = ""
    @State private var selectedDate: Date = Date()
    @State private var expenseType: ExpenseType = .expense
    @State private var showingCategoryPicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Type Selector
                        Picker("Type", selection: $expenseType) {
                            ForEach(ExpenseType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .onChange(of: expenseType) { _, _ in
                            Haptics.selection()
                        }
                        
                        // Amount Keypad Card
                        VStack(spacing: 0) {
                            AmountKeypadView(amount: $amount)
                                .padding(.vertical, 20)
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // Details Card
                        VStack(spacing: 0) {
                            // Category Picker
                            Button {
                                showingCategoryPicker = true
                            } label: {
                                HStack(spacing: 16) {
                                    if let selectedCategoryID = selectedCategoryID,
                                       let category = viewModel.getCategory(for: selectedCategoryID) {
                                        Text(category.icon)
                                            .font(.system(size: 28))
                                            .frame(width: 56, height: 56)
                                            .background(AppTheme.secondaryBackground)
                                            .cornerRadius(16)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Category")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppTheme.secondaryText)
                                            Text(category.name)
                                                .foregroundColor(AppTheme.primaryText)
                                                .font(.system(size: 17, weight: .semibold))
                                        }
                                    } else {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppTheme.accent)
                                            .frame(width: 56, height: 56)
                                            .background(AppTheme.accent.opacity(0.15))
                                            .cornerRadius(16)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Category")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppTheme.secondaryText)
                                            Text("Select Category")
                                                .foregroundColor(AppTheme.accent)
                                                .font(.system(size: 17, weight: .medium))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.tertiaryText)
                                }
                                .padding(20)
                            }
                            
                            Divider()
                                .background(AppTheme.tertiaryText.opacity(0.3))
                                .padding(.leading, 92)
                            
                            // Note
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Note")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.secondaryText)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                                
                                TextField("Optional note", text: $note)
                                    .foregroundColor(AppTheme.primaryText)
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                            }
                            
                            Divider()
                                .background(AppTheme.tertiaryText.opacity(0.3))
                            
                            // Date Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.secondaryText)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                                
                                DateWheelPicker(date: $selectedDate, title: "Date")
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                            }
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // Spacer for bottom padding
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationTitle(expenseType == .expense ? "Add Expense" : "Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveExpense()
                    }
                    .foregroundColor(AppTheme.accent)
                    .fontWeight(.semibold)
                    .disabled(amount <= 0 || selectedCategoryID == nil)
                    .opacity(amount <= 0 || selectedCategoryID == nil ? 0.5 : 1.0)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    viewModel: viewModel,
                    selectedCategoryID: $selectedCategoryID
                )
            }
        }
    }
    
    private func saveExpense() {
        guard let categoryID = selectedCategoryID else { return }
        
        Haptics.success()
        viewModel.addExpense(
            amount: amount,
            categoryID: categoryID,
            note: note.isEmpty ? nil : note,
            date: selectedDate,
            type: expenseType
        )
        
        dismiss()
    }
}

struct CategoryPickerView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Binding var selectedCategoryID: UUID?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    ForEach(viewModel.categories) { category in
                        Button {
                            selectedCategoryID = category.id
                            Haptics.selection()
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                Text(category.icon)
                                    .font(.system(size: 28))
                                    .frame(width: 50, height: 50)
                                    .background(AppTheme.secondaryBackground)
                                    .cornerRadius(14)
                                
                                Text(category.name)
                                    .foregroundColor(AppTheme.primaryText)
                                    .font(.system(size: 17, weight: .medium))
                                
                                Spacer()
                                
                                if selectedCategoryID == category.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.accent)
                                        .font(.system(size: 22))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Category")
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

#Preview {
    AddExpenseView(viewModel: ExpenseViewModel())
        .preferredColorScheme(.dark)
}
