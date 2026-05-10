import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/progress_chart.dart';
import '../utils/theme.dart';
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProgressChart(
                    title: _t(context, 'Overall Accuracy', 'ஒட்டுமொத்த துல்லியம்'),
                    percentage: 82.5,
                    color: AppTheme.primaryColor,
                    size: 120,
                  ),
                  ProgressChart(
                    title: _t(context, 'Weekly Target', 'வார இலக்கு'),
                    percentage: 65.0,
                    color: AppTheme.successColor,
                    size: 120,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(context, 'Statistics', 'புள்ளிவிவரங்கள்'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    icon: Icons.quiz,
                    title: _t(context, 'Total Questions Answered', 'மொத்த கேள்விகள்'),
                    value: '125',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    icon: Icons.check_circle,
                    title: _t(context, 'Correct Answers', 'சரியான பதில்கள்'),
                    value: '103',
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    title: _t(context, 'Current Streak', 'தற்போதைய தொடர்'),
                    value: '12 days',
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    icon: Icons.calendar_today,
                    title: _t(context, 'Last Activity', 'கடைசி செயல்பாடு'),
                    value: 'Today',
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category Performance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(context, 'Category Performance', 'பிரிவு செயல்திறன்'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryCard(context, loc.health, 0.9, AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  _buildCategoryCard(context, loc.science, 0.85, AppTheme.successColor),
                  const SizedBox(height: 8),
                  _buildCategoryCard(context, loc.technology, 0.75, AppTheme.accentColor),
                  const SizedBox(height: 8),
                  _buildCategoryCard(context, loc.history, 0.8, AppTheme.secondaryColor),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Activity Heatmap (simplified)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(context, 'Recent Activity', 'சமீபத்திய செயல்பாடு'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      21,
                      (index) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: index % 3 == 0
                            ? AppTheme.primaryColor.withOpacity(0.8)
                            : index % 3 == 1
                              ? AppTheme.primaryColor.withOpacity(0.4)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _t(BuildContext context, String english, String tamil) {
    return Localizations.localeOf(context).languageCode == 'ta' ? tamil : english;
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

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    double percentage,
    Color color,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
