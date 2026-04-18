# Dentzy App - Architecture Documentation

## 🏗️ Project Architecture

### **Layered Architecture Pattern**

```
┌─────────────────────────────────────────────┐
│         UI LAYER (Screens & Widgets)        │
│  ┌────────────────────────────────────────┐ │
│  │ splash_screen   │ home_screen         │ │
│  │ myth_checker    │ tracker_screen      │ │
│  │ reports         │ learn_screen        │ │
│  │ video_screen    │ profile_screen      │ │
│  └────────────────────────────────────────┘ │
└───────────────────────┬─────────────────────┘
                        │
      ┌─────────────────┴─────────────────┐
      │  REUSABLE WIDGETS LAYER           │
      │  • CustomCard • ProgressChart     │
      └─────────────────┬─────────────────┘
                        │
┌───────────────────────┴─────────────────┐
│    BUSINESS LOGIC LAYER (Services)      │
│  ┌─────────────────────────────────────┐│
│  │ MythApiService    │ TrackerService ││
│  │ • fetchMyths()    │ • trackProgress()
│  │ • checkMyth()     │ • getMetrics()  ││
│  │ • getStats()      │ • getStreak()   ││
│  └─────────────────────────────────────┘│
└───────────────────────┬─────────────────┘
                        │
┌───────────────────────┴──────────────────┐
│      DATA LAYER (Models & Storage)       │
│  ┌──────────────────────────────────────┐│
│  │ Models:        │ Storage:           ││
│  │ • UserModel    │ • HiveDB           ││
│  │ • MythResult   │ • database/*.dart  ││
│  └──────────────────────────────────────┘│
└──────────────────────────────────────────┘
```

## 🔄 Data Flow

### **Quiz Flow Example**
```
User starts quiz
    ↓
myth_checker_screen displays question
    ↓
User selects answer
    ↓
Call MythApiService.checkMyth()
    ↓
Service processes through models
    ↓
Store result via HiveDB
    ↓
Update in TrackerService
    ↓
Display result_screen
```

## 📱 Screen Navigation

### **Navigation Structure**
```
Splash Screen (2s animation)
    ↓
Language Selection
    ↓
Bottom Tab Navigation
    ├─ HOME (HomeScreen)
    ├─ QUIZ (MythCheckerScreen → ResultScreen)
    ├─ TRACKER (TrackerScreen)
    ├─ REPORTS (ReportsScreen)
    └─ LEARN (LearnScreen + VideoScreen)
    
Profile Access: Side menu or Settings
```

## 📂 File Organization

### **Screens** (`lib/screens/`)
- **Purpose:** User-facing screens and UI layouts
- **Pattern:** Each screen is a StatefulWidget when needed
- **Responsibilities:** 
  - Render UI components
  - Handle user interactions
  - Call services for data
  - Update state

### **Widgets** (`lib/widgets/`)
- **Purpose:** Reusable, isolated UI components
- **Pattern:** Stateless/Stateful generic components
- **Responsibilities:**
  - Encapsulate UI patterns
  - Accept parameters for customization
  - Handle visual logic
  - Emit events to parent

### **Services** (`lib/services/`)
- **Purpose:** Business logic and external communication
- **Pattern:** Stateless service classes with static methods
- **Responsibilities:**
  - API calls
  - Data processing
  - External integrations
  - Error handling

### **Models** (`lib/models/`)
- **Purpose:** Data structures and serialization
- **Pattern:** Immutable classes with factory constructors
- **Responsibilities:**
  - Define data schemas
  - Serialize/deserialize JSON
  - Type safety
  - Validation

### **Utils** (`lib/utils/`)
- **purpose:** Configuration and constants
- **Files:**
  - `theme.dart` - Complete theme configuration
  - `constants.dart` - App-wide constants, API endpoints
  - Extensible for: logger, validators, helpers

### **Database** (`lib/database/`)
- **Purpose:** Data persistence layer
- **Pattern:** Singleton pattern with static methods
- **Responsibilities:**
  - CRUD operations
  - Box management
  - Data caching

### **Localization** (`lib/localization/`)
- **Purpose:** Multi-language support
- **Pattern:** Centralized string management
- **Supported:** EN, HI, ES, FR

