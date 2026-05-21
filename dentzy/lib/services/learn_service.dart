import '../models/educational_article.dart';
import '../models/daily_tip.dart';
import '../models/interactive_activity.dart';
import '../models/dental_challenge.dart';
import '../models/pdf_resource.dart';
import '../models/bookmark.dart';
import '../models/user_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnService {
  static final LearnService _instance = LearnService._internal();

  factory LearnService() {
    return _instance;
  }

  LearnService._internal();

  List<EducationalArticle> _articles = [];
  List<DailyTip> _tips = [];
  List<InteractiveActivity> _activities = [];
  List<DentalChallenge> _challenges = [];
  List<PDFResource> _pdfs = [];
  List<Bookmark> _bookmarks = [];
  UserProgress? _userProgress;
  final Map<String, Set<int>> _completedDaysByChallenge = {};
  int _challengeStreak = 0;

  static const String _challengeStateKey = 'learn.challenge.state.v1';
  static const String _challengeStreakKey = 'learn.challenge.streak.v1';
  static const String _challengeLastCompletedDateKey = 'learn.challenge.lastDate.v1';

  Future<void> initializeMockData() async {
    _articles = _generateMockArticles();
    _tips = _generateMockTips();
    _activities = _generateMockActivities();
    _challenges = _generateMockChallenges();
    _pdfs = _generateMockPDFs();
    _userProgress = UserProgress(
      id: '1',
      lastActivityDate: DateTime.now(),
      articlesRead: 3,
      activitiesCompleted: 2,
      challengesCompleted: 1,
      pdfsRead: 1,
      currentStreak: 7,
      longestStreak: 14,
      totalPoints: 450,
    );

    await _loadChallengeState();
  }

  List<EducationalArticle> _generateMockArticles() {
    return [
      EducationalArticle(
        id: 'art_1',
        titleEn: 'Brushing Guide',
        titleTa: 'பல் துலக்க வழிகாட்டி',
        categoryEn: 'Brushing Techniques',
        categoryTa: 'பல் துலக்கும் முறை',
        summaryEn: 'Learn the basic brush steps.',
        summaryTa: 'பல் துலக்கும் எளிய படிகளை கற்கவும்.',
        contentEn: 'Brush twice a day. Use a soft brush. Move in small circles. Clean all tooth surfaces and your tongue.',
        contentTa: 'தினமும் இரண்டு முறை பல் துலக்கவும். மென்மையான பிரஷ் பயன்படுத்தவும். சிறிய வட்டமாக நகர்த்தவும். அனைத்து பல் மேடைகளையும் நாக்கையும் சுத்தம் செய்யவும்.',
        readTimeMinutes: 5,
        imageUrl: '',
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
        tagsEn: ['brushing', 'hygiene', 'technique'],
        tagsTa: ['பல்துலக்குதல்', 'சுகாதாரம்', 'நுட்பம்'],
        isBookmarked: true,
        isRead: true,
        readProgress: 75,
      ),
      EducationalArticle(
        id: 'art_2',
        titleEn: 'Food for Teeth',
        titleTa: 'பற்களுக்கு உணவு',
        categoryEn: 'Nutrition',
        categoryTa: 'ஊட்டச்சத்து',
        summaryEn: 'Choose food that helps teeth.',
        summaryTa: 'பற்களுக்கு உதவும் உணவுகளை தேர்வு செய்யவும்.',
        contentEn: 'Pick milk, cheese, eggs, fruits, and vegetables. Cut down on sweets and soda.',
        contentTa: 'பால், பனீர், முட்டை, பழம், காய்கறி எடுக்கவும். இனிப்பு மற்றும் சோடாவை குறைக்கவும்.',
        readTimeMinutes: 7,
        imageUrl: '',
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
        tagsEn: ['nutrition', 'diet', 'teeth'],
        tagsTa: ['ஊட்டச்சத்து', 'உணவு', 'பல்கள்'],
        isBookmarked: false,
        isRead: false,
        readProgress: 0,
      ),
      EducationalArticle(
        id: 'art_3',
        titleEn: 'Gum Care',
        titleTa: 'ஈறு பராமரிப்பு',
        categoryEn: 'Prevention',
        categoryTa: 'தடுப்பு',
        summaryEn: 'Keep gums clean and calm.',
        summaryTa: 'ஈறுகளை சுத்தமாகவும் ஆரோக்கியமாகவும் வைத்துக்கொள்ளவும்.',
        contentEn: 'Brush gently, floss daily, and visit the dentist if gums bleed or swell.',
        contentTa: 'மெதுவாக பல் துலக்கவும், தினமும் பல் நூல் பயன்படுத்தவும், ஈறு வீக்கம் அல்லது இரத்தம் வந்தால் மருத்துவரை பார்க்கவும்.',
        readTimeMinutes: 6,
        imageUrl: '',
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
        tagsEn: ['gums', 'prevention', 'health'],
        tagsTa: ['ஈறு', 'தடுப்பு', 'சுகாதாரம்'],
        isBookmarked: false,
        isRead: false,
        readProgress: 0,
      ),
    ];
  }

  List<DailyTip> _generateMockTips() {
    return [
      DailyTip(
        id: 'tip_1',
        tipEn: 'Brush for 2 minutes, morning and night.',
        tipTa: 'காலை மற்றும் இரவு 2 நிமிடங்கள் பல் துலக்கவும்.',
        categoryEn: 'Brushing',
        categoryTa: 'துலக்குதல்',
        iconType: 'brush',
        dateCreated: DateTime.now(),
        isViewed: true,
      ),
      DailyTip(
        id: 'tip_2',
        tipEn: 'Floss once a day.',
        tipTa: 'தினமும் ஒருமுறை பல் நூல் பயன்படுத்தவும்.',
        categoryEn: 'Flossing',
        categoryTa: 'பல் நூல்',
        iconType: 'floss',
        dateCreated: DateTime.now(),
        isViewed: false,
      ),
      DailyTip(
        id: 'tip_3',
        tipEn: 'Pick water over soda.',
        tipTa: 'சோடாவுக்கு பதில் தண்ணீர் குடிக்கவும்.',
        categoryEn: 'Diet',
        categoryTa: 'உணவு',
        iconType: 'food',
        dateCreated: DateTime.now(),
        isViewed: false,
      ),
    ];
  }

  List<InteractiveActivity> _generateMockActivities() {
    return [
      InteractiveActivity(
        id: 'act_1',
        titleEn: 'Food Sort',
        titleTa: 'உணவு வகை',
        descriptionEn: 'Pick the healthy foods.',
        descriptionTa: 'ஆரோக்கிய உணவுகளை தேர்வு செய்யவும்.',
        activityType: 'sorting',
        iconType: 'games',
        durationMinutes: 10,
        itemsEn: ['Apple', 'Chocolate', 'Milk', 'Candy', 'Cheese', 'Soda'],
        itemsTa: ['ஆப்பிள்', 'சாக்லேட்', 'பால்', 'மிட்டாய்', 'பனீர்', 'சோடா'],
        correctAnswers: ['Apple', 'Milk', 'Cheese'],
        isCompleted: true,
        score: 85,
      ),
      InteractiveActivity(
        id: 'act_2',
        titleEn: 'Brush Steps',
        titleTa: 'துலக்கும் படிகள்',
        descriptionEn: 'Check each brush step.',
        descriptionTa: 'ஒவ்வொரு படியையும் குறிக்கவும்.',
        activityType: 'checklist',
        iconType: 'games',
        durationMinutes: 5,
        itemsEn: ['Wet brush', 'Add toothpaste', 'Brush outside', 'Brush inside', 'Brush top', 'Clean tongue'],
        itemsTa: ['பிரஷ் ஈரப்படுத்து', 'பற்பசை இடு', 'வெளிப்புறம் துலக்கு', 'உள்புறம் துலக்கு', 'மேல்புறம் துலக்கு', 'நாக்கு சுத்தம்'],
        correctAnswers: ['Wet brush', 'Add toothpaste', 'Brush outside', 'Brush inside', 'Brush top', 'Clean tongue'],
        isCompleted: false,
        score: 0,
      ),
    ];
  }

  List<DentalChallenge> _generateMockChallenges() {
    return [
      DentalChallenge(
        id: 'chal_1',
        titleEn: '7-Day Brush',
        titleTa: '7 நாள் துலக்கு',
        descriptionEn: 'Brush morning and night for 7 days.',
        descriptionTa: '7 நாட்கள் காலை, இரவு துலக்கவும்.',
        benefitsEn: 'Build a steady brushing habit.',
        benefitsTa: 'தொடர்ந்த துலக்கும் பழக்கம் உருவாகும்.',
        durationDays: 7,
        iconType: 'brush',
        currentDay: 5,
        isActive: true,
        isCompleted: false,
        completionPercentage: 71,
      ),
      DentalChallenge(
        id: 'chal_2',
        titleEn: 'No Soda',
        titleTa: 'சோடா வேண்டாம்',
        descriptionEn: 'Skip sugary drinks for 7 days.',
        descriptionTa: '7 நாட்கள் இனிப்பு பான்கள் வேண்டாம்.',
        benefitsEn: 'Less sugar means less cavity risk.',
        benefitsTa: 'சர்க்கரை குறைந்தால் சொத்தை ஆபமும் குறையும்.',
        durationDays: 7,
        iconType: 'sugar',
        currentDay: 0,
        isActive: false,
        isCompleted: false,
        completionPercentage: 0,
      ),
      DentalChallenge(
        id: 'chal_3',
        titleEn: 'Floss 14 Days',
        titleTa: '14 நாள் பல் நூல்',
        descriptionEn: 'Use floss every day for 14 days.',
        descriptionTa: '14 நாட்கள் தினமும் பல் நூல் பயன்படுத்தவும்.',
        benefitsEn: 'Keep gum lines cleaner.',
        benefitsTa: 'ஈறு வரி சுத்தமாக இருக்கும்.',
        durationDays: 14,
        iconType: 'floss',
        currentDay: 0,
        isActive: false,
        isCompleted: false,
        completionPercentage: 0,
      ),
    ];
  }

  List<PDFResource> _generateMockPDFs() {
    return [
      PDFResource(
        id: 'pdf_1',
        titleEn: 'Brushing Guide',
        titleTa: 'பல் துலக்கும் வழிகாட்டி',
        descriptionEn: 'Daily brushing basics with morning and night routine tips.',
        descriptionTa: 'காலை மற்றும் இரவு தினசரி துலக்கும் அடிப்படை குறிப்புகள்.',
        categoryEn: 'Brushing',
        categoryTa: 'துலக்குதல்',
        pdfUrl: 'https://iris.who.int/server/api/core/bitstreams/dd9c07d6-9b29-4f94-8fb7-4c2d44906109/content',
        thumbnailUrl: '',
        pages: 20,
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        isDownloaded: true,
        isBookmarked: true,
        readPages: 12,
      ),
      PDFResource(
        id: 'pdf_2',
        titleEn: 'Gum Care Guide',
        titleTa: 'ஈறு பராமரிப்பு வழிகாட்டி',
        descriptionEn: 'How to protect gums and reduce bleeding risk.',
        descriptionTa: 'ஈறுகளை பாதுகாக்கவும் இரத்தப்போக்கு ஆபத்தை குறைக்கவும்.',
        categoryEn: 'Gum Care',
        categoryTa: 'ஈறு பராமரிப்பு',
        pdfUrl: 'https://iris.who.int/server/api/core/bitstreams/022cde3b-a0d8-440e-8b5e-7ab5a90f89e6/content',
        thumbnailUrl: '',
        pages: 18,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        isDownloaded: false,
        isBookmarked: false,
        readPages: 0,
      ),
      PDFResource(
        id: 'pdf_3',
        titleEn: 'Cavity Prevention',
        titleTa: 'சொத்தை தடுப்பு',
        descriptionEn: 'Simple diet and hygiene habits to prevent cavities.',
        descriptionTa: 'சொத்தைத் தடுக்கும் எளிய உணவு மற்றும் சுகாதார பழக்கங்கள்.',
        categoryEn: 'Prevention',
        categoryTa: 'தடுப்பு',
        pdfUrl: 'https://apps.who.int/gb/ebwha/pdf_files/WHA74/A74_R5-en.pdf',
        thumbnailUrl: '',
        pages: 20,
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        isDownloaded: false,
        isBookmarked: false,
        readPages: 0,
      ),
      PDFResource(
        id: 'pdf_4',
        titleEn: 'Kids Oral Care',
        titleTa: 'குழந்தைகள் வாய்நல பராமரிப்பு',
        descriptionEn: 'Practical oral care tips for children and parents.',
        descriptionTa: 'குழந்தைகள் மற்றும் பெற்றோருக்கான நடைமுறை வாய்நல குறிப்புகள்.',
        categoryEn: 'Kids',
        categoryTa: 'குழந்தைகள்',
        pdfUrl: 'https://iris.who.int/server/api/core/bitstreams/dd9c07d6-9b29-4f94-8fb7-4c2d44906109/content',
        thumbnailUrl: '',
        pages: 16,
        uploadDate: DateTime.now().subtract(const Duration(days: 12)),
        isDownloaded: false,
        isBookmarked: false,
        readPages: 0,
      ),
      PDFResource(
        id: 'pdf_5',
        titleEn: 'Gum Care Guide',
        titleTa: 'ஈறு பராமரிப்பு வழிகாட்டி',
        descriptionEn: 'Learn how to keep gums healthy.',
        descriptionTa: 'ஆரோக்கியமான ஈறுகளை எப்படி காக்கலாம் என்பதைக் கற்கவும்.',
        categoryEn: 'Gums',
        categoryTa: 'ஈறு',
        pdfUrl: 'https://iris.who.int/server/api/core/bitstreams/022cde3b-a0d8-440e-8b5e-7ab5a90f89e6/content',
        thumbnailUrl: '',
        pages: 16,
        uploadDate: DateTime.now().subtract(const Duration(days: 8)),
        isDownloaded: false,
        isBookmarked: false,
        readPages: 0,
      ),
    ];
  }

  List<EducationalArticle> get articles => _articles;
  List<DailyTip> get tips => _tips;
  List<InteractiveActivity> get activities => _activities;
  List<DentalChallenge> get challenges => _challenges;
  List<PDFResource> get pdfs => _pdfs;
  List<Bookmark> get bookmarks => _bookmarks;
  UserProgress? get userProgress => _userProgress;
  int get challengeStreak => _challengeStreak;

  List<EducationalArticle> getFeaturedArticles() {
    return _articles.take(3).toList();
  }

  List<DailyTip> getDailyTips() {
    return _tips;
  }

  List<InteractiveActivity> getActivities() {
    return _activities;
  }

  List<DentalChallenge> getChallenges() {
    return _challenges;
  }

  List<PDFResource> getPDFResources() {
    return _pdfs;
  }

  void addBookmark(Bookmark bookmark) {
    if (!_bookmarks.any((b) => b.resourceId == bookmark.resourceId)) {
      _bookmarks.add(bookmark);
      _markResourceAsBookmarked(bookmark.resourceId);
    }
  }

  void removeBookmark(String resourceId) {
    _bookmarks.removeWhere((b) => b.resourceId == resourceId);
    _markResourceAsUnbookmarked(resourceId);
  }

  void _markResourceAsBookmarked(String resourceId) {
    for (var article in _articles) {
      if (article.id == resourceId) {
        article.isBookmarked = true;
      }
    }
    for (var pdf in _pdfs) {
      if (pdf.id == resourceId) {
        pdf.isBookmarked = true;
      }
    }
  }

  void _markResourceAsUnbookmarked(String resourceId) {
    for (var article in _articles) {
      if (article.id == resourceId) {
        article.isBookmarked = false;
      }
    }
    for (var pdf in _pdfs) {
      if (pdf.id == resourceId) {
        pdf.isBookmarked = false;
      }
    }
  }

  void markArticleAsRead(String articleId) {
    for (var article in _articles) {
      if (article.id == articleId) {
        article.isRead = true;
        article.readProgress = 100;
      }
    }
  }

  void markActivityAsCompleted(String activityId, int score) {
    for (var activity in _activities) {
      if (activity.id == activityId) {
        activity.isCompleted = true;
        activity.score = score;
      }
    }
  }

  void updateChallengeProgress(String challengeId, int newCurrentDay) {
    for (var challenge in _challenges) {
      if (challenge.id == challengeId) {
        challenge.currentDay = newCurrentDay;
        challenge.completionPercentage = ((newCurrentDay / challenge.durationDays) * 100).toInt();
        if (newCurrentDay >= challenge.durationDays) {
          challenge.isCompleted = true;
        }
      }
    }
    _saveChallengeState();
  }

  void startChallenge(String challengeId) {
    for (var challenge in _challenges) {
      if (challenge.id == challengeId) {
        challenge.isActive = true;
      }
    }
    _saveChallengeState();
  }

  Set<int> getCompletedDays(String challengeId) {
    return _completedDaysByChallenge[challengeId] ?? <int>{};
  }

  bool markTodayComplete(String challengeId) {
    for (var challenge in _challenges) {
      if (challenge.id != challengeId || challenge.isCompleted) {
        continue;
      }

      challenge.isActive = true;
      final completedDays = _completedDaysByChallenge.putIfAbsent(challengeId, () => <int>{});
      final nextDay = (challenge.currentDay + 1).clamp(1, challenge.durationDays);
      final added = completedDays.add(nextDay);
      if (!added) {
        return false;
      }

      challenge.currentDay = nextDay;
      challenge.completionPercentage = ((challenge.currentDay / challenge.durationDays) * 100).toInt();
      if (challenge.currentDay >= challenge.durationDays) {
        challenge.isCompleted = true;
        challenge.isActive = false;
      }

      _updateChallengeStreak();
      _updateProgressFromChallenges();
      _saveChallengeState();
      return true;
    }
    return false;
  }

  Future<void> _loadChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    final persisted = prefs.getString(_challengeStateKey);
    _challengeStreak = prefs.getInt(_challengeStreakKey) ?? _challengeStreak;

    if (persisted == null || persisted.isEmpty) {
      return;
    }

    final entries = persisted.split('|');
    for (final entry in entries) {
      if (entry.isEmpty) {
        continue;
      }
      final parts = entry.split(':');
      if (parts.length != 4) {
        continue;
      }

      final id = parts[0];
      final currentDay = int.tryParse(parts[1]) ?? 0;
      final active = parts[2] == '1';
      final completed = parts[3] == '1';

      for (final challenge in _challenges) {
        if (challenge.id == id) {
          challenge.currentDay = currentDay;
          challenge.isActive = active;
          challenge.isCompleted = completed;
          challenge.completionPercentage =
              ((challenge.currentDay / challenge.durationDays) * 100).toInt();
          _completedDaysByChallenge[id] =
              Set<int>.from(List<int>.generate(challenge.currentDay, (index) => index + 1));
          break;
        }
      }
    }

    _updateProgressFromChallenges();
  }

  Future<void> _saveChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _challenges
        .map(
          (challenge) =>
              '${challenge.id}:${challenge.currentDay}:${challenge.isActive ? '1' : '0'}:${challenge.isCompleted ? '1' : '0'}',
        )
        .join('|');

    await prefs.setString(_challengeStateKey, encoded);
    await prefs.setInt(_challengeStreakKey, _challengeStreak);
  }

  Future<void> _updateChallengeStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stored = prefs.getString(_challengeLastCompletedDateKey);

    if (stored == null) {
      _challengeStreak = 1;
      await prefs.setString(_challengeLastCompletedDateKey, today.toIso8601String());
      return;
    }

    final last = DateTime.tryParse(stored);
    if (last == null) {
      _challengeStreak = 1;
      await prefs.setString(_challengeLastCompletedDateKey, today.toIso8601String());
      return;
    }

    final lastDay = DateTime(last.year, last.month, last.day);
    final diff = today.difference(lastDay).inDays;
    if (diff == 0) {
      return;
    }
    if (diff == 1) {
      _challengeStreak += 1;
    } else {
      _challengeStreak = 1;
    }

    await prefs.setString(_challengeLastCompletedDateKey, today.toIso8601String());
  }

  void _updateProgressFromChallenges() {
    if (_userProgress == null) {
      return;
    }

    final completedChallenges = _challenges.where((challenge) => challenge.isCompleted).length;
    final previous = _userProgress!;
    final longest = _challengeStreak > previous.longestStreak ? _challengeStreak : previous.longestStreak;
    _userProgress = UserProgress(
      id: previous.id,
      articlesRead: previous.articlesRead,
      activitiesCompleted: previous.activitiesCompleted,
      challengesCompleted: completedChallenges,
      pdfsRead: previous.pdfsRead,
      currentStreak: _challengeStreak,
      longestStreak: longest,
      lastActivityDate: DateTime.now(),
      totalPoints: previous.totalPoints,
      categoryProgress: previous.categoryProgress,
    );
  }

  List<EducationalArticle> searchArticles(String query) {
    return _articles
        .where((article) =>
            article.titleEn.toLowerCase().contains(query.toLowerCase()) ||
            article.summaryEn.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<EducationalArticle> filterArticlesByCategory(String category) {
    if (category == 'All') {
      return _articles;
    }
    return _articles.where((article) => article.categoryEn == category).toList();
  }
}
