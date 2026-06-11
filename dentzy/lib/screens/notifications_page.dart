import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/settings_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<_Notification> _notifications;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeNotifications();
      // Request runtime notification permission when screen appears
      NotificationService.instance.requestPermissions().then((_) {
        debugPrint('[Notifications UI] Requested runtime notification permissions');
      });
      _initialized = true;
    }
  }

  void _initializeNotifications() {
    final loc = AppLocalizations.of(context)!;

    _notifications = [
      _Notification(
        title: loc.morningBrushingReminder,
        message: loc.morningBrushingDescription,
        icon: Icons.access_time,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      _Notification(
        title: loc.quizAchievement,
        message: loc.quizAchievementDescription,
        icon: Icons.star,
        time: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      _Notification(
        title: loc.brushingStreak,
        message: loc.brushingStreakDescription,
        icon: Icons.local_fire_department,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      _Notification(
        title: loc.eveningBrushingReminder,
        message: loc.eveningBrushingDescription,
        icon: Icons.bedtime,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.notifications),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                loc.notifications,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your reminders and updates',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              // Status Card
              _buildStatusCard(context, settings),
              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 16),

              // Reminder Controls
              _buildReminderControls(context),
              const SizedBox(height: 18),

              // Notification History
              Text(
                'Recent notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (_notifications.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)?.noData ?? 'No notifications', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                )
              else
                ..._notifications.map(_buildNotificationCard),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildNotificationCard(_Notification notification) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.grey[300]
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.icon,
              color: notification.isRead
                  ? Colors.grey[600]
                  : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(notification.time, AppLocalizations.of(context)!),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SettingsProvider settings) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<bool?>(
            future: NotificationService.instance.areNotificationsEnabled(),
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? 'Notifications Enabled ✅' : 'Notifications Disabled',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reminder times: Morning ${settings.morningTimeDisplay} • Evening ${settings.nightTimeDisplay}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () async {
              await NotificationService.instance.requestPermissions();
              final enabled = await NotificationService.instance.areNotificationsEnabled();
              if (enabled != true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable notifications in system settings')));
                debugPrint('[Notifications UI] Test notification blocked: permissions not granted');
                return;
              }

              debugPrint('[Notifications UI] Triggering test notification');
              await NotificationService.instance.showImmediateNotification(
                id: 9001,
                title: 'Dentzy Test Notification',
                body: 'Notifications are working properly.',
                payload: 'test_immediate',
              );
              debugPrint('[Notifications UI] Test notification shown id=9001');
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Send Test Notification'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () async {
            await NotificationService.instance.openBatteryOptimizationSettings();
          },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.battery_alert_outlined),
              SizedBox(width: 8),
              Text('Battery Settings'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderControls(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final morningOn = settings.morningReminderEnabled;
    final eveningOn = settings.nightReminderEnabled;

    return Row(
      children: [
        Expanded(
          child: morningOn
              ? FilledButton(
                  onPressed: () async {
                    await settings.toggleMorningReminderEnabled(false);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Morning reminder disabled')));
                    setState(() {});
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Morning ON'),
                )
              : OutlinedButton(
                  onPressed: () async {
                    await settings.toggleMorningReminderEnabled(true);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Morning reminder enabled')));
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Morning OFF'),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: eveningOn
              ? FilledButton(
                  onPressed: () async {
                    await settings.toggleEveningReminderEnabled(false);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evening reminder disabled')));
                    setState(() {});
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Evening ON'),
                )
              : OutlinedButton(
                  onPressed: () async {
                    await settings.toggleEveningReminderEnabled(true);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evening reminder enabled')));
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Evening OFF'),
                ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time, AppLocalizations loc) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return loc.justNow;
    } else if (difference.inMinutes < 60) {
      return loc.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return loc.hoursAgo(difference.inHours);
    } else {
      return loc.daysAgo(difference.inDays);
    }
  }
}

class _DiagnosticRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _Notification {
  final String title;
  final String message;
  final IconData icon;
  final DateTime time;
  bool isRead;

  _Notification({
    required this.title,
    required this.message,
    required this.icon,
    required this.time,
    required this.isRead,
  });
}
