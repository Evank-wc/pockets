//
//  DashboardView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI
import Charts

enum DashboardTab: String, CaseIterable {
    case overview = "Overview"
    case spending = "Spending"
}

/// Main dashboard with Overview and Spending tabs
struct DashboardView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingBudgetSheet = false
    @State private var animateCards = false
    @State private var selectedTab: DashboardTab = .overview
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Month Selector
                        monthSelector
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Tab Selector
                        tabSelector
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                            .animation(AppTheme.springAnimation.delay(0.05), value: animateCards)
                        
                        // Tab Content
                        if selectedTab == .overview {
                            OverviewView(viewModel: viewModel)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : -20)
                                .animation(AppTheme.springAnimation.delay(0.1), value: animateCards)
                        } else {
                            SpendingView(viewModel: viewModel)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : -20)
                                .animation(AppTheme.springAnimation.delay(0.1), value: animateCards)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 100) // Space for floating button
                }
                .background(AppTheme.background.ignoresSafeArea())
                .scrollIndicators(.hidden)
                
                // Floating Add Button (Bottom Right, above nav bar)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            Haptics.medium()
                            showingAddExpense = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppTheme.primaryText)
                                .frame(width: 56, height: 56)
                                .background(AppTheme.secondaryBackground)
                                .clipShape(Circle())
                                .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationTitle("Pockets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Haptics.light()
                        showingBudgetSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingBudgetSheet) {
                BudgetSettingsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .onAppear {
                withAnimation {
                    animateCards = true
                }
            }
        }
    }
    
    // MARK: - Month Selector
    private var monthSelector: some View {
        HStack(spacing: 20) {
            Button {
                Haptics.selection()
                withAnimation(AppTheme.springAnimation) {
                    viewModel.changeMonth(by: -1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.secondaryBackground)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(AppFormatter.monthYearString(from: viewModel.selectedMonth))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            Button {
                Haptics.selection()
                withAnimation(AppTheme.springAnimation) {
                    viewModel.changeMonth(by: 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.secondaryBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width > 0 {
                        Haptics.selection()
                        withAnimation(AppTheme.springAnimation) {
                            viewModel.changeMonth(by: -1)
                        }
                    } else {
                        Haptics.selection()
                        withAnimation(AppTheme.springAnimation) {
                            viewModel.changeMonth(by: 1)
                        }
                    }
                }
        )
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(AppTheme.springAnimation) {
                        selectedTab = tab
                        Haptics.selection()
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .medium))
                        .foregroundColor(selectedTab == tab ? AppTheme.primaryText : AppTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == tab ? AppTheme.accent.opacity(0.2) : Color.clear
                        )
                }
            }
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
    }
}

