//
//  FAQView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct FAQView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Why is this free?
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Why is this free?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            Text("This is a personal passion project. Also, I already have enough subscriptions in my life — I don't want to make another one for you.")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
                        
                        // Where is my data stored?
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Where is my data stored?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            Text("On your device only. Not in the cloud, not on a mysterious server, not in a secret spreadsheet somewhere. It stays with you.")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
                        
                        // Will my data stay if I uninstall the app?
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Will my data stay if I uninstall the app?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            Text("If you delete the app and choose to remove the data, then poof — it's gone.\n\nIf you uninstall without clearing data, it should still be there when you reinstall.\n\n(But hey, backups are your friend.)")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
                        
                        // I have ideas / feature requests!
                        VStack(alignment: .leading, spacing: 12) {
                            Text("I have ideas / feature requests!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.primaryText)
                            
                            Text("Love it. contact me — I genuinely want to hear them. No promises I'll build everything… but surprises do happen.")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FAQView()
        .preferredColorScheme(.dark)
}

