import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Weekly';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.reports),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildPeriodButton(loc.weekly),
                  const SizedBox(width: 8),
                  _buildPeriodButton(loc.monthly),
                  const SizedBox(width: 8),
                  _buildPeriodButton(loc.yearly),
                ],
              ),
            ),

            // Performance Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.performancePeriod(_selectedPeriod),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomCard(
                          gradient: AppTheme.primaryGradient,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Questions',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '45',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomCard(
                          gradient: AppTheme.successGradient,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correct',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '39',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Charts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.category,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildCategoryRow(context, loc.health, 12, 15, AppTheme.primaryColor),
                        const SizedBox(height: 16),
                        _buildCategoryRow(context, loc.science, 10, 12, AppTheme.successColor),
                        const SizedBox(height: 16),
                        _buildCategoryRow(context, loc.technology, 9, 11, AppTheme.accentColor),
                        const SizedBox(height: 16),
                        _buildCategoryRow(context, loc.history, 8, 7, AppTheme.secondaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Achievements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.achievements,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAchievementBadge('📱 First Myth', 'Checked first myth'),
                        _buildAchievementBadge('🔥 7-Day Streak', 'Maintained 7-day streak'),
                        _buildAchievementBadge('🎯 Perfect Day', '100% accuracy in a day'),
                      ],
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

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: AppTheme.dividerColor),
          ),
          child: Center(
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    int correct,
    int total,
    Color color,
  ) {
    final percentage = correct / total;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            '$correct/$total',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
