class Localization {
  static String _currentLanguage = 'en';

  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_name': 'Dentzy',
      'app_tagline': 'Bust the Myths, Embrace the Truth',
      'welcome': 'Welcome to Dentzy',
      'select_language': 'Select Language',
      'home': 'Home',
      'myth_checker': 'Myth Checker',
      'tracker': 'Tracker',
      'reports': 'Reports',
      'learn': 'Learn',
      'profile': 'Profile',
      'logout': 'Logout',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'no_data': 'No data available',
    },
    'ta': {
      'app_name': 'டென்ட்ஸி',
      'app_tagline': 'கட்டுக்கதைகளை உடைக்கவும், உண்மையை ஏற்றுக்கொள்ளுங்கள்',
      'welcome': 'டென்ட்ஸிக்கு வரவேற்கிறோம்',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'home': 'முகப்பு',
      'myth_checker': 'கட்டுக்கதை சரிபார்ப்பான்',
      'tracker': 'ট्रैக்கர்',
      'reports': 'அறிக்கைகள்',
      'learn': 'கற்க',
      'profile': 'சுயவிவரம்',
      'logout': 'வெளியே இறங்கவும்',
      'loading': 'ஏற்றுதல்...',
      'error': 'பிழை',
      'retry': 'மீண்டும் முயற்சி செய்யவும்',
      'cancel': 'ரद்द செய்க',
      'save': 'சேமிக்க',
      'delete': 'அழிக்க',
      'edit': 'திருத்த',
      'no_data': 'தரவு கிடைக்கவில்லை',
    },
  };

  static void setCurrentLanguage(String language) {
    if (_localizedStrings.containsKey(language)) {
      _currentLanguage = language;
    }
  }

  static String getCurrentLanguage() {
    return _currentLanguage;
  }

  static String getString(String key, {String? locale}) {
    locale ??= _currentLanguage;
    return _localizedStrings[locale]?[key] ?? _localizedStrings['en']?[key] ?? key;
  }

  static List<String> getSupportedLocales() {
    return _localizedStrings.keys.toList();
  }
}
