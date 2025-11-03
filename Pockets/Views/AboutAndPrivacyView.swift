//
//  AboutAndPrivacyView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct AboutAndPrivacyView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Tab Selector
                HStack(spacing: 0) {
                    TabButton(title: "Privacy", isSelected: selectedTab == 0) {
                        withAnimation {
                            selectedTab = 0
                        }
                        Haptics.selection()
                    }
                    
                    TabButton(title: "Terms", isSelected: selectedTab == 1) {
                        withAnimation {
                            selectedTab = 1
                        }
                        Haptics.selection()
                    }
                    
                    TabButton(title: "About", isSelected: selectedTab == 2) {
                        withAnimation {
                            selectedTab = 2
                        }
                        Haptics.selection()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Tab Content
                Group {
                    if selectedTab == 0 {
                        PrivacyPolicyView()
                    } else if selectedTab == 1 {
                        TermsOfServiceView()
                    } else {
                        AboutUsView()
                    }
                }
            }
        }
        .navigationTitle("About & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.accent : AppTheme.secondaryText)
                
                Rectangle()
                    .fill(isSelected ? AppTheme.accent : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pockets — Privacy Policy")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text("Last updated: \(formatDate(Date()))")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.secondaryText)
                }
                
                Text("Pockets is built with privacy in mind. Your financial data belongs to you — not us.")
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.primaryText)
                    .lineSpacing(4)
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Data Collection
                SectionView(title: "Data Collection") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pockets does not collect, store, or transmit any personal data.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        BulletPoint(text: "No account required")
                        BulletPoint(text: "No analytics")
                        BulletPoint(text: "No ads")
                        BulletPoint(text: "No tracking")
                        BulletPoint(text: "No servers")
                        BulletPoint(text: "No cloud by default")
                        
                        Text("All data you enter stays locally on your device, stored securely using Apple's system storage.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                            .padding(.top, 8)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Data Access
                SectionView(title: "Data Access") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Only you have access to your data.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("We (the developers) cannot see, access, or recover your data.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Data Sync
                SectionView(title: "Data Sync") {
                    Text("If you choose to enable iCloud sync (future feature), your data will be synced via Apple's secure cloud services. The app does not store or access it.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Deleting Your Data
                SectionView(title: "Deleting Your Data") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You can delete your data anytime from within the app or by deleting the app.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("If you remove the app and choose to delete stored data during uninstall, your data will be erased permanently.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Third-Party Services
                SectionView(title: "Third-Party Services") {
                    Text("Pockets does not use third-party services for data processing or analytics.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Children's Privacy
                SectionView(title: "Children's Privacy") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pockets is not directed to children under 13.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("We do not knowingly collect information from children.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Changes to This Policy
                SectionView(title: "Changes to This Policy") {
                    Text("We may update this policy occasionally. Updates will be reflected in the app or App Store page.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Contact
                SectionView(title: "Contact") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Have questions or suggestions?")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Link("Email: evankology@gmail.com", destination: URL(string: "mailto:evankology@gmail.com")!)
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.accent)
                    }
                }
                
                // Flavor Text
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(AppTheme.tertiaryText.opacity(0.3))
                        .padding(.top, 16)
                    
                    Text("Pockets doesn't track you, collect your personal data, or send your info anywhere. Everything stays on your device. Delete the app = delete your data. It's your wallet — we don't look inside.")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.secondaryText)
                        .italic()
                        .lineSpacing(4)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            // Spacer to prevent content from being hidden behind nav bar
            Color.clear.frame(height: 80)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pockets — Terms of Use")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text("Last updated: \(formatDate(Date()))")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.secondaryText)
                }
                
                Text("By using Pockets, you agree to these terms.")
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.primaryText)
                    .lineSpacing(4)
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Purpose
                SectionView(title: "Purpose") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pockets is a personal finance app designed to help track expenses.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("It is provided for personal use only.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // No Warranty
                SectionView(title: "No Warranty") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pockets is provided \"as-is,\" with no warranty of any kind.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("We do not guarantee:")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText)
                            .padding(.top, 8)
                        
                        BulletPoint(text: "Data accuracy")
                        BulletPoint(text: "Feature availability")
                        BulletPoint(text: "That the app will meet all your financial tracking needs")
                        
                        Text("You are responsible for verifying and managing your finances.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                            .padding(.top, 8)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Limitation of Liability
                SectionView(title: "Limitation of Liability") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("We are not responsible for:")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        BulletPoint(text: "Loss of data")
                        BulletPoint(text: "Financial losses related to app use")
                        BulletPoint(text: "Bugs, glitches, or interruptions")
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Data Responsibility
                SectionView(title: "Data Responsibility") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You are responsible for backing up your data.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("Deleting the app may delete your local data.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Fair Use
                SectionView(title: "Fair Use") {
                    Text("Please use Pockets responsibly and only for lawful purposes.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Updates & Changes
                SectionView(title: "Updates & Changes") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features may change, improve, or be removed over time.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Text("Terms may be updated; continued use means acceptance.")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                    }
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Contact
                SectionView(title: "Contact") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Questions? Feedback?")
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.primaryText)
                        
                        Link("Email: evankology@gmail.com", destination: URL(string: "mailto:evankology@gmail.com")!)
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            // Spacer to prevent content from being hidden behind nav bar
            Color.clear.frame(height: 80)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("About Pockets")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)
                
                // Intro
                VStack(alignment: .leading, spacing: 16) {
                    Text("Hi! 👋 I'm the solo developer behind Pockets.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text("I built this app because managing money shouldn't feel complicated, demanding, or expensive. There are already plenty of budget apps out there — but most of them lock features behind subscriptions, collect your data, or bombard you with ads. I wanted something simpler, private, and genuinely helpful… so I made it.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                        .lineSpacing(4)
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Design Principles
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pockets is designed to be:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    BulletPoint(text: "Private — your financial data stays on your device.")
                    BulletPoint(text: "Ad-free — no banners, no tracking, no nonsense.")
                    BulletPoint(text: "Subscription-free — budgeting shouldn't require a budget.")
                    BulletPoint(text: "Simple & clean — quick to use, pleasant to look at.")
                    BulletPoint(text: "Built with love — this is a passion project, not a product trying to \"maximize revenue\".")
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Closing
                VStack(alignment: .leading, spacing: 16) {
                    Text("If this app helps you stay mindful of your spending and feel more peaceful about your finances, then I've done my job.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                        .lineSpacing(4)
                    
                    Text("Thanks for giving Pockets a try — and for supporting an independent developer.")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                        .lineSpacing(4)
                }
                
                Divider()
                    .background(AppTheme.tertiaryText.opacity(0.3))
                
                // Contact Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("If you have feedback, ideas, or just want to say hi, I'd love to hear from you:")
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.primaryText)
                        .lineSpacing(4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Link("📧 evankology@gmail.com", destination: URL(string: "mailto:evankology@gmail.com")!)
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.accent)
                        
                        Link("GitHub: @Evank-wc", destination: URL(string: "https://github.com/Evank-wc")!)
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            // Spacer to prevent content from being hidden behind nav bar
            Color.clear.frame(height: 80)
        }
    }
}

// MARK: - Helper Views
struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)
            
            content
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 17))
                .foregroundColor(AppTheme.accent)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 17))
                .foregroundColor(AppTheme.primaryText)
        }
    }
}

#Preview {
    NavigationStack {
        AboutAndPrivacyView()
    }
    .preferredColorScheme(.dark)
}

