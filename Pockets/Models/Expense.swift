//
//  Expense.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation

enum ExpenseType: String, Codable, CaseIterable {
    case expense = "expense"
    case income = "income"
    
    var displayName: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        }
    }
}

// MARK: - Core Data Model (will be generated from .xcdatamodeld)
// ExpenseEntity attributes:
// - id: UUID
// - amount: Decimal (NSDecimalNumber)
// - categoryID: UUID
// - note: String?
// - date: Date
// - type: String (ExpenseType.rawValue)
// - createdAt: Date
// - updatedAt: Date

// MARK: - Swift Model Wrapper
struct Expense: Identifiable, Hashable {
    let id: UUID
    var amount: Decimal
    var categoryID: UUID
    var note: String?
    var date: Date
    var type: ExpenseType
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         amount: Decimal,
         categoryID: UUID,
         note: String? = nil,
         date: Date = Date(),
         type: ExpenseType = .expense,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.amount = amount
        self.categoryID = categoryID
        self.note = note
        self.date = date
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Extensions
extension Expense {
    var isIncome: Bool {
        type == .income
    }
    
    var signedAmount: Decimal {
        isIncome ? amount : -amount
    }
}

