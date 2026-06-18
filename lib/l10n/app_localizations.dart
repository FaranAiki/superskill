import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

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
    Locale('id'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @miniGamesHub.
  ///
  /// In en, this message translates to:
  /// **'Superskill Hub'**
  String get miniGamesHub;

  /// No description provided for @visualGames.
  ///
  /// In en, this message translates to:
  /// **'Visual Games'**
  String get visualGames;

  /// No description provided for @audioGames.
  ///
  /// In en, this message translates to:
  /// **'Audio Games'**
  String get audioGames;

  /// No description provided for @brainGames.
  ///
  /// In en, this message translates to:
  /// **'Brain Games'**
  String get brainGames;

  /// No description provided for @memoryGames.
  ///
  /// In en, this message translates to:
  /// **'Memory Games'**
  String get memoryGames;

  /// No description provided for @spatialGames.
  ///
  /// In en, this message translates to:
  /// **'Spatial Games'**
  String get spatialGames;

  /// No description provided for @tebakHexRgb.
  ///
  /// In en, this message translates to:
  /// **'Guess HEX/RGB'**
  String get tebakHexRgb;

  /// No description provided for @pointDiffSystem.
  ///
  /// In en, this message translates to:
  /// **'Color difference point system'**
  String get pointDiffSystem;

  /// No description provided for @tebakHexCmyk.
  ///
  /// In en, this message translates to:
  /// **'Guess HEX/CMYK'**
  String get tebakHexCmyk;

  /// No description provided for @cmykChallenge.
  ///
  /// In en, this message translates to:
  /// **'CMYK color challenge'**
  String get cmykChallenge;

  /// No description provided for @perfectPitch.
  ///
  /// In en, this message translates to:
  /// **'Perfect Pitch'**
  String get perfectPitch;

  /// No description provided for @trainMusicPitch.
  ///
  /// In en, this message translates to:
  /// **'Train your music pitch hearing'**
  String get trainMusicPitch;

  /// No description provided for @brainReflex.
  ///
  /// In en, this message translates to:
  /// **'Brain Reflex'**
  String get brainReflex;

  /// No description provided for @stroopTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Stroop Test: Train focus & accuracy'**
  String get stroopTestDesc;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @yourResult.
  ///
  /// In en, this message translates to:
  /// **'Your Result'**
  String get yourResult;

  /// No description provided for @previewActive.
  ///
  /// In en, this message translates to:
  /// **'Preview Active'**
  String get previewActive;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @cyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get cyan;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @checkScore.
  ///
  /// In en, this message translates to:
  /// **'Check Score'**
  String get checkScore;

  /// No description provided for @gameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// No description provided for @showUserPreview.
  ///
  /// In en, this message translates to:
  /// **'Show Your Color Preview'**
  String get showUserPreview;

  /// No description provided for @showTargetHex.
  ///
  /// In en, this message translates to:
  /// **'Show Target HEX Code'**
  String get showTargetHex;

  /// No description provided for @inputHexFor.
  ///
  /// In en, this message translates to:
  /// **'Input HEX for {label}'**
  String inputHexFor(String label);

  /// No description provided for @hexHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. FF or 80'**
  String get hexHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @perfectPitchTrainer.
  ///
  /// In en, this message translates to:
  /// **'Perfect Pitch Trainer'**
  String get perfectPitchTrainer;

  /// No description provided for @listenAndGuess.
  ///
  /// In en, this message translates to:
  /// **'Listen to the note and guess!'**
  String get listenAndGuess;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @wrongNote.
  ///
  /// In en, this message translates to:
  /// **'Wrong! It was {targetNote}'**
  String wrongNote(String targetNote);

  /// No description provided for @nextNote.
  ///
  /// In en, this message translates to:
  /// **'Next note'**
  String get nextNote;

  /// No description provided for @brainReflexStroop.
  ///
  /// In en, this message translates to:
  /// **'Brain Reflex: Stroop'**
  String get brainReflexStroop;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {timeLeft}'**
  String timeLabel(int timeLeft);

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(int score);

  /// No description provided for @pickInkColor.
  ///
  /// In en, this message translates to:
  /// **'Pick ink color'**
  String get pickInkColor;

  /// No description provided for @pickWordMeaning.
  ///
  /// In en, this message translates to:
  /// **'Pick word meaning'**
  String get pickWordMeaning;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get timeUp;

  /// No description provided for @yourFinalScore.
  ///
  /// In en, this message translates to:
  /// **'Your Final Score:'**
  String get yourFinalScore;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @memorySequence.
  ///
  /// In en, this message translates to:
  /// **'Memory Sequence'**
  String get memorySequence;

  /// No description provided for @memorySequenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Remember and repeat the color sequence'**
  String get memorySequenceDesc;

  /// No description provided for @watchSequence.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence!'**
  String get watchSequence;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn!'**
  String get yourTurn;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String levelLabel(String level);

  /// No description provided for @tileCount.
  ///
  /// In en, this message translates to:
  /// **'Tile Count'**
  String get tileCount;

  /// No description provided for @gameSpeed.
  ///
  /// In en, this message translates to:
  /// **'Game Speed'**
  String get gameSpeed;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @superFast.
  ///
  /// In en, this message translates to:
  /// **'Super Fast'**
  String get superFast;

  /// No description provided for @spatialIq.
  ///
  /// In en, this message translates to:
  /// **'Spatial IQ'**
  String get spatialIq;

  /// No description provided for @spatialIqDesc.
  ///
  /// In en, this message translates to:
  /// **'Train mental rotation and 3D space cognition'**
  String get spatialIqDesc;

  /// No description provided for @gridSize.
  ///
  /// In en, this message translates to:
  /// **'Grid Size'**
  String get gridSize;

  /// No description provided for @optionsCount.
  ///
  /// In en, this message translates to:
  /// **'Options Count'**
  String get optionsCount;

  /// No description provided for @matchRotatedShape.
  ///
  /// In en, this message translates to:
  /// **'Find the correct matching shape!'**
  String get matchRotatedShape;
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
      <String>['en', 'id', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
