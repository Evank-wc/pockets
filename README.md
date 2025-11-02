# Pockets 💰

A minimal, privacy-focused expense tracker for iOS built with SwiftUI and CoreData.

## Features

- 📊 **Dashboard** - Monthly summaries, budget tracking, and visual charts
- 📝 **Expense & Income Tracking** - Easy-to-use interface with custom numeric keypad
- 🔄 **Recurring Expenses** - Automatically track subscriptions and recurring payments
- 📅 **Calendar View** - See your daily spending at a glance
- 🏷️ **Categories** - Organize expenses with custom categories and icons
- 🔍 **Search & Filter** - Quickly find transactions
- 🔔 **Smart Notifications** - Daily reminders, budget alerts, and subscription notifications
- 💾 **Local Storage Only** - Your data stays on your device, period
- 🌙 **Dark Theme** - Beautiful dark interface designed for comfort

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
