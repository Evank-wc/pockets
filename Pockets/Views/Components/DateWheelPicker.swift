//
//  DateWheelPicker.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI

struct DateWheelPicker: View {
    @Binding var date: Date
    var title: String = "Date"
    var displayedComponents: DatePickerComponents = .date
    
    @State private var showingPicker = false
    @State private var tempDate: Date
    
    init(date: Binding<Date>, title: String = "Date", displayedComponents: DatePickerComponents = .date) {
        self._date = date
        self.title = title
        self.displayedComponents = displayedComponents
        self._tempDate = State(initialValue: date.wrappedValue)
    }
    
    var body: some View {
        Button {
            tempDate = date
            showingPicker = true
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(AppTheme.primaryText)
                
                Spacer()
                
                Text(formattedDate)
                    .foregroundColor(AppTheme.secondaryText)
                    .font(.system(size: 17))
            }
        }
        .sheet(isPresented: $showingPicker) {
            DatePickerSheet(
                date: $tempDate,
                title: title,
                displayedComponents: displayedComponents,
                onDateChanged: { newDate in
                    date = newDate
                    Haptics.selection()
                    showingPicker = false
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        if displayedComponents.contains(.date) && displayedComponents.contains(.hourAndMinute) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        } else if displayedComponents.contains(.hourAndMinute) {
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .medium
        }
        return formatter.string(from: date)
    }
}

struct DatePickerSheet: View {
    @Binding var date: Date
    var title: String
    var displayedComponents: DatePickerComponents
    var onDateChanged: (Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    DatePicker(
                        title,
                        selection: $date,
                        displayedComponents: displayedComponents
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDateChanged(date)
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
        }
    }
}

