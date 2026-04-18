class AppConstants {
  // API endpoints
  static const String baseUrl = 'https://api.dentzy.app';
  static const String mythsEndpoint = '/api/myths';
  static const String usersEndpoint = '/api/users';

  // App strings
  static const String appName = 'Dentzy';
  static const String appTagline = 'Bust the Myths, Embrace the Truth';

  // Database
  static const String dbName = 'dentzy_db';
  static const String usersBox = 'users';
  static const String mythResultsBox = 'myth_results';
  static const String userSettingsBox = 'user_settings';

  // Categories
  static const List<String> mythCategories = [
    'Health',
    'Science',
    'Technology',
    'History',
    'Society',
    'Environment',
  ];

  // Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ta': 'Tamil',
  };

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration dbTimeout = Duration(seconds: 10);
}
