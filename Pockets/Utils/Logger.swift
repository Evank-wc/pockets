//
//  Logger.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import Foundation
import os.log

/// Simple logging utility to prevent console flooding and Xcode logging issues
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.pockets.app"
    private static let category = "AppLogs"
    
    // Use OSLog for better performance and to avoid Xcode logging system issues
    private static let logger = OSLog(subsystem: subsystem, category: category)
    
    static func info(_ message: String) {
        // Only log in debug builds to reduce console output
        #if DEBUG
        os_log("%{public}@", log: logger, type: .info, message)
        #endif
    }
    
    static func error(_ message: String) {
        // Always log errors
        os_log("%{public}@", log: logger, type: .error, message)
    }
    
    static func warning(_ message: String) {
        // Only log warnings in debug builds
        #if DEBUG
        os_log("%{public}@", log: logger, type: .default, message)
        #endif
    }
    
    static func debug(_ message: String) {
        // Only log in debug builds
        #if DEBUG
        os_log("%{public}@", log: logger, type: .debug, message)
        #endif
    }
}

