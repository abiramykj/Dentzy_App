import 'package:flutter/material.dart';

import '../services/tracker_service.dart';
import '../utils/theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/progress_chart.dart';
import '../l10n/app_localizations.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.yourStatistics),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: TrackerService.instance.fetchStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data ?? const <String, dynamic>{};
          final completedArticles = _intValue(stats, 'completed_articles');
          final totalArticles = _intValue(stats, 'total_articles');
          final articlePercentage = _intValue(stats, 'article_percentage');
          final watchedVideos = _intValue(stats, 'watched_videos');
          final totalVideos = _intValue(stats, 'total_videos');
          final videoPercentage = _intValue(stats, 'video_percentage');
          final mythsChecked = _intValue(stats, 'myths_checked');
          final brushingSessions = _intValue(stats, 'brushing_sessions');
          final currentStreak = _intValue(stats, 'current_streak');
          final articleDisplayCount = _safeCompletedCount(completedArticles, totalArticles);
          final videoDisplayCount = _safeCompletedCount(watchedVideos, totalVideos);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProgressChart(
                        title: _t(context, 'Articles Completed', 'கட்டுரைகள் முடிந்தது'),
                        percentage: articlePercentage.toDouble(),
                        color: AppTheme.primaryColor,
                        size: 120,
                      ),
                      ProgressChart(
                        title: _t(context, 'Videos Watched', 'வீடியோக்கள் பார்த்தது'),
                        percentage: videoPercentage.toDouble(),
                        color: AppTheme.successColor,
                        size: 120,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(context, 'Learning Progress', 'கற்றல் முன்னேற்றம்'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        icon: Icons.menu_book_rounded,
                        title: _t(context, 'Learning Articles Completed', 'கற்றல் கட்டுரைகள் முடிந்தது'),
                        value: '$articleDisplayCount / $totalArticles',
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        icon: Icons.play_circle_fill_rounded,
                        title: _t(context, 'Videos Watched', 'வீடியோக்கள் பார்த்தது'),
                        value: '$videoDisplayCount / $totalVideos',
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        icon: Icons.quiz_rounded,
                        title: _t(context, 'Myths Checked', 'மித் சோதனைகள்'),
                        value: mythsChecked.toString(),
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        icon: Icons.brush_rounded,
                        title: _t(context, 'Brushing Sessions', 'பல் துலக்கும் அமர்வுகள்'),
                        value: brushingSessions.toString(),
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        icon: Icons.local_fire_department_rounded,
                        title: _t(context, 'Current Streak', 'தற்போதைய தொடர்'),
                        value: _t(context, '$currentStreak days', '$currentStreak நாட்கள்'),
                        color: AppTheme.primaryDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(context, 'Activity Summary', 'செயல்பாட்டு சுருக்கம்'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _summaryRow(context, _t(context, 'Article completion', 'கட்டுரை நிறைவு'), '$articleDisplayCount / $totalArticles'),
                            const SizedBox(height: 10),
                            _summaryRow(context, _t(context, 'Video watch rate', 'வீடியோ பார்வை வீதம்'), '$videoDisplayCount / $totalVideos'),
                            const SizedBox(height: 10),
                            _summaryRow(context, _t(context, 'Myths checked', 'மித்கள் சோதனை'), mythsChecked.toString()),
                            const SizedBox(height: 10),
                            _summaryRow(context, _t(context, 'Brushing sessions', 'பல் துலக்கும் அமர்வுகள்'), brushingSessions.toString()),
                            const SizedBox(height: 10),
                            _summaryRow(context, _t(context, 'Current streak', 'தற்போதைய தொடர்'), currentStreak.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _t(BuildContext context, String english, String tamil) {
    return Localizations.localeOf(context).languageCode == 'ta' ? tamil : english;
  }

  int _intValue(Map<String, dynamic> stats, String key) {
    final value = stats[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _safeCompletedCount(int completed, int total) {
    if (total <= 0) {
      return 0;
    }
    return completed.clamp(0, total);
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}