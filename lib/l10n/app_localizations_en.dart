// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get miniGamesHub => 'Superskill Hub';

  @override
  String get visualGames => 'Visual Games';

  @override
  String get audioGames => 'Audio Games';

  @override
  String get brainGames => 'Brain Games';

  @override
  String get memoryGames => 'Memory Games';

  @override
  String get spatialGames => 'Spatial Games';

  @override
  String get tebakHexRgb => 'Guess HEX/RGB';

  @override
  String get pointDiffSystem => 'Color difference point system';

  @override
  String get tebakHexCmyk => 'Guess HEX/CMYK';

  @override
  String get cmykChallenge => 'CMYK color challenge';

  @override
  String get perfectPitch => 'Perfect Pitch';

  @override
  String get trainMusicPitch => 'Train your music pitch hearing';

  @override
  String get brainReflex => 'Brain Reflex';

  @override
  String get stroopTestDesc => 'Stroop Test: Train focus & accuracy';

  @override
  String get target => 'Target';

  @override
  String get yourResult => 'Your Result';

  @override
  String get previewActive => 'Preview Active';

  @override
  String get hidden => 'Hidden';

  @override
  String get red => 'Red';

  @override
  String get green => 'Green';

  @override
  String get blue => 'Blue';

  @override
  String get cyan => 'Cyan';

  @override
  String get pink => 'Pink';

  @override
  String get yellow => 'Yellow';

  @override
  String get white => 'White';

  @override
  String get difference => 'Difference';

  @override
  String get playAgain => 'Play Again';

  @override
  String get checkScore => 'Check Score';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String get showUserPreview => 'Show Your Color Preview';

  @override
  String get showTargetHex => 'Show Target HEX Code';

  @override
  String inputHexFor(String label) {
    return 'Input HEX for $label';
  }

  @override
  String get hexHint => 'e.g. FF or 80';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'Ok';

  @override
  String get perfectPitchTrainer => 'Perfect Pitch Trainer';

  @override
  String get listenAndGuess => 'Listen to the note and guess!';

  @override
  String get correct => 'Correct!';

  @override
  String wrongNote(String targetNote) {
    return 'Wrong! It was $targetNote';
  }

  @override
  String get nextNote => 'Next note';

  @override
  String get brainReflexStroop => 'Brain Reflex: Stroop';

  @override
  String timeLabel(int timeLeft) {
    return 'Time: $timeLeft';
  }

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String get pickInkColor => 'Pick ink color';

  @override
  String get pickWordMeaning => 'Pick word meaning';

  @override
  String get timeUp => 'Time\'s up!';

  @override
  String get yourFinalScore => 'Your Final Score:';

  @override
  String get tryAgain => 'Try again';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get memorySequence => 'Memory Sequence';

  @override
  String get memorySequenceDesc => 'Remember and repeat the color sequence';

  @override
  String get watchSequence => 'Watch the sequence!';

  @override
  String get yourTurn => 'Your turn!';

  @override
  String levelLabel(String level) {
    return 'Level: $level';
  }

  @override
  String get tileCount => 'Tile Count';

  @override
  String get gameSpeed => 'Game Speed';

  @override
  String get fast => 'Fast';

  @override
  String get medium => 'Medium';

  @override
  String get slow => 'Slow';

  @override
  String get superFast => 'Super Fast';

  @override
  String get spatialIq => 'Spatial IQ';

  @override
  String get spatialIqDesc => 'Train mental rotation and 3D space cognition';

  @override
  String get gridSize => 'Grid Size';

  @override
  String get optionsCount => 'Options Count';

  @override
  String get matchRotatedShape => 'Find the correct matching shape!';

  @override
  String get mazeGame => 'Neon Maze';

  @override
  String get mazeGameDesc => 'Find the correct path out of the neon grid';

  @override
  String get reachTheExit => 'Reach the exit!';

  @override
  String get levelComplete => 'Level Complete!';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'White / Light';

  @override
  String get fontStyle => 'Font Style';

  @override
  String fontSize(String percent) {
    return 'Font Size: $percent%';
  }

  @override
  String get suddenDeath => 'Sudden Death (Hit = Die)';

  @override
  String get suddenDeathDesc => 'Return to start position if you hit a wall';

  @override
  String get suddenDeathMessage =>
      'Bummer! Sudden Death Activated - Back to Start!';

  @override
  String get memorizationMode => 'Memorization Mode';

  @override
  String get memorizationModeDesc => 'Walls disappear after countdown';

  @override
  String memorizeMaze(int seconds) {
    return 'Memorize the Maze: $seconds s';
  }

  @override
  String get resetShowAgain => 'Reset / Show Again';

  @override
  String get chimpGame => 'Chimp Memory';

  @override
  String get chimpGameDesc => 'Remember and tap hidden numbers in order';

  @override
  String livesLabel(int count) {
    return 'Lives: $count';
  }

  @override
  String numbersCount(int count) {
    return 'Numbers: $count';
  }

  @override
  String get chimpTestStart => 'Tap 1 to begin and hide numbers!';

  @override
  String get chimpTestInstructions =>
      'Tap the squares in ascending order (1, 2, 3...)';

  @override
  String gameOverChimp(int level) {
    return 'Game Over! Your final memory level was $level numbers.';
  }
}
