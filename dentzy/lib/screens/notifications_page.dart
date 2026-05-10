import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<_Notification> _notifications;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeNotifications();
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.notifications),
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification.isRead = true;
                  }
                });
              },
              child: Text(loc.markAllAsRead),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.noData ?? 'No notifications',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
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
                  : AppTheme.primaryColor.withOpacity(0.2),
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
