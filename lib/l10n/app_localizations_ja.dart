// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get miniGamesHub => 'Superskill Hub';

  @override
  String get visualGames => '視覚ゲーム';

  @override
  String get audioGames => 'オーディオゲーム';

  @override
  String get brainGames => '脳トレゲーム';

  @override
  String get memoryGames => '記憶ゲーム';

  @override
  String get spatialGames => '空間ゲーム';

  @override
  String get tebakHexRgb => 'HEX/RGBを当てる';

  @override
  String get pointDiffSystem => '色差ポイントシステム';

  @override
  String get tebakHexCmyk => 'HEX/CMYKを当てる';

  @override
  String get cmykChallenge => 'CMYKカラーチャレンジ';

  @override
  String get perfectPitch => '絶対音感';

  @override
  String get trainMusicPitch => '音感トレーニング';

  @override
  String get brainReflex => '脳トレ反射';

  @override
  String get stroopTestDesc => 'ストループテスト：集中力と正確さを鍛える';

  @override
  String get target => 'ターゲット';

  @override
  String get yourResult => 'あなたの結果';

  @override
  String get previewActive => 'プレビュー有効';

  @override
  String get hidden => '非表示';

  @override
  String get red => '赤';

  @override
  String get green => '緑';

  @override
  String get blue => '青';

  @override
  String get cyan => 'シアン';

  @override
  String get pink => 'マゼンタ';

  @override
  String get yellow => 'イエロー';

  @override
  String get white => 'ブラック';

  @override
  String get difference => '差分';

  @override
  String get playAgain => 'もう一度遊ぶ';

  @override
  String get checkScore => 'スコアを確認';

  @override
  String get gameSettings => 'ゲーム設定';

  @override
  String get showUserPreview => 'カラープレビューを表示';

  @override
  String get showTargetHex => 'ターゲットのHEXコードを表示';

  @override
  String inputHexFor(String label) {
    return '$label のHEXを入力';
  }

  @override
  String get hexHint => '例：FF または 80';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get perfectPitchTrainer => '絶対音感トレーナー';

  @override
  String get listenAndGuess => '音を聴いて当てよう！';

  @override
  String get correct => '正解！';

  @override
  String wrongNote(String targetNote) {
    return '不正解！正解は $targetNote でした';
  }

  @override
  String get nextNote => '次の音へ';

  @override
  String get brainReflexStroop => '脳トレ反射：ストループ';

  @override
  String timeLabel(int timeLeft) {
    return '残り時間：$timeLeft';
  }

  @override
  String scoreLabel(int score) {
    return 'スコア：$score';
  }

  @override
  String get pickInkColor => 'インクの色を選んでください';

  @override
  String get pickWordMeaning => '言葉の意味を選んでください';

  @override
  String get timeUp => '時間切れ！';

  @override
  String get yourFinalScore => '最終スコア：';

  @override
  String get tryAgain => 'もう一度挑戦';

  @override
  String get backToMenu => 'メニューに戻る';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get memorySequence => '記憶シーケンス';

  @override
  String get memorySequenceDesc => '色の順番を覚えて繰り返す';

  @override
  String get watchSequence => '順番を覚えてください！';

  @override
  String get yourTurn => 'あなたの番です！';

  @override
  String levelLabel(String level) {
    return 'レベル: $level';
  }

  @override
  String get tileCount => 'タイル数';

  @override
  String get gameSpeed => 'ゲーム速度';

  @override
  String get fast => '速い';

  @override
  String get medium => '普通';

  @override
  String get slow => '遅い';

  @override
  String get superFast => '超速い';

  @override
  String get spatialIq => '空間IQ';

  @override
  String get spatialIqDesc => 'メンタルローテーションと3D空間認知のトレーニング';

  @override
  String get gridSize => 'グリッドサイズ';

  @override
  String get optionsCount => '選択肢の数';

  @override
  String get matchRotatedShape => '正しく一致する形状を見つけてください！';

  @override
  String get mazeGame => 'ネオン迷路';

  @override
  String get mazeGameDesc => 'ネオングリッドから正しい脱出路を見つけよう';

  @override
  String get reachTheExit => '出口に到達せよ！';

  @override
  String get levelComplete => 'レベル完了！';

  @override
  String get advancedSettings => '詳細設定';

  @override
  String get themeMode => 'テーマモード';

  @override
  String get dark => 'ダーク';

  @override
  String get light => 'ホワイト / ライト';

  @override
  String get fontStyle => 'フォントスタイル';

  @override
  String fontSize(String percent) {
    return 'フォントサイズ: $percent%';
  }

  @override
  String get suddenDeath => 'サドンデス (壁に当たるとゲームオーバー)';

  @override
  String get suddenDeathDesc => '壁に当たると開始位置に戻ります';

  @override
  String get suddenDeathMessage => '残念！壁に当たりました - 最初からやり直し！';

  @override
  String get memorizationMode => '暗記モード';

  @override
  String get memorizationModeDesc => 'カウントダウン後に壁が消えます';

  @override
  String memorizeMaze(int seconds) {
    return '迷路を暗記してください: $seconds 秒';
  }

  @override
  String get resetShowAgain => 'リセット / もう一度表示';

  @override
  String get chimpGame => 'チンパンジー・テスト';

  @override
  String get chimpGameDesc => '隠された数字を順番に記憶してタップします';

  @override
  String livesLabel(int count) {
    return 'ライフ: $count';
  }

  @override
  String numbersCount(int count) {
    return '数字の数: $count';
  }

  @override
  String get chimpTestStart => '1をタップして数字を隠し、開始します！';

  @override
  String get chimpTestInstructions => '昇順（1、2、3...）に四角をタップしてください';

  @override
  String gameOverChimp(int level) {
    return 'ゲームオーバー！あなたの最終的な記憶レベルは $level 個の数字でした。';
  }
}
