import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_api_service.dart';
import 'notification_service.dart';
import 'session_manager.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsProvider extends ChangeNotifier {
  // State variables
  bool _remindersEnabled = false;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _nightReminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _morningReminderEnabled = false;
  bool _nightReminderEnabled = false;
  int _lastLoadedSessionEpoch = -1;
  bool _initializing = false;
  int _initializedSessionEpoch = -1;
  final NotificationApiService _notificationApiService = NotificationApiService();
  final NotificationService _notificationService = NotificationService.instance;
  bool _isScheduling = false;
  int? _scheduledMorningEpoch;
  int? _scheduledNightEpoch;

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
  bool get morningReminderEnabled => _morningReminderEnabled;
  bool get nightReminderEnabled => _nightReminderEnabled;

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

      if (_remindersEnabled) {
        try {
          debugPrint('🔄 [SettingsProvider.initialize] Scheduling reminders...');
          await scheduleReminders()
              .timeout(const Duration(seconds: 5));
          debugPrint('✅ [SettingsProvider.initialize] Reminders scheduled');
        } catch (e) {
          debugPrint('⚠️  [SettingsProvider.initialize] Error scheduling reminders: $e');
        }
      } else {
        try {
          debugPrint('🔄 [SettingsProvider.initialize] Clearing previous reminders...');
          await cancelReminders();
        } catch (e) {
          debugPrint('⚠️  [SettingsProvider.initialize] Error clearing reminders: $e');
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
      _morningReminderEnabled = settings['morningReminderEnabled'] as bool? ?? false;
      _nightReminderEnabled = settings['eveningReminderEnabled'] as bool? ?? false;

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

      _scheduledMorningEpoch = prefs.getInt('$settingsKey:scheduledMorningEpoch');
      _scheduledNightEpoch = prefs.getInt('$settingsKey:scheduledNightEpoch');
      debugPrint(
        '[SETTINGS] restored scheduled epochs morning=$_scheduledMorningEpoch night=$_scheduledNightEpoch',
      );

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
          'morningReminderEnabled': _morningReminderEnabled,
          'eveningReminderEnabled': _nightReminderEnabled,
          'morningReminderTime': '${_morningReminderTime.hour}:${_morningReminderTime.minute}',
          'nightReminderTime': '${_nightReminderTime.hour}:${_nightReminderTime.minute}',
        }),
      );
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

    // Toggle morning reminder enabled state
    Future<void> toggleMorningReminderEnabled(bool enabled) async {
      _morningReminderEnabled = enabled;
      await _saveSettings();
        if (_morningReminderEnabled) {
          await scheduleMorningReminder();
          debugPrint('[SETTINGS] Morning reminder enabled');
        } else {
          await cancelMorningReminder();
          debugPrint('[SETTINGS] Morning reminder disabled');
        }
      notifyListeners();
    }

    // Toggle evening reminder enabled state
    Future<void> toggleEveningReminderEnabled(bool enabled) async {
      _nightReminderEnabled = enabled;
      await _saveSettings();
      if (_nightReminderEnabled) {
        await scheduleNightReminder();
        debugPrint('[SETTINGS] Evening reminder enabled');
      } else {
        await cancelEveningReminder();
        debugPrint('[SETTINGS] Evening reminder disabled');
      }
      notifyListeners();
    }

    Future<void> cancelMorningReminder() async {
      try {
        await _notificationService.cancelNotification(101);
        debugPrint('[SETTINGS] cancelMorningReminder id=101');
        // Clear persisted scheduled epoch
        try {
          final prefs = await SharedPreferences.getInstance();
          final settingsKey = _settingsKey();
          if (settingsKey != null) {
            await prefs.remove('\$settingsKey:scheduledMorningEpoch');
          }
        } catch (e) {
          debugPrint('[SETTINGS] cancelMorningReminder: failed to clear stored epoch: $e');
        }
        _scheduledMorningEpoch = null;
      } catch (e) {
        debugPrint('[SETTINGS] cancelMorningReminder error=$e');
      }
    }

    Future<void> cancelEveningReminder() async {
      try {
        await _notificationService.cancelNotification(102);
        debugPrint('[SETTINGS] cancelEveningReminder id=102');
        // Clear persisted scheduled epoch
        try {
          final prefs = await SharedPreferences.getInstance();
          final settingsKey = _settingsKey();
          if (settingsKey != null) {
            await prefs.remove('\$settingsKey:scheduledNightEpoch');
          }
        } catch (e) {
          debugPrint('[SETTINGS] cancelEveningReminder: failed to clear stored epoch: $e');
        }
        _scheduledNightEpoch = null;
      } catch (e) {
        debugPrint('[SETTINGS] cancelEveningReminder error=$e');
      }
    }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    try {
      debugPrint('🔔 [_initializeNotifications] Initializing notification service...');
      await _notificationService.initialize();
      await _notificationService.logDiagnostics(reason: 'settings initialize');
      debugPrint('✅ [_initializeNotifications] Notification service initialized successfully');
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
    // Reconcile desired state with actual scheduled alarms. Do not unconditionally cancel
    // to avoid cancel → schedule loops during rebuilds.
    if (_morningReminderEnabled) {
      await scheduleMorningReminder();
      debugPrint('[SETTINGS] scheduleReminders: morning scheduled (or already present)');
    } else {
      await cancelMorningReminder();
    }

    if (_nightReminderEnabled) {
      await scheduleNightReminder();
      debugPrint('[SETTINGS] scheduleReminders: evening scheduled (or already present)');
    } else {
      await cancelEveningReminder();
    }

    debugPrint('scheduleReminders reconciliation complete');
  }

  // Schedule morning reminder at specified time
  Future<void> scheduleMorningReminder() async {
    if (_isScheduling) {
      debugPrint('[SETTINGS] scheduleMorningReminder skipped: already scheduling');
      return;
    }

    try {
      _isScheduling = true;
      final scheduledDate = _nextOccurrence(_morningReminderTime);
      final scheduledEpoch = scheduledDate.millisecondsSinceEpoch;

      debugPrint('[SETTINGS] scheduleMorningReminder: now=${tz.TZDateTime.now(tz.local)} scheduled=$scheduledDate (epoch=$scheduledEpoch)');

      final settingsKey = _settingsKey();
      if (settingsKey != null && _scheduledMorningEpoch == scheduledEpoch) {
        debugPrint('[SETTINGS] scheduleMorningReminder: identical reminder already scheduled (epoch=$scheduledEpoch), skipping');
        return;
      }

      // Only cancel existing if a different scheduled time exists
      if (_scheduledMorningEpoch != null && _scheduledMorningEpoch != scheduledEpoch) {
        await _notificationService.cancelNotification(101);
        debugPrint('[SETTINGS] scheduleMorningReminder: canceled old morning reminder epoch=$_scheduledMorningEpoch');
      }

      await _notificationService.scheduleNotificationAt(
        id: 101,
        title: 'Good Morning! 🦷',
        body: 'Time to brush your teeth',
        scheduledDate: scheduledDate,
        repeatDaily: true,
        payload: 'morning_brush',
        preferExact: true,
      );

      // Persist scheduled epoch
      try {
        final prefs = await SharedPreferences.getInstance();
        if (settingsKey != null) {
          await prefs.setInt('\$settingsKey:scheduledMorningEpoch', scheduledEpoch);
          _scheduledMorningEpoch = scheduledEpoch;
          debugPrint('[SETTINGS] scheduleMorningReminder: stored scheduledMorningEpoch=$scheduledEpoch');
        }
      } catch (e) {
        debugPrint('[SETTINGS] scheduleMorningReminder: failed to store epoch: $e');
      }

      print('Morning reminder scheduled for ${_morningReminderTime.hour}:${_morningReminderTime.minute} at $scheduledDate');
    } catch (e) {
      print('Error scheduling morning reminder: $e');
    } finally {
      _isScheduling = false;
    }
  }

  // Schedule night reminder at specified time
  Future<void> scheduleNightReminder() async {
    if (_isScheduling) {
      debugPrint('[SETTINGS] scheduleNightReminder skipped: already scheduling');
      return;
    }

    try {
      _isScheduling = true;
      final scheduledDate = _nextOccurrence(_nightReminderTime);
      final scheduledEpoch = scheduledDate.millisecondsSinceEpoch;

      debugPrint('[SETTINGS] scheduleNightReminder: now=${tz.TZDateTime.now(tz.local)} scheduled=$scheduledDate (epoch=$scheduledEpoch)');

      final settingsKey = _settingsKey();
      if (settingsKey != null && _scheduledNightEpoch == scheduledEpoch) {
        debugPrint('[SETTINGS] scheduleNightReminder: identical reminder already scheduled (epoch=$scheduledEpoch), skipping');
        return;
      }

      if (_scheduledNightEpoch != null && _scheduledNightEpoch != scheduledEpoch) {
        await _notificationService.cancelNotification(102);
        debugPrint('[SETTINGS] scheduleNightReminder: canceled old night reminder epoch=$_scheduledNightEpoch');
      }

      await _notificationService.scheduleNotificationAt(
        id: 102,
        title: 'Before Bed! 🌙',
        body: 'Don\'t forget to brush your teeth',
        scheduledDate: scheduledDate,
        repeatDaily: true,
        payload: 'night_brush',
        preferExact: true,
      );

      // Persist scheduled epoch
      try {
        final prefs = await SharedPreferences.getInstance();
        if (settingsKey != null) {
          await prefs.setInt('\$settingsKey:scheduledNightEpoch', scheduledEpoch);
          _scheduledNightEpoch = scheduledEpoch;
          debugPrint('[SETTINGS] scheduleNightReminder: stored scheduledNightEpoch=$scheduledEpoch');
        }
      } catch (e) {
        debugPrint('[SETTINGS] scheduleNightReminder: failed to store epoch: $e');
      }

      print('Night reminder scheduled for ${_nightReminderTime.hour}:${_nightReminderTime.minute} at $scheduledDate');
    } catch (e) {
      print('Error scheduling night reminder: $e');
    } finally {
      _isScheduling = false;
    }
  }

  // Cancel all reminders
  Future<void> cancelReminders() async {
    try {
      await _notificationService.cancelAll();
      print('All reminders canceled');
    } catch (e) {
      print('Error canceling reminders: $e');
    }
  }

  DateTime _nextOccurrence(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    debugPrint('[SETTINGS] _nextOccurrence nowLocal=$now selected=${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} scheduledLocal=$scheduled timezone=${tz.local.name}');
    return DateTime(scheduled.year, scheduled.month, scheduled.day, scheduled.hour, scheduled.minute, scheduled.second, scheduled.millisecond, scheduled.microsecond);
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
