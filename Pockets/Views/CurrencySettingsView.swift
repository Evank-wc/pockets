//
//  CurrencySettingsView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct CurrencySettingsView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    Section {
                        ForEach(currencyManager.availableCurrencies, id: \.code) { currency in
                            Button {
                                Haptics.selection()
                                currencyManager.selectedCurrencyCode = currency.code
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currency.name)
                                            .font(.system(size: 17))
                                            .foregroundColor(AppTheme.primaryText)
                                        Text(currency.code)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    if currencyManager.selectedCurrencyCode == currency.code {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        Text("Select Currency")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("Currency selection affects how all amounts are displayed throughout the app.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onReceive(NotificationCenter.default.publisher(for: .currencyDidChange)) { _ in
            // Refresh views when currency changes
        }
    }
}

#Preview {
    CurrencySettingsView()
        .preferredColorScheme(.dark)
}

