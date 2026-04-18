# Dentzy - Dental Myth Buster App

A professional Flutter application for identifying and debunking dental myths using AI technology. Built as a final year AI project with a futuristic and modern UI design.

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point and navigation
├── screens/                           # UI Screens
│   ├── splash_screen.dart            # Initial splash animation screen
│   ├── language_screen.dart          # Language selection screen
│   ├── home_screen.dart              # Main dashboard with quick actions
│   ├── myth_checker_screen.dart      # Quiz/myth validation screen
│   ├── result_screen.dart            # Result display with explanation
│   ├── tracker_screen.dart           # Progress tracking dashboard
│   ├── reports_screen.dart           # Performance reports and analytics
│   ├── learn_screen.dart             # Educational content
│   ├── video_screen.dart             # Video lesson viewer
│   └── profile_screen.dart           # User profile management
│
├── widgets/                           # Reusable UI Components
│   ├── custom_card.dart              # Customizable card widget with gradients
│   └── progress_chart.dart           # Circular progress chart widget
│
├── services/                          # Business Logic & API
│   ├── myth_api_service.dart         # API calls for myth data
│   └── tracker_service.dart          # Progress tracking and metrics
│
├── models/                            # Data Models
│   ├── user_model.dart               # User data structure
│   └── myth_result_model.dart        # Myth result data structure
│
├── utils/                             # Utilities
│   ├── constants.dart                # App-wide constants
│   ├── theme.dart                    # Theme configuration (Light/Dark)
│   └── strings.dart                  # Localized strings (planned)
│
├── database/                          # Local Storage
│   └── hive_db.dart                  # Hive database operations
│
└── localization/                      # Multi-language Support
    └── localization.dart             # Localization strings
```

## 🎨 Design Features

### Color Scheme
- **Primary:** `#6366F1` (Indigo) - Modern and professional
- **Secondary:** `#10B981` (Emerald) - Success and positive actions
- **Accent:** `#F59E0B` (Amber) - Important information
- **Error:** `#EF4444` (Red) - Error states

### Typography
- **Display Large:** 32px, Bold - Headings
- **Headline Small:** 20px, Semi-bold - Section titles
- **Body Large:** 16px - Primary text
- **Body Medium:** 14px - Secondary text

### UI Components
- **Gradients:** Smooth color transitions for premium feel
- **Rounded Corners:** 12-16px border radius for modern look
- **Shadows:** Subtle elevation for depth
- **Icons:** Material Design icons for intuitive navigation
- **Cards:** Elevated cards with hover effects

## 📱 Screens Overview

### 1. **Splash Screen** (`splash_screen.dart`)
- Animated app logo with fade and scale transitions
- Professional branding display
- 2-3 seconds display duration

### 2. **Language Selection** (`language_screen.dart`)
- Multi-language support (English, Hindi, Spanish, French)
- Interactive language cards
- Smooth transition to main app

### 3. **Home Screen** (`home_screen.dart`)
- Welcome banner with call-to-action
- Statistics cards (myths checked, accuracy rate, streak)
- Quick action grid for main features
- Navigation to all features

### 4. **Myth Checker** (`myth_checker_screen.dart`)
- Question display with category information
- Multiple choice answers (Myth/Truth)
- Progress indicator
- AI confidence score display
- Previous/Next navigation

### 5. **Result Screen** (`result_screen.dart`)
- Visual feedback (checkmark for correct, X for incorrect)
- Question recap
- Correct answer highlight
- Detailed explanation
- Next question and home buttons

### 6. **Progress Tracker** (`tracker_screen.dart`)
- Overall accuracy percentage
- Weekly progress target
- Category-wise performance
- Recent activity heatmap
- Statistics cards

### 7. **Reports** (`reports_screen.dart`)
- Period selector (Weekly, Monthly, Yearly)
- Performance summary
- Category breakdown charts
- Achievement badges
- Detailed statistics

### 8. **Learn Screen** (`learn_screen.dart`)
- Featured articles with thumbnails
- Category filtering
- Read time indicators
- Educational content organization
- Topic tags

### 9. **Video Screen** (`video_screen.dart`)
- Featured video player
- Video metadata (instructor, date)
- Recommended videos list
- Like and save functionality
- Duration indicators

### 10. **Profile Screen** (`profile_screen.dart`)
- User profile information
- Editable user details
- User statistics overview
- Preferences and settings
- Help and logout options

## 📊 Data Models

### UserModel
```dart
- id: String
- name: String
- email: String
- profileImage: String?
- languagePreference: String
- createdAt: DateTime
- mythsChecked: int
- accuracyRate: double
```

### MythResultModel
```dart
- id: String
- mythId: String
- mythTitle: String
- userAnswer: String
- correctAnswer: String
- isCorrect: bool
- checkedAt: DateTime
- confidenceScore: double
- explanation: String
- category: String
```

## 🌐 Localization

Supported languages:
- English (en)
- Hindi (हिंदी)
- Spanish (Español)
- French (Français)

## 🗄️ Database

Uses **Hive** for local storage:
- `users` box - User information
- `myth_results` box - Quiz results history
- `user_settings` box - App preferences

## 🔌 Services

### MythApiService
- `fetchMyths()` - Retrieve myths from API
- `checkMyth()` - Validate user answer
- `getMythStatistics()` - Get user statistics

### TrackerService
- `trackProgress()` - Record user actions
- `getPerformanceMetrics()` - Calculate statistics
- `getStreakData()` - Generate streak information
- `getCategoryPerformance()` - Get category-wise metrics

## 🎯 Key Features

✅ **Multi-language Support** - Internationalization ready
✅ **AI Integration** - Confidence scores for myth validation
✅ **Progress Tracking** - Detailed analytics and reports
✅ **Responsive Design** - Adapts to different screen sizes
✅ **Dark Mode Ready** - Theme system supports dark theme
✅ **Local Storage** - Offline data persistence with Hive
✅ **Modern UI** - Professional, futuristic design
✅ **Performance Metrics** - Comprehensive user statistics

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code (if using Hive adapters):
```bash
flutter pub run build_runner build
```

3. Run the app:
```bash
flutter run
```

## 📦 Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  
dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.3.0
```

## 🔮 Future Enhancements

- [ ] Backend API integration
- [ ] Real AI model for myth validation
- [ ] Social sharing features
- [ ] Push notifications
- [ ] Video streaming integration
- [ ] Advanced analytics dashboard
- [ ] Offline quiz bank
- [ ] Community forum
- [ ] Leaderboards
- [ ] Achievement system with badges

## 📝 Notes for Development

1. **API Integration** - Replace TODO comments in services with actual API calls
2. **Database Setup** - Uncomment and configure Hive initialization in main.dart
3. **Image Assets** - Add app icons and image assets to pubspec.yaml
4. **Testing** - Create unit and widget tests for all components
5. **Performance** - Optimize image loading and network calls

## 🎓 Academic Use

This project is structured for demonstration as a final year AI project with:
- Clean architecture
- Separation of concerns
- Reusable components
- Professional UI/UX
- Documentation
- Scalable structure

## 📄 License

This project is for educational purposes.

---

**Last Updated:** March 2026
**Version:** 1.0.0
