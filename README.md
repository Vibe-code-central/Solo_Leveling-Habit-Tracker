# Solo Leveling: Habit Tracker

A Flutter mobile application that gamifies personal development through the Solo Leveling universe. Transform daily habits into an immersive RPG experience with character progression and Solo Leveling lore.

## Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

## Setup & Installation

1. **Navigate to project directory**
   ```bash
   cd Solo_Leveling-Habit-Tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For mobile (Android/iOS)
   flutter run
   
   # For web
   flutter run -d chrome
   ```

## Troubleshooting

- **Build errors**: `flutter clean && flutter pub get`
- **Hive errors**: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- **Platform issues**: `flutter doctor`

## Tech Stack

- **State Management**: Provider
- **Local Storage**: Hive
- **Notifications**: Flutter Local Notifications
- **UI**: Material Design with custom Solo Leveling theme

---

**Complete your daily quests and unlock the power of the Shadow Monarch! 👑⚔️**