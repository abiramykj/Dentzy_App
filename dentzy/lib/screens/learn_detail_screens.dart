import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/bookmark.dart';
import '../models/dental_challenge.dart';
import '../models/educational_article.dart';
import '../models/interactive_activity.dart';
import '../models/pdf_resource.dart';
import '../services/learn_service.dart';
import '../services/tracker_service.dart';
import '../utils/theme.dart';

String _localized(BuildContext context, String en, String ta) {
  return Localizations.localeOf(context).languageCode == 'ta' ? ta : en;
}

class ArticleDetailScreen extends StatefulWidget {
  final EducationalArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late bool _isBookmarked;
  final LearnService _learnService = LearnService();

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
    unawaited(TrackerService.instance.markArticleCompleted(widget.article.id));
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      widget.article.isBookmarked = _isBookmarked;
    });

    if (_isBookmarked) {
      _learnService.addBookmark(
        Bookmark(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          resourceId: widget.article.id,
          resourceType: 'article',
          resourceTitle: widget.article.titleEn,
          bookmarkedDate: DateTime.now(),
        ),
      );
    } else {
      _learnService.removeBookmark(widget.article.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _localized(context, widget.article.titleEn, widget.article.titleTa);
    final category = _localized(context, widget.article.categoryEn, widget.article.categoryTa);
    final summary = _localized(context, widget.article.summaryEn, widget.article.summaryTa);
    final content = _localized(context, widget.article.contentEn, widget.article.contentTa);
    final tags = Localizations.localeOf(context).languageCode == 'ta'
        ? widget.article.tagsTa
        : widget.article.tagsEn;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_localized(context, 'Read', 'படி')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(widget.article.imageUrl, fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Icon(Icons.menu_book_rounded, size: 64, color: Colors.white),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'article_bookmark_${widget.article.id}',
                      onPressed: _toggleBookmark,
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      child: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(label: category, color: AppTheme.primaryColor),
                _Pill(label: '${widget.article.readTimeMinutes} min', color: AppTheme.successColor),
                _Pill(label: widget.article.isRead ? _localized(context, 'Read', 'படி') : _localized(context, 'New', 'புதியது'), color: widget.article.isRead ? AppTheme.successColor : AppTheme.accentColor),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              _localized(context, 'What to know', 'தெரிந்துகொள்ள வேண்டியது'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              _localized(context, 'Tips', 'குறிப்புகள்'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.10),
                      labelStyle: TextStyle(color: AppTheme.primaryDark),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityDetailScreen extends StatefulWidget {
  final InteractiveActivity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final LearnService _learnService = LearnService();
  final Set<String> _selectedItems = <String>{};
  final Set<int> _checkedSteps = <int>{};
  bool _submitted = false;
  int _score = 0;

  bool get _isSorting => widget.activity.activityType == 'sorting';

  List<String> get _items => Localizations.localeOf(context).languageCode == 'ta'
      ? widget.activity.itemsTa
      : widget.activity.itemsEn;

  List<String> get _answers => widget.activity.correctAnswers;

  int _calculateScore() {
    if (_isSorting) {
      final correctSelected = _selectedItems.where(_answers.contains).length;
      final incorrectSelected = _selectedItems.difference(_answers.toSet()).length;
      final raw = ((correctSelected / _answers.length) * 100).round() - (incorrectSelected * 10);
      return raw.clamp(0, 100);
    }

    final total = _items.length;
    return total == 0 ? 0 : ((_checkedSteps.length / total) * 100).round();
  }

  void _submit() {
    final score = _calculateScore();
    setState(() {
      _submitted = true;
      _score = score;
    });
    _learnService.markActivityAsCompleted(widget.activity.id, score);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          score >= 80
              ? _localized(context, 'Nice work!', 'நல்ல வேலை!')
              : _localized(context, 'Keep trying', 'மீண்டும் முயலுங்கள்'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _localized(context, widget.activity.titleEn, widget.activity.titleTa);
    final description = _localized(context, widget.activity.descriptionEn, widget.activity.descriptionTa);
    final color = widget.activity.activityType == 'sorting'
        ? const Color(0xFF3498DB)
        : const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_localized(context, 'Activity', 'செயல்பாடு')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(
              icon: widget.activity.activityType == 'sorting'
                  ? Icons.category_rounded
                  : Icons.checklist_rounded,
              color: color,
              title: title,
              description: description,
              badge: widget.activity.isCompleted
                  ? _localized(context, 'Done', 'முடிந்தது')
                  : _localized(context, 'Play', 'தொடங்கு'),
            ),
            const SizedBox(height: 16),
            if (_isSorting) ...[
              Text(
                _localized(context, 'Tap healthy foods', 'ஆரோக்கிய உணவுகளைத் தேர்வு செய்யவும்'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _items
                    .map(
                      (item) => ChoiceChip(
                        label: Text(item),
                        selected: _selectedItems.contains(item),
                        selectedColor: color.withOpacity(0.18),
                        onSelected: (_) {
                          setState(() {
                            if (_selectedItems.contains(item)) {
                              _selectedItems.remove(item);
                            } else {
                              _selectedItems.add(item);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ] else ...[
              Text(
                _localized(context, 'Check each step', 'ஒவ்வொரு படியையும் குறிக்கவும்'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _items.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    value: _checkedSteps.contains(index),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _checkedSteps.add(index);
                        } else {
                          _checkedSteps.remove(index);
                        }
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    title: Text(_items[index]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_submitted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_localized(context, 'Score', 'மதிப்பு')}: $_score/100',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(_localized(context, 'Finish', 'முடிக்கவும்')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChallengeDetailScreen extends StatefulWidget {
  final DentalChallenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final LearnService _learnService = LearnService();
  late int _currentDay;
  late bool _isActive;
  late bool _isCompleted;
  late Set<int> _completedDays;
  late int _streak;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.challenge.currentDay;
    _isActive = widget.challenge.isActive;
    _isCompleted = widget.challenge.isCompleted;
    _completedDays = _learnService.getCompletedDays(widget.challenge.id);
    _streak = _learnService.challengeStreak;
  }

  void _startChallenge() {
    setState(() {
      _isActive = true;
    });
    _learnService.startChallenge(widget.challenge.id);
  }

  void _advanceDay() {
    if (_isCompleted) {
      return;
    }

    final changed = _learnService.markTodayComplete(widget.challenge.id);
    if (!changed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localized(context, 'Today is already marked complete', 'இன்றைய முன்னேற்றம் ஏற்கனவே பதிவு செய்யப்பட்டது')),
        ),
      );
      return;
    }

    setState(() {
      _currentDay = widget.challenge.currentDay;
      _isActive = widget.challenge.isActive;
      _completedDays = _learnService.getCompletedDays(widget.challenge.id);
      _streak = _learnService.challengeStreak;
      if (_currentDay >= widget.challenge.durationDays) {
        _isCompleted = true;
      }
    });

    if (_isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localized(context, 'Challenge completed!', 'சவால் முடிந்தது!'))),
      );
    }
  }

  List<String> _dailyTasks(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';
    switch (widget.challenge.id) {
      case 'chal_1':
        return isTamil
            ? ['காலை 2 நிமிடம் துலக்கு', 'இரவு 2 நிமிடம் துலக்கு', 'நாக்கை சுத்தம் செய்']
            : ['Brush 2 minutes in the morning', 'Brush 2 minutes at night', 'Clean your tongue'];
      case 'chal_2':
        return isTamil
            ? ['சோடா தவிர்', 'தண்ணீர் குடி', 'உணவுக்குப் பிறகு வாயை கழுவு']
            : ['Skip soda today', 'Drink water through the day', 'Rinse mouth after meals'];
      case 'chal_3':
        return isTamil
            ? ['இரவு பல் நூல் பயன்படுத்து', 'ஈறு வரியை மெதுவாக சுத்தம் செய்', 'பல் நூலுக்கு பின் தண்ணீர் குடி']
            : ['Floss before bed', 'Clean along the gum line gently', 'Rinse with water after flossing'];
      default:
        return isTamil ? ['இன்றைய சவாலை முடி'] : ['Complete your challenge tasks today'];
    }
  }

  String _dayLabel(BuildContext context, int day) {
    return _localized(context, 'Day $day', 'நாள் $day');
  }

  String _motivation(BuildContext context) {
    if (_isCompleted) {
      return _localized(context, 'Amazing consistency. Keep this habit going!', 'அற்புதமான தொடர்ச்சி. இந்த பழக்கத்தை தொடருங்கள்!');
    }
    if (_streak >= 3) {
      return _localized(context, 'You are on a strong streak. Do not break it today.', 'நல்ல தொடர்ச்சியில் இருக்கிறீர்கள். இன்று நிறுத்த வேண்டாம்.');
    }
    return _localized(context, 'Small daily wins build lifelong oral health habits.', 'சிறு தினசரி முன்னேற்றங்கள் ஆயுள் முழுதும் நல்ல வாய்நல பழக்கத்தை உருவாக்கும்.');
  }

  @override
  Widget build(BuildContext context) {
    final title = _localized(context, widget.challenge.titleEn, widget.challenge.titleTa);
    final description = _localized(context, widget.challenge.descriptionEn, widget.challenge.descriptionTa);
    final benefits = _localized(context, widget.challenge.benefitsEn, widget.challenge.benefitsTa);
    final color = widget.challenge.iconType == 'floss'
        ? const Color(0xFF9B59B6)
        : widget.challenge.iconType == 'sugar'
            ? const Color(0xFFE74C3C)
            : const Color(0xFF3498DB);
    final progress = widget.challenge.durationDays == 0 ? 0.0 : _currentDay / widget.challenge.durationDays;
    final tasks = _dailyTasks(context);
    final totalDays = widget.challenge.durationDays;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_localized(context, 'Challenge', 'சவால்')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(
              icon: Icons.emoji_events_rounded,
              color: color,
              title: title,
              description: description,
              badge: _isCompleted
                  ? _localized(context, 'Done', 'முடிந்தது')
                  : _isActive
                      ? _localized(context, 'Active', 'செயலில்')
                      : _localized(context, 'Start', 'தொடங்கு'),
            ),
            const SizedBox(height: 16),
            Text(
              _localized(context, 'Benefits', 'நன்மைகள்'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              benefits,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              _localized(context, 'Progress', 'முன்னேற்றம்'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.withOpacity(0.18),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 10),
            Text('${_currentDay}/${widget.challenge.durationDays} ${_localized(context, 'days', 'நாட்கள்')}'),
            const SizedBox(height: 8),
            Text(
              '${_localized(context, 'Current streak', 'தொடர்ச்சி')}: $_streak',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              _localized(context, 'Daily Tasks', 'தினசரி பணிகள்'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              totalDays,
              (index) {
                final dayIndex = index + 1;
                final done = _completedDays.contains(dayIndex);
                final taskText = tasks[index % tasks.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: done ? color.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.20)),
                  ),
                  child: Row(
                    children: [
                      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_dayLabel(context, dayIndex)}: $taskText',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _motivation(context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (!_isActive && !_isCompleted)
                  FilledButton.icon(
                    onPressed: _startChallenge,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_localized(context, 'Start Challenge', 'சவாலை தொடங்கு')),
                  ),
                OutlinedButton.icon(
                  onPressed: _isActive ? _advanceDay : null,
                  icon: const Icon(Icons.add_task_rounded),
                  label: Text(_localized(context, 'Mark Today Complete', 'இன்றையதை முடிந்தது என குறி')),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.20)),
                ),
                child: Text(
                  _localized(context, 'Challenge complete', 'சவால் முடிந்தது'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PDFResourceDetailScreen extends StatefulWidget {
  final PDFResource resource;

  const PDFResourceDetailScreen({super.key, required this.resource});

  @override
  State<PDFResourceDetailScreen> createState() => _PDFResourceDetailScreenState();
}

class _PDFResourceDetailScreenState extends State<PDFResourceDetailScreen> {
  final LearnService _learnService = LearnService();
  late bool _isBookmarked;
  late bool _isLaunching;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.resource.isBookmarked;
    _isLaunching = false;
  }

  Future<void> _openPdf() async {
    if (_isLaunching) {
      return;
    }
    setState(() {
      _isLaunching = true;
    });
    final url = Uri.tryParse(widget.resource.pdfUrl);
    final success = url != null && await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!mounted) {
      return;
    }
    setState(() {
      _isLaunching = false;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localized(context, 'Could not open PDF', 'PDF திறக்க முடியவில்லை'))),
      );
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      widget.resource.isBookmarked = _isBookmarked;
    });
    if (_isBookmarked) {
      _learnService.addBookmark(
        Bookmark(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          resourceId: widget.resource.id,
          resourceType: 'pdf',
          resourceTitle: widget.resource.titleEn,
          bookmarkedDate: DateTime.now(),
        ),
      );
    } else {
      _learnService.removeBookmark(widget.resource.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _localized(context, widget.resource.titleEn, widget.resource.titleTa);
    final description = _localized(context, widget.resource.descriptionEn, widget.resource.descriptionTa);
    final category = _localized(context, widget.resource.categoryEn, widget.resource.categoryTa);
    final progress = widget.resource.pages == 0 ? 0.0 : widget.resource.readPages / widget.resource.pages;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_localized(context, 'PDF', 'PDF')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.picture_as_pdf_rounded, size: 64, color: Colors.white),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'pdf_bookmark_${widget.resource.id}',
                      onPressed: _toggleBookmark,
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      child: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _Pill(label: category, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.withOpacity(0.18),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            Text('${widget.resource.readPages}/${widget.resource.pages} ${_localized(context, 'pages read', 'பக்கங்கள் படிக்கப்பட்டது')}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLaunching ? null : _openPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(_localized(context, 'Open PDF', 'PDF திற')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String badge;

  const _HeaderCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4, color: AppTheme.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Pill(label: badge, color: color),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
