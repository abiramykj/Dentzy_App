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
