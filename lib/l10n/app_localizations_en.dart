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

  @override
  String get blindMode => 'Blind Mode';

  @override
  String get blindModeDesc => 'Hide tile outlines after tapping 1';

  @override
  String get startingNumbers => 'Starting Numbers';

  @override
  String get reflexGame => 'Reflex Tap';

  @override
  String get reflexGameDesc => 'Tap the glowing tiles as fast as you can';

  @override
  String gameOverReflex(int score) {
    return 'Game Over! Your final score was $score.';
  }

  @override
  String get operatorGame => 'Operator Rush';

  @override
  String get operatorGameDesc => 'Find the missing math operators quickly';

  @override
  String gameOverOperator(int score) {
    return 'Game Over! Your final score was $score.';
  }

  @override
  String get numericalGames => 'Numerical Games';

  @override
  String get game24 => 'Game 24';

  @override
  String get game24Desc => 'Decide if cards can be combined to reach target';

  @override
  String get speedMath => 'Speed Math';

  @override
  String get speedMathDesc => 'Calculate fast flashing numbers & operators';

  @override
  String get hideOutlines => 'Hide Outlines';

  @override
  String get hideOutlinesDesc =>
      'Hide all grid outlines once numbers disappear';

  @override
  String get game24Yes => 'Yes';

  @override
  String get game24No => 'No';

  @override
  String game24CanBeMade(int target) {
    return 'Can you make $target?';
  }

  @override
  String game24CorrectSolvable(String solution) {
    return 'Correct! Here is a solution:\n$solution';
  }

  @override
  String get game24CorrectUnsolvable => 'Correct! No solution exists.';

  @override
  String game24WrongSolvable(String solution) {
    return 'Wrong! It is possible. Solution:\n$solution';
  }

  @override
  String get game24WrongUnsolvable => 'Wrong! No mathematical solution exists.';

  @override
  String get diceGame => 'Spatial Dice';

  @override
  String get diceGameDesc =>
      'Find the valid dice where opposite faces sum to 7';

  @override
  String get diceGameInstruction =>
      'Rotate the dice to inspect all faces. Opposite faces must sum to 7!';

  @override
  String get all => 'All';

  @override
  String get scoreboard => 'Scoreboard';

  @override
  String highScore(int score) {
    return 'High Score: $score';
  }

  @override
  String get noScoresYet => 'No scores recorded yet!';

  @override
  String get allowRotation => 'Allow Rotation';

  @override
  String get allowRotationDesc => 'Disable to prevent rotating the shapes';

  @override
  String get schulteGame => 'Schulte Focus';

  @override
  String get schulteGameDesc =>
      'Tap numbers in order as fast as possible to train focus';

  @override
  String get schulteOrder => 'Number Order';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get gridColorMode => 'Color Mode';

  @override
  String get monochrome => 'Monochrome';

  @override
  String get rainbow => 'Rainbow';

  @override
  String tapNextNumber(int number) {
    return 'Tap next: $number';
  }
}