// MARK: - Overview View
struct OverviewView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var animateCards = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Balance Card
            balanceCard
            
            // Line Chart
            if #available(iOS 17.0, *) {
                lineChartCard
            } else {
                // Fallback for iOS 16
                VStack(alignment: .leading, spacing: 20) {
                    Text("Monthly Trends")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    Text("Charts require iOS 17+")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.secondaryText)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                }
                .padding(24)
                .background(AppTheme.cardBackground)
                .cornerRadius(24)
                .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
            }
            
            // Calendar
            calendarCard
        }
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Balance")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(1)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppFormatter.currencyString(from: viewModel.monthlyBalance))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.success)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.success.opacity(0.15))
                            .clipShape(Circle())
                        Text(AppFormatter.currencyString(from: viewModel.currentMonthIncome))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.error)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.error.opacity(0.15))
                            .clipShape(Circle())
                        Text(AppFormatter.currencyString(from: viewModel.currentMonthExpenses))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppTheme.cardBackground, AppTheme.secondaryBackground.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 30, x: 0, y: 15)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    @available(iOS 17.0, *)
    private var lineChartCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Monthly Trends")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)
            
            let dailyData = viewModel.getDailyExpenses(for: viewModel.selectedMonth)
            let maxValue = max(
                dailyData.map { $0.expense + $0.income }.max() ?? 0,
                100
            )
            
            Chart {
                ForEach(Array(dailyData.enumerated()), id: \.offset) { index, data in
                    LineMark(
                        x: .value("Day", index + 1),
                        y: .value("Income", data.income.doubleValue),
                        series: .value("Type", "Income")
                    )
                    .foregroundStyle(AppTheme.success)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Day", index + 1),
                        y: .value("Expense", data.expense.doubleValue),
                        series: .value("Type", "Expense")
                    )
                    .foregroundStyle(AppTheme.error)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppTheme.tertiaryText.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppTheme.tertiaryText.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .frame(height: 220)
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.success)
                        .frame(width: 8, height: 8)
                    Text("Income")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.secondaryText)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.error)
                        .frame(width: 8, height: 8)
                    Text("Expenses")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(24)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
    }
    
    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Monthly Calendar")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)
            
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedMonth))!
            let dailyData = viewModel.getDailyExpenses(for: viewModel.selectedMonth)
            // Normalize dates to midnight for proper matching
            let dailyDataDict = Dictionary(uniqueKeysWithValues: dailyData.map { 
                let normalizedDate = calendar.startOfDay(for: $0.date)
                return (normalizedDate, ($0.expense, $0.income))
            })
            
            CalendarView(
                month: viewModel.selectedMonth,
                dailyData: dailyDataDict,
                viewModel: viewModel
            )
        }
        .padding(24)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    let month: Date
    let dailyData: [Date: (expense: Decimal, income: Decimal)]
    let viewModel: ExpenseViewModel
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            let days = getDaysForMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month),
                        expense: dailyData[calendar.startOfDay(for: date)]?.expense ?? 0,
                        income: dailyData[calendar.startOfDay(for: date)]?.income ?? 0,
                        viewModel: viewModel
                    )
                }
            }
        }
    }
    
    private func getDaysForMonth() -> [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: startOfMonth)!
        
        var days: [Date] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks)
        for _ in 0..<42 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
}

struct CalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let expense: Decimal
    let income: Decimal
    let viewModel: ExpenseViewModel
    
    private let calendar = Calendar.current
    
    var body: some View {
        if isCurrentMonth {
            NavigationLink {
                DayDetailView(date: date, viewModel: viewModel)
            } label: {
                VStack(spacing: 4) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText)
                    
                    if expense > 0 || income > 0 {
                        HStack(spacing: 2) {
                            if expense > 0 {
                                Circle()
                                    .fill(AppTheme.error)
                                    .frame(width: 4, height: 4)
                            }
                            if income > 0 {
                                Circle()
                                    .fill(AppTheme.success)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.secondaryBackground.opacity(0.5))
                )
                .overlay(
                    Group {
                        if calendar.isDateInToday(date) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.accent, lineWidth: 2)
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(TapGesture().onEnded {
                Haptics.light()
            })
        } else {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.tertiaryText)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
        }
    }
}

struct DayDetailView: View {
    let date: Date
    @ObservedObject var viewModel: ExpenseViewModel
    
    private var dayExpenses: [Expense] {
        viewModel.getExpensesForDate(date)
    }
    
