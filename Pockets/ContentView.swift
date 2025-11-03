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
    @State private var swipeDirection: SwipeDirection = .none
    
    enum SwipeDirection {
        case left, right, none
    }
    
    // Visual tab order: Dashboard (1), History (2), Recurring (0), Settings (3)
    // Map visual position to tab number: [Dashboard=0, History=1, Recurring=2, Settings=3]
    private func getVisualPosition(for tab: Int) -> Int {
        switch tab {
        case 1: return 0  // Dashboard is first visually
        case 2: return 1  // History is second
        case 0: return 2  // Recurring is third
        case 3: return 3  // Settings is fourth
        default: return 0
        }
    }
    
    private func transitionForTab() -> AnyTransition {
        let direction: Edge = {
            if swipeDirection == .left {
                return .trailing // New page comes from right (swipe left = forward)
            } else if swipeDirection == .right {
                return .leading // New page comes from left (swipe right = backward)
            } else {
                // Default: determine direction based on visual position order
                let prevPos = getVisualPosition(for: previousTab)
                let newPos = getVisualPosition(for: selectedTab)
                return newPos > prevPos ? .trailing : .leading
            }
        }()
        
        return .asymmetric(
            insertion: .move(edge: direction).combined(with: .opacity),
            removal: .move(edge: direction == .trailing ? .leading : .trailing).combined(with: .opacity)
        )
    }
    
    private func getNextTab() -> Int? {
        switch selectedTab {
        case 1: return 2  // Dashboard -> History
        case 2: return 0  // History -> Recurring
        case 0: return 3  // Recurring -> Settings
        case 3: return nil // Settings is last
        default: return nil
        }
    }
    
    private func getPreviousTab() -> Int? {
        switch selectedTab {
        case 1: return nil // Dashboard is first
        case 2: return 1   // History -> Dashboard
        case 0: return 2   // Recurring -> History
        case 3: return 0   // Settings -> Recurring
        default: return nil
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background.ignoresSafeArea()
            
            // Tab content with transitions and swipe gesture
            Group {
                if selectedTab == 0 {
                    RecurringView(viewModel: viewModel)
                        .transition(transitionForTab())
                } else if selectedTab == 1 {
                    DashboardView(viewModel: viewModel)
                        .transition(transitionForTab())
                } else if selectedTab == 2 {
                    HistoryView(viewModel: viewModel)
                        .transition(transitionForTab())
                } else if selectedTab == 3 {
                    SettingsView(viewModel: viewModel)
                        .transition(transitionForTab())
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: selectedTab)
            .simultaneousGesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        
                        // Only trigger if horizontal swipe is significantly more than vertical
                        if abs(horizontalAmount) > abs(verticalAmount) && abs(horizontalAmount) > 100 {
                            // Horizontal swipe
                            if horizontalAmount > 0 {
                                // Swipe right - go to previous tab (in visual order)
                                if let previous = getPreviousTab() {
                                    swipeDirection = .right
                                    Haptics.selection()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                        selectedTab = previous
                                    }
                                }
                            } else {
                                // Swipe left - go to next tab (in visual order)
                                if let next = getNextTab() {
                                    swipeDirection = .left
                                    Haptics.selection()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                        selectedTab = next
                                    }
                                }
                            }
                        }
                    }
            )
            .onChange(of: selectedTab) { oldValue, newValue in
                previousTab = oldValue
                // Reset swipe direction after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    swipeDirection = .none
                }
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
                            let prevPos = getVisualPosition(for: selectedTab)
                            let newPos = getVisualPosition(for: 1)
                            swipeDirection = newPos > prevPos ? .left : .right
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
                            let prevPos = getVisualPosition(for: selectedTab)
                            let newPos = getVisualPosition(for: 2)
                            swipeDirection = newPos > prevPos ? .left : .right
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
                            let prevPos = getVisualPosition(for: selectedTab)
                            let newPos = getVisualPosition(for: 0)
                            swipeDirection = newPos > prevPos ? .left : .right
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
                            let prevPos = getVisualPosition(for: selectedTab)
                            let newPos = getVisualPosition(for: 3)
                            swipeDirection = newPos > prevPos ? .left : .right
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
