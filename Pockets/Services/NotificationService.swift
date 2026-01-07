//
//  NotificationService.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation
import UserNotifications

/// Service for managing app notifications
class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    // Notification identifiers
    private enum NotificationID {
        static let dailyReminder = "dailyExpenseReminder"
        static let budgetAlert = "budgetAlert"
        static let subscriptionPrefix = "subscription_"
    }
    
    private init() {}
    
    // MARK: - Permission
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Daily Reminder
    
    func scheduleDailyReminder(enabled: Bool, hour: Int = 20, minute: Int = 0) {
        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyReminder])
        
        guard enabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Track Your Expenses"
        content.body = "Don't forget to log your expenses for today!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.dailyReminder, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Budget Alert
    
    func scheduleBudgetAlert(enabled: Bool, threshold: Double = 0.8) {
        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.budgetAlert])
        
        guard enabled else { return }
        
        // Schedule check for budget threshold
        // This will need to be called when expenses are updated
        // For now, we'll schedule a daily check
        let content = UNMutableNotificationContent()
        content.title = "Budget Warning"
        content.body = "You're approaching your monthly budget limit."
        content.sound = .default
        content.userInfo = ["type": "budget", "threshold": threshold]
        
        // Schedule a daily check (this will be triggered programmatically when checking expenses)
        // We'll use a time interval trigger as a placeholder that gets updated
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.budgetAlert, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling budget alert: \(error.localizedDescription)")
            }
        }
    }
    
    func checkBudgetThreshold(currentSpending: Decimal, budget: Decimal, threshold: Double = 0.8, enabled: Bool) {
        print("🔎 NotificationService.checkBudgetThreshold() called")
        print("   Parameters: spending=\(currentSpending), budget=\(budget), threshold=\(threshold * 100)%, enabled=\(enabled)")
        
        guard enabled, budget > 0 else {
            print("⚠️ Budget notification check skipped: enabled=\(enabled), budget=\(budget)")
            return
        }
        
        let progress = (currentSpending / budget).doubleValue
        print("📊 Calculated progress: \(String(format: "%.2f", progress * 100))%")
        print("   (Spending: \(currentSpending) / Budget: \(budget) = \(progress))")
        
        // Check if we should send a notification
        // Send notification if spending has crossed the threshold OR exceeded the budget
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let monthKey = "budgetAlert_\(currentYear)_\(currentMonth)"
        
        // Track notifications separately for threshold and budget milestones
        let thresholdNotifiedKey = "\(monthKey)_threshold_notified"
        let budgetNotifiedKey = "\(monthKey)_budget_notified"
        
        let thresholdNotified = UserDefaults.standard.bool(forKey: thresholdNotifiedKey)
        let budgetNotified = UserDefaults.standard.bool(forKey: budgetNotifiedKey)
        
        print("📝 Notification tracking keys:")
        print("   - Threshold key: \(thresholdNotifiedKey)")
        print("   - Budget key: \(budgetNotifiedKey)")
        print("📝 Notification status:")
        print("   - Threshold notified: \(thresholdNotified)")
        print("   - Budget notified: \(budgetNotified)")
        
        // Reset tracking if spending has dropped below the threshold
        // This allows re-notification if spending increases again
        if progress < threshold {
            if thresholdNotified {
                print("🔄 Spending dropped below threshold, resetting threshold notification tracking")
                UserDefaults.standard.set(false, forKey: thresholdNotifiedKey)
            }
            if budgetNotified {
                print("🔄 Spending dropped below budget, resetting budget notification tracking")
                UserDefaults.standard.set(false, forKey: budgetNotifiedKey)
            }
        }
        
        // Determine if we should notify
        // Notify if:
        // 1. We've reached or exceeded the threshold AND we haven't notified for threshold yet
        // 2. We've exceeded the budget (100%) AND we haven't notified for budget yet
        let crossedThreshold = progress >= threshold && !thresholdNotified
        let exceededBudget = progress >= 1.0 && !budgetNotified
        
        let shouldNotify = crossedThreshold || exceededBudget
        
        print("🔔 Notification decision:")
        print("   - Progress >= threshold (\(threshold * 100)%): \(progress >= threshold)")
        print("   - Progress >= 100%: \(progress >= 1.0)")
        print("   - Crossed threshold: \(crossedThreshold)")
        print("   - Exceeded budget: \(exceededBudget)")
        print("   - Should notify: \(shouldNotify)")
        
        if shouldNotify {
            // Check notification authorization
            center.getNotificationSettings { [weak self] settings in
                guard let self = self else { return }
                
                guard settings.authorizationStatus == .authorized else {
                    print("⚠️ Budget notification skipped: notifications not authorized (status: \(settings.authorizationStatus.rawValue))")
                    print("   Please enable notifications in Settings > Pockets > Notifications")
                    return
                }
                
                let content = UNMutableNotificationContent()
                
                if progress >= 1.0 {
                    let overBudgetPercent = (progress - 1.0) * 100
                    content.title = "Budget Exceeded"
                    if overBudgetPercent > 0 {
                        content.body = String(format: "You've exceeded your monthly budget by %.0f%%", overBudgetPercent)
                    } else {
                        content.body = "You've reached your monthly budget limit"
                    }
                } else {
                    content.title = "Budget Warning"
                    content.body = String(format: "You've spent %.0f%% of your monthly budget", progress * 100)
                }
                
                content.sound = .default
                content.userInfo = ["type": "budget", "progress": progress, "threshold": threshold]
                
                // Schedule notification to appear 1 minute after the transaction
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                let uniqueID = NotificationID.budgetAlert + "_\(Date().timeIntervalSince1970)"
                let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
                
                print("📤 Scheduling notification...")
                print("   - Trigger: 60 seconds from now")
                print("   - Unique ID: \(uniqueID)")
                
                self.center.add(request) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ ERROR scheduling budget alert:")
                            print("   \(error.localizedDescription)")
                        } else {
                            // Track that we've sent notifications for the appropriate milestones
                            if progress >= 1.0 {
                                UserDefaults.standard.set(true, forKey: budgetNotifiedKey)
                                print("✅ Budget exceeded notification scheduled successfully!")
                                print("   - Type: Budget Exceeded")
                            } else if progress >= threshold {
                                UserDefaults.standard.set(true, forKey: thresholdNotifiedKey)
                                print("✅ Budget threshold notification scheduled successfully!")
                                print("   - Type: Budget Warning")
                            }
                            
                            // Also track the progress for debugging
                            UserDefaults.standard.set(progress, forKey: "\(monthKey)_progress")
                            print("📬 Notification details:")
                            print("   - Title: \(content.title)")
                            print("   - Body: \(content.body)")
                            print("   - Notification ID: \(uniqueID)")
                            print("   - Will appear in: 1 minute")
                        }
                    }
                }
            }
        } else {
            print("⏭️ Skipping notification:")
            print("   - Reason: Already notified for this threshold/budget milestone")
            print("   - Threshold notified: \(thresholdNotified)")
            print("   - Budget notified: \(budgetNotified)")
            print("   - Current progress: \(String(format: "%.2f", progress * 100))%")
        }
    }
    
    // MARK: - Subscription Alerts
    
    func scheduleSubscriptionAlert(recurring: RecurringExpense, enabled: Bool) {
        let identifier = NotificationID.subscriptionPrefix + recurring.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        guard enabled, recurring.isActive else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate next occurrence
        let currentDay = calendar.component(.day, from: now)
        let targetDay = recurring.dayOfMonth
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        if currentDay < targetDay {
            // This month
            dateComponents.day = targetDay
        } else {
            // Next month
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) {
                dateComponents = calendar.dateComponents([.year, .month, .day], from: nextMonth)
                dateComponents.day = targetDay
            }
        }
        
        // Adjust for last day of month if needed
        if let targetDate = calendar.date(from: dateComponents) {
            // Check if date exists (e.g., Feb 30 doesn't exist)
            if calendar.component(.day, from: targetDate) != targetDay {
                // Use last day of month
                if let monthRange = calendar.range(of: .day, in: .month, for: targetDate),
                   let lastDay = monthRange.last {
                    dateComponents.day = lastDay
                }
            }
        }
        
        guard let notificationDate = calendar.date(from: dateComponents) else { return }
        
        // Schedule reminder 1 day before
        if let reminderDate = calendar.date(byAdding: .day, value: -1, to: notificationDate),
           reminderDate > now {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming Subscription"
            content.body = "\(recurring.name) - \(AppFormatter.currencyString(from: recurring.amount))"
            content.sound = .default
            content.userInfo = ["type": "subscription", "id": recurring.id.uuidString]
            
            let dateComponentsReminder = calendar.dateComponents([.year, .month, .day, .hour], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsReminder, repeats: false)
            let request = UNNotificationRequest(identifier: identifier + "_reminder", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling subscription reminder: \(error.localizedDescription)")
                }
            }
        }
        
        // Also schedule on the day itself
        if notificationDate > now {
            let content = UNMutableNotificationContent()
            content.title = "Subscription Due Today"
            content.body = "\(recurring.name) - \(AppFormatter.currencyString(from: recurring.amount))"
            content.sound = .default
            content.userInfo = ["type": "subscription", "id": recurring.id.uuidString]
            
            var dateComponentsOnDay = calendar.dateComponents([.year, .month, .day, .hour], from: notificationDate)
            dateComponentsOnDay.hour = 9 // 9 AM
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsOnDay, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling subscription alert: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateAllSubscriptionAlerts(recurringExpenses: [RecurringExpense], enabled: Bool) {
        // Remove all subscription notifications
        center.getPendingNotificationRequests { requests in
            let subscriptionIDs = requests.filter { $0.identifier.hasPrefix(NotificationID.subscriptionPrefix) }.map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: subscriptionIDs)
        }
        
        guard enabled else { return }
        
        // Reschedule all active subscriptions
        for recurring in recurringExpenses {
            scheduleSubscriptionAlert(recurring: recurring, enabled: true)
        }
    }
    
    // MARK: - Cancel All
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Budget Alert Tracking
    
    /// Clears budget alert tracking for old months (keeps only current month)
    func clearOldBudgetAlertTracking() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        // Remove tracking for all months except current
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys
        
        for key in keys {
            if key.hasPrefix("budgetAlert_") && !key.contains("_\(currentYear)_\(currentMonth)") {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    /// Resets notification tracking flags for the current month
    /// Call this when budget or threshold changes to allow re-notification
    func resetCurrentMonthBudgetTracking() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let monthKey = "budgetAlert_\(currentYear)_\(currentMonth)"
        
        let thresholdNotifiedKey = "\(monthKey)_threshold_notified"
        let budgetNotifiedKey = "\(monthKey)_budget_notified"
        let progressKey = "\(monthKey)_progress"
        
        UserDefaults.standard.set(false, forKey: thresholdNotifiedKey)
        UserDefaults.standard.set(false, forKey: budgetNotifiedKey)
        UserDefaults.standard.removeObject(forKey: progressKey)
        
        print("🔄 Reset budget notification tracking for current month")
        print("   - Threshold notified: false")
        print("   - Budget notified: false")
        print("   - Progress tracking cleared")
    }
}