    private var dayTotalExpenses: Decimal {
        dayExpenses.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var dayTotalIncome: Decimal {
        dayExpenses.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        Group {
            if dayExpenses.isEmpty {
                ZStack {
                    AppTheme.background.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.tertiaryText)
                        Text("No transactions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.secondaryText)
                        Text(AppFormatter.dateString(from: date))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                }
            } else {
                ZStack {
                    AppTheme.background.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            // Summary Card
                            VStack(spacing: 16) {
                                Text(AppFormatter.dateString(from: date))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.secondaryText)
                                
                                VStack(spacing: 16) {
                                    // Income
                                    HStack {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.up")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.success)
                                            Text("Income")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(AppTheme.secondaryText)
                                        }
                                        Spacer()
                                        Text(AppFormatter.currencyString(from: dayTotalIncome))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.primaryText)
                                            .monospacedDigit()
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    
                                    Divider()
                                        .background(AppTheme.tertiaryText.opacity(0.3))
                                    
                                    // Expenses
                                    HStack {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.down")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.error)
                                            Text("Expenses")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(AppTheme.secondaryText)
                                        }
                                        Spacer()
                                        Text(AppFormatter.currencyString(from: dayTotalExpenses))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.primaryText)
                                            .monospacedDigit()
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    
                                    Divider()
                                        .background(AppTheme.tertiaryText.opacity(0.3))
                                    
                                    // Net
                                    HStack {
                                        Text("Net")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppTheme.primaryText)
                                        Spacer()
                                        Text(AppFormatter.currencyString(from: dayTotalIncome - dayTotalExpenses))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.primaryText)
                                            .monospacedDigit()
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(20)
                            .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
                            
                            // Transactions List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Transactions")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryText)
                                
                                ForEach(dayExpenses) { expense in
                                    HStack(spacing: 16) {
                                        Text(viewModel.getCategoryIcon(for: expense.categoryID))
                                            .font(.system(size: 28))
                                            .frame(width: 50, height: 50)
                                            .background(AppTheme.secondaryBackground)
                                            .cornerRadius(14)
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(viewModel.getCategoryName(for: expense.categoryID))
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppTheme.primaryText)
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            if let note = expense.note, !note.isEmpty {
                                                Text(note)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppTheme.secondaryText)
                                                    .lineLimit(2)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: expense.isIncome ? "arrow.up" : "arrow.down")
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundColor(expense.isIncome ? AppTheme.success : AppTheme.error)
                                                Text("•")
                                                    .foregroundColor(AppTheme.tertiaryText)
                                                Text(AppFormatter.timeFormatter.string(from: expense.date))
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.tertiaryText)
                                                    .lineLimit(1)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Image(systemName: expense.isIncome ? "arrow.up" : "arrow.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(expense.isIncome ? AppTheme.success : AppTheme.error)
                                            Text(AppFormatter.currencyString(from: expense.amount))
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(AppTheme.primaryText)
                                                .monospacedDigit()
                                                .fixedSize(horizontal: true, vertical: false)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(20)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(20)
                            .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationTitle("Day Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Spending View
struct SpendingView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var chartType: ExpenseType = .expense
    
    var body: some View {
        VStack(spacing: 20) {
            // Balance Card
            balanceCard
            
            // Budget Progress
            if viewModel.monthlyBudget > 0 {
                budgetProgressCard
            }
            
            // Category Breakdown Chart (Always visible)
            categoryBreakdownCard
            
            // Category List Below Chart (only if has data)
            if !currentCategoryData.isEmpty {
                categoryListCard
            }
            
            // Quick Stats
            quickStatsGrid
        }
    }
    
    private var currentCategoryData: [(category: Category, amount: Decimal)] {
        chartType == .expense ? viewModel.monthlyExpensesByCategory : viewModel.monthlyIncomeByCategory
    }
    
    private var currentCategoryTotal: Decimal {
        chartType == .expense ? viewModel.currentMonthExpenses : viewModel.currentMonthIncome
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Balance")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(1)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppFormatter.currencyString(from: viewModel.monthlyBalance))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.success)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.success.opacity(0.15))
                            .clipShape(Circle())
                        Text(AppFormatter.currencyString(from: viewModel.currentMonthIncome))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.error)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.error.opacity(0.15))
                            .clipShape(Circle())
                        Text(AppFormatter.currencyString(from: viewModel.currentMonthExpenses))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppTheme.cardBackground, AppTheme.secondaryBackground.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 30, x: 0, y: 15)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var budgetProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Monthly Budget")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                
                Spacer()
                
                Text("\(Int(viewModel.budgetProgress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.tertiaryBackground)
                    .cornerRadius(12)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.tertiaryBackground)
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: viewModel.isOverBudget ? [AppTheme.error, AppTheme.error.opacity(0.7)] : [AppTheme.accent, AppTheme.accentLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(viewModel.budgetProgress), height: 10)
                        .animation(AppTheme.springAnimation, value: viewModel.budgetProgress)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text("Spent: \(AppFormatter.currencyString(from: viewModel.currentMonthExpenses))")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Text("Budget: \(AppFormatter.currencyString(from: viewModel.monthlyBudget))")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            if viewModel.isOverBudget {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.error)
                    Text("Over budget by \(AppFormatter.currencyString(from: viewModel.currentMonthExpenses - viewModel.monthlyBudget))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.error)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.error.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .padding(24)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
    }
    
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Category Breakdown")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                
                Spacer()
                
                Picker("", selection: $chartType) {
                    Text("Expense").tag(ExpenseType.expense)
                    Text("Income").tag(ExpenseType.income)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
                .onChange(of: chartType) { _, _ in
                    Haptics.selection()
                }
            }
            
            if currentCategoryData.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: chartType == .expense ? "chart.pie" : "chart.bar")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.tertiaryText)
                    Text(chartType == .expense ? "No expenses this month" : "No income this month")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
            } else if #available(iOS 17.0, *) {
                Chart {
                    ForEach(Array(currentCategoryData.enumerated()), id: \.element.category.id) { index, item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 3
                        )
                        .foregroundStyle(colorForCategoryAtIndex(index))
                    }
                }
                .frame(height: 220)
            } else {
                VStack(spacing: 14) {
                    ForEach(Array(currentCategoryData.prefix(5).enumerated()), id: \.element.category.id) { index, item in
                        CategoryProgressRow(
                            category: item.category,
                            amount: item.amount,
                            total: currentCategoryTotal,
                            colorIndex: index
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
    }
    
    private var categoryListCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(chartType == .expense ? "Expenses by Category" : "Income by Category")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)
            
            VStack(spacing: 12) {
                ForEach(Array(currentCategoryData.enumerated()), id: \.element.category.id) { index, item in
                    CategoryListItem(
                        category: item.category,
                        amount: item.amount,
                        color: colorForCategoryAtIndex(index)
                    )
                }
            }
        }
        .padding(24)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: AppTheme.cardShadow, radius: 20, x: 0, y: 10)
    }
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            StatCard(
                title: "Daily Avg",
                value: AppFormatter.currencyString(from: dailyAverage),
                icon: "calendar",
                color: AppTheme.accent
            )
            
            StatCard(
                title: "Transactions",
                value: "\(expenseCount)",
                icon: "list.bullet",
                color: AppTheme.categoryColors[3]
            )
        }
    }
    
    private var dailyAverage: Decimal {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: viewModel.selectedMonth)?.count ?? 30
        let daysPassed = min(calendar.component(.day, from: Date()), daysInMonth)
        return daysPassed > 0 ? viewModel.currentMonthExpenses / Decimal(daysPassed) : 0
    }
    
    private var expenseCount: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedMonth))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        return viewModel.expenses.filter { expense in
            expense.date >= startOfMonth && expense.date < endOfMonth
        }.count
    }
    
    private func colorForCategoryAtIndex(_ index: Int) -> Color {
        AppTheme.categoryColors[index % AppTheme.categoryColors.count]
    }
}

