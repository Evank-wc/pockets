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
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
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
        content.badge = 1
        
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
        guard enabled, budget > 0 else { return }
        
        let progress = (currentSpending / budget).doubleValue
        
        if progress >= threshold && progress < 1.0 {
            let content = UNMutableNotificationContent()
            content.title = "Budget Warning"
            content.body = String(format: "You've spent %.0f%% of your monthly budget", progress * 100)
            content.sound = .default
            content.userInfo = ["type": "budget"]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: NotificationID.budgetAlert + "_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error sending budget alert: \(error.localizedDescription)")
                }
            }
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
}

