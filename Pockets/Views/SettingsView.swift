//
//  SettingsView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

/// Settings and app information view
struct SettingsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.accent)
                                .frame(width: 32, height: 32)
                                .background(AppTheme.accent.opacity(0.15))
                                .clipShape(Circle())
                            
                            Text("Local Storage")
                                .foregroundColor(AppTheme.primaryText)
                                .font(.system(size: 17))
                            
                            Spacer()
                            
                            Text("Secure")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.success)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.success.opacity(0.15))
                                .cornerRadius(8)
                        }
                    } header: {
                        Text("Storage")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("Your data is stored securely on your device. No cloud sync required.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        NavigationLink {
                            CategoriesView(viewModel: viewModel)
                        } label: {
                            Label {
                                Text("Categories")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        
                        NavigationLink {
                            NotificationSettingsView(viewModel: viewModel)
                        } label: {
                            Label {
                                Text("Notifications")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        
                        NavigationLink {
                            CurrencySettingsView()
                        } label: {
                            Label {
                                Text("Currency")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                    } header: {
                        Text("Data")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        NavigationLink {
                            FAQView()
                        } label: {
                            Label {
                                Text("FAQ")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        
                        NavigationLink {
                            ContactView()
                        } label: {
                            Label {
                                Text("Contact")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                    } header: {
                        Text("Support")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundColor(AppTheme.primaryText)
                            Spacer()
                            Text("1.0")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        
                        Link(destination: URL(string: "https://apps.apple.com")!) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(AppTheme.accent)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                        
                        Link(destination: URL(string: "https://apps.apple.com")!) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(AppTheme.accent)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    } header: {
                        Text("About")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        Button {
                            Haptics.warning()
                            showingResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(AppTheme.error)
                                    .font(.system(size: 17))
                                Text("Reset All Data")
                                    .foregroundColor(AppTheme.error)
                                    .font(.system(size: 17))
                                Spacer()
                            }
                        }
                    } header: {
                        Text("Danger Zone")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("This will permanently delete all expenses, categories, budgets, recurring expenses, and notification settings. This action cannot be undone.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                // App Logo
                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(20)
                                    .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
                                
                                Text("Pockets")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.primaryText)
                                Text("Minimal Expense Tracker")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.secondaryText)
                                Text("© 2025 Evank-WC")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.tertiaryText)
                                    .padding(.top, 4)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingResetAlert) {
                ResetConfirmationView(
                    isPresented: $showingResetAlert,
                    onConfirm: {
                        viewModel.resetAllData()
                    }
                )
            }
        }
    }
}

struct ResetConfirmationView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    @State private var confirmationText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Warning Icon
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.error)
                        .padding(.top, 40)
                    
                    // Warning Message
                    VStack(spacing: 12) {
                        Text("Reset All Data")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("This will permanently delete all expenses, categories, budgets, recurring expenses, and notification settings.")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text("This action cannot be undone.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.error)
                    }
                    
                    Spacer()
                    
                    // Confirmation Input
                    VStack(spacing: 16) {
                        Text("Type 'RESETTHEAPP' to confirm:")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.secondaryText)
                        
                        TextField("RESETTHEAPP", text: $confirmationText)
                            .autocapitalization(.allCharacters)
                            .autocorrectionDisabled()
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.primaryText)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(confirmationText == "RESETTHEAPP" ? AppTheme.error : AppTheme.tertiaryText.opacity(0.3), lineWidth: 2)
                            )
                            .focused($isTextFieldFocused)
                            .onAppear {
                                isTextFieldFocused = true
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button {
                            onConfirm()
                            isPresented = false
                        } label: {
                            Text("Reset All Data")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(confirmationText == "RESETTHEAPP" ? AppTheme.error : AppTheme.tertiaryText.opacity(0.3))
                                .cornerRadius(16)
                        }
                        .disabled(confirmationText != "RESETTHEAPP")
                        
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .presentationDetents([.large])
    }
}

#Preview {
    SettingsView(viewModel: ExpenseViewModel())
        .preferredColorScheme(.dark)
}
