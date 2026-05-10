import 'package:flutter/foundation.dart';
import '../services/session_manager.dart';

class HiveDB {
  static const String _profileSuffix = 'profile';
  static const String _mythHistorySuffix = 'history';

  static String? _currentEmail([String? userEmail]) {
    final email = userEmail ?? AuthSessionService.instance.currentLoggedInUserEmail;
    if (email == null || email.isEmpty) {
      return null;
    }

    return AuthSessionService.normalizeEmail(email);
  }

  static String? _keyFor(String suffix, [String? userEmail]) {
    final email = _currentEmail(userEmail);
    if (email == null) {
      return null;
    }

    return AuthSessionService.userScopedKey(email, suffix);
  }

  // Initialize Hive database
  static Future<void> initHive() async {
    try {
      if (kDebugMode) {
        print('Initializing Hive database...');
      }
      
      // TODO: Initialize Hive and register adapters
      // Hive.registerAdapter(UserModelAdapter());
      // Hive.registerAdapter(MythResultModelAdapter());
      
      if (kDebugMode) {
        print('Hive database initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Hive: $e');
      }
      rethrow;
    }
  }

  // Save user data
  static Future<void> saveUser(Map<String, dynamic> userData, {String? userEmail}) async {
    try {
      final key = _keyFor(_profileSuffix, userEmail);
      if (key == null) {
        if (kDebugMode) {
          print('Saving user data skipped: no active user');
        }
        return;
      }

      if (kDebugMode) {
        print('Saving user data for key=$key...');
      }
      
      // TODO: Save to Hive
      // var box = Hive.box('users');
      // await box.put(key, userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      rethrow;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUser({String? userEmail}) async {
    try {
      final key = _keyFor(_profileSuffix, userEmail);
      if (key == null) {
        return null;
      }

      if (kDebugMode) {
        print('Fetching user data for key=$key...');
      }
      
      // TODO: Get from Hive
      // var box = Hive.box('users');
      // return box.get('current_user');
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      rethrow;
    }
  }

  // Save myth result
  static Future<void> saveMythResult(Map<String, dynamic> resultData, {String? userEmail}) async {
    try {
      final key = _keyFor(_mythHistorySuffix, userEmail);
      if (key == null) {
        if (kDebugMode) {
          print('Saving myth result skipped: no active user');
        }
        return;
      }

      if (kDebugMode) {
        print('Saving myth result for key=$key...');
      }
      
      // TODO: Save to Hive
      // var box = Hive.box('myth_results');
      // await box.add(resultData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving myth result: $e');
      }
      rethrow;
    }
  }

  // Get all myth results
  static Future<List<Map<String, dynamic>>> getAllMythResults({String? userEmail}) async {
    try {
      final key = _keyFor(_mythHistorySuffix, userEmail);
      if (key == null) {
        return [];
      }

      if (kDebugMode) {
        print('Fetching all myth results for key=$key...');
      }
      
      // TODO: Get from Hive
      // var box = Hive.box('myth_results');
      // return box.values.cast<Map<String, dynamic>>().toList();
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching myth results: $e');
      }
      rethrow;
    }
  }

  // Clear all data
  static Future<void> clearAllData({String? userEmail}) async {
    try {
      final profileKey = _keyFor(_profileSuffix, userEmail);
      final mythHistoryKey = _keyFor(_mythHistorySuffix, userEmail);

      if (kDebugMode) {
        print('Clearing local data for profileKey=$profileKey mythHistoryKey=$mythHistoryKey...');
      }
      
      // TODO: Clear Hive boxes
      // await Hive.box('users').clear();
      // await Hive.box('myth_results').clear();
      
      if (kDebugMode) {
        print('All data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing data: $e');
      }
      rethrow;
    }
  }
}
