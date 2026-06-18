// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get miniGamesHub => 'Хаб Супернавыков';

  @override
  String get visualGames => 'Визуальные Игры';

  @override
  String get audioGames => 'Аудио Игры';

  @override
  String get brainGames => 'Игры для Мозга';

  @override
  String get memoryGames => 'Игры на Память';

  @override
  String get spatialGames => 'Пространственные Игры';

  @override
  String get tebakHexRgb => 'Угадай HEX/RGB';

  @override
  String get pointDiffSystem => 'Система очков по разнице цветов';

  @override
  String get tebakHexCmyk => 'Угадай HEX/CMYK';

  @override
  String get cmykChallenge => 'Цветовой вызов CMYK';

  @override
  String get perfectPitch => 'Абсолютный Слух';

  @override
  String get trainMusicPitch => 'Тренируйте музыкальный слух';

  @override
  String get brainReflex => 'Мозговой Рефлекс';

  @override
  String get stroopTestDesc => 'Тест Струпа: Тренировка фокуса и точности';

  @override
  String get target => 'Цель';

  @override
  String get yourResult => 'Ваш Результат';

  @override
  String get previewActive => 'Предпросмотр Активен';

  @override
  String get hidden => 'Скрыто';

  @override
  String get red => 'Красный';

  @override
  String get green => 'Зеленый';

  @override
  String get blue => 'Синий';

  @override
  String get cyan => 'Циан';

  @override
  String get pink => 'Розовый';

  @override
  String get yellow => 'Желтый';

  @override
  String get white => 'Белый';

  @override
  String get difference => 'Разница';

  @override
  String get playAgain => 'Играть Снова';

  @override
  String get checkScore => 'Проверить Счет';

  @override
  String get gameSettings => 'Настройки Игры';

  @override
  String get showUserPreview => 'Показать предпросмотр вашего цвета';

  @override
  String get showTargetHex => 'Показать целевой HEX-код';

  @override
  String inputHexFor(String label) {
    return 'Введите HEX для $label';
  }

  @override
  String get hexHint => 'например, FF или 80';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'ОК';

  @override
  String get perfectPitchTrainer => 'Тренажер Абсолютного Слуха';

  @override
  String get listenAndGuess => 'Слушайте ноту и угадывайте!';

  @override
  String get correct => 'Верно!';

  @override
  String wrongNote(String targetNote) {
    return 'Неверно! Это была $targetNote';
  }

  @override
  String get nextNote => 'Следующая нота';

  @override
  String get brainReflexStroop => 'Рефлекс Мозга: Струп';

  @override
  String timeLabel(int timeLeft) {
    return 'Время: $timeLeft';
  }

  @override
  String scoreLabel(int score) {
    return 'Счет: $score';
  }

  @override
  String get pickInkColor => 'Выберите цвет чернил';

  @override
  String get pickWordMeaning => 'Выберите значение слова';

  @override
  String get timeUp => 'Время вышло!';

  @override
  String get yourFinalScore => 'Ваш окончательный счет:';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get backToMenu => 'В меню';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите Язык';

  @override
  String get memorySequence => 'Последовательность Памяти';

  @override
  String get memorySequenceDesc =>
      'Запомните и повторите последовательность цветов';

  @override
  String get watchSequence => 'Следите за последовательностью!';

  @override
  String get yourTurn => 'Ваш ход!';

  @override
  String levelLabel(String level) {
    return 'Уровень: $level';
  }

  @override
  String get tileCount => 'Количество плиток';

  @override
  String get gameSpeed => 'Скорость Игры';

  @override
  String get fast => 'Быстро';

  @override
  String get medium => 'Средне';

  @override
  String get slow => 'Медленно';

  @override
  String get superFast => 'Очень быстро';

  @override
  String get spatialIq => 'Пространственный IQ';

  @override
  String get spatialIqDesc =>
      'Тренируйте мысленное вращение и 3D-пространственное мышление';

  @override
  String get gridSize => 'Размер Сетки';

  @override
  String get optionsCount => 'Количество Вариантов';

  @override
  String get matchRotatedShape => 'Найдите правильную совпадающую фигуру!';

  @override
  String get mazeGame => 'Неоновый Лабиринт';

  @override
  String get mazeGameDesc => 'Найдите путь из неоновой сетки';

  @override
  String get reachTheExit => 'Доберитесь до выхода!';

  @override
  String get levelComplete => 'Уровень Пройден!';

  @override
  String get advancedSettings => 'Расширенные Настройки';

  @override
  String get themeMode => 'Режим Темы';

  @override
  String get dark => 'Темная';

  @override
  String get light => 'Светлая';

  @override
  String get fontStyle => 'Стиль Шрифта';

  @override
  String fontSize(String percent) {
    return 'Размер шрифта: $percent%';
  }

  @override
  String get suddenDeath => 'Внезапная смерть (касание = проигрыш)';

  @override
  String get suddenDeathDesc => 'Возврат в начало при касании стены';

  @override
  String get suddenDeathMessage =>
      'О нет! Активирована внезапная смерть - назад на старт!';

  @override
  String get memorizationMode => 'Режим Запоминания';

  @override
  String get memorizationModeDesc => 'Стены исчезают после обратного отсчета';

  @override
  String memorizeMaze(int seconds) {
    return 'Запомните лабиринт: $seconds с';
  }

  @override
  String get resetShowAgain => 'Сбросить / Показать снова';

  @override
  String get chimpGame => 'Шимпанзе-Память';

  @override
  String get chimpGameDesc => 'Запомните и коснитесь скрытых чисел по порядку';

  @override
  String livesLabel(int count) {
    return 'Жизни: $count';
  }

  @override
  String numbersCount(int count) {
    return 'Числа: $count';
  }

  @override
  String get chimpTestStart => 'Нажмите 1, чтобы начать и скрыть числа!';

  @override
  String get chimpTestInstructions =>
      'Нажимайте на квадраты в порядке возрастания (1, 2, 3...)';

  @override
  String gameOverChimp(int level) {
    return 'Игра окончена! Ваш конечный уровень памяти: $level чисел.';
  }

  @override
  String get blindMode => 'Слепой Режим';

  @override
  String get blindModeDesc => 'Скрыть очертания после нажатия на 1';

  @override
  String get startingNumbers => 'Начальные Числа';

  @override
  String get reflexGame => 'Быстрый Тап';

  @override
  String get reflexGameDesc =>
      'Нажимайте на светящиеся плитки как можно быстрее';

  @override
  String gameOverReflex(int score) {
    return 'Игра окончена! Ваш окончательный счет: $score.';
  }

  @override
  String get operatorGame => 'Операторский Раш';

  @override
  String get operatorGameDesc =>
      'Быстро находите пропущенные математические знаки';

  @override
  String gameOverOperator(int score) {
    return 'Игра окончена! Ваш окончательный счет: $score.';
  }

  @override
  String get numericalGames => 'Числовые Игры';

  @override
  String get game24 => 'Игра 24';

  @override
  String get game24Desc =>
      'Решите, можно ли объединить карты для получения цели';

  @override
  String get speedMath => 'Быстрая Математика';

  @override
  String get speedMathDesc => 'Считайте быстро мелькающие числа и операторы';

  @override
  String get hideOutlines => 'Скрыть очертания';

  @override
  String get hideOutlinesDesc =>
      'Скрыть все очертания сетки после исчезновения чисел';

  @override
  String get game24Yes => 'Да';

  @override
  String get game24No => 'Нет';

  @override
  String game24CanBeMade(int target) {
    return 'Можно ли получить $target?';
  }

  @override
  String game24CorrectSolvable(String solution) {
    return 'Верно! Вот решение:\n$solution';
  }

  @override
  String get game24CorrectUnsolvable => 'Верно! Решений нет.';

  @override
  String game24WrongSolvable(String solution) {
    return 'Неверно! Это возможно. Решение:\n$solution';
  }

  @override
  String get game24WrongUnsolvable =>
      'Неверно! Математического решения не существует.';

  @override
  String get diceGame => 'Пространственный Кубик';

  @override
  String get diceGameDesc =>
      'Найдите правильный кубик, где сумма противоположных граней равна 7';

  @override
  String get diceGameInstruction =>
      'Вращайте кубик, чтобы осмотреть все грани. Противоположные грани должны давать в сумме 7!';

  @override
  String get all => 'Все';

  @override
  String get scoreboard => 'Таблица Рекордов';

  @override
  String highScore(int score) {
    return 'Рекорд: $score';
  }

  @override
  String get noScoresYet => 'Рекордов пока нет!';

  @override
  String get allowRotation => 'Разрешить Вращение';

  @override
  String get allowRotationDesc => 'Отключите, чтобы запретить вращение фигур';

  @override
  String get showGrid => 'Показывать границы сетки';

  @override
  String get showGridDesc =>
      'Показывать неоновые линии сетки для помощи в визуализации блоков';

  @override
  String get schulteGame => 'Фокус Шульте';

  @override
  String get schulteGameDesc =>
      'Нажимайте числа по порядку как можно быстрее для тренировки фокуса';

  @override
  String get schulteOrder => 'Порядок Чисел';

  @override
  String get ascending => 'По возрастанию';

  @override
  String get descending => 'По убыванию';

  @override
  String get gridColorMode => 'Цветовой Режим';

  @override
  String get monochrome => 'Монохромный';

  @override
  String get rainbow => 'Радужный';

  @override
  String tapNextNumber(int number) {
    return 'Нажмите следующее: $number';
  }

  @override
  String get temporalGames => 'Временной Контроль';

  @override
  String get timeEstimator => 'Оценка Времени';

  @override
  String get timeEstimatorDesc =>
      'Остановите секундомер ровно на целевом времени';

  @override
  String get rhythmSync => 'Синхронизация Ритма';

  @override
  String get rhythmSyncDesc => 'Нажимайте в идеальный такт с ритмом';

  @override
  String waitTargetTime(Object seconds) {
    return 'Подождите ровно $seconds секунд';
  }

  @override
  String get hideTimerDesc =>
      'Остановите, когда, по вашей оценке, время достигнет цели!';

  @override
  String get startEstimating => 'Старт';

  @override
  String get stopEstimating => 'Стоп';

  @override
  String get tapOnBeat => 'Тап!';

  @override
  String get listenRhythm => 'Слушайте ритм...';

  @override
  String get rhythmSyncTap => 'Тапайте на удары 4, 5, 6, 7, 8!';
}
