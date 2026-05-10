import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_api_service.dart';
import 'session_manager.dart';

class SettingsProvider extends ChangeNotifier {
  // State variables
  bool _remindersEnabled = false;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _nightReminderTime = const TimeOfDay(hour: 21, minute: 0);
  int _lastLoadedSessionEpoch = -1;
  bool _initializing = false;
  int _initializedSessionEpoch = -1;
  final NotificationApiService _notificationApiService = NotificationApiService();

  static const String _settingsSuffix = 'settings';

  // Local notifications instance
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  SettingsProvider() {
    AuthSessionService.instance.addListener(_handleSessionChanged);
  }

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
    final currentEpoch = AuthSessionService.instance.sessionEpoch;
    if (_initializing || _initializedSessionEpoch == currentEpoch) {
      debugPrint('[SETTINGS] initialize skipped epoch=$currentEpoch initializing=$_initializing');
      return;
    }

    _initializing = true;
    debugPrint('🔄 [SettingsProvider.initialize] Starting initialization...');

    try {
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

      try {
        debugPrint('🔄 [SettingsProvider.initialize] Clearing previous reminders before rescheduling...');
        await cancelReminders();
      } catch (e) {
        debugPrint('⚠️  [SettingsProvider.initialize] Error clearing reminders: $e');
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

      await _syncNotificationSettingsToBackend();

      _initializedSessionEpoch = currentEpoch;
      debugPrint('✅ [SettingsProvider.initialize] Initialization COMPLETE epoch=$_initializedSessionEpoch');
    } finally {
      _initializing = false;
    }
  }

  void _handleSessionChanged() {
    debugPrint('[SETTINGS] session changed user=${AuthSessionService.instance.currentLoggedInUserEmail} epoch=${AuthSessionService.instance.sessionEpoch}');
    _resetState();
    notifyListeners();
    initialize();
  }

  String? _settingsKey() {
    final email = AuthSessionService.instance.currentLoggedInUserEmail;
    if (email == null || email.isEmpty) {
      return null;
    }

    return AuthSessionService.userScopedKey(email, _settingsSuffix);
  }

  void _resetState() {
    _remindersEnabled = false;
    _morningReminderTime = const TimeOfDay(hour: 7, minute: 0);
    _nightReminderTime = const TimeOfDay(hour: 21, minute: 0);
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final loadEpoch = AuthSessionService.instance.sessionEpoch;
      _resetState();
      final prefs = await SharedPreferences.getInstance();
      if (loadEpoch != AuthSessionService.instance.sessionEpoch) {
        debugPrint('[SETTINGS] Ignoring stale load for epoch=$loadEpoch current=${AuthSessionService.instance.sessionEpoch}');
        return;
      }

      final settingsKey = _settingsKey();
      if (settingsKey == null) {
        notifyListeners();
        return;
      }

      debugPrint('[STORAGE] Loading key=$settingsKey');
      final encoded = prefs.getString(settingsKey) ?? '';
      if (encoded.isEmpty) {
        notifyListeners();
        return;
      }

      final decoded = jsonDecode(encoded);
      final settings = decoded is Map ? decoded.map((key, value) => MapEntry(key.toString(), value)) : <String, dynamic>{};

      _remindersEnabled = settings['remindersEnabled'] as bool? ?? false;

      // Load and parse morning time with null safety
      final morningStr = settings['morningReminderTime']?.toString() ?? '';
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
      final nightStr = settings['nightReminderTime']?.toString() ?? '';
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

      if (loadEpoch != AuthSessionService.instance.sessionEpoch) {
        debugPrint('[SETTINGS] Discarding decoded settings for stale epoch=$loadEpoch');
        return;
      }

      _lastLoadedSessionEpoch = loadEpoch;
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsKey = _settingsKey();
      if (settingsKey == null) {
        debugPrint('[SETTINGS] save skipped: no active session');
        return;
      }

      debugPrint('[STORAGE] Saving key=$settingsKey');
      _lastLoadedSessionEpoch = AuthSessionService.instance.sessionEpoch;
      await prefs.setString(
        settingsKey,
        jsonEncode({
          'remindersEnabled': _remindersEnabled,
          'morningReminderTime': '${_morningReminderTime.hour}:${_morningReminderTime.minute}',
          'nightReminderTime': '${_nightReminderTime.hour}:${_nightReminderTime.minute}',
        }),
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
    await _syncNotificationSettingsToBackend();
    notifyListeners();
  }

  // Update morning reminder time
  Future<void> setMorningReminderTime(TimeOfDay time) async {
    _morningReminderTime = time;
    await _saveSettings();
    await _syncNotificationSettingsToBackend();

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

  Future<void> _syncNotificationSettingsToBackend() async {
    final email = AuthSessionService.instance.currentLoggedInUserEmail;
    if (email == null || email.isEmpty) {
      return;
    }

    final synced = await _notificationApiService.saveNotificationSettings(
      reminderTime: _morningReminderTime,
      enabled: _remindersEnabled,
    );

    if (!synced) {
      debugPrint('[SETTINGS] notification sync skipped or failed');
    }
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

  Future<void> resetForSessionChange() async {
    _resetState();
    notifyListeners();
  }

  @override
  void dispose() {
    AuthSessionService.instance.removeListener(_handleSessionChanged);
    super.dispose();
  }
}
