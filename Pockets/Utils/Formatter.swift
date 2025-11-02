//
//  Formatter.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation

/// Centralized formatters for consistent display throughout the app
struct AppFormatter {
    /// Currency formatter for displaying amounts
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Date formatter for displaying dates
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Time formatter for displaying times
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Month-year formatter
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    /// Short date formatter (e.g., "Jan 15")
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    /// Day formatter (e.g., "Monday")
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    /// Formats a Decimal amount as currency string
    static func currencyString(from amount: Decimal) -> String {
        return currency.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
    
    /// Formats a Date for display
    static func dateString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    /// Formats a Date as month-year
    static func monthYearString(from date: Date) -> String {
        return monthYearFormatter.string(from: date)
    }
}

