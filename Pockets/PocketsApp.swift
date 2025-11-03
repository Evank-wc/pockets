//
//  PocketsApp.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI
import CoreData

@main
struct PocketsApp: App {
    // Initialize CoreData stack
    let storageService = StorageService.shared
    
    init() {
        // Don't request notification permissions on app launch
        // This will be handled in the onboarding flow
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, storageService.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
