//
//  OnboardingView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showingNotificationPermission = false
    @Binding var hasCompletedOnboarding: Bool
    var isStandalone: Bool = false
    
    init(hasCompletedOnboarding: Binding<Bool>, isStandalone: Bool = false) {
        self._hasCompletedOnboarding = hasCompletedOnboarding
        self.isStandalone = isStandalone
    }
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            if showingNotificationPermission && !isStandalone {
                NotificationPermissionView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                TabView(selection: $currentPage) {
                    WelcomeOnboardingView(currentPage: $currentPage)
                        .tag(0)
                    
                    TrackExpensesOnboardingView(currentPage: $currentPage)
                        .tag(1)
                    
                    SeeMoneyOnboardingView(currentPage: $currentPage)
                        .tag(2)
                    
                    PrivateOnboardingView(currentPage: $currentPage)
                        .tag(3)
                    
                    FreeOnboardingView(
                        currentPage: $currentPage,
                        showingNotificationPermission: $showingNotificationPermission,
                        isStandalone: isStandalone
                    )
                        .tag(4)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all, edges: .top)
    }
}

// MARK: - Shared Onboarding Page Style (with swipe hint)
struct OnboardingPageStyle<Content: View>: View {
    let title: String
    let bodyText: String
    let ctaText: String?
    let ctaAction: (() -> Void)?
    let secondaryCtaText: String?
    let secondaryCtaAction: (() -> Void)?
    let showSwipeHint: Bool
    @ViewBuilder let visualContent: Content
    
    init(
        title: String,
        bodyText: String,
        ctaText: String? = nil,
        ctaAction: (() -> Void)? = nil,
        secondaryCtaText: String? = nil,
        secondaryCtaAction: (() -> Void)? = nil,
        showSwipeHint: Bool = true,
        @ViewBuilder visualContent: () -> Content
    ) {
        self.title = title
        self.bodyText = bodyText
        self.ctaText = ctaText
        self.ctaAction = ctaAction
        self.secondaryCtaText = secondaryCtaText
        self.secondaryCtaAction = secondaryCtaAction
        self.showSwipeHint = showSwipeHint
        self.visualContent = visualContent()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 40)
                
                // Visual Content
                visualContent
                    .padding(.bottom, 40)
                
                // Text Content
                VStack(spacing: 24) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                    
                    Text(bodyText)
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                }
                
                // CTA Button (if provided) - inside scrollable
                if let ctaText = ctaText, let ctaAction = ctaAction {
                    VStack(spacing: 12) {
                        Button {
                            Haptics.medium()
                            ctaAction()
                        } label: {
                            HStack {
                                Text(ctaText)
                                    .font(.system(size: 17, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(AppTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.accent)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                        
                        if let secondaryText = secondaryCtaText, let secondaryAction = secondaryCtaAction {
                            Button {
                                Haptics.light()
                                secondaryAction()
                            } label: {
                                Text(secondaryText)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                    }
                    .padding(.bottom, 60)
                } else if showSwipeHint {
                    // Swipe hint for pages without buttons
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText.opacity(0.6))
                            .rotationEffect(.degrees(-30))
                        
                        Text("Swipe to continue")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.secondaryText.opacity(0.6))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                } else {
                    Spacer(minLength: 60)
                }
            }
        }
    }
}

// MARK: - Page 1: Welcome
struct WelcomeOnboardingView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        OnboardingPageStyle(
            title: "Welcome to Pockets",
            bodyText: "A simple, private way to track your spending and stay on top of your money.\n\nNo ads. No subscriptions. \n\nNo data tracking.\n\nJust you and your wallet.",
            showSwipeHint: true
        ) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .cornerRadius(28)
                .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Page 2: Track Expenses
struct TrackExpensesOnboardingView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        OnboardingPageStyle(
            title: "Track expenses in seconds",
            bodyText: "Record your spending with a clean interface, custom categories, and a smooth numeric keypad.\n\nFast. Simple. No clutter.",
            showSwipeHint: true
        ) {
            VStack(spacing: 20) {
                // Mock Add Expense Screen
                VStack(spacing: 12) {
                    // Amount Display
                    Text("$45.99")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .monospacedDigit()
                        .frame(height: 60)
                    
                    // Keypad Mock
                    VStack(spacing: 8) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 8) {
                                ForEach(1..<4) { col in
                                    let number = row * 3 + col
                                    Text("\(number)")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(AppTheme.primaryText)
                                        .frame(width: 60, height: 60)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        HStack(spacing: 8) {
                            Text(".")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(AppTheme.primaryText)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)
                            Text("0")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(AppTheme.primaryText)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)
                            Image(systemName: "delete.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.accent)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.accent.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
                .background(AppTheme.cardBackground)
                .cornerRadius(20)
                .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                .frame(width: 280)
            }
        }
    }
}

// MARK: - Page 3: See Money Clearly
struct SeeMoneyOnboardingView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        OnboardingPageStyle(
            title: "Understand your habits",
            bodyText: "Dashboard insights, monthly charts, and a calendar view help you see where your money goes — and stay in control.",
            showSwipeHint: true
        ) {
            HStack(spacing: 16) {
                // Mock Chart
                HStack(spacing: 16) {
                    ForEach(0..<5) { index in
                        VStack(spacing: 0) {
                            Spacer()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppTheme.accent)
                                .frame(width: 30, height: CGFloat(40 + index * 15))
                            
                            Text(["Mon", "Tue", "Wed", "Thu", "Fri"][index])
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.secondaryText)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
                .frame(width: 140)
                .padding(20)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                
                // Mock Calendar
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                            Text(day)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    ForEach(0..<2) { week in
                        HStack(spacing: 0) {
                            ForEach(0..<7) { day in
                                Text("\(week * 7 + day + 1)")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 32)
                                    .background(day == 3 ? AppTheme.accent.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .frame(width: 140)
                .padding(.vertical, 12)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - Page 4: Private by Default
struct PrivateOnboardingView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        OnboardingPageStyle(
            title: "Your data stays with you",
            bodyText: "Everything is stored locally on your device.\n\nNo accounts. No servers. No one looking over your shoulder.\n\nYour money, your business.",
            showSwipeHint: true
        ) {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 140, height: 140)
                    .background(AppTheme.accent.opacity(0.15))
                    .clipShape(Circle())
                
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.error)
                        Text("No Cloud")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.error)
                        Text("No Servers")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.error)
                        Text("No Tracking")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: 280)
            }
        }
    }
}

// MARK: - Page 5: Free Forever
struct FreeOnboardingView: View {
    @Binding var currentPage: Int
    @Binding var showingNotificationPermission: Bool
    var isStandalone: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        OnboardingPageStyle(
            title: "Free today, free forever",
            bodyText: "Built as a passion project, not a business model.\n\nNo subscriptions. No ads. No hidden upsells.\n\nIf you love the app, you can buy me a coffee later — totally optional.",
            ctaText: isStandalone ? "Done" : "Start Using Pockets",
            ctaAction: {
                if isStandalone {
                    dismiss()
                } else {
                    showingNotificationPermission = true
                }
            },
            showSwipeHint: false
        ) {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 120, height: 120)
                    .background(AppTheme.accent.opacity(0.15))
                    .clipShape(Circle())
                
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.success)
                        Text("No Subscriptions")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.success)
                        Text("No Ads")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.success)
                        Text("Free Forever")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: 280)
            }
        }
    }
}

