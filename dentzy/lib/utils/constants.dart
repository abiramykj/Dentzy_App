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

  // Timeouts - changed to 20 seconds for backend API calls
  static const Duration apiTimeout = Duration(seconds: 25);
  static const Duration dbTimeout = Duration(seconds: 10);
  
  // Backend URL - FIXED for local development
  // For Android Emulator: http://10.0.2.2:8090
  // For Real Device: http://<YOUR_PC_IP>:8090 (e.g., 192.168.1.100:8090)
  // Change this based on your setup
  static const String localBackendUrl = 'http://10.0.2.2:8090'; // Android emulator
}
