//
//  CurrencyManager.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation

/// Manages currency selection and formatting preferences
class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    @Published var selectedCurrencyCode: String {
        didSet {
            UserDefaults.standard.set(selectedCurrencyCode, forKey: "selectedCurrencyCode")
            NotificationCenter.default.post(name: .currencyDidChange, object: nil)
        }
    }
    
    private let currencyCodes: [String] = [
        "USD", "EUR", "GBP", "JPY", "CNY", "AUD", "CAD", "CHF", "HKD", "SGD",
        "SEK", "NOK", "DKK", "NZD", "MXN", "INR", "BRL", "ZAR", "KRW", "TRY"
    ]
    
    var availableCurrencies: [(code: String, name: String)] {
        currencyCodes.map { code in
            // Get currency name from locale
            let name = Locale.current.localizedString(forCurrencyCode: code) ?? code
            return (code: code, name: "\(code) - \(name)")
        }
    }
    
    var currencyLocale: Locale {
        // Use current locale but ensure currency code is set
        // NumberFormatter will use the currency code we set, locale mainly affects language
        return Locale.current
    }
    
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrencyCode
        formatter.locale = Locale.current
        return formatter
    }
    
    private init() {
        // Default to device locale currency or USD
        if let savedCode = UserDefaults.standard.string(forKey: "selectedCurrencyCode") {
            selectedCurrencyCode = savedCode
        } else if let deviceCurrency = Locale.current.currencyCode {
            selectedCurrencyCode = deviceCurrency
        } else {
            selectedCurrencyCode = "USD"
        }
    }
    
    func currencySymbol(for code: String) -> String {
        // Create a temporary formatter to get the symbol
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.currencySymbol ?? code
    }
    
    func currencyName(for code: String) -> String {
        return Locale.current.localizedString(forCurrencyCode: code) ?? code
    }
}

extension Notification.Name {
    static let currencyDidChange = Notification.Name("currencyDidChange")
}

