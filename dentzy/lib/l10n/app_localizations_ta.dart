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

  @override
  String get brushingTimer => 'பல் துலக்கும் நேர வரிசையாக்கி';

  @override
  String get brushingTracker => 'பல் துலக்கும் கண்காணிப்பு';

  @override
  String get twoMinuteGuidedBrush => '2 நிமிட வழிகாட்டப்பட்ட துலக்குதல்';

  @override
  String get trackDailyBrushing => 'தினசரி பல் துலக்குதலைக் கண்காணி';

  @override
  String get timeRemaining => 'மீதமுள்ள நேரம்';

  @override
  String get brushingTips => 'பல் துலக்கும் குறிப்புகள்';

  @override
  String get brushTip1 => 'குறைந்தபட்சம் 2 நிமிடங்கள் பல் துலக்கவும்';

  @override
  String get brushTip2 => 'மென்மையான வட்டவடிவ இயக்கங்களைப் பயன்படுத்தவும்';

  @override
  String get brushTip3 => 'உங்கள் நாக்கை மறந்து விடாதீர்கள்';

  @override
  String get brushTip4 => 'தினமும் இரண்டு முறை பல் துலக்கவும்';

  @override
  String get greatJob => '멋진 வேலை!';

  @override
  String get completedBrushingSession =>
      'நீங்கள் உங்கள் 2 நிமிட பல் துலக்கும் அமர்வை முடிந்துவிட்டீர்கள்!';

  @override
  String get start => 'தொடங்கவும்';

  @override
  String get pause => 'இடைநிறுத்தவும்';

  @override
  String get reset => 'மீட்டமை';

  @override
  String get noFamilyMembersAdded => 'குடும்ப உறுப்பினர்கள் சேர்க்கப்படவில்லை';

  @override
  String get addFamilyMembersProfile =>
      'கண்காணிக்கத் தொடங்க சுயவிவரப் பிரிவில் குடும்ப உறுப்பினர்களைச் சேர்க்கவும்';

  @override
  String get daily => 'தினசரி';

  @override
  String get weekly => 'வாரம்';

  @override
  String get monthly => 'மாதம்';

  @override
  String get todaysBrushingStatus => 'இன்றைய பல் துலக்கும் நிலை';

  @override
  String get morning => 'காலை';

  @override
  String get night => 'இரவு';

  @override
  String get markMorning => 'காலை குறிக்க';

  @override
  String get markNight => 'இரவு குறிக்க';

  @override
  String get ok => 'சரி';

  @override
  String get profileFamily => 'சுயவிவரம் & குடும்பம்';

  @override
  String get myProfile => 'என் சுயவிவரம்';

  @override
  String get yourStatistics => 'உங்கள் புள்ளிவிவரங்கள்';

  @override
  String get familyMembers => 'குடும்ப உறுப்பினர்கள்';

  @override
  String get achievements => 'சாதனைகள்';

  @override
  String get add => 'சேர்';

  @override
  String get age => 'வயது';

  @override
  String get years => 'ஆண்டுகள்';

  @override
  String get achievementsUnlocked => 'திறக்கப்பட்ட சாதனைகள்';

  @override
  String get addFamilyMember => 'குடும்ப உறுப்பினரை சேர்க்கவும்';

  @override
  String get editFamilyMember => 'குடும்ப உறுப்பினரை திருத்தவும்';

  @override
  String get relationOptional => 'உறவு (விருப்பத்தேர்வு)';

  @override
  String get update => 'புதுப்பிக்கவும்';

  @override
  String get father => 'அப்பா';

  @override
  String get mother => 'அம்மா';

  @override
  String get child => 'குழந்தை';

  @override
  String get sibling => 'உடன்பிறந்தவர்';

  @override
  String get grandparent => 'தாத்தா/பாட்டி';

  @override
  String get auntUncle => 'அத்தை/மாமா';

  @override
  String get cousin => 'சகோதரப்பிள்ளை';

  @override
  String get friend => 'நண்பர்';

  @override
  String get mythsChecked => 'சரிபார்க்கப்பட்ட கட்டுக்கதைகள்';

  @override
  String get dayStreak => 'தொடர் நாட்கள்';

  @override
  String get noFamilyMembersYet => 'இன்னும் குடும்ப உறுப்பினர்கள் இல்லை';

  @override
  String get addFamilyMembersTrackBrushing =>
      'அவர்களின் பல் துலக்கும் பழக்கத்தை கண்காணிக்க குடும்ப உறுப்பினர்களை சேர்க்கவும்';

  @override
  String get noAchievements => 'சாதனைகள் இல்லை';

  @override
  String get close => 'மூடு';

  @override
  String get brushingProgress => 'பல் துலக்கும் முன்னேற்றம்';

  @override
  String get selectFamilyMember => 'குடும்ப உறுப்பினரை தேர்ந்தெடுக்கவும்';

  @override
  String get errorLoadingProgressData => 'முன்னேற்ற தரவை ஏற்றுவதில் பிழை';

  @override
  String get noBrushingDataAvailable => 'பல் துலக்கும் தரவு கிடைக்கவில்லை';

  @override
  String get startBrushingToSeeProgress =>
      'உங்கள் முன்னேற்றத்தை காண பல் துலக்கத் தொடங்கவும்!';

  @override
  String get today => 'இன்று';

  @override
  String get thisWeek => 'இந்த வாரம்';

  @override
  String get thisMonth => 'இந்த மாதம்';

  @override
  String get reminders => 'நினைவூட்டல்கள்';

  @override
  String get enableReminders => 'நினைவூட்டலை இயக்கவும்';

  @override
  String get receiveBrushingNotifications =>
      'பல் துலக்கும் அறிவிப்புகளை பெறுங்கள்';

  @override
  String get remindersEnabled => 'நினைவூட்டல் இயக்கப்பட்டது';

  @override
  String get remindersDisabled => 'நினைவூட்டல் முடக்கப்பட்டது';

  @override
  String get morningReminder => 'காலை நினைவூட்டல்';

  @override
  String get nightReminder => 'இரவு நினைவூட்டல்';

  @override
  String get tapToChangeTime => 'நேரத்தை மாற்ற தட்டவும்';

  @override
  String get selectedForTracking => 'கண்காணிப்பிற்காக தேர்ந்தெடுக்கப்பட்டார்';

  @override
  String get name => 'பெயர்';

  @override
  String get deleteMemberQuestion => 'உறுப்பினரை நீக்கவா?';

  @override
  String confirmRemoveMember(String name) {
    return '$name ஐ நீக்க விரும்புகிறீர்களா?';
  }

  @override
  String get resultUnavailable => 'முடிவுகள் கிடைக்கவில்லை';

  @override
  String get checkAnotherStatement => 'மற்ற ஒரு கூற்றை சரிபார்க்கவும்';

  @override
  String get aiDentalScreening => 'AI பல் பரிசோதனை';

  @override
  String get scanMyths =>
      'ஒரு சுத்தமான ஸ்கேன் மூலம் பல் கட்டுக்கதைகளை சரிபார்க்கவும்.';

  @override
  String get mythPremiumDescription =>
      'சுருக்கமான பதில்கள், தெளிவான காரணங்கள், மற்றும் ஒரு பிரீமியம் மருத்துவப் பாணி முடிவு தோற்றம்.';

  @override
  String get yourStatement => 'உங்கள் கூற்று';

  @override
  String get statementExample =>
      'உதாரணம்: தினமும் இரண்டு முறை பல் துலக்கும் போது காவிடீஸ் தவிர்க்கப்படுமா';

  @override
  String get statistics => 'புள்ளிவிவரங்கள்';

  @override
  String get preferences => 'முன்னுரைகள்';

  @override
  String get darkMode => 'இருள் வழிமுறை';

  @override
  String get privacyPolicy => 'தனியுரிமை கொள்கை';

  @override
  String get yearly => 'வருடாந்திரம்';

  @override
  String performancePeriod(String period) {
    return '$period செயல்திறன்';
  }

  @override
  String get noExplanationAvailable => 'விரிவான விளக்கம் கிடைக்கவில்லை.';

  @override
  String get moreVideos => 'மேலும் வீடியோக்கள்';

  @override
  String get invalidYouTubeUrl => 'செல்லுகிற YouTube URL அல்ல';

  @override
  String get noAppToOpenVideo => 'வீடியோ திறக்க பயன்பாடு இல்லை';

  @override
  String get couldNotOpenVideo => 'வீடியோ திறக்க முடியவில்லை';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get emailLabel => 'மின்னஞ்சல்';

  @override
  String get phoneLabel => 'தொலைபேசி';

  @override
  String get languageLabel => 'மொழி';

  @override
  String get personalInformation => 'தனிப்பட்ட தகவல்கள்';

  @override
  String get helpAndSupport => 'உதவி மற்றும் ஆதரவு';

  @override
  String get liveResult => 'நேரடி முடிவு';

  @override
  String get resultsWillAppearHere => 'முடிவுகள் இங்கே தோன்றும்';

  @override
  String get tryDentalStatement =>
      'ஒரு பல் கூற்றை முயற்சி செய்யுங்கள், அது உண்மை, கட்டுக்கதை அல்லது பல்-வலைதளமில்லாத தீர்மானம் ஆகுமோ என்பதை பார்க்கவும்.';

  @override
  String get whatAIchecksFirst => 'AI முதலில் என்ன பரிசோதிக்கிறது';

  @override
  String get dentalRelevance => 'பல் தொடர்புடைய பொருத்தம்';

  @override
  String get dentalRelevanceDesc =>
      'பற்கள், மற்றும் இடை, வாய், துலக்குதல், பிளாஸிங் மற்றும் வாய்ப்பராமரிப்பு.';

  @override
  String get thenClassify => 'பின்னர் வகைப்படுத்து';

  @override
  String get thenClassifyDesc =>
      'பல் தொடர்புடையதாக இருந்தால், மாதிரிகள் FACT அல்லது MYTH என்பதை தீர்மானிக்கிறது.';

  @override
  String get enterStatementToCheck => 'சரிபார்க்க ஒரு கூற்றை உள்ளிடவும்';

  @override
  String get quiz => 'வினாடி வினா';

  @override
  String get testYourKnowledgeAI =>
      'AI-செயல்படுத்தப்பட்ட பல் வினாடி வினாக்களுடன் உங்கள் அறிவைப் பரிசோதிக்கவும்';

  @override
  String get aiLabel => 'AI';

  @override
  String get weeklyProgress => 'வாரத்தின் முன்னேற்றம்';

  @override
  String get monthlyProgress => 'மாதத்தின் முன்னேற்றம்';

  @override
  String get brushingTipsLabel => 'பல் துலக்கும் குறிப்புகள்';

  @override
  String get statisticsLabel => 'புள்ளிவிவரங்கள்';

  @override
  String get totalBrushings => 'மொத்த பல் துலக்குதல்';

  @override
  String get completionRate => 'முடிப்பு விகிதம்';

  @override
  String get daysTracked => 'கண்காணிக்கப்பட்ட நாட்கள்';

  @override
  String get averagePerDay => 'ஒரு நாளுக்கு சராசரி';

  @override
  String get brushTipsBulletPoints =>
      '• குறைந்தபட்சம் 2 நிமிடங்கள் பல் துலக்கவும்\n• தினமும் இரண்டு முறை பல் துலக்கவும் (காலை மற்றும் இரவு)\n• மென்மையான, வட்டவடிவ இயக்கங்களைப் பயன்படுத்தவும்\n• பின்களை பற்களை மறந்து விடாதீர்கள்\n• பல் துலக்கிய பின்னர் பிளாஸ் செய்யவும்';

  @override
  String get healthySmilesTracker => 'ஆரோக்கியமான புன்னகை கண்காணிப்பான்';

  @override
  String get trackBrushingHabits =>
      'உங்கள் பல் துலக்கும் பழக்கங்களை தினசரி கண்காணி';

  @override
  String get morningBrushingReminder => 'காலை பல் துலக்கும் நினைவூட்டல்';

  @override
  String get morningBrushingDescription =>
      'பற்களை துலக்க வேண்டிய நேரம்! 2 நிமிடங்கள் துலக்க மறக்காதீர்கள்.';

  @override
  String get quizAchievement => 'வினாடி வினா சாதனை';

  @override
  String get quizAchievementDescription =>
      'அருமை! இன்று நீங்கள் 5 வினாடி வினாக்களை முடித்துள்ளீர்கள். தொடர்ந்து செய்யுங்கள்!';

  @override
  String get brushingStreak => 'தொடர்ச்சியான பல் துலக்கம்';

  @override
  String get brushingStreakDescription =>
      'நீங்கள் 7 நாட்கள் தொடர்ந்து பல் துலக்கியுள்ளீர்கள்! அபூர்வமான அர்ப்பணிப்பு!';

  @override
  String get eveningBrushingReminder => 'இரவு பல் துலக்கும் நினைவூட்டல்';

  @override
  String get eveningBrushingDescription =>
      'தூங்குவதற்கு முன் பல் துலக்க மறக்காதீர்கள்.';

  @override
  String get markAllAsRead => 'அனைத்தையும் படிக்கப்பட்டதாகக் குறிக்கவும்';

  @override
  String get justNow => 'இப்போது';

  @override
  String minutesAgo(int minutes) {
    return '$minutesநி முன்';
  }

  @override
  String hoursAgo(int hours) {
    return '$hoursமணி முன்';
  }

  @override
  String daysAgo(int days) {
    return '$daysநாட்கள் முன்';
  }
}
