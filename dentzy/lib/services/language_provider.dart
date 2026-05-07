import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language';
  static const String _legacyLanguageKey = 'app_language';
  static const Locale _defaultLocale = Locale('en');

  late Locale _currentLocale;

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  LanguageProvider() : _currentLocale = _defaultLocale;

  /// Initialize the provider - always start with English (default)
  /// Saved language is only loaded AFTER user explicitly selects it
  Future<void> initialize() async {
    try {
      debugPrint('🔄 [LanguageProvider] Initializing...');
      final prefs = await SharedPreferences.getInstance();
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

      // Get SharedPreferences instance
      debugPrint('🔄 [LanguageProvider.setLanguage] Getting SharedPreferences instance...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ [LanguageProvider.setLanguage] SharedPreferences instance obtained');

      // Save language
      debugPrint('💾 [LanguageProvider.setLanguage] Calling setString("$_languageKey", "$languageCode")...');
      final saved = await prefs.setString(_languageKey, languageCode);
      debugPrint('📊 [LanguageProvider.setLanguage] setString returned: $saved');

      if (!saved) {
        throw Exception('setString() returned false - could not save to SharedPreferences');
      }

      // Verify save
      final verified = prefs.getString(_languageKey);
      debugPrint('🔍 [LanguageProvider.setLanguage] Verification - saved value: $verified');

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
}
