// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get miniGamesHub => 'Superskill Hub';

  @override
  String get visualGames => '视觉游戏';

  @override
  String get audioGames => '音频游戏';

  @override
  String get brainGames => '益智游戏';

  @override
  String get memoryGames => '记忆游戏';

  @override
  String get spatialGames => '空间游戏';

  @override
  String get tebakHexRgb => '猜 HEX/RGB';

  @override
  String get pointDiffSystem => '颜色色差积分系统';

  @override
  String get tebakHexCmyk => '猜 HEX/CMYK';

  @override
  String get cmykChallenge => 'CMYK 颜色挑战';

  @override
  String get perfectPitch => '绝对音感';

  @override
  String get trainMusicPitch => '练习音乐音高听力';

  @override
  String get brainReflex => '大脑反射术';

  @override
  String get stroopTestDesc => '斯特鲁普测试：训练专注力与准确性';

  @override
  String get target => '目标';

  @override
  String get yourResult => '你的结果';

  @override
  String get previewActive => '预览已启用';

  @override
  String get hidden => '已隐藏';

  @override
  String get red => '红';

  @override
  String get green => '绿';

  @override
  String get blue => '蓝';

  @override
  String get cyan => '青';

  @override
  String get pink => '洋红';

  @override
  String get yellow => '黄';

  @override
  String get white => '黑';

  @override
  String get difference => '差异';

  @override
  String get playAgain => '再玩一次';

  @override
  String get checkScore => '查看分数';

  @override
  String get gameSettings => '游戏设置';

  @override
  String get showUserPreview => '显示你的颜色预览';

  @override
  String get showTargetHex => '显示目标 HEX 代码';

  @override
  String inputHexFor(String label) {
    return '输入 $label 的 HEX';
  }

  @override
  String get hexHint => '例如：FF 或 80';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get perfectPitchTrainer => '绝对音感训练器';

  @override
  String get listenAndGuess => '听音并猜测！';

  @override
  String get correct => '正确！';

  @override
  String wrongNote(String targetNote) {
    return '错误！那是 $targetNote';
  }

  @override
  String get nextNote => '下一个音符';

  @override
  String get brainReflexStroop => '大脑反射：斯特鲁普';

  @override
  String timeLabel(int timeLeft) {
    return '时间：$timeLeft';
  }

  @override
  String scoreLabel(int score) {
    return '分数：$score';
  }

  @override
  String get pickInkColor => '选择墨水颜色';

  @override
  String get pickWordMeaning => '选择字义';

  @override
  String get timeUp => '时间到！';

  @override
  String get yourFinalScore => '你的最终分数：';

  @override
  String get tryAgain => '再试一次';

  @override
  String get backToMenu => '返回菜单';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get memorySequence => '记忆序列';

  @override
  String get memorySequenceDesc => '记住并重复颜色序列';

  @override
  String get watchSequence => '观察序列！';

  @override
  String get yourTurn => '轮到你了！';

  @override
  String levelLabel(String level) {
    return '等级: $level';
  }

  @override
  String get tileCount => '瓷砖数量';

  @override
  String get gameSpeed => '游戏速度';

  @override
  String get fast => '快';

  @override
  String get medium => '中';

  @override
  String get slow => '慢';

  @override
  String get superFast => '极快';

  @override
  String get spatialIq => '空间智商';

  @override
  String get spatialIqDesc => '训练心理旋转和3D空间认知';

  @override
  String get gridSize => '网格大小';

  @override
  String get optionsCount => '选项数量';

  @override
  String get matchRotatedShape => '找到正确匹配的形状！';

  @override
  String get mazeGame => '霓虹迷宫';

  @override
  String get mazeGameDesc => '从霓虹网格中找到正确的出口';

  @override
  String get reachTheExit => '到达出口！';

  @override
  String get levelComplete => '通关成功！';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get themeMode => '主题模式';

  @override
  String get dark => '深色';

  @override
  String get light => '白色 / 浅色';

  @override
  String get fontStyle => '字体样式';

  @override
  String fontSize(String percent) {
    return '字体大小: $percent%';
  }

  @override
  String get suddenDeath => '突然死亡 (撞墙即死)';

  @override
  String get suddenDeathDesc => '碰到墙壁返回起点';

  @override
  String get suddenDeathMessage => '哎呀！碰到墙壁了 - 回到起点！';

  @override
  String get memorizationMode => '记忆模式';

  @override
  String get memorizationModeDesc => '倒计时结束后墙壁消失';

  @override
  String memorizeMaze(int seconds) {
    return '记住迷宫: $seconds 秒';
  }

  @override
  String get resetShowAgain => '重置 / 再次显示';

  @override
  String get chimpGame => '黑猩猩记忆';

  @override
  String get chimpGameDesc => '记住并按顺序点击隐藏的数字';

  @override
  String livesLabel(int count) {
    return '生命值: $count';
  }

  @override
  String numbersCount(int count) {
    return '数字数量: $count';
  }

  @override
  String get chimpTestStart => '点击 1 开始并隐藏数字！';

  @override
  String get chimpTestInstructions => '按升序（1, 2, 3...）点击方块';

  @override
  String gameOverChimp(int level) {
    return '游戏结束！您的最终记忆等级是 $level 个数字。';
  }
}
