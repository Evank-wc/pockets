//
//  NotificationSettingsView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @StateObject private var notificationManager = NotificationSettingsManager.shared
    
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                List {
                    // Daily Reminder Section
                    Section {
                        Toggle(isOn: $notificationManager.dailyReminderEnabled) {
                            Label {
                                Text("Daily Reminder")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        .onChange(of: notificationManager.dailyReminderEnabled) { _, newValue in
                            notificationManager.updateDailyReminder(enabled: newValue)
                        }
                        
                        if notificationManager.dailyReminderEnabled {
                            DatePicker("Time", selection: $notificationManager.dailyReminderTime, displayedComponents: .hourAndMinute)
                                .foregroundColor(AppTheme.primaryText)
                                .onChange(of: notificationManager.dailyReminderTime) { _, _ in
                                    notificationManager.updateDailyReminder(enabled: true)
                                }
                        }
                    } header: {
                        Text("Daily Reminder")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("Get reminded to log your expenses each day.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    // Budget Alert Section
                    Section {
                        Toggle(isOn: $notificationManager.budgetAlertEnabled) {
                            Label {
                                Text("Budget Warning")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.warning)
                            }
                        }
                        .onChange(of: notificationManager.budgetAlertEnabled) { _, newValue in
                            notificationManager.updateBudgetAlert(enabled: newValue)
                        }
                        
                        if notificationManager.budgetAlertEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Alert Threshold")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.secondaryText)
                                
                                HStack {
                                    Slider(
                                        value: $notificationManager.budgetThreshold,
                                        in: 0.5...0.95,
                                        step: 0.05
                                    )
                                    .tint(AppTheme.accent)
                                    
                                    Text("\(Int(notificationManager.budgetThreshold * 100))%")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryText)
                                        .frame(minWidth: 50, alignment: .trailing)
                                }
                            }
                            .padding(.vertical, 4)
                            .onChange(of: notificationManager.budgetThreshold) { _, _ in
                                notificationManager.updateBudgetAlert(enabled: true)
                            }
                        }
                    } header: {
                        Text("Budget Alerts")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("Get notified when you're approaching your monthly budget limit.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    // Subscription Alerts Section
                    Section {
                        Toggle(isOn: $notificationManager.subscriptionAlertsEnabled) {
                            Label {
                                Text("Subscription Reminders")
                                    .foregroundColor(AppTheme.primaryText)
                            } icon: {
                                Image(systemName: "repeat.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        .onChange(of: notificationManager.subscriptionAlertsEnabled) { _, newValue in
                            notificationManager.updateSubscriptionAlerts(enabled: newValue, recurringExpenses: viewModel.recurringExpenses)
                        }
                    } header: {
                        Text("Subscriptions")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("Receive reminders for upcoming recurring expenses and subscriptions.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationPermissions()
            }
            .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive reminders and alerts.")
            }
        }
    }
    
    private func checkNotificationPermissions() {
        NotificationService.shared.checkAuthorizationStatus { status in
            if status == .denied {
                showingPermissionAlert = true
            } else if status == .notDetermined {
                NotificationService.shared.requestAuthorization { granted in
                    if !granted {
                        showingPermissionAlert = true
                    }
                }
            }
        }
    }
}

/// Manages notification settings and schedules
class NotificationSettingsManager: ObservableObject {
    static let shared = NotificationSettingsManager()
    
    @Published var dailyReminderEnabled: Bool {
        didSet { UserDefaults.standard.set(dailyReminderEnabled, forKey: "notificationDailyReminder") }
    }
    
    @Published var dailyReminderTime: Date {
        didSet {
            UserDefaults.standard.set(dailyReminderTime, forKey: "notificationDailyReminderTime")
            // Only update if manager is fully initialized
            if isInitialized {
                updateDailyReminder(enabled: dailyReminderEnabled)
            }
        }
    }
    
    @Published var budgetAlertEnabled: Bool {
        didSet { UserDefaults.standard.set(budgetAlertEnabled, forKey: "notificationBudgetAlert") }
    }
    
    @Published var budgetThreshold: Double {
        didSet { UserDefaults.standard.set(budgetThreshold, forKey: "notificationBudgetThreshold") }
    }
    
    @Published var subscriptionAlertsEnabled: Bool {
        didSet { UserDefaults.standard.set(subscriptionAlertsEnabled, forKey: "notificationSubscriptionAlerts") }
    }
    
    private let notificationService = NotificationService.shared
    private var isInitialized = false
    
    private init() {
        // Load from UserDefaults
        dailyReminderEnabled = UserDefaults.standard.bool(forKey: "notificationDailyReminder")
        
        // Compute default time first
        let defaultTime: Date
        if let savedTime = UserDefaults.standard.object(forKey: "notificationDailyReminderTime") as? Date {
            defaultTime = savedTime
        } else {
            // Default to 8 PM
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            defaultTime = Calendar.current.date(from: components) ?? Date()
        }
        
        budgetAlertEnabled = UserDefaults.standard.bool(forKey: "notificationBudgetAlert")
        
        // Compute threshold value first
        let threshold = UserDefaults.standard.double(forKey: "notificationBudgetThreshold")
        let finalThreshold = threshold == 0 ? 0.8 : threshold
        
        subscriptionAlertsEnabled = UserDefaults.standard.bool(forKey: "notificationSubscriptionAlerts")
        
        // Now assign after all computations
        dailyReminderTime = defaultTime
        budgetThreshold = finalThreshold
        
        // Mark as initialized so didSet can work properly
        isInitialized = true
    }
    
    func updateDailyReminder(enabled: Bool) {
        if enabled {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: dailyReminderTime)
            notificationService.scheduleDailyReminder(
                enabled: true,
                hour: components.hour ?? 20,
                minute: components.minute ?? 0
            )
        } else {
            notificationService.scheduleDailyReminder(enabled: false)
        }
    }
    
    func updateBudgetAlert(enabled: Bool) {
        notificationService.scheduleBudgetAlert(enabled: enabled, threshold: budgetThreshold)
    }
    
    func updateSubscriptionAlerts(enabled: Bool, recurringExpenses: [RecurringExpense]) {
        notificationService.updateAllSubscriptionAlerts(recurringExpenses: recurringExpenses, enabled: enabled)
    }
}

