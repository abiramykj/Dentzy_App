import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/educational_article.dart';

class FeaturedArticleCard extends StatefulWidget {
  final EducationalArticle article;
  final VoidCallback onTap;
  final Function(bool)? onBookmarkToggle;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmarkToggle,
  });

  @override
  State<FeaturedArticleCard> createState() => _FeaturedArticleCardState();
}

class _FeaturedArticleCardState extends State<FeaturedArticleCard> {
  late bool _isBookmarked;

  bool get _isTamil => Localizations.localeOf(context).languageCode == 'ta';

  String _text(String en, String ta) => _isTamil ? ta : en;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
  }

  @override
  void didUpdateWidget(covariant FeaturedArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.isBookmarked != widget.article.isBookmarked) {
      _isBookmarked = widget.article.isBookmarked;
    }
  }

  @override
  Widget build(BuildContext context) {
    _isBookmarked = widget.article.isBookmarked;
    return Material(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Image/Header area
              Container(
                height: 118,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: widget.article.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.article.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.article_rounded,
                                size: 50,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                          widget.onBookmarkToggle?.call(_isBookmarked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _text(widget.article.categoryEn, widget.article.categoryTa),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 13,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.article.readTimeMinutes} min',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _text(widget.article.titleEn, widget.article.titleTa),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          _text(widget.article.summaryEn, widget.article.summaryTa),
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.article.isRead) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.article.readProgress / 100,
                            minHeight: 4,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
