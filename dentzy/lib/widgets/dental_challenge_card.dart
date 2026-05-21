import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/dental_challenge.dart';

class DentalChallengeCard extends StatelessWidget {
  final DentalChallenge challenge;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;
  final Function(bool)? onStatusChange;

  const DentalChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.onActionTap,
    this.onStatusChange,
  });

  String _text(BuildContext context, String en, String ta) {
    return Localizations.localeOf(context).languageCode == 'ta' ? ta : en;
  }

  Color _getColorForChallenge(String iconType) {
    switch (iconType) {
      case 'brush':
        return const Color(0xFF3498DB);
      case 'floss':
        return const Color(0xFF9B59B6);
      case 'hydration':
        return const Color(0xFF1ABC9C);
      case 'sugar':
        return const Color(0xFFE74C3C);
      case 'challenge':
        return const Color(0xFFF39C12);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getIconForChallenge(String iconType) {
    switch (iconType) {
      case 'brush':
        return Icons.brush_rounded;
      case 'floss':
        return Icons.clean_hands_rounded;
      case 'hydration':
        return Icons.water_drop_rounded;
      case 'sugar':
        return Icons.cake_rounded;
      case 'challenge':
        return Icons.emoji_events_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Widget _buildActionButton(Color color) {
    final action = onActionTap ?? onTap;

    if (challenge.isCompleted) {
      return _StatusBadge(
        color: Colors.green.shade700,
        bgColor: Colors.green.withOpacity(0.14),
        icon: Icons.check_circle,
        label: 'Completed',
      );
    }

    if (challenge.isActive) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: action,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'Continue',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.20)),
          backgroundColor: color.withOpacity(0.10),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text(
          'Start',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForChallenge(challenge.iconType);
    final progressPercent = (challenge.completionPercentage.clamp(0, 100)) / 100;
    final progressText = challenge.isActive || challenge.isCompleted
        ? '${challenge.currentDay}/${challenge.durationDays}'
        : '0/${challenge.durationDays}';
    final statusText = challenge.isCompleted ? 'Completed' : challenge.isActive ? 'In Progress' : 'Not Started';

    debugPrint('ChallengeCard rebuild: ${challenge.id}');

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_getIconForChallenge(challenge.iconType), color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _text(context, challenge.titleEn, challenge.titleTa),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${challenge.durationDays}d',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _text(context, challenge.descriptionEn, challenge.descriptionTa),
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(statusText, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text(progressText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: challenge.isActive || challenge.isCompleted ? progressPercent : 0,
              minHeight: 6,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 12),
            _buildActionButton(color),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;

  const _StatusBadge({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
