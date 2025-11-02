//
//  Category.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation

// MARK: - Core Data Model (will be generated from .xcdatamodeld)
// CategoryEntity attributes:
// - id: UUID
// - name: String
// - icon: String (emoji or SF Symbol name)
// - color: String? (optional hex color)
// - createdAt: Date
// - updatedAt: Date
// - isDefault: Bool

// MARK: - Swift Model Wrapper
struct Category: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: String?
    var createdAt: Date
    var updatedAt: Date
    var isDefault: Bool
    
    init(id: UUID = UUID(),
         name: String,
         icon: String,
         color: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDefault = isDefault
    }
}

// MARK: - Default Categories
extension Category {
    static let defaultCategories: [Category] = [
        Category(name: "Food", icon: "🍔", isDefault: true),
        Category(name: "Transport", icon: "🚗", isDefault: true),
        Category(name: "Shopping", icon: "🛍️", isDefault: true),
        Category(name: "Bills", icon: "📄", isDefault: true),
        Category(name: "Entertainment", icon: "🎬", isDefault: true),
        Category(name: "Health", icon: "🏥", isDefault: true),
        Category(name: "Education", icon: "📚", isDefault: true),
        Category(name: "Travel", icon: "✈️", isDefault: true),
        Category(name: "Salary", icon: "💰", isDefault: true),
        Category(name: "Other", icon: "📦", isDefault: true)
    ]
}