## 🎨 Theme System

### **Color Palette Architecture**
```
AppTheme Class
├── Primary Colors
│   ├── primaryColor: #6366F1
│   ├── primaryLight: #818CF8
│   └── primaryDark: #4F46E5
├── Secondary Colors
│   ├── secondaryColor: #10B981
│   ├── secondaryLight: #34D399
│   └── secondaryDark: #059669
├── Accent Colors
│   ├── accentColor: #F59E0B
│   ├── errorColor: #EF4444
│   ├── successColor: #10B981
│   └── warningColor: #F59E0B
├── Neutral Colors
│   └── textPrimary, textSecondary, dividerColor
├── Gradients
│   ├── primaryGradient
│   └── successGradient
└── Themes
    ├── lightTheme: ThemeData
    └── darkTheme: ThemeData
```

## 📊 State Management (Current)

**Current:** setState (Stateful widgets)

**Recommended Upgrades:**
```
Simple:          Provider
Medium:          Riverpod
Complex:         BLoC Pattern (Recommended for scaling)
```

## 🔌 API Integration Points

### **MythApiService**
```dart
// To implement:
- Replace baseUrl
- Implement actual HTTP calls
- Add error handling
- Add retry logic
- Add request/response logging
```

### **Future Considerations**
```dart
- Implement caching layer
- Add request interceptors
- Implement token refresh
- Add offline support
- Implement rate limiting
```

## 💾 Database Schema (Hive)

### **Planned Boxes**
```
Box: "users"
├── Key: "current_user"
└── Value: UserModel (JSON)

Box: "myth_results"
├── Key: AutoIncrement ID
├── Value: MythResultModel (JSON)
└── Usage: Historical data

Box: "user_settings"
├── Key: String
├── Value: Dynamic
└── Usage: Preferences storage
```

## 🔐 Security Considerations

### **Implemented**
- Data validation in models
- Type safety with Dart
- Input validation patterns

### **To Implement**
- API authentication
- Token storage (secure)
- Data encryption (Hive)
- SSL/TLS pinning
- Obfuscation (release builds)

## 📈 Scalability Path

### **Phase 1: Current** ✅
- Basic structure
- Mock data
- UI complete

### **Phase 2: Data Integration**
- Connect to backend
- Real database
- Authentication

### **Phase 3: Enhancement**
- Advanced analytics
- Social features
- Community elements

### **Phase 4: Optimization**
- Performance tuning
- Code splitting
- Native modules

## 🧪 Testing Structure (Recommended)

```
test/
├── unit/
│   ├── models/
│   └── services/
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    └── flows/
```

## 🚀 Performance Optimization Tips

1. **Image Loading**
   - Use cached_network_image
   - Optimize SVGs
   - Implement lazy loading

2. **List Performance**
   - Use ListView.builder
   - Implement pagination
   - Virtual scrolling for large lists

3. **State Management**
   - Limit rebuild scope
   - Use const constructors
   - Implement shouldRebuild logic

4. **Network**
   - Implement connection check
   - Add request caching
   - Use gzip compression

5. **App Size**
   - Remove unused dependencies
   - Use code splitting
   - Minify with R8/ProGuard

## 📋 Code Standards Implemented

✅ **Null Safety:** All code is null-safe
✅ **Naming:** camelCase for variables/methods, PascalCase for classes
✅ **Comments:** Self-documenting code with TODO markers
✅ **Formatting:** Consistent indentation (2 spaces)
✅ **Error Handling:** Try-catch blocks in services
✅ **Documentation:** README and inline comments

## 🔄 Development Workflow

### **Adding a New Feature**
1. Create screen in `lib/screens/`
2. Create/update service in `lib/services/`
3. Create/update model in `lib/models/`
4. Update navigation in `main.dart`
5. Test UI and logic
6. Update documentation

### **Team Collaboration**
- Use feature branches
- Keep screens isolated
- Share reusable widgets
- Centralize constants
- Document API changes

---

**Architecture Version:** 1.0
**Pattern:** Clean Layered Architecture
**Best For:** Academic project + commercial scaling
