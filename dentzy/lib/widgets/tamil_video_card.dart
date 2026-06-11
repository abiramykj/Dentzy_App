import 'package:flutter/material.dart';

import '../models/tamil_video_lesson.dart';

class TamilVideoCard extends StatefulWidget {
  final TamilVideoLesson video;
  final VoidCallback onTap;
  final Animation<double>? animation;

  const TamilVideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.animation,
  });

  @override
  State<TamilVideoCard> createState() => _TamilVideoCardState();
}

class _TamilVideoCardState extends State<TamilVideoCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final card = Material(
      color: colorScheme.surface,
      elevation: _pressed ? 8 : 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.video.thumbnailUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primaryContainer.withOpacity(0.75),
                                  colorScheme.secondaryContainer.withOpacity(0.75),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x5A000000)],
                          ),
                        ),
                        child: SizedBox.expand(),
                      ),
                      Center(
                        child: Material(
                          color: Colors.white.withOpacity(0.92),
                          shape: const CircleBorder(),
                          elevation: 5,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: widget.onTap,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 30,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.video.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                widget.video.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    Widget content = AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: card,
    );

    if (widget.animation != null) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(widget.animation!);

      content = FadeTransition(
        opacity: widget.animation!,
        child: SlideTransition(
          position: slide,
          child: content,
        ),
      );
    }

    return content;
  }
}