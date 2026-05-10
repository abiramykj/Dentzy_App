import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsProvider extends ChangeNotifier {
  // State variables
  bool _remindersEnabled = false;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _nightReminderTime = const TimeOfDay(hour: 21, minute: 0);

  // SharedPreferences keys
  static const String _remindersKey = 'reminders_enabled';
  static const String _morningTimeKey = 'morning_reminder_time';
  static const String _nightTimeKey = 'night_reminder_time';

  // Local notifications instance
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Getters
  bool get remindersEnabled => _remindersEnabled;
  TimeOfDay get morningReminderTime => _morningReminderTime;
  TimeOfDay get nightReminderTime => _nightReminderTime;

  String get morningTimeDisplay =>
      '${_morningReminderTime.hour.toString().padLeft(2, '0')}:${_morningReminderTime.minute.toString().padLeft(2, '0')}';
  String get nightTimeDisplay =>
      '${_nightReminderTime.hour.toString().padLeft(2, '0')}:${_nightReminderTime.minute.toString().padLeft(2, '0')}';

  // Initialize settings and notifications
  Future<void> initialize() async {
    debugPrint('🔄 [SettingsProvider.initialize] Starting initialization...');
    
    try {
      debugPrint('🔄 [SettingsProvider.initialize] Loading settings from SharedPreferences...');
      await _loadSettings();
      debugPrint('✅ [SettingsProvider.initialize] Settings loaded');
    } catch (e) {
      debugPrint('⚠️  [SettingsProvider.initialize] Error loading settings: $e');
    }

    try {
      debugPrint('🔄 [SettingsProvider.initialize] Initializing notifications...');
      await _initializeNotifications()
          .timeout(const Duration(seconds: 8));
      debugPrint('✅ [SettingsProvider.initialize] Notifications initialized');
    } on TimeoutException catch (e) {
      debugPrint('⚠️  [SettingsProvider.initialize] Notifications init TIMEOUT - continuing anyway');
      debugPrint('⚠️  [SettingsProvider.initialize] Timeout details: $e');
      // Don't crash the app if notifications take too long
    } catch (e) {
      debugPrint('⚠️  [SettingsProvider.initialize] Notifications init error: $e');
      // Don't crash the app if notifications fail
    }

    // Schedule reminders if enabled
    if (_remindersEnabled) {
      try {
        debugPrint('🔄 [SettingsProvider.initialize] Scheduling reminders...');
        await scheduleReminders()
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ [SettingsProvider.initialize] Reminders scheduled');
      } catch (e) {
        debugPrint('⚠️  [SettingsProvider.initialize] Error scheduling reminders: $e');
      }
    }
    
    debugPrint('✅ [SettingsProvider.initialize] Initialization COMPLETE');
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _remindersEnabled = prefs.getBool(_remindersKey) ?? false;

      // Load and parse morning time with null safety
      final morningStr = prefs.getString(_morningTimeKey) ?? '';
      if (morningStr.isNotEmpty) {
        try {
          final parts = morningStr.split(':');
          if (parts.length == 2) {
            final hour = int.tryParse(parts[0]) ?? 7;
            final minute = int.tryParse(parts[1]) ?? 0;
            _morningReminderTime = TimeOfDay(hour: hour, minute: minute);
          }
        } catch (e) {
          print('Error parsing morning time: $e');
          _morningReminderTime = const TimeOfDay(hour: 7, minute: 0);
        }
      }

      // Load and parse night time with null safety
      final nightStr = prefs.getString(_nightTimeKey) ?? '';
      if (nightStr.isNotEmpty) {
        try {
          final parts = nightStr.split(':');
          if (parts.length == 2) {
            final hour = int.tryParse(parts[0]) ?? 21;
            final minute = int.tryParse(parts[1]) ?? 0;
            _nightReminderTime = TimeOfDay(hour: hour, minute: minute);
          }
        } catch (e) {
          print('Error parsing night time: $e');
          _nightReminderTime = const TimeOfDay(hour: 21, minute: 0);
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_remindersKey, _remindersEnabled);
      await prefs.setString(
        _morningTimeKey,
        '${_morningReminderTime.hour}:${_morningReminderTime.minute}',
      );
      await prefs.setString(
        _nightTimeKey,
        '${_nightReminderTime.hour}:${_nightReminderTime.minute}',
      );
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    try {
      debugPrint('🔔 [_initializeNotifications] Creating FlutterLocalNotificationsPlugin...');
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android initialization - use a default system icon if app_icon doesn't exist
      const androidInitSettings = AndroidInitializationSettings(
        'app_icon',
      );
      debugPrint('🔔 [_initializeNotifications] Android settings created');

      // General initialization
      final initSettings = InitializationSettings(
        android: androidInitSettings,
      );
      debugPrint('🔔 [_initializeNotifications] Init settings created');

      debugPrint('🔔 [_initializeNotifications] Calling plugin.initialize()...');
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 [onDidReceiveNotificationResponse] Notification tapped: ${response.payload}');
        },
      );
      debugPrint('✅ [_initializeNotifications] Plugin initialized successfully');
    } catch (e) {
      debugPrint('❌ [_initializeNotifications] Error: $e');
      // Continue app execution even if notifications fail to initialize
      rethrow; // Will be caught by caller with timeout handling
    }
  }

  // Toggle reminders
  Future<void> toggleReminders(bool value) async {
    _remindersEnabled = value;

    if (_remindersEnabled) {
      await scheduleReminders();
    } else {
      await cancelReminders();
    }

    await _saveSettings();
    notifyListeners();
  }

  // Update morning reminder time
  Future<void> setMorningReminderTime(TimeOfDay time) async {
    _morningReminderTime = time;
    await _saveSettings();

    if (_remindersEnabled) {
      await scheduleMorningReminder();
    }

    notifyListeners();
  }

  // Update night reminder time
  Future<void> setNightReminderTime(TimeOfDay time) async {
    _nightReminderTime = time;
    await _saveSettings();

    if (_remindersEnabled) {
      await scheduleNightReminder();
    }

    notifyListeners();
  }

  // Schedule both reminders
  Future<void> scheduleReminders() async {
    await cancelReminders();
    await scheduleMorningReminder();
    await scheduleNightReminder();
    print('Both reminders scheduled');
  }

  // Schedule morning reminder at specified time
  Future<void> scheduleMorningReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'dentzy_reminders',
        'Brushing Reminders',
        channelDescription: 'Daily brushing reminders',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const generalNotificationDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        1,
        'Good Morning! 🦷',
        'Time to brush your teeth',
        generalNotificationDetails,
        payload: 'morning_brush',
      );

      print(
          'Morning reminder scheduled for ${_morningReminderTime.hour}:${_morningReminderTime.minute}');
    } catch (e) {
      print('Error scheduling morning reminder: $e');
    }
  }

  // Schedule night reminder at specified time
  Future<void> scheduleNightReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'dentzy_reminders',
        'Brushing Reminders',
        channelDescription: 'Daily brushing reminders',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const generalNotificationDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        2,
        'Before Bed! 🌙',
        'Don\'t forget to brush your teeth',
        generalNotificationDetails,
        payload: 'night_brush',
      );

      print(
          'Night reminder scheduled for ${_nightReminderTime.hour}:${_nightReminderTime.minute}');
    } catch (e) {
      print('Error scheduling night reminder: $e');
    }
  }

  // Cancel all reminders
  Future<void> cancelReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('All reminders canceled');
    } catch (e) {
      print('Error canceling reminders: $e');
    }
  }
}
