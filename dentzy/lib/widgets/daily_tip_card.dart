import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/daily_tip.dart';

class DailyTipCard extends StatefulWidget {
  final DailyTip tip;
  final VoidCallback onTap;
  final VoidCallback? onViewed;

  const DailyTipCard({
    super.key,
    required this.tip,
    required this.onTap,
    this.onViewed,
  });

  @override
  State<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends State<DailyTipCard> {
  late bool _isViewed;

  bool get _isTamil => Localizations.localeOf(context).languageCode == 'ta';

  String _text(String en, String ta) => _isTamil ? ta : en;

  @override
  void initState() {
    super.initState();
    _isViewed = widget.tip.isViewed;
  }

  IconData _getIconForCategory(String iconType) {
    switch (iconType) {
      case 'brush':
        return Icons.brush_rounded;
      case 'floss':
        return Icons.clean_hands_rounded;
      case 'food':
        return Icons.fastfood_rounded;
      case 'prevention':
        return Icons.shield_rounded;
      case 'habit':
        return Icons.favorite_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Color _getColorForCategory(String iconType) {
    switch (iconType) {
      case 'brush':
        return const Color(0xFF3498DB);
      case 'floss':
        return const Color(0xFF9B59B6);
      case 'food':
        return const Color(0xFFF39C12);
      case 'prevention':
        return const Color(0xFF2ECC71);
      case 'habit':
        return const Color(0xFFE74C3C);
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForCategory(widget.tip.iconType);

    return InkWell(
      onTap: () {
        if (!_isViewed) {
          setState(() {
            _isViewed = true;
          });
          widget.onViewed?.call();
        }
        widget.onTap();
      },
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
            // Icon and title area
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Icon(
                    _getIconForCategory(widget.tip.iconType),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _text(widget.tip.categoryEn, widget.tip.categoryTa),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (_isViewed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Viewed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Tip content
            Text(
              _text(widget.tip.tipEn, widget.tip.tipTa),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
