import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationDiagnostics {
  final bool notificationsGranted;
  final bool exactAlarmsGranted;
  final bool batteryOptimizationIgnored;
  final String? manufacturer;
  final int pendingCount;
  final List<int> pendingIds;

  const NotificationDiagnostics({
    required this.notificationsGranted,
    required this.exactAlarmsGranted,
    required this.batteryOptimizationIgnored,
    required this.manufacturer,
    required this.pendingCount,
    required this.pendingIds,
  });
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const MethodChannel _androidChannel = MethodChannel(
    'dentzy/notification_diagnostics',
  );

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _timeZoneInitialized = false;

  Future<void> initialize() async {
    await _ensureInitialized();
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _ensureInitialized();

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final notificationsGranted = await android.requestNotificationsPermission();
      final exactGranted = await android.requestExactAlarmsPermission();
      debugPrint(
        '[Notifications] Android permissions requested notifications=$notificationsGranted exactAlarms=$exactGranted',
      );
    }

    if (ios != null) {
      final permissionsGranted = await ios.requestPermissions(
        alert: true,
        sound: true,
        badge: true,
      );
      debugPrint(
        '[Notifications] iOS permissions requested granted=$permissionsGranted',
      );
    }
  }

  Future<NotificationDiagnostics> collectDiagnostics() async {
    await _ensureInitialized();

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool notificationsGranted = true;
    bool exactAlarmsGranted = true;

    if (android != null) {
      notificationsGranted =
          await android.areNotificationsEnabled() ?? false;
      exactAlarmsGranted =
          await android.canScheduleExactNotifications() ?? false;
    } else if (ios != null) {
      final permissions = await ios.checkPermissions();
      notificationsGranted = permissions?.isEnabled ?? false;
      exactAlarmsGranted = true;
    }

    final pending = await _notificationsPlugin.pendingNotificationRequests();
    final batteryOptimizationIgnored =
        await isBatteryOptimizationIgnored() ?? false;
    final manufacturer = await getAndroidManufacturer();

    return NotificationDiagnostics(
      notificationsGranted: notificationsGranted,
      exactAlarmsGranted: exactAlarmsGranted,
      batteryOptimizationIgnored: batteryOptimizationIgnored,
      manufacturer: manufacturer,
      pendingCount: pending.length,
      pendingIds: pending.map((request) => request.id).toList(growable: false),
    );
  }

  Future<void> logDiagnostics({String reason = 'snapshot'}) async {
    final diagnostics = await collectDiagnostics();
    debugPrint(
      '[Notifications] diagnostics($reason) notifications=${diagnostics.notificationsGranted} exactAlarms=${diagnostics.exactAlarmsGranted} batteryIgnored=${diagnostics.batteryOptimizationIgnored} manufacturer=${diagnostics.manufacturer} pendingCount=${diagnostics.pendingCount} pendingIds=${diagnostics.pendingIds}',
    );
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();
    debugPrint('[Notifications] showImmediateNotification id=$id title=$title body=$body payload=$payload');
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        _buildDetails(body: body),
        payload: payload,
      );
      await logDiagnostics(reason: 'after immediate show id=$id');
    } catch (e) {
      debugPrint('[Notifications] Immediate notification failed: $e');
    }
  }

  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool preferExact = true,
    bool repeatDaily = false,
  }) async {
    await _ensureInitialized();

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canScheduleExact = android == null
        ? true
        : (await android.canScheduleExactNotifications() ?? false);
    final scheduleMode = preferExact && canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    if (preferExact && !canScheduleExact) {
      debugPrint(
        '[Notifications] Exact alarms unavailable, falling back to inexact scheduling for id=$id',
      );
    }

    final scheduledAt = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
      scheduledDate.second,
      scheduledDate.millisecond,
      scheduledDate.microsecond,
    );
    debugPrint(
      '[Notifications] scheduleNotificationAt id=$id title=$title body=$body nowLocal=${tz.TZDateTime.now(tz.local)} scheduledLocal=$scheduledAt scheduledDate=$scheduledDate scheduleMode=$scheduleMode payload=$payload timezone=${tz.local.name}',
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        _buildDetails(body: body),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
      );
      await logDiagnostics(reason: 'after schedule id=$id');
    } catch (e) {
      debugPrint('[Notifications] Notification scheduling failed: $e');
    }
  }

  Future<void> scheduleDelayedTestNotification() async {
    await scheduleNotificationAt(
      id: 9010,
      title: 'Dentzy test notification',
      body: 'This notification fired after a 10-second delay.',
      scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
      payload: 'test_delayed',
      preferExact: true,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    debugPrint('[Notifications] cancelNotification id=$id');
    await _notificationsPlugin.cancel(id);
    await logDiagnostics(reason: 'after cancel id=$id');
  }

  Future<void> cancelAll() async {
    await _ensureInitialized();
    debugPrint('[Notifications] cancelAll');
    await _notificationsPlugin.cancelAll();
    await logDiagnostics(reason: 'after cancelAll');
  }

  Future<bool?> areNotificationsEnabled() async {
    await _ensureInitialized();
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return android.areNotificationsEnabled();
    }

    if (ios != null) {
      final permissions = await ios.checkPermissions();
      return permissions?.isEnabled ?? false;
    }

    return null;
  }

  Future<bool?> canScheduleExactNotifications() async {
    await _ensureInitialized();
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return null;
    }

    return android.canScheduleExactNotifications();
  }

  Future<bool?> isBatteryOptimizationIgnored() async {
    if (!_isAndroid) {
      return null;
    }

    try {
      return await _androidChannel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
    } catch (error) {
      debugPrint('[Notifications] isBatteryOptimizationIgnored error=$error');
      return null;
    }
  }

  Future<String?> getAndroidManufacturer() async {
    if (!_isAndroid) {
      return null;
    }

    try {
      return await _androidChannel.invokeMethod<String>('getAndroidManufacturer');
    } catch (error) {
      debugPrint('[Notifications] getAndroidManufacturer error=$error');
      return null;
    }
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (!_isAndroid) {
      return;
    }

    try {
      await _androidChannel.invokeMethod<void>('openBatteryOptimizationSettings');
    } catch (error) {
      debugPrint('[Notifications] openBatteryOptimizationSettings error=$error');
    }
  }

  Future<void> requestAndShowTestNotifications() async {
    await requestPermissions();
    await showImmediateNotification(
      id: 9001,
      title: 'Dentzy test notification',
      body: 'This notification fired immediately.',
      payload: 'test_immediate',
    );
    await scheduleDelayedTestNotification();
  }

  Future<void> ensurePermissionsAndLogDiagnostics() async {
    await requestPermissions();
    await logDiagnostics(reason: 'ensurePermissionsAndLogDiagnostics');
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _ensureTimeZoneInitialized();

    const androidInitializationSettings = AndroidInitializationSettings(
      'ic_notification',
    );
    const darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          '[Notifications] callback tapped id=${response.id} payload=${response.payload} action=${response.actionId}',
        );
      },
    );

    // Create Android notification channel for brushing reminders
    if (_isAndroid) {
      final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        const channel = AndroidNotificationChannel(
          'brushing_reminders',
          'Brushing Reminders',
          description: 'Daily brushing reminder notifications',
          importance: Importance.max,
        );
        try {
          // In debug mode, remove existing channel to ensure importance/settings are applied during development.
          if (kDebugMode) {
            try {
              await androidImpl.deleteNotificationChannel('brushing_reminders');
              debugPrint('[Notifications] Deleted existing brushing_reminders channel (debug)');
            } catch (e) {
              debugPrint('[Notifications] No existing channel to delete or delete failed: $e');
            }
          }

          await androidImpl.createNotificationChannel(channel);
          debugPrint('[Notifications] Created Android channel brushing_reminders');
        } catch (e) {
          debugPrint('[Notifications] Failed to create channel: $e');
        }
      }
    }

    _initialized = true;
    debugPrint('[Notifications] FlutterLocalNotificationsPlugin initialized');
  }

  Future<void> _ensureTimeZoneInitialized() async {
    if (_timeZoneInitialized) {
      return;
    }

    tz.initializeTimeZones();

    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      debugPrint('[Notifications] Time zone initialized: Asia/Kolkata');
    } catch (error) {
      debugPrint('[Notifications] Time zone initialization failed, falling back to system local: $error');
      try {
        final localTimeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimeZone.identifier));
        debugPrint('[Notifications] Time zone fallback initialized: ${localTimeZone.identifier}');
      } catch (fallbackError) {
        debugPrint('[Notifications] Time zone fallback failed, using UTC as last resort: $fallbackError');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    _timeZoneInitialized = true;
  }

  NotificationDetails _buildDetails({required String body}) {
    final androidDetails = AndroidNotificationDetails(
      'brushing_reminders',
      'Brushing Reminders',
      channelDescription: 'Daily brushing reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification',
      category: AndroidNotificationCategory.reminder,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}