# Dentzy App

[![Flutter CI](https://github.com/YOUR_USERNAME/Dentzy_App/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/Dentzy_App/actions/workflows/flutter_ci.yml)

## Description
Dentzy is a comprehensive Flutter-based mobile application designed to provide users with essential oral health information, myth checking capabilities, and various specialized features. It integrates seamlessly with robust backend services to ensure a smooth, multilingual, and intuitive user experience.

## Features
- **Multilingual Support**: Supports multiple languages including English and Tamil.
- **Oral Health Myth Checker**: Easily verify facts versus myths regarding oral hygiene.
- **Backend Persistence**: Reliable data storage and retrieval.
- **Responsive UI**: Beautiful and fluid interface optimized for iOS and Android.

## Technologies
- **Frontend**: Flutter, Dart
- **Backend**: Python, Groq Integration
- **Testing**: Appium, Selenium, Flutter test framework
- **CI/CD**: GitHub Actions

## Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/abiramykj/Dentzy_App.git
   cd Dentzy_App/dentzy
   ```
2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

## Running the App
To run the application locally on an emulator or physical device:
```bash
cd dentzy
flutter run
```

## Folder Structure
```
Dentzy_App/
├── .github/workflows/       # GitHub Actions CI workflow
├── backend/                 # Backend scripts and services
├── dentzy/                  # Main Flutter application source code
├── reports/                 # Testing reports (Appium, Selenium, etc.)
├── tests/                   # Backend/Integration tests
└── README.md                # Project documentation
```

## Screenshots
*(Add your screenshots here)*
- Dashboard Screen:
- Myth Checker Screen:

## Testing
The project maintains comprehensive test coverage across the stack:
- **Unit & Widget Tests**: Flutter tests located in `dentzy/test/`.
- **UI & Automation**: Appium and Selenium test reports are generated and stored in the `reports/` folder.
- **Coverage**: Generated automatically during the CI workflow.

To run the Flutter tests manually:
```bash
cd dentzy
flutter test --coverage
```

## GitHub Actions
We use GitHub Actions to automate the continuous integration pipeline. The workflow (`flutter_ci.yml`) is triggered on pushes and pull requests to the `main` branch. 

**It automatically:**
- Installs the latest stable Flutter SDK.
- Caches dependencies for faster builds.
- Validates Dart formatting (`dart format`).
- Runs static analysis (`flutter analyze`).
- Executes unit/widget tests (if any exist) and generates code coverage.
- Builds a Release APK and Android App Bundle (AAB).
- Uploads the builds and all Excel test reports (`reports/*.xlsx`) as downloadable artifacts.
