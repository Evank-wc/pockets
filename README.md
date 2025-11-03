# Pockets 💰

A minimal, privacy-focused expense tracker for iOS built with SwiftUI and CoreData.

## Features

- 📊 **Dashboard** - Monthly summaries, budget tracking, and visual charts
- 📝 **Expense & Income Tracking** - Easy-to-use interface with custom numeric keypad
- 🔄 **Recurring Expenses** - Automatically track subscriptions and recurring payments
- 📅 **Calendar View** - See your daily spending at a glance with interactive day details
- 🏷️ **Categories** - Organize expenses with custom categories and icons
- 🔍 **Advanced Filtering** - Search, filter by category, type, and date range
- 📆 **Date Range Filter** - Filter transactions by custom date ranges
- 🌍 **Multi-Currency Support** - Choose from 20+ currencies with dynamic formatting
- 📤 **CSV Export** - Export all your data to CSV for analysis in Excel, Numbers, or Google Sheets
- 🔔 **Smart Notifications** - Daily reminders, budget alerts, and subscription notifications
- 💾 **Local Storage Only** - Your data stays on your device, period
- 🌙 **Dark Theme** - Beautiful dark interface designed for comfort
- 📱 **Intuitive Date Pickers** - Wheel-style date pickers for smooth date selection

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Pockets.git
```

2. Open `Pockets.xcodeproj` in Xcode

3. Build and run on your device or simulator

## Project Structure

```
Pockets/
├── Pockets/
│   ├── Views/           # SwiftUI views
│   ├── ViewModels/      # MVVM view models
│   ├── Models/          # Data models
│   ├── Services/        # CoreData and notification services
│   ├── Utils/           # Utilities (Theme, Haptics, Formatters)
│   └── Assets.xcassets/ # App icons and images
```

## Architecture

- **SwiftUI** - Modern declarative UI framework
- **MVVM** - Model-View-ViewModel architecture pattern
- **CoreData** - Local data persistence (no cloud sync)
- **Swift Charts** - Data visualization

## Key Features in Detail

### 📤 CSV Export
Export all your expense data to a CSV file that can be opened in any spreadsheet application. Perfect for:
- Year-end tax preparation
- Financial analysis
- Data backup
- Sharing with accountants or financial advisors

The export includes date, type (expense/income), category, amount (with currency formatting), notes, and creation timestamp.

### 🔍 Advanced Filtering
- **Search** - Find transactions by category name or note
- **Category Filter** - Filter by specific categories
- **Type Filter** - Show only expenses or only income
- **Date Range Filter** - Filter transactions within custom date ranges (e.g., last 30 days, specific month, etc.)

### 🌍 Currency Support
Select from 20+ currencies including USD, EUR, GBP, JPY, CNY, AUD, CAD, CHF, HKD, SGD, and more. The selected currency is applied throughout the app, including:
- Dashboard displays
- Expense entries
- CSV exports
- All monetary values

### 📅 Interactive Calendar
The dashboard includes an interactive calendar where you can:
- See daily expense and income totals at a glance
- Tap any day to view detailed transaction list
- Navigate between months with swipe gestures

## Privacy

This app is built with privacy in mind:
- ✅ All data stored locally on your device
- ✅ No cloud sync or external servers
- ✅ No analytics or tracking
- ✅ No third-party dependencies that compromise privacy

## Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to open an issue or contact me.

## License

Copyright © 2025 Evank-WC. All rights reserved.

## Acknowledgments

Built with ❤️ using SwiftUI and CoreData.
