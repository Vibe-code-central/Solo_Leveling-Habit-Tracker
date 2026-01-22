# Solo Leveling: Shadow Monarch Transformation System

A comprehensive Flutter mobile application that gamifies personal development through the Solo Leveling universe. Transform daily habits into an immersive RPG experience with deep character progression, consequences, and Solo Leveling lore integration.

## 🎯 Features Implemented

### ✅ Core Systems
- **User Profile System** - Complete hunter profile with stats, level, rank, and progression
- **Habit Tracking** - Daily quests (good habits) and demon traps (bad habits) 
- **XP & Leveling** - Gain XP from completing habits, level up to unlock new features
- **Achievement System** - Unlock achievements for various milestones and accomplishments
- **Shadow Army** - Unlock shadow soldiers as you progress through levels
- **Notification System** - Smart reminders and system messages
- **Dark Theme UI** - Immersive Solo Leveling aesthetic with glowing effects
- **Local Data Storage** - All progress saved locally using Hive database

### 🎮 Gamification Elements
- **Rank System** - Progress from E-Rank to Special S-Rank Hunter
- **Stat Growth** - 6 core stats (Strength, Agility, Vitality, Intelligence, Sense, Willpower)
- **Buff/Debuff System** - Temporary effects from completing or failing habits
- **Streak Bonuses** - Extra XP for maintaining habit streaks
- **Penalty System** - Real consequences for failing habits
- **Weekly Boss Challenges** - Special weekly objectives with big rewards

### 📱 Screens & UI
- **Onboarding** - Character creation and class selection
- **Home Screen** - Daily quest overview with shadow army display
- **Stats Screen** - Detailed analytics and progress charts
- **Habits Screen** - Manage daily quests and demon traps
- **Achievements Screen** - View unlocked and locked achievements
- **Profile Screen** - Hunter profile and settings

## 🛠️ Technical Implementation

### Architecture
- **State Management**: Provider pattern for reactive UI updates
- **Local Storage**: Hive for fast, efficient data persistence
- **Notifications**: Flutter Local Notifications for habit reminders
- **UI Framework**: Material Design with custom Solo Leveling theme
- **Animations**: Flutter Animate for smooth transitions and effects

### Key Files Structure
```
lib/
├── core/
│   └── theme/app_theme.dart          # Solo Leveling color scheme & styling
├── data/
│   ├── models/                       # Data models (User, Habit, Achievement)
│   └── services/                     # Notification service
├── presentation/
│   ├── providers/                    # State management
│   ├── screens/                      # All app screens
│   └── widgets/                      # Reusable UI components
└── main.dart                         # App entry point
```

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation Steps

1. **Clone/Download the project**
   ```bash
   # If you have the project folder, navigate to it
   cd path/to/SOLO-Leveling
   ```

