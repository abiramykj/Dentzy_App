// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'டென்ட்ஸி';

  @override
  String get appTagline =>
      'கட்டுக்கதைகளை உடைக்கவும், உண்மையை ஏற்றுக்கொள்ளுங்கள்';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get continueBtn => 'தொடர்க';

  @override
  String get next => 'அடுத்தது';

  @override
  String get previous => 'முந்தையது';

  @override
  String get save => 'சேமிக்க';

  @override
  String get delete => 'அழிக்க';

  @override
  String get edit => 'திருத்த';

  @override
  String get cancel => 'ரத்து செய்க';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்க';

  @override
  String get loading => 'ஏற்றுதல்...';

  @override
  String get error => 'பிழை';

  @override
  String get noData => 'தரவு கிடைக்கவில்லை';

  @override
  String get welcome => 'மீண்டும் வரவேற்கிறோம்!';

  @override
  String get readyForQuiz => 'இன்று கட்டுக்கதைகளை உடைக்க தயாரா?';

  @override
  String get startQuiz => 'வினாடி வினா தொடங்கவும்';

  @override
  String get mythChecker => 'கட்டுக்கதை சரிபார்ப்பான்';

  @override
  String get learn => 'கற்க';

  @override
  String get progress => 'முன்னேற்றம்';

  @override
  String get videos => 'வீடியோக்கள்';

  @override
  String get home => 'முகப்பு';

  @override
  String get tracker => 'ட்ராக்கர்';

  @override
  String get reports => 'அறிக்கைகள்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get logout => 'வெளியே இறங்கவும்';

  @override
  String questionNumber(int number, int total) {
    return 'கேள்வி $number/$total';
  }

  @override
  String get isThisMythOrTruth => 'இது கட்டுக்கதையா அல்லது உண்மையா?';

  @override
  String get selectYourAnswer => 'உங்கள் பதிலைத் தேர்ந்தெடுக்கவும்:';

  @override
  String get myth => 'கட்டுக்கதை';

  @override
  String get truth => 'உண்மை';

  @override
  String get aiConfidence => 'AI நம்பிக்கை';

  @override
  String get category => 'வகை';

  @override
  String categoryColon(String category) {
    return 'வகை: $category';
  }

  @override
  String get checked => 'சரிபார்க்கப்பட்ட';

  @override
  String get accuracy => 'துல்லியம்';

  @override
  String get streak => 'தொடர்';

  @override
  String get quickActions => 'விரைவு நடவடிக்கைகள்';

  @override
  String get testYourKnowledge => 'உங்கள் அறிவை சோதிக்கவும்';

  @override
  String get educationalContent => 'கல்வி உள்ளடக்கம்';

  @override
  String get trackYourStats => 'உங்கள் புள்ளிவிவரங்களைக் கண்டறியவும்';

  @override
  String get videoLessons => 'வீடியோ பாடங்கள்';

  @override
  String get featuredArticles => 'முன்னிலை கட்டுரைகள்';

  @override
  String get topicsCovered => 'கவரிய தலைப்புகள்';

  @override
  String get categoryFilter => 'அனைத்தும்';

  @override
  String get health => 'ஆரோக்கியம்';

  @override
  String get science => 'அறிவியல்';

  @override
  String get technology => 'தொழில்நுட்பம்';

  @override
  String get history => 'வரலாறு';

  @override
  String get society => 'சமூகம்';

  @override
  String get environment => 'சுற்றுச்சூழல்';

  @override
  String get oralHygiene => 'வாய் சுகாதாரம்';

  @override
  String get nutrition => 'ஊட்டச்சத்து';

  @override
  String get brushingTechniques => 'பல் துலக்கும் நுட்பங்கள்';

  @override
  String get dentalHealth => 'பல் சுகாதாரம்';

  @override
  String get commonMyths => 'பொதுவான கட்டுக்கதைகள்';

  @override
  String get prevention => 'தடுப்பு';

  @override
  String minRead(int minutes) {
    return '$minutes நிமிட வாசிப்பு';
  }

  @override
  String get understandingDentalMyths =>
      'பல் சுகாதாரம் பற்றிய கட்டுக்கதைகளைப் புரிந்துகொள்ளுதல்';

  @override
  String get learnTheDifference =>
      'பொதுவான பல் கட்டுக்கதைகள் மற்றும் உண்மைகளுக்கு இடையிலான வேறுபாட்டை அறிக.';

  @override
  String get scienceOfToothDecay => 'பல் சிதைவின் பின்னணியிலுள்ள அறிவியல்';

  @override
  String get discoverScientific =>
      'பல் சிதைவை ஏற்படுத்தும் பின்னணியிலுள்ள அறிவியல் செயல்முறைகளைக் கண்டறியவும்.';

  @override
  String get modernDentalTech => 'நவீன பல் பயவமை';

  @override
  String get exploreInnovations =>
      'பல் பயவமைக்குள் சமீபத்திய கண்டுபிடிப்புகளை ஆராயவும்.';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get accountSettings => 'கணக்கு அமைப்புகள்';

  @override
  String percentage(int value) {
    return '$value%';
  }
}
