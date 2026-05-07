import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dentzy'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Bust the Myths, Embrace the Truth'**
  String get appTagline;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome;

  /// No description provided for @readyForQuiz.
  ///
  /// In en, this message translates to:
  /// **'Ready to bust some myths today?'**
  String get readyForQuiz;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @mythChecker.
  ///
  /// In en, this message translates to:
  /// **'Myth Checker'**
  String get mythChecker;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get tracker;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Progress indicator showing current question
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String questionNumber(int number, int total);

  /// No description provided for @isThisMythOrTruth.
  ///
  /// In en, this message translates to:
  /// **'Is this a myth or truth?'**
  String get isThisMythOrTruth;

  /// No description provided for @selectYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select your answer:'**
  String get selectYourAnswer;

  /// No description provided for @myth.
  ///
  /// In en, this message translates to:
  /// **'Myth'**
  String get myth;

  /// No description provided for @truth.
  ///
  /// In en, this message translates to:
  /// **'Truth'**
  String get truth;

  /// No description provided for @aiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence'**
  String get aiConfidence;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Category label with value
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String categoryColon(String category);

  /// No description provided for @checked.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get checked;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @testYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get testYourKnowledge;

  /// No description provided for @educationalContent.
  ///
  /// In en, this message translates to:
  /// **'Educational content'**
  String get educationalContent;

  /// No description provided for @trackYourStats.
  ///
  /// In en, this message translates to:
  /// **'Track your stats'**
  String get trackYourStats;

  /// No description provided for @videoLessons.
  ///
  /// In en, this message translates to:
  /// **'Video lessons'**
  String get videoLessons;

  /// No description provided for @featuredArticles.
  ///
  /// In en, this message translates to:
  /// **'Featured Articles'**
  String get featuredArticles;

  /// No description provided for @topicsCovered.
  ///
  /// In en, this message translates to:
  /// **'Topics Covered'**
  String get topicsCovered;

  /// No description provided for @categoryFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryFilter;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @society.
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get society;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @oralHygiene.
  ///
  /// In en, this message translates to:
  /// **'Oral Hygiene'**
  String get oralHygiene;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @brushingTechniques.
  ///
  /// In en, this message translates to:
  /// **'Brushing Techniques'**
  String get brushingTechniques;

  /// No description provided for @dentalHealth.
  ///
  /// In en, this message translates to:
  /// **'Dental Health'**
  String get dentalHealth;

  /// No description provided for @commonMyths.
  ///
  /// In en, this message translates to:
  /// **'Common Myths'**
  String get commonMyths;

  /// No description provided for @prevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get prevention;

  /// Reading time indicator
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String minRead(int minutes);

  /// No description provided for @understandingDentalMyths.
  ///
  /// In en, this message translates to:
  /// **'Understanding Dental Myths'**
  String get understandingDentalMyths;

  /// No description provided for @learnTheDifference.
  ///
  /// In en, this message translates to:
  /// **'Learn the difference between common dental myths and facts.'**
  String get learnTheDifference;

  /// No description provided for @scienceOfToothDecay.
  ///
  /// In en, this message translates to:
  /// **'The Science Behind Tooth Decay'**
  String get scienceOfToothDecay;

  /// No description provided for @discoverScientific.
  ///
  /// In en, this message translates to:
  /// **'Discover the scientific processes that cause tooth decay.'**
  String get discoverScientific;

  /// No description provided for @modernDentalTech.
  ///
  /// In en, this message translates to:
  /// **'Modern Dental Technology'**
  String get modernDentalTech;

  /// No description provided for @exploreInnovations.
  ///
  /// In en, this message translates to:
  /// **'Explore the latest innovations in dental technology.'**
  String get exploreInnovations;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Percentage display
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentage(int value);

  /// No description provided for @brushingTimer.
  ///
  /// In en, this message translates to:
  /// **'Brushing Timer'**
  String get brushingTimer;

  /// No description provided for @brushingTracker.
  ///
  /// In en, this message translates to:
  /// **'Brushing Tracker'**
  String get brushingTracker;

  /// No description provided for @twoMinuteGuidedBrush.
  ///
  /// In en, this message translates to:
  /// **'2-minute guided brush'**
  String get twoMinuteGuidedBrush;

  /// No description provided for @trackDailyBrushing.
  ///
  /// In en, this message translates to:
  /// **'Track daily brushing'**
  String get trackDailyBrushing;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @brushingTips.
  ///
  /// In en, this message translates to:
  /// **'Brushing Tips'**
  String get brushingTips;

  /// No description provided for @brushTip1.
  ///
  /// In en, this message translates to:
  /// **'Brush for at least 2 minutes'**
  String get brushTip1;

  /// No description provided for @brushTip2.
  ///
  /// In en, this message translates to:
  /// **'Use gentle, circular motions'**
  String get brushTip2;

  /// No description provided for @brushTip3.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget your tongue'**
  String get brushTip3;

  /// No description provided for @brushTip4.
  ///
  /// In en, this message translates to:
  /// **'Brush twice daily'**
  String get brushTip4;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// No description provided for @completedBrushingSession.
  ///
  /// In en, this message translates to:
  /// **'You completed your 2-minute brushing session!'**
  String get completedBrushingSession;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noFamilyMembersAdded.
  ///
  /// In en, this message translates to:
  /// **'No family members added'**
  String get noFamilyMembersAdded;

  /// No description provided for @addFamilyMembersProfile.
  ///
  /// In en, this message translates to:
  /// **'Add family members in the Profile section to start tracking'**
  String get addFamilyMembersProfile;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @todaysBrushingStatus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Brushing Status'**
  String get todaysBrushingStatus;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @markMorning.
  ///
  /// In en, this message translates to:
  /// **'Mark Morning'**
  String get markMorning;

  /// No description provided for @markNight.
  ///
  /// In en, this message translates to:
  /// **'Mark Night'**
  String get markNight;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @profileFamily.
  ///
  /// In en, this message translates to:
  /// **'Profile & Family'**
  String get profileFamily;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @yourStatistics.
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get yourStatistics;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievements Unlocked'**
  String get achievementsUnlocked;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @editFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Family Member'**
  String get editFamilyMember;

  /// No description provided for @relationOptional.
  ///
  /// In en, this message translates to:
  /// **'Relation (Optional)'**
  String get relationOptional;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @sibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get sibling;

  /// No description provided for @grandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get grandparent;

  /// No description provided for @auntUncle.
  ///
  /// In en, this message translates to:
  /// **'Aunt/Uncle'**
  String get auntUncle;

  /// No description provided for @cousin.
  ///
  /// In en, this message translates to:
  /// **'Cousin'**
  String get cousin;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @mythsChecked.
  ///
  /// In en, this message translates to:
  /// **'Myths Checked'**
  String get mythsChecked;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @noFamilyMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No family members yet'**
  String get noFamilyMembersYet;

  /// No description provided for @addFamilyMembersTrackBrushing.
  ///
  /// In en, this message translates to:
  /// **'Add family members to track their brushing habits'**
  String get addFamilyMembersTrackBrushing;

  /// No description provided for @noAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements'**
  String get noAchievements;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @brushingProgress.
  ///
  /// In en, this message translates to:
  /// **'Brushing Progress'**
  String get brushingProgress;

  /// No description provided for @selectFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Select Family Member'**
  String get selectFamilyMember;

  /// No description provided for @errorLoadingProgressData.
  ///
  /// In en, this message translates to:
  /// **'Error loading progress data'**
  String get errorLoadingProgressData;

  /// No description provided for @noBrushingDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No brushing data available'**
  String get noBrushingDataAvailable;

  /// No description provided for @startBrushingToSeeProgress.
  ///
  /// In en, this message translates to:
  /// **'Start brushing to see your progress!'**
  String get startBrushingToSeeProgress;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminders'**
  String get enableReminders;

  /// No description provided for @receiveBrushingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive brushing notifications'**
  String get receiveBrushingNotifications;

  /// No description provided for @remindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders enabled'**
  String get remindersEnabled;

  /// No description provided for @remindersDisabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders disabled'**
  String get remindersDisabled;

  /// No description provided for @morningReminder.
  ///
  /// In en, this message translates to:
  /// **'Morning Reminder'**
  String get morningReminder;

  /// No description provided for @nightReminder.
  ///
  /// In en, this message translates to:
  /// **'Night Reminder'**
  String get nightReminder;

  /// No description provided for @tapToChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Tap to change time'**
  String get tapToChangeTime;

  /// No description provided for @selectedForTracking.
  ///
  /// In en, this message translates to:
  /// **'selected for tracking'**
  String get selectedForTracking;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @deleteMemberQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Member?'**
  String get deleteMemberQuestion;

  /// Delete confirmation with member name
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name}?'**
  String confirmRemoveMember(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
