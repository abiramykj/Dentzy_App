import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/pdf_resource.dart';

class PDFResourceCard extends StatefulWidget {
  final PDFResource resource;
  final VoidCallback onTap;
  final Function(bool)? onBookmarkToggle;

  const PDFResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onBookmarkToggle,
  });

  @override
  State<PDFResourceCard> createState() => _PDFResourceCardState();
}

class _PDFResourceCardState extends State<PDFResourceCard> {
  late bool _isBookmarked;

  bool get _isTamil => Localizations.localeOf(context).languageCode == 'ta';

  String _text(String en, String ta) => _isTamil ? ta : en;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.resource.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    _isBookmarked = widget.resource.isBookmarked;
    final readProgress = widget.resource.readPages / widget.resource.pages * 100;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Thumbnail Area
            Container(
              height: 108,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: widget.resource.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            widget.resource.thumbnailUrl,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 40,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 10,
                    right: 10,
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
                  // Page count badge
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.resource.pages} pages',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _text(widget.resource.categoryEn, widget.resource.categoryTa),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    _text(widget.resource.titleEn, widget.resource.titleTa),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    _text(widget.resource.descriptionEn, widget.resource.descriptionTa),
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.25,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Progress if partially read
                  if (widget.resource.readPages > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.resource.readPages}/${widget.resource.pages}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: readProgress / 100,
                        minHeight: 3,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],

                  // Download status
                  if (widget.resource.isDownloaded) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.download_done,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Downloaded',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_download_outlined,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Download',                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
