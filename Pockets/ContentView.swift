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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecurringView(viewModel: viewModel)
                .tabItem {
                    Label("Recurring", systemImage: "repeat")
                }
                .tag(0)
            
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
                .tag(2)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
