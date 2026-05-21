import 'package:flutter/material.dart';
import '../widgets/featured_article_card.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/interactive_activity_card.dart';
import '../widgets/dental_challenge_card.dart';
import '../widgets/pdf_resource_card.dart';
import '../screens/learn_detail_screens.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/learn_service.dart';
import '../models/bookmark.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final LearnService _learnService = LearnService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isNavigating = false;
  bool _isReady = false;
  bool _loggedLearnBuild = false;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _initializeLearnData();
  }

  Future<void> _initializeLearnData() async {
    await _learnService.initializeMockData();
    if (!mounted) {
      return;
    }
    setState(() {
      _isReady = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _categories = [
      loc.categoryAll,
      'Oral Hygiene',
      'Nutrition',
      'Brushing Techniques',
      'Prevention',
    ];
  }

  Future<void> _pushDetail(Widget page) async {
    if (_isNavigating) {
      return;
    }
    _isNavigating = true;
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } finally {
      _isNavigating = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7F7),
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(AppLocalizations.of(context)!.learnModuleTitle),
        ),
        body: const SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final loc = AppLocalizations.of(context)!;
    final featuredArticles = _learnService.getFeaturedArticles();
    final dailyTips = _learnService.getDailyTips();
    final activities = _learnService.getActivities();
    final challenges = _learnService.getChallenges();
    final pdfResources = _learnService.getPDFResources();
    if (!_loggedLearnBuild) {
      _loggedLearnBuild = true;
      debugPrint('LearnScreen rebuild');
      debugPrint('Challenge section built: ${challenges.length} cards');
    }

    final sections = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.learnModuleTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.learnModuleSubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: loc.searchLearnContent,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _categories.length,
            (index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return FilterChip(
                selected: isSelected,
                label: Text(category),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          loc.featuredReads,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: List.generate(
            featuredArticles.length,
            (index) {
              final article = featuredArticles[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == featuredArticles.length - 1 ? 0 : 12),
                child: SizedBox(
                  height: 250,
                  child: FeaturedArticleCard(
                    article: article,
                    onTap: () async {
                      _learnService.markArticleAsRead(article.id);
                      await _pushDetail(ArticleDetailScreen(article: article));
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onBookmarkToggle: (isBookmarked) {
                      if (isBookmarked) {
                        _learnService.addBookmark(
                          Bookmark(
                            id: DateTime.now().toString(),
                            resourceId: article.id,
                            resourceType: 'article',
                            resourceTitle: article.titleEn,
                            bookmarkedDate: DateTime.now(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.addedToBookmarks),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _learnService.removeBookmark(article.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.removedFromBookmarks),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          loc.dailyDentalTips,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: List.generate(
            dailyTips.length,
            (index) {
              final tip = dailyTips[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == dailyTips.length - 1 ? 0 : 12),
                child: DailyTipCard(
                  tip: tip,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tip.tipEn),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onViewed: () {
                    setState(() {});
                  },
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          loc.interactiveActivities,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: activities
                  .map(
                    (activity) => SizedBox(
                      width: itemWidth,
                      child: RepaintBoundary(
                        child: InteractiveActivityCard(
                          activity: activity,
                          onTap: () async {
                            await _pushDetail(ActivityDetailScreen(activity: activity));
                          },
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          loc.dentalChallenges,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            challenges.length,
            (index) {
              final challenge = challenges[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == challenges.length - 1 ? 0 : 12),
                child: RepaintBoundary(
                  child: DentalChallengeCard(
                    challenge: challenge,
                    onTap: () async {
                      await _pushDetail(ChallengeDetailScreen(challenge: challenge));
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onActionTap: () async {
                      await _pushDetail(ChallengeDetailScreen(challenge: challenge));
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          loc.pdfResources,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pdfResources
                  .map(
                    (pdf) => SizedBox(
                      width: itemWidth,
                      child: RepaintBoundary(
                        child: PDFResourceCard(
                          resource: pdf,
                          onTap: () async {
                            await _pushDetail(PDFResourceDetailScreen(resource: pdf));
                          },
                          onBookmarkToggle: (isBookmarked) {
                            if (isBookmarked) {
                              _learnService.addBookmark(
                                Bookmark(
                                  id: DateTime.now().toString(),
                                  resourceId: pdf.id,
                                  resourceType: 'pdf',
                                  resourceTitle: pdf.titleEn,
                                  bookmarkedDate: DateTime.now(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.addedToBookmarks),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              _learnService.removeBookmark(pdf.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.removedFromBookmarks),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.myProgress,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressCard(context, loc),
          ],
        ),
      ),
      const SizedBox(height: 32),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(loc.learnModuleTitle),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: sections,
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, AppLocalizations loc) {
    final progress = _learnService.userProgress;
    if (progress == null) {
      return const SizedBox.shrink();
    }

    return Container(
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
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: itemWidth,
                child: _buildStatItem(
                  context,
                  icon: Icons.article,
                  label: loc.articlesRead,
                  value: progress.articlesRead.toString(),
                  color: const Color(0xFF3498DB),
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildStatItem(
                  context,
                  icon: Icons.games_rounded,
                  label: loc.activitiesCompleted,
                  value: progress.activitiesCompleted.toString(),
                  color: const Color(0xFF2ECC71),
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildStatItem(
                  context,
                  icon: Icons.emoji_events,
                  label: loc.challengesCompleted,
                  value: progress.challengesCompleted.toString(),
                  color: const Color(0xFFF39C12),
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  label: loc.currentStreak,
                  value: '${progress.currentStreak} ${loc.days}',
                  color: const Color(0xFFE74C3C),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
