import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const Locale _defaultLocale = Locale('en');
  
  late Locale _currentLocale;
  late SharedPreferences _prefs;

  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;

  LanguageProvider() : _currentLocale = _defaultLocale;

  /// Initialize the provider and load saved language
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
    } else {
      _currentLocale = _defaultLocale;
    }
  }

  /// Change the current language and save it
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = Locale(languageCode);
    await _prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  /// Get current language display name
  String getLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'ta':
        return 'தமிழ்';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Check if language is Tamil
  bool isTamil() => _currentLocale.languageCode == 'ta';

  /// Check if language is English
  bool isEnglish() => _currentLocale.languageCode == 'en';
}
