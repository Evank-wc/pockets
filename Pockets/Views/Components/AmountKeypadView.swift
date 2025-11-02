//
//  AmountKeypadView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

/// Custom numeric keypad for entering expense amounts
struct AmountKeypadView: View {
    @Binding var amount: Decimal
    @State private var displayAmount: String = "0"
    @State private var pressedButton: String? = nil
    
    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Display
            HStack {
                Spacer()
                Text(formatDisplayAmount())
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Keypad
            VStack(spacing: 12) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            KeypadButton(
                                title: button,
                                isPressed: pressedButton == button
                            ) {
                                handleTap(button)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .onAppear {
            updateDisplayAmount()
        }
        .onChange(of: amount) { _, _ in
            withAnimation(AppTheme.springAnimation) {
                updateDisplayAmount()
            }
        }
    }
    
    private func handleTap(_ button: String) {
        Haptics.light()
        
        withAnimation(AppTheme.quickAnimation) {
            pressedButton = button
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(AppTheme.quickAnimation) {
                pressedButton = nil
            }
        }
        
        switch button {
        case "⌫":
            deleteLastDigit()
        case ".":
            if !displayAmount.contains(".") {
                displayAmount += "."
            }
        default:
            if displayAmount == "0" {
                displayAmount = button
            } else {
                displayAmount += button
            }
        }
        
        updateAmount()
    }
    
    private func deleteLastDigit() {
        if displayAmount.count > 1 {
            displayAmount.removeLast()
        } else {
            displayAmount = "0"
        }
        updateAmount()
    }
    
    private func updateAmount() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        if let number = formatter.number(from: displayAmount) {
            withAnimation(AppTheme.springAnimation) {
                amount = number.decimalValue
            }
        }
    }
    
    private func updateDisplayAmount() {
        if amount == 0 {
            displayAmount = "0"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            displayAmount = formatter.string(from: amount as NSDecimalNumber) ?? "0"
        }
    }
    
    private func formatDisplayAmount() -> String {
        return AppFormatter.currencyString(from: amount)
    }
}

struct KeypadButton: View {
    let title: String
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 68)
                .background(
                    Group {
                        if title == "⌫" {
                            AppTheme.secondaryBackground
                        } else {
                            AppTheme.cardBackground
                        }
                    }
                )
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .brightness(isPressed ? -0.1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @State var amount: Decimal = 0
    return ZStack {
        AppTheme.background
        AmountKeypadView(amount: $amount)
            .padding()
    }
    .preferredColorScheme(.dark)
}
