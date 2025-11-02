//
//  RecurringExpense.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation

struct RecurringExpense: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var amount: Decimal
    var categoryID: UUID
    var dayOfMonth: Int // 1-31, or use special value for end of month
    var type: ExpenseType
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    var lastProcessedDate: Date? // Track when this was last processed
    
    init(id: UUID = UUID(),
         name: String,
         amount: Decimal,
         categoryID: UUID,
         dayOfMonth: Int,
         type: ExpenseType = .expense,
         isActive: Bool = true,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         lastProcessedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.amount = amount
        self.categoryID = categoryID
        self.dayOfMonth = min(max(dayOfMonth, 1), 31)
        self.type = type
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastProcessedDate = lastProcessedDate
    }
}

