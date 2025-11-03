//
//  NotificationPermissionView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Visual Content
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 140, height: 140)
                    .background(AppTheme.accent.opacity(0.15))
                    .clipShape(Circle())
            }
            .padding(.bottom, 40)
            
            // Text Content
            VStack(spacing: 24) {
                Text("Stay on track")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("Turn on reminders to log expenses and stay within your budget.\n\nNo spam — just helpful nudges.")
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // CTA Buttons
            VStack(spacing: 12) {
                Button {
                    Haptics.medium()
                    requestNotificationPermission()
                } label: {
                    Text("Enable Notifications")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                Button {
                    Haptics.light()
                    skipNotificationPermission()
                } label: {
                    Text("Maybe later")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    private func requestNotificationPermission() {
        NotificationService.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                // Move to main app regardless of permission result
                skipNotificationPermission()
            }
        }
    }
    
    private func skipNotificationPermission() {
        // Mark onboarding as complete in UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
    }
}

