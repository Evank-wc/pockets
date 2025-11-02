//
//  CategoriesView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

/// View for managing expense categories
struct CategoriesView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    ForEach(viewModel.categories) { category in
                        CategoryRowView(category: category, viewModel: viewModel)
                            .listRowBackground(AppTheme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Haptics.light()
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(viewModel: viewModel)
            }
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingDetailSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            Text(category.icon)
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(16)
            
            Text(category.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)
            
            Spacer()
            
            if category.isDefault {
                Text("Default")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.tertiaryBackground)
                    .cornerRadius(10)
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
            CategoryDetailView(category: category, viewModel: viewModel)
        }
    }
}

struct AddCategoryView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var icon: String = "📦"
    @State private var showingIconPicker = false
    
    private let emojiCategories: [(String, [String])] = [
        ("Food", ["🍔", "🍕", "🌮", "🍜", "🍱", "🥗", "🍳", "🥐", "🍞", "🥖"]),
        ("Transport", ["🚗", "🚕", "🚙", "🚌", "🚎", "🚐", "🛴", "🚲", "🏍️", "✈️"]),
        ("Shopping", ["🛍️", "👕", "👗", "👟", "👜", "💄", "⌚", "📱", "💻", "🎧"]),
        ("Bills", ["📄", "💡", "💧", "🔥", "📺", "📡", "🏠", "📞", "💳", "🏦"]),
        ("Entertainment", ["🎬", "🎮", "🎵", "🎸", "🎤", "🎭", "🎨", "📚", "🎯", "🎲"]),
        ("Health", ["🏥", "💊", "🩺", "🚑", "🧘", "🏋️", "🤸", "🏃", "🚶", "🧴"]),
        ("Travel", ["✈️", "🌍", "🏖️", "⛰️", "🏨", "🧳", "🗺️", "📸", "🎒", "🚂"]),
        ("Other", ["📦", "🎁", "💝", "🎊", "🎉", "⭐", "✨", "💫", "🌟", "🔥"])
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Category Name", text: $name)
                            .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Name")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        Button {
                            showingIconPicker = true
                        } label: {
                            HStack {
                                Text("Icon")
                                    .foregroundColor(AppTheme.primaryText)
                                Spacer()
                                Text(icon)
                                    .font(.system(size: 32))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    } header: {
                        Text("Icon")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Category")
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
                        saveCategory()
                    }
                    .foregroundColor(AppTheme.accent)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $icon)
            }
        }
    }
    
    private func saveCategory() {
        viewModel.addCategory(name: name, icon: icon)
        dismiss()
    }
}

struct EditCategoryView: View {
    let category: Category
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var icon: String
    @State private var showingIconPicker = false
    
    init(category: Category, viewModel: ExpenseViewModel) {
        self.category = category
        self.viewModel = viewModel
        _name = State(initialValue: category.name)
        _icon = State(initialValue: category.icon)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Category Name", text: $name)
                            .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Name")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        Button {
                            showingIconPicker = true
                        } label: {
                            HStack {
                                Text("Icon")
                                    .foregroundColor(AppTheme.primaryText)
                                Spacer()
                                Text(icon)
                                    .font(.system(size: 32))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    } header: {
                        Text("Icon")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Category")
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
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $icon)
            }
        }
    }
    
    private func saveChanges() {
        var updatedCategory = category
        updatedCategory.name = name
        updatedCategory.icon = icon
        updatedCategory.updatedAt = Date()
        
        viewModel.updateCategory(updatedCategory)
        dismiss()
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) var dismiss
    
    private let emojiCategories: [(String, [String])] = [
        ("Food", ["🍔", "🍕", "🌮", "🍜", "🍱", "🥗", "🍳", "🥐", "🍞", "🥖"]),
        ("Transport", ["🚗", "🚕", "🚙", "🚌", "🚎", "🚐", "🛴", "🚲", "🏍️", "✈️"]),
        ("Shopping", ["🛍️", "👕", "👗", "👟", "👜", "💄", "⌚", "📱", "💻", "🎧"]),
        ("Bills", ["📄", "💡", "💧", "🔥", "📺", "📡", "🏠", "📞", "💳", "🏦"]),
        ("Entertainment", ["🎬", "🎮", "🎵", "🎸", "🎤", "🎭", "🎨", "📚", "🎯", "🎲"]),
        ("Health", ["🏥", "💊", "🩺", "🚑", "🧘", "🏋️", "🤸", "🏃", "🚶", "🧴"]),
        ("Travel", ["✈️", "🌍", "🏖️", "⛰️", "🏨", "🧳", "🗺️", "📸", "🎒", "🚂"]),
        ("Other", ["📦", "🎁", "💝", "🎊", "🎉", "⭐", "✨", "💫", "🌟", "🔥"])
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    ForEach(emojiCategories, id: \.0) { category in
                        Section(header: 
                            Text(category.0)
                                .foregroundColor(AppTheme.secondaryText)
                                .font(.system(size: 14, weight: .semibold))
                        ) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                                ForEach(category.1, id: \.self) { emoji in
                                    Button {
                                        selectedIcon = emoji
                                        Haptics.selection()
                                        withAnimation(AppTheme.springAnimation) {
                                            dismiss()
                                        }
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                            .frame(width: 56, height: 56)
                                            .background(selectedIcon == emoji ? AppTheme.accent.opacity(0.2) : AppTheme.secondaryBackground)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(selectedIcon == emoji ? AppTheme.accent.opacity(0.5) : Color.clear, lineWidth: 2)
                                            )
                                            .scaleEffect(selectedIcon == emoji ? 1.1 : 1.0)
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Icon")
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

struct CategoryDetailView: View {
    let category: Category
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
                            Text(category.icon)
                                .font(.system(size: 120))
                                .frame(width: 160, height: 160)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(Circle())
                            
                            Text(category.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            if category.isDefault {
                                Text("Default Category")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.tertiaryText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.tertiaryBackground)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            if !category.isDefault {
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
                            } else {
                                Text("Default categories cannot be edited or deleted")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 16)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Category")
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
                EditCategoryView(category: category, viewModel: viewModel)
            }
            .alert("Delete Category", isPresented: $showingDeleteSheet) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteCategory(category)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(category.name)\"? Expenses using this category will not be affected.")
            }
        }
    }
}

#Preview {
    CategoriesView(viewModel: ExpenseViewModel())
        .preferredColorScheme(.dark)
}
