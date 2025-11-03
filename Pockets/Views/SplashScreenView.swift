//
//  SplashScreenView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var hasCompletedOnboarding: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    init() {
        _hasCompletedOnboarding = State(initialValue: UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))
    }
    
    var body: some View {
        Group {
            if isActive {
                if hasCompletedOnboarding {
                    ContentView()
                        .environment(\.managedObjectContext, managedObjectContext)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environment(\.managedObjectContext, managedObjectContext)
                        .onChange(of: hasCompletedOnboarding) { _, newValue in
                            // Update UserDefaults when onboarding completes
                            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
                        }
                }
            } else {
                ZStack {
                    AppTheme.background.ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        // App Logo
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .opacity(opacity)
                            .scaleEffect(scale)
                        
                        // App Name
                        Text("Pockets")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                            .opacity(opacity)
                    }
                }
                .onAppear {
                    // Fade in animation
                    withAnimation(.easeIn(duration: 0.6)) {
                        opacity = 1.0
                        scale = 1.0
                    }
                    
                    // Wait 2 seconds then transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            opacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .preferredColorScheme(.dark)
}

