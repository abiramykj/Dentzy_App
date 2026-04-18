// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dentzy';

  @override
  String get appTagline => 'Bust the Myths, Embrace the Truth';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get continueBtn => 'Continue';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get noData => 'No data available';

  @override
  String get welcome => 'Welcome Back!';

  @override
  String get readyForQuiz => 'Ready to bust some myths today?';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get mythChecker => 'Myth Checker';

  @override
  String get learn => 'Learn';

  @override
  String get progress => 'Progress';

  @override
  String get videos => 'Videos';

  @override
  String get home => 'Home';

  @override
  String get tracker => 'Tracker';

  @override
  String get reports => 'Reports';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String questionNumber(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get isThisMythOrTruth => 'Is this a myth or truth?';

  @override
  String get selectYourAnswer => 'Select your answer:';

  @override
  String get myth => 'Myth';

  @override
  String get truth => 'Truth';

  @override
  String get aiConfidence => 'AI Confidence';

  @override
  String get category => 'Category';

  @override
  String categoryColon(String category) {
    return 'Category: $category';
  }

  @override
  String get checked => 'Checked';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get streak => 'Streak';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get testYourKnowledge => 'Test your knowledge';

  @override
  String get educationalContent => 'Educational content';

  @override
  String get trackYourStats => 'Track your stats';

  @override
  String get videoLessons => 'Video lessons';

  @override
  String get featuredArticles => 'Featured Articles';

  @override
  String get topicsCovered => 'Topics Covered';

  @override
  String get categoryFilter => 'All';

  @override
  String get health => 'Health';

  @override
  String get science => 'Science';

  @override
  String get technology => 'Technology';

  @override
  String get history => 'History';

  @override
  String get society => 'Society';

  @override
  String get environment => 'Environment';

  @override
  String get oralHygiene => 'Oral Hygiene';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get brushingTechniques => 'Brushing Techniques';

  @override
  String get dentalHealth => 'Dental Health';

  @override
  String get commonMyths => 'Common Myths';

  @override
  String get prevention => 'Prevention';

  @override
  String minRead(int minutes) {
    return '$minutes min read';
  }

  @override
  String get understandingDentalMyths => 'Understanding Dental Myths';

  @override
  String get learnTheDifference =>
      'Learn the difference between common dental myths and facts.';

  @override
  String get scienceOfToothDecay => 'The Science Behind Tooth Decay';

  @override
  String get discoverScientific =>
      'Discover the scientific processes that cause tooth decay.';

  @override
  String get modernDentalTech => 'Modern Dental Technology';

  @override
  String get exploreInnovations =>
      'Explore the latest innovations in dental technology.';

  @override
  String get notifications => 'Notifications';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String percentage(int value) {
    return '$value%';
  }
}
