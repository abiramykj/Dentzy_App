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

  /// No description provided for @resultUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Result unavailable'**
  String get resultUnavailable;

  /// No description provided for @checkAnotherStatement.
  ///
  /// In en, this message translates to:
  /// **'Check Another Statement'**
  String get checkAnotherStatement;

  /// No description provided for @aiDentalScreening.
  ///
  /// In en, this message translates to:
  /// **'AI dental screening'**
  String get aiDentalScreening;

  /// No description provided for @scanMyths.
  ///
  /// In en, this message translates to:
  /// **'Check dental myths with one clean scan.'**
  String get scanMyths;

  /// No description provided for @mythPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Short answers, clear reasoning, and a premium medical-style result layout.'**
  String get mythPremiumDescription;

  /// No description provided for @yourStatement.
  ///
  /// In en, this message translates to:
  /// **'Your statement'**
  String get yourStatement;

  /// No description provided for @statementExample.
  ///
  /// In en, this message translates to:
  /// **'E.g., Brushing teeth twice daily prevents cavities'**
  String get statementExample;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Performance header with selected period
  ///
  /// In en, this message translates to:
  /// **'{period} Performance'**
  String performancePeriod(String period);

  /// No description provided for @noExplanationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No explanation available.'**
  String get noExplanationAvailable;

  /// No description provided for @moreVideos.
  ///
  /// In en, this message translates to:
  /// **'More Videos'**
  String get moreVideos;

  /// No description provided for @invalidYouTubeUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid YouTube URL'**
  String get invalidYouTubeUrl;

  /// No description provided for @noAppToOpenVideo.
  ///
  /// In en, this message translates to:
  /// **'No app available to open video'**
  String get noAppToOpenVideo;

  /// No description provided for @couldNotOpenVideo.
  ///
  /// In en, this message translates to:
  /// **'Could not open video'**
  String get couldNotOpenVideo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpAndSupport;

  /// No description provided for @liveResult.
  ///
  /// In en, this message translates to:
  /// **'Live result'**
  String get liveResult;

  /// No description provided for @resultsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Results will appear here'**
  String get resultsWillAppearHere;

  /// No description provided for @tryDentalStatement.
  ///
  /// In en, this message translates to:
  /// **'Try a dental statement to see a fact, myth, or not-dental verdict in a clean card layout.'**
  String get tryDentalStatement;

  /// No description provided for @whatAIchecksFirst.
  ///
  /// In en, this message translates to:
  /// **'What the AI checks first'**
  String get whatAIchecksFirst;

  /// No description provided for @dentalRelevance.
  ///
  /// In en, this message translates to:
  /// **'Dental relevance'**
  String get dentalRelevance;

  /// No description provided for @dentalRelevanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Teeth, gums, mouth, brushing, flossing, and oral care.'**
  String get dentalRelevanceDesc;

  /// No description provided for @thenClassify.
  ///
  /// In en, this message translates to:
  /// **'Then classify'**
  String get thenClassify;

  /// No description provided for @thenClassifyDesc.
  ///
  /// In en, this message translates to:
  /// **'If dental-related, the model decides whether it is FACT or MYTH.'**
  String get thenClassifyDesc;

  /// No description provided for @enterStatementToCheck.
  ///
  /// In en, this message translates to:
  /// **'Please enter a statement to check'**
  String get enterStatementToCheck;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @testYourKnowledgeAI.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge with AI-powered dental quizzes'**
  String get testYourKnowledgeAI;

  /// No description provided for @aiLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiLabel;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @monthlyProgress.
  ///
  /// In en, this message translates to:
  /// **'Monthly Progress'**
  String get monthlyProgress;

  /// No description provided for @brushingTipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Brushing Tips'**
  String get brushingTipsLabel;

  /// No description provided for @statisticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsLabel;

  /// No description provided for @totalBrushings.
  ///
  /// In en, this message translates to:
  /// **'Total Brushings'**
  String get totalBrushings;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @daysTracked.
  ///
  /// In en, this message translates to:
  /// **'Days Tracked'**
  String get daysTracked;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average per Day'**
  String get averagePerDay;

  /// No description provided for @brushTipsBulletPoints.
  ///
  /// In en, this message translates to:
  /// **'• Brush for at least 2 minutes\n• Brush twice daily (morning & night)\n• Use gentle, circular motions\n• Don\'t forget the back teeth\n• Floss after brushing'**
  String get brushTipsBulletPoints;

  /// No description provided for @healthySmilesTracker.
  ///
  /// In en, this message translates to:
  /// **'Healthy Smile Tracker'**
  String get healthySmilesTracker;

  /// No description provided for @trackBrushingHabits.
  ///
  /// In en, this message translates to:
  /// **'Track your brushing habits daily'**
  String get trackBrushingHabits;

  /// No description provided for @morningBrushingReminder.
  ///
  /// In en, this message translates to:
  /// **'Morning Brushing Reminder'**
  String get morningBrushingReminder;

  /// No description provided for @morningBrushingDescription.
  ///
  /// In en, this message translates to:
  /// **'Time to brush your teeth! Remember to brush for 2 minutes.'**
  String get morningBrushingDescription;

  /// No description provided for @quizAchievement.
  ///
  /// In en, this message translates to:
  /// **'Quiz Achievement'**
  String get quizAchievement;

  /// No description provided for @quizAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Great job! You completed 5 quizzes today. Keep it up!'**
  String get quizAchievementDescription;

  /// No description provided for @brushingStreak.
  ///
  /// In en, this message translates to:
  /// **'Brushing Streak'**
  String get brushingStreak;

  /// No description provided for @brushingStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'re on a 7-day brushing streak! Amazing dedication!'**
  String get brushingStreakDescription;

  /// No description provided for @eveningBrushingReminder.
  ///
  /// In en, this message translates to:
  /// **'Evening Brushing Reminder'**
  String get eveningBrushingReminder;

  /// No description provided for @eveningBrushingDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to brush before bedtime.'**
  String get eveningBrushingDescription;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Time format for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Time format for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Time format for days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @appTour.
  ///
  /// In en, this message translates to:
  /// **'App Tour'**
  String get appTour;

  /// No description provided for @replayAppTour.
  ///
  /// In en, this message translates to:
  /// **'Replay Guided Tour'**
  String get replayAppTour;

  /// No description provided for @tourWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dentzy'**
  String get tourWelcomeTitle;

  /// No description provided for @tourWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered dental health companion. Let\'s explore the app together!'**
  String get tourWelcomeDescription;

  /// No description provided for @tourMythCheckerTitle.
  ///
  /// In en, this message translates to:
  /// **'Myth Checker'**
  String get tourMythCheckerTitle;

  /// No description provided for @tourMythCheckerDescription.
  ///
  /// In en, this message translates to:
  /// **'Check whether a dental statement is a fact, myth, or unrelated to oral health with AI-powered analysis.'**
  String get tourMythCheckerDescription;

  /// No description provided for @tourMythInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Statement'**
  String get tourMythInputTitle;

  /// No description provided for @tourMythInputDescription.
  ///
  /// In en, this message translates to:
  /// **'Type or paste any dental statement here to check if it\'s true or false.'**
  String get tourMythInputDescription;

  /// No description provided for @tourMythCheckButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Statement'**
  String get tourMythCheckButtonTitle;

  /// No description provided for @tourMythCheckButtonDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap this button to analyze your statement with AI.'**
  String get tourMythCheckButtonDescription;

  /// No description provided for @tourMythResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get tourMythResultsTitle;

  /// No description provided for @tourMythResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'See the verdict (Fact, Myth, or Not Dental), confidence level, and detailed explanation.'**
  String get tourMythResultsDescription;

  /// No description provided for @tourBrushingTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Brushing Tracker'**
  String get tourBrushingTrackerTitle;

  /// No description provided for @tourBrushingTrackerDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your morning and night brushing habits and maintain healthy streaks.'**
  String get tourBrushingTrackerDescription;

  /// No description provided for @tourBrushingDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Brushing'**
  String get tourBrushingDailyTitle;

  /// No description provided for @tourBrushingDailyDescription.
  ///
  /// In en, this message translates to:
  /// **'Mark your morning and night brushing sessions here and see your daily progress.'**
  String get tourBrushingDailyDescription;

  /// No description provided for @tourBrushingWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get tourBrushingWeeklyTitle;

  /// No description provided for @tourBrushingWeeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor your brushing consistency over 7 days with a visual progress bar.'**
  String get tourBrushingWeeklyDescription;

  /// No description provided for @tourBrushingMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Stats'**
  String get tourBrushingMonthlyTitle;

  /// No description provided for @tourBrushingMonthlyDescription.
  ///
  /// In en, this message translates to:
  /// **'View your monthly brushing statistics, completion rate, and patterns.'**
  String get tourBrushingMonthlyDescription;

  /// No description provided for @tourBrushingTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Brushing Timer'**
  String get tourBrushingTimerTitle;

  /// No description provided for @tourBrushingTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the guided 2-minute timer to brush your teeth properly and build healthy habits.'**
  String get tourBrushingTimerDescription;

  /// No description provided for @tourBrushingTimerStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Your Session'**
  String get tourBrushingTimerStartTitle;

  /// No description provided for @tourBrushingTimerStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap Start to begin a guided 2-minute brushing session.'**
  String get tourBrushingTimerStartDescription;

  /// No description provided for @tourLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tourLearnTitle;

  /// No description provided for @tourLearnDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore educational articles about dental health, myths, and prevention techniques.'**
  String get tourLearnDescription;

  /// No description provided for @tourLearnCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tourLearnCategoriesTitle;

  /// No description provided for @tourLearnCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Filter articles by category or read featured content about dental care.'**
  String get tourLearnCategoriesDescription;

  /// No description provided for @tourProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tourProgressTitle;

  /// No description provided for @tourProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor your learning accuracy, quiz streaks, and dental health consistency metrics.'**
  String get tourProgressDescription;

  /// No description provided for @tourVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get tourVideoTitle;

  /// No description provided for @tourVideoDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch educational video lessons about brushing techniques, oral health, and dental care.'**
  String get tourVideoDescription;

  /// No description provided for @tourSettingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get tourSettingsLanguageTitle;

  /// No description provided for @tourSettingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch between English and Tamil anytime in your settings.'**
  String get tourSettingsLanguageDescription;

  /// No description provided for @tourSettingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tourSettingsNotificationsTitle;

  /// No description provided for @tourSettingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders for morning and evening brushing sessions.'**
  String get tourSettingsNotificationsDescription;

  /// No description provided for @tourBottomNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get tourBottomNavTitle;

  /// No description provided for @tourBottomNavDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap any tab to explore Myth Checker, Learn, Progress, Videos, and more.'**
  String get tourBottomNavDescription;

  /// No description provided for @tourFABTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Action'**
  String get tourFABTitle;

  /// No description provided for @tourFABDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the floating button for quick access to your most-used features.'**
  String get tourFABDescription;

  /// No description provided for @tourFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get tourFinishTitle;

  /// No description provided for @tourFinishDescription.
  ///
  /// In en, this message translates to:
  /// **'You now know all about Dentzy. Let\'s start improving your dental health!'**
  String get tourFinishDescription;

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// No description provided for @tourPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get tourPrevious;

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip Tour'**
  String get tourSkip;

  /// No description provided for @tourFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get tourFinish;

  /// No description provided for @tourGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get tourGetStarted;
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
