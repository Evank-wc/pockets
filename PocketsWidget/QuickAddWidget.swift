//
//  QuickAddWidget.swift
//  PocketsWidget
//
//  Created on 2/11/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

@available(iOS 17.0, *)
struct QuickAddWidget: Widget {
    let kind: String = "QuickAddWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddWidgetProvider()) { entry in
            QuickAddWidgetView(entry: entry)
                .containerBackground(Color(hex: "000000"), for: .widget)
        }
        .configurationDisplayName("Pockets")
        .description("Quickly add expenses or income from your home screen")
        .supportedFamilies([.systemLarge])
    }
}

@available(iOS 17.0, *)
struct QuickAddWidgetEntry: TimelineEntry {
    let date: Date
    let defaultCategoryID: String?
    
    init(date: Date, defaultCategoryID: String?) {
        self.date = date
        self.defaultCategoryID = defaultCategoryID
    }
}

@available(iOS 17.0, *)
struct QuickAddWidgetView: View {
    var entry: QuickAddWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        MediumWidgetView(entry: entry)
    }
}

// MARK: - Widget Theme Colors
extension Color {
    static let widgetBackground = Color(hex: "000000")
    static let widgetCardBackground = Color(hex: "1C1C1E")
    static let widgetPrimaryText = Color(hex: "F2F2F7")
    static let widgetSecondaryText = Color(hex: "AEAEB2")
    static let widgetAccent = Color(hex: "007AFF")
    static let widgetError = Color(hex: "FF3B30")
    static let widgetSuccess = Color(hex: "34C759")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Medium Widget (Preset Amounts Only)
@available(iOS 17.0, *)
struct MediumWidgetView: View {
    var entry: QuickAddWidgetEntry
    
    // Preset amounts
    private let presetAmounts: [Double] = [5.0, 10.0, 20.0, 50.0]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Pockets")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.widgetPrimaryText)
                Spacer()
            }
            
            Spacer()
            
            // Preset Amount Buttons
            VStack(spacing: 16) {
                // Expense buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Add Expense")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.widgetSecondaryText)
                    
                    HStack(spacing: 10) {
                        ForEach(presetAmounts, id: \.self) { amount in
                            Button(intent: {
                                var intent = QuickAddExpenseIntent()
                                intent.amount = amount
                                intent.categoryID = entry.defaultCategoryID ?? ""
                                return intent
                            }()) {
                                VStack(spacing: 6) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 18, weight: .medium))
                                    Text(AppFormatter.currencyString(from: Decimal(amount)))
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.widgetError.opacity(0.15))
                                .foregroundColor(.widgetError)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Income buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Add Income")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.widgetSecondaryText)
                    
                    HStack(spacing: 10) {
                        ForEach(presetAmounts, id: \.self) { amount in
                            Button(intent: {
                                var intent = QuickAddIncomeIntent()
                                intent.amount = amount
                                intent.categoryID = entry.defaultCategoryID ?? ""
                                return intent
                            }()) {
                                VStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18, weight: .medium))
                                    Text(AppFormatter.currencyString(from: Decimal(amount)))
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.widgetSuccess.opacity(0.15))
                                .foregroundColor(.widgetSuccess)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - Widget Provider
@available(iOS 17.0, *)
struct QuickAddWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddWidgetEntry {
        QuickAddWidgetEntry(
            date: Date(),
            defaultCategoryID: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickAddWidgetEntry) -> Void) {
        // For snapshot (used when widget is first added), fetch real data
        let entry = getCurrentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddWidgetEntry>) -> Void) {
        let entry = getCurrentEntry()
        
        // Update every hour
        let calendar = Calendar.current
        let now = Date()
        let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: now) ?? now
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getCurrentEntry() -> QuickAddWidgetEntry {
        let storageService = StorageService.shared
        let now = Date()
        
        // Force refresh CoreData context to get latest data from persistent store
        // This ensures we see changes made by App Intents or the main app
        let context = storageService.viewContext
        context.refreshAllObjects()
        
        // Get "Other" category ID for default
        let categories = storageService.fetchCategories()
        let otherCategory = categories.first(where: { $0.name == "Other" })
        let defaultCategoryID = otherCategory?.id.uuidString ?? categories.first?.id.uuidString
        
        return QuickAddWidgetEntry(
            date: now,
            defaultCategoryID: defaultCategoryID
        )
    }
}

// MARK: - Preview
@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    QuickAddWidget()
} timeline: {
    QuickAddWidgetEntry(
        date: Date(),
        defaultCategoryID: nil
    )
}
