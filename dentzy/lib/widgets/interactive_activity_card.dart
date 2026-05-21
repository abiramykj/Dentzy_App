import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/interactive_activity.dart';

class InteractiveActivityCard extends StatelessWidget {
  final InteractiveActivity activity;
  final VoidCallback onTap;

  const InteractiveActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  String _text(BuildContext context, String en, String ta) {
    return Localizations.localeOf(context).languageCode == 'ta' ? ta : en;
  }

  IconData _getIconForActivityType(String activityType) {
    switch (activityType) {
      case 'sorting':
        return Icons.category_rounded;
      case 'checklist':
        return Icons.checklist_rounded;
      case 'matching':
        return Icons.link_rounded;
      case 'challenge':
        return Icons.trending_up_rounded;
      default:
        return Icons.games_rounded;
    }
  }

  Color _getColorForActivityType(String activityType) {
    switch (activityType) {
      case 'sorting':
        return const Color(0xFF3498DB);
      case 'checklist':
        return const Color(0xFF2ECC71);
      case 'matching':
        return const Color(0xFFE67E22);
      case 'challenge':
        return const Color(0xFF9B59B6);
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForActivityType(activity.activityType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and completion status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Icon(
                    _getIconForActivityType(activity.activityType),
                    color: color,
                    size: 24,
                  ),
                ),
                if (activity.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${activity.durationMinutes} min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              _text(context, activity.titleEn, activity.titleTa),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              _text(context, activity.descriptionEn, activity.descriptionTa),
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Score or progress
            if (activity.isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Score ${activity.score}/100',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Start',                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
