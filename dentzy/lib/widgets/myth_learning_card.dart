import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/myth_learning_card.dart';

class MythLearningCardWidget extends StatefulWidget {
  final MythLearningCard mythCard;
  final VoidCallback? onMarkAsLearned;

  const MythLearningCardWidget({
    super.key,
    required this.mythCard,
    this.onMarkAsLearned,
  });

  @override
  State<MythLearningCardWidget> createState() => _MythLearningCardWidgetState();
}

class _MythLearningCardWidgetState extends State<MythLearningCardWidget>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late bool _isLearned;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.mythCard.isExpanded;
    _isLearned = widget.mythCard.isLearned;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';
    String text(String en, String ta) => isTamil ? ta : en;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.08),
              AppTheme.primaryColor.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            if (_isExpanded)
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            // Header - Myth
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE74C3C).withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFE74C3C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text('Myth', 'கட்டுக்கதை'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE74C3C),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          text(widget.mythCard.mythEn, widget.mythCard.mythTa),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5)
                        .animate(_controller),
                    child: Icon(
                      Icons.expand_more,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Expansion Area
            SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOutCubic,
              ),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),

                  // Truth
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text('Truth', 'உண்மை'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                text(widget.mythCard.truthEn, widget.mythCard.truthTa),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Explanation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text('Why?', 'ஏன்?'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            text(widget.mythCard.explanationEn, widget.mythCard.explanationTa),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Scientific Facts
                  if (widget.mythCard.scientificFactsEn.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text('Facts', 'விவரங்கள்'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(isTamil ? widget.mythCard.scientificFactsTa : widget.mythCard.scientificFactsEn)
                              .map((fact) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    fact,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],

                  // Learn Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_isLearned) {
                            setState(() {
                              _isLearned = true;
                            });
                            widget.onMarkAsLearned?.call();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLearned
                              ? Colors.green
                              : AppTheme.primaryColor,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isLearned
                                  ? Icons.check_circle
                                  : Icons.lightbulb_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isLearned
                                  ? 'Learned!'
                                  : 'Mark as Learned',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
