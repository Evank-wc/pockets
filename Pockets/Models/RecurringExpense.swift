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
    
    // Custom Codable implementation for Decimal
    enum CodingKeys: String, CodingKey {
        case id, name, amount, categoryID, dayOfMonth, type, isActive, createdAt, updatedAt, lastProcessedDate
    }
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Decode Decimal - handle multiple formats defensively
        amount = Decimal(0) // Default fallback
        if container.contains(.amount) {
            // Try String first (current format)
            if let amountString = try? container.decode(String.self, forKey: .amount),
               let decoded = Decimal(string: amountString) {
                amount = decoded
            }
            // Try Double as fallback (old format or corrupted data)
            else if let amountDouble = try? container.decode(Double.self, forKey: .amount) {
                amount = Decimal(amountDouble)
            }
            // Try Int as last resort
            else if let amountInt = try? container.decode(Int.self, forKey: .amount) {
                amount = Decimal(amountInt)
            }
        }
        
        categoryID = try container.decode(UUID.self, forKey: .categoryID)
        dayOfMonth = try container.decode(Int.self, forKey: .dayOfMonth)
        type = try container.decode(ExpenseType.self, forKey: .type)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        lastProcessedDate = try container.decodeIfPresent(Date.self, forKey: .lastProcessedDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        // Encode Decimal as String for precision
        let amountString = String(describing: amount)
        try container.encode(amountString, forKey: .amount)
        
        try container.encode(categoryID, forKey: .categoryID)
        try container.encode(dayOfMonth, forKey: .dayOfMonth)
        try container.encode(type, forKey: .type)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(lastProcessedDate, forKey: .lastProcessedDate)
    }
}

