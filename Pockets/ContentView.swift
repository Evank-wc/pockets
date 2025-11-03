//
//  ContentView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @StateObject private var viewModel: ExpenseViewModel = {
        // Initialize with error handling
        do {
            return ExpenseViewModel()
        } catch {
            // If initialization fails, return a new instance
            // (init doesn't throw, but being defensive)
            return ExpenseViewModel()
        }
    }()
    @State private var selectedTab = 1 // Dashboard in center
    @State private var previousTab = 1
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background.ignoresSafeArea()
            
            // Tab content with transitions
            Group {
                if selectedTab == 0 {
                    RecurringView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab < selectedTab ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: previousTab < selectedTab ? .leading : .trailing).combined(with: .opacity)
                        ))
                } else if selectedTab == 1 {
                    DashboardView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab < selectedTab ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: previousTab < selectedTab ? .leading : .trailing).combined(with: .opacity)
                        ))
                } else if selectedTab == 2 {
                    HistoryView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab < selectedTab ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: previousTab < selectedTab ? .leading : .trailing).combined(with: .opacity)
                        ))
                } else if selectedTab == 3 {
                    SettingsView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: previousTab < selectedTab ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: previousTab < selectedTab ? .leading : .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: selectedTab)
            .onChange(of: selectedTab) { oldValue, newValue in
                previousTab = oldValue
            }
            
            // Bottom tab bar
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    TabBarButton(
                        icon: "chart.bar.fill",
                        label: "Dashboard",
                        isSelected: selectedTab == 1,
                        action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                selectedTab = 1
                            }
                        }
                    )
                    
                    TabBarButton(
                        icon: "list.bullet",
                        label: "History",
                        isSelected: selectedTab == 2,
                        action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                selectedTab = 2
                            }
                        }
                    )
                    
                    TabBarButton(
                        icon: "repeat",
                        label: "Recurring",
                        isSelected: selectedTab == 0,
                        action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                selectedTab = 0
                            }
                        }
                    )
                    
                    TabBarButton(
                        icon: "gearshape.fill",
                        label: "Settings",
                        isSelected: selectedTab == 3,
                        action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                selectedTab = 3
                            }
                        }
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadow.opacity(0.3), radius: 10, x: 0, y: -5)
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(.dark)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.accent : AppTheme.secondaryText)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.accent : AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    #Preview {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
