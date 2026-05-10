import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'session_manager.dart';

class LanguageProvider extends ChangeNotifier {
  static const Locale _defaultLocale = Locale('en');

  late Locale _currentLocale;

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  LanguageProvider() : _currentLocale = _defaultLocale {
    AuthSessionService.instance.addListener(_handleSessionChanged);
  }

  /// Initialize the provider - always start with English (default)
  /// Saved language is only loaded AFTER user explicitly selects it
  Future<void> initialize() async {
    try {
      debugPrint('🔄 [LanguageProvider] Initializing...');
      await SharedPreferences.getInstance();
      debugPrint('✅ [LanguageProvider] SharedPreferences loaded');
      
      // Always start with English on app launch
      _currentLocale = _defaultLocale;
      debugPrint('ℹ️  [LanguageProvider] Starting with default language: ${_defaultLocale.languageCode}');
      
      // NOTE: Saved language preference can be loaded later after user makes initial selection
      // For now, always show English at startup
    } catch (e) {
      debugPrint('❌ [LanguageProvider] Initialize error: $e');
      _currentLocale = _defaultLocale;
    }
  }

  void _handleSessionChanged() {
    final email = AuthSessionService.instance.currentLoggedInUserEmail;
    final storedLanguage = AuthService.getStoredLanguage();

    if (email == null || email.isEmpty) {
      debugPrint('🌐 [LanguageProvider] Session cleared - resetting to default locale');
      _currentLocale = _defaultLocale;
      notifyListeners();
      return;
    }

    final nextLocaleCode = storedLanguage.isEmpty ? _defaultLocale.languageCode : storedLanguage;
    if (nextLocaleCode != _currentLocale.languageCode) {
      debugPrint('🌐 [LanguageProvider] Restoring locale for user=$email -> $nextLocaleCode');
      _currentLocale = Locale(nextLocaleCode);
      notifyListeners();
    }
  }

  /// Change locale immediately (for instant UI update) without saving
  /// The save happens only when user taps Continue
  void setLocaleOnly(String languageCode) {
    debugPrint('🎯 [LanguageProvider.setLocaleOnly] Setting locale to: $languageCode');
    
    if (languageCode == 'en' || languageCode == 'ta') {
      _currentLocale = Locale(languageCode);
      notifyListeners();
      debugPrint('✅ [LanguageProvider.setLocaleOnly] Locale updated and listeners notified');
    }
  }

  /// Change the current language and save it
  Future<bool> setLanguage(String languageCode) async {
    debugPrint('🔤 [LanguageProvider.setLanguage] START - Setting language to: $languageCode');
    
    try {
      // Validate input
      if (languageCode != 'en' && languageCode != 'ta') {
        throw Exception('Invalid language code: $languageCode. Must be "en" or "ta"');
      }
      debugPrint('✓ [LanguageProvider.setLanguage] Language code validated');

      debugPrint('💾 [LanguageProvider.setLanguage] Saving language on active user session...');
      await AuthService.saveSelectedLanguage(languageCode);

      // Update local state
      _currentLocale = Locale(languageCode);
      debugPrint('🎯 [LanguageProvider.setLanguage] Local locale updated to: $languageCode');

      // Notify listeners
      notifyListeners();
      debugPrint('📢 [LanguageProvider.setLanguage] Listeners notified');
      
      debugPrint('✅ [LanguageProvider.setLanguage] COMPLETE - Success!');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [LanguageProvider.setLanguage] ERROR: $e');
      debugPrint('❌ [LanguageProvider.setLanguage] STACK: $stackTrace');
      return false;
    }
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

  @override
  void dispose() {
    AuthSessionService.instance.removeListener(_handleSessionChanged);
    super.dispose();
  }
}
