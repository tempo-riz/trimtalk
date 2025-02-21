import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @ttMeaning.
  ///
  /// In en, this message translates to:
  /// **'TrimTalk means converting audio messages into concise and accurate text transcripts.'**
  String get ttMeaning;

  /// No description provided for @transcribeAndSummarizeBySharingThemWithTheApp.
  ///
  /// In en, this message translates to:
  /// **'Transcribe and summarize audio messages by sharing them with the app.'**
  String get transcribeAndSummarizeBySharingThemWithTheApp;

  /// No description provided for @transcribeAndSummarizeWhatsAppAudioMessages.
  ///
  /// In en, this message translates to:
  /// **'Transcribe and summarize WhatsApp audio messages.'**
  String get transcribeAndSummarizeWhatsAppAudioMessages;

  /// No description provided for @youCanAlsoTranscribeOtherAudioFilesBySharingThemWithTheApp.
  ///
  /// In en, this message translates to:
  /// **'You can also transcribe other audio files by sharing it with the app.'**
  String get youCanAlsoTranscribeOtherAudioFilesBySharingThemWithTheApp;

  /// No description provided for @stillInDevDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The app is in developpement, If you find a bug or have ideas please use this button later to send feedback :)'**
  String get stillInDevDisclaimer;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get letsGetStarted;

  /// No description provided for @ttNeedsToAccesAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'Trim Talk needs access to audio files to transcribe them !'**
  String get ttNeedsToAccesAudioFiles;

  /// No description provided for @readAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'Read audio files'**
  String get readAudioFiles;

  /// No description provided for @yourDataIsPrivateAndNeverShared.
  ///
  /// In en, this message translates to:
  /// **'Your data is private and never shared'**
  String get yourDataIsPrivateAndNeverShared;

  /// No description provided for @givePermission.
  ///
  /// In en, this message translates to:
  /// **'Give permission'**
  String get givePermission;

  /// No description provided for @giveAccesToTheFollowingFolder.
  ///
  /// In en, this message translates to:
  /// **'Give access to the following folder : '**
  String get giveAccesToTheFollowingFolder;

  /// No description provided for @nothingToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing to see here...'**
  String get nothingToSeeHere;

  /// No description provided for @shareAnyAudioFileToTheApp.
  ///
  /// In en, this message translates to:
  /// **'Share any audio file to the app'**
  String get shareAnyAudioFileToTheApp;

  /// No description provided for @tapCheckNow.
  ///
  /// In en, this message translates to:
  /// **'Tap check now'**
  String get tapCheckNow;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get thankYou;

  /// No description provided for @failedToSendFeedbackPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to send feedback, please try again'**
  String get failedToSendFeedbackPleaseTryAgain;

  /// No description provided for @pleaseTryAgainWithText.
  ///
  /// In en, this message translates to:
  /// **'Please try again with text'**
  String get pleaseTryAgainWithText;

  /// No description provided for @quickExplanation.
  ///
  /// In en, this message translates to:
  /// **'Quick explanation'**
  String get quickExplanation;

  /// No description provided for @audioMessagesAppearLikeThat.
  ///
  /// In en, this message translates to:
  /// **'Audio messages appear like that:'**
  String get audioMessagesAppearLikeThat;

  /// No description provided for @tapTheCardToLoadTheTranscript.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to load the transcript'**
  String get tapTheCardToLoadTheTranscript;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get tap;

  /// No description provided for @skipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip tutorial'**
  String get skipTutorial;

  /// No description provided for @toSummarize.
  ///
  /// In en, this message translates to:
  /// **'to summarize'**
  String get toSummarize;

  /// No description provided for @tapTheCardToSeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to see details'**
  String get tapTheCardToSeeDetails;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareTt.
  ///
  /// In en, this message translates to:
  /// **'Share TrimTalk'**
  String get shareTt;

  /// No description provided for @rateTtOnStore.
  ///
  /// In en, this message translates to:
  /// **'Rate TrimTalk on the store'**
  String get rateTtOnStore;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure ?'**
  String get areYouSure;

  /// No description provided for @doYouReallyWantToDeleteEveryTranscriptThisCantBeUndone.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete every transcript ? This can\'t be undone.'**
  String get doYouReallyWantToDeleteEveryTranscriptThisCantBeUndone;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @deleteAllTranscripts.
  ///
  /// In en, this message translates to:
  /// **'Delete all transcripts'**
  String get deleteAllTranscripts;

  /// No description provided for @transcriptionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Transcription language'**
  String get transcriptionLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @autoLanguageDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'More accurate with a specific language'**
  String get autoLanguageDisclaimer;

  /// No description provided for @periodicCheckFrequency.
  ///
  /// In en, this message translates to:
  /// **'Periodic check frequency'**
  String get periodicCheckFrequency;

  /// No description provided for @disablePeriodicCheck.
  ///
  /// In en, this message translates to:
  /// **'Disable periodic check'**
  String get disablePeriodicCheck;

  /// No description provided for @enablePeriodicCheck.
  ///
  /// In en, this message translates to:
  /// **'Enable periodic check'**
  String get enablePeriodicCheck;

  /// No description provided for @periodicCheck.
  ///
  /// In en, this message translates to:
  /// **'Periodic check'**
  String get periodicCheck;

  /// No description provided for @checkFrequency.
  ///
  /// In en, this message translates to:
  /// **'Check frequency'**
  String get checkFrequency;

  /// No description provided for @dontAskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask confirmation'**
  String get dontAskConfirmation;

  /// No description provided for @alwaysAutoTranscribe.
  ///
  /// In en, this message translates to:
  /// **'Auto transcribe'**
  String get alwaysAutoTranscribe;

  /// No description provided for @whenAppIsInBackground.
  ///
  /// In en, this message translates to:
  /// **'When app is in background'**
  String get whenAppIsInBackground;

  /// No description provided for @sendNotifications.
  ///
  /// In en, this message translates to:
  /// **'Send notifications'**
  String get sendNotifications;

  /// No description provided for @autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto detect'**
  String get autoDetect;

  /// No description provided for @autoDetectExplain.
  ///
  /// In en, this message translates to:
  /// **'Listens to notifications to detect new messages'**
  String get autoDetectExplain;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @translateExplain.
  ///
  /// In en, this message translates to:
  /// **'Translate to the app language if different'**
  String get translateExplain;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at'**
  String get todayAt;

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at'**
  String get yesterdayAt;

  /// No description provided for @neverChecked.
  ///
  /// In en, this message translates to:
  /// **'Never checked'**
  String get neverChecked;

  /// No description provided for @receivedAt.
  ///
  /// In en, this message translates to:
  /// **'Received at'**
  String get receivedAt;

  /// No description provided for @daysAgoAt.
  ///
  /// In en, this message translates to:
  /// **'days ago at'**
  String get daysAgoAt;

  /// No description provided for @noNewAudiosFound.
  ///
  /// In en, this message translates to:
  /// **'No new audios found'**
  String get noNewAudiosFound;

  /// No description provided for @transcribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing'**
  String get transcribing;

  /// No description provided for @failedToTranscribe.
  ///
  /// In en, this message translates to:
  /// **'Failed to transcribe'**
  String get failedToTranscribe;

  /// No description provided for @trimAudio.
  ///
  /// In en, this message translates to:
  /// **'Trim audio'**
  String get trimAudio;

  /// No description provided for @emptyTranscript.
  ///
  /// In en, this message translates to:
  /// **'Empty transcript'**
  String get emptyTranscript;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @audioMessage.
  ///
  /// In en, this message translates to:
  /// **'Audio message'**
  String get audioMessage;

  /// No description provided for @copyTranscript.
  ///
  /// In en, this message translates to:
  /// **'Copy transcript'**
  String get copyTranscript;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @copySummary.
  ///
  /// In en, this message translates to:
  /// **'Copy summary'**
  String get copySummary;

  /// No description provided for @heyImUsingTtToTranscribeAndSummarizeCheckItOut.
  ///
  /// In en, this message translates to:
  /// **'Hey, I\'m using TrimTalk to transcribe and summarize audio messages, check it out!'**
  String get heyImUsingTtToTranscribeAndSummarizeCheckItOut;

  /// No description provided for @madeWithTt.
  ///
  /// In en, this message translates to:
  /// **'Made with TrimTalk'**
  String get madeWithTt;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @checkCodeOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Check code on GitHub'**
  String get checkCodeOnGithub;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