2. **Fix the project name** (Flutter requires lowercase names)
   ```bash
   # Rename the folder to use underscores
   mv "SOLO-Leveling" "solo_leveling"
   cd solo_leveling
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate Hive adapters** (for data models)
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Add platform support**
   ```bash
   # Add web support (optional)
   flutter create . --platforms=web
   
   # For mobile only, ensure Android/iOS are configured
   flutter doctor
   ```

6. **Run the app**
   ```bash
   # For mobile (Android/iOS)
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For testing basic functionality
   flutter run lib/test_main.dart
   ```

## 🎨 Solo Leveling Theme

### Color Palette
- **Primary Purple** (#6B46C1) - Shadow Energy
- **Electric Blue** (#3B82F6) - Mana Flow  
- **Crimson Red** (#DC2626) - Combat Alert
- **Emerald Green** (#10B981) - Quest Complete
- **Amber Gold** (#F59E0B) - Achievements
- **Dark Background** (#0F0F1E) - Primary BG
- **Card Background** (#1A1A2E) - Secondary BG

### Visual Effects
- Glowing containers with shadow effects
- Animated progress bars and XP gains
- Particle-like animations for level ups
- Glassmorphism cards for stats display
- Gradient backgrounds and borders

## 📊 Habit System

### Good Habits (Daily Quests)
**S-Tier (Monarch's Path)**
- Arise Before Dawn (5-6 AM wake) - +100 XP
- Shadow Training (60+ min workout) - +150 XP

**A-Tier (Hunter's Discipline)**  
- Meditation & Mindfulness (20+ min) - +80 XP
- Knowledge Dungeon (30+ min learning) - +90 XP
- Side Quest Progress (work/projects) - +120 XP

**B-Tier (Essential Training)**
- Healthy Nutrition (balanced meals) - +70 XP
- Social Connection (networking) - +60 XP
- Daily Quest Log (journaling) - +50 XP
- Rest & Recovery (7-8h sleep) - +80 XP

### Bad Habits (Demon Traps)
**Catastrophic Failures**
- Midnight Scrolling (social media after 10 PM) - -150 XP
- Gaming Abyss (2+ hours gaming weekdays) - -180 XP

**Severe Setbacks**
- Junk Food Consumption - -120 XP
- Snooze Defeat (hitting snooze) - -100 XP
- Procrastination Beast - -130 XP

## 🏆 Achievement Categories

1. **Monarch's Path** - Level milestones (10, 25, 50, 100)
2. **Flame Keeper** - Streak achievements (7, 30, 100, 365 days)
3. **Boss Slayer** - Weekly challenge completions
4. **Stat Master** - Reach stat thresholds (100, 250, 500)
5. **Perfect Hunter** - Perfect week/month streaks
6. **Collector** - Unlock all shadows, titles, achievements

## 👥 Shadow Army Progression

- **Level 1-10**: Solo Hunter (no shadows)
- **Level 11-20**: Iron (Knight shadow) - +5% Strength
- **Level 21-35**: Tank (Bear shadow) - +10% Vitality
- **Level 36-50**: Igris (Elite Knight) - +15% Strength & Agility
- **Level 51-70**: Beru (Ant King) - +20% all combat stats
- **Level 71-90**: Bellion (Grand Marshal) - +25% all stats
- **Level 91+**: Army of Shadows - +30% all stats

## 📱 Notifications

### Daily Reminders
- **6:00 AM**: "ARISE! Your daily quests await, Hunter."
- **12:00 PM**: Quest progress check
- **6:00 PM**: Evening reminder for incomplete quests
- **10:00 PM**: Final warning before penalties
- **10:30 PM**: Sleep reminder for vitality

### Achievement Notifications
- Level up celebrations
- Rank advancement alerts
- Achievement unlocks
- Penalty warnings
- Buff availability

## 🔧 Troubleshooting

### Common Issues

1. **Build errors**: Run `flutter clean && flutter pub get`
2. **Hive errors**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
3. **Import errors**: Check that all file paths are correct
4. **Platform issues**: Run `flutter doctor` to check setup

### Development Notes

- The app uses Provider for state management
- All data is stored locally with Hive (no backend required)
- Notifications work on both Android and iOS
- Web support is available but mobile is recommended
- The UI is optimized for dark theme

## 🎯 Future Enhancements

### Planned Features
- Weekly boss raid system
- Guild/social features  
- Custom habit creation UI
- Advanced analytics dashboard
- Cloud sync (optional)
- Seasonal events
- More shadow soldiers
- Achievement rewards system

### Technical Improvements
- Add unit tests
- Implement CI/CD
- Add crash reporting
- Performance optimizations
- Accessibility improvements
- Internationalization

## 📄 License

This project is for educational and personal use. Solo Leveling is a trademark of its respective owners.

## 🤝 Contributing

This is a personal productivity app inspired by Solo Leveling. Feel free to fork and customize for your own use!

---

**Ready to begin your journey as a Hunter? Complete your daily quests and unlock the power of the Shadow Monarch! 👑⚔️**