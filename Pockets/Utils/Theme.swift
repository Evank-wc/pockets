//
//  Theme.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

/// Modern dark theme colors and design tokens
struct AppTheme {
    // MARK: - Background Colors
    static let background = Color(hex: "000000")
    static let cardBackground = Color(hex: "1C1C1E")
    static let secondaryBackground = Color(hex: "2C2C2E")
    static let tertiaryBackground = Color(hex: "3A3A3C")
    
    // MARK: - Accent Colors
    static let accent = Color(hex: "007AFF")
    static let accentLight = Color(hex: "5AC8FA")
    static let accentDark = Color(hex: "0051D5")
    
    // MARK: - Text Colors (Easier on the eyes)
    static let primaryText = Color(hex: "F2F2F7")  // Softer white
    static let secondaryText = Color(hex: "AEAEB2") // Softer gray
    static let tertiaryText = Color(hex: "8E8E93")  // Softer dark gray
    
    // MARK: - Status Colors
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
    static let info = Color(hex: "5AC8FA")
    
    // MARK: - Category Colors (Modern palette)
    static let categoryColors: [Color] = [
        Color(hex: "5E5CE6"), // Purple
        Color(hex: "64D2FF"), // Cyan
        Color(hex: "30D158"), // Green
        Color(hex: "FF9F0A"), // Orange
        Color(hex: "FF375F"), // Pink
        Color(hex: "BF5AF2"), // Purple
        Color(hex: "00C7BE"), // Teal
        Color(hex: "FF453A"), // Red
    ]
    
    // MARK: - Shadows
    static let cardShadow = Color.black.opacity(0.3)
    static let buttonShadow = Color.black.opacity(0.4)
    
    // MARK: - Animation Constants
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.25)
    static let smoothAnimation = Animation.easeInOut(duration: 0.3)
    static let quickAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

