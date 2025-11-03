//
//  CSVExportService.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation
import UIKit

class CSVExportService {
    static let shared = CSVExportService()
    
    private init() {}
    
    /// Generates CSV content from expenses and categories
    func generateCSV(expenses: [Expense], categories: [Category]) -> String {
        // CSV Header
        var csvContent = "Date,Type,Category,Amount,Note,Created At\n"
        
        // Create a dictionary for quick category lookup
        let categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
        
        // Date formatters
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currencyFormatter = CurrencyManager.shared.currencyFormatter
        
        // Sort expenses by date (newest first)
        let sortedExpenses = expenses.sorted { $0.date > $1.date }
        
        // Generate rows
        for expense in sortedExpenses {
            let dateString = dateFormatter.string(from: expense.date)
            let typeString = expense.type.displayName
            let categoryName = categoryDict[expense.categoryID] ?? "Unknown"
            
            // Format amount with currency symbol
            let amountString: String
            if let formattedAmount = currencyFormatter.string(from: NSDecimalNumber(decimal: expense.amount)) {
                amountString = formattedAmount
            } else {
                amountString = String(describing: expense.amount)
            }
            
            let noteString = expense.note?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            let createdAtString = dateFormatter.string(from: expense.createdAt)
            
            // Escape commas and quotes in CSV
            let escapedNote = noteString.isEmpty ? "" : "\"\(noteString)\""
            
            csvContent += "\(dateString),\(typeString),\(categoryName),\(amountString),\(escapedNote),\(createdAtString)\n"
        }
        
        return csvContent
    }
    
    /// Creates a temporary file URL with the CSV content
    func createCSVFile(expenses: [Expense], categories: [Category]) -> URL? {
        let csvContent = generateCSV(expenses: expenses, categories: categories)
        
        // Create a temporary file
        let fileName = "Pockets_Export_\(dateStringForFilename()).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating CSV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Generates a date string for the filename
    private func dateStringForFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
}