// MARK: - Supporting Views
struct CategoryListItem: View {
    let category: Category
    let amount: Decimal
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(category.icon)
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    
                    Text(AppFormatter.currencyString(from: amount))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct CategoryProgressRow: View {
    let category: Category
    let amount: Decimal
    let total: Decimal
    let colorIndex: Int
    
    init(category: Category, amount: Decimal, total: Decimal, colorIndex: Int = 0) {
        self.category = category
        self.amount = amount
        self.total = total
        self.colorIndex = colorIndex
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(category.icon)
                .font(.system(size: 28))
                .frame(width: 50, height: 50)
                .background(AppTheme.secondaryBackground)
                .cornerRadius(14)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(category.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.tertiaryBackground)
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(colorForCategory())
                            .frame(
                                width: geometry.size.width * CGFloat(amount.doubleValue / max(total.doubleValue, 0.01)),
                                height: 6
                            )
                            .animation(AppTheme.springAnimation, value: amount)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            Text(AppFormatter.currencyString(from: amount))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 8)
    }
    
    private func colorForCategory() -> Color {
        AppTheme.categoryColors[colorIndex % AppTheme.categoryColors.count]
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.cardShadow, radius: 15, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppTheme.quickAnimation, value: isPressed)
    }
}

struct BudgetSettingsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var budgetText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Monthly Budget", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .foregroundColor(AppTheme.primaryText)
                    } header: {
                        Text("Budget Amount")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("Set a monthly budget to track your spending.")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        formatter.locale = Locale.current
                        if let number = formatter.number(from: budgetText) {
                            viewModel.setMonthlyBudget(number.decimalValue)
                        }
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
            .onAppear {
                budgetText = viewModel.monthlyBudget == 0 ? "" : String(describing: viewModel.monthlyBudget)
            }
        }
    }
}

#Preview {
    DashboardView(viewModel: ExpenseViewModel())
        .preferredColorScheme(.dark)
}
