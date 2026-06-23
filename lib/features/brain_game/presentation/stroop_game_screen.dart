import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';
import 'package:superskill/core/soundfont_service.dart';

class StroopGameScreen extends StatefulWidget {
  const StroopGameScreen({super.key});

  @override
  State<StroopGameScreen> createState() => _StroopGameScreenState();
}

class _StroopGameScreenState extends State<StroopGameScreen> {
  late List<Map<String, dynamic>> colorData;

  late Map<String, dynamic> displayWord;
  late Map<String, dynamic> displayColor;
  late bool taskIsPickColor;
  
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  bool isGameOver = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    colorData = [
      {'name': l10n.red, 'color': Colors.red},
      {'name': l10n.blue, 'color': Colors.blue},
      {'name': l10n.green, 'color': Colors.green},
      {'name': l10n.yellow, 'color': Colors.yellow},
      {'name': l10n.pink, 'color': Colors.pink},
      {'name': l10n.cyan, 'color': Colors.cyan},
      {'name': l10n.white, 'color': Colors.white},
    ];
    if (timer == null && !isGameOver) {
      _startNewGame();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      _nextRound();
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            isGameOver = true;
            HighScoreService.instance.saveScore("brain_reflex", score);
            timer?.cancel();
          }
        });
      }
    });
  }

  void _nextRound() {
    final random = Random();
    setState(() {
      displayWord = colorData[random.nextInt(colorData.length)];
      displayColor = colorData[random.nextInt(colorData.length)];
      taskIsPickColor = random.nextBool();
    });
  }

  void _checkAnswer(Map<String, dynamic> picked) {
    if (isGameOver) return;

    bool correct = false;
    if (taskIsPickColor) {
      correct = picked['color'] == displayColor['color'];
    } else {
      correct = picked['name'] == displayWord['name'];
    }

    setState(() {
      if (correct) {
        score += 10;
        SoundFontService.instance.playCorrect();
      } else {
        score = max(0, score - 5);
        SoundFontService.instance.playIncorrect();
      }
      _nextRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isGameOver) {
      return _buildGameOver(l10n);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.brainReflexStroop),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.timeLabel(timeLeft),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: timeLeft / 30,
            backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white10,
            color: timeLeft < 10 ? Colors.red : Colors.green,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.scoreLabel(score),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.05) : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    taskIsPickColor ? l10n.pickInkColor : l10n.pickWordMeaning,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  displayWord['name'],
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 72 * (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16) / 16,
                    fontWeight: FontWeight.w900,
                    color: displayColor['color'],
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(2, 2))
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: colorData.map((data) {
                return SizedBox(
                  width: (min(MediaQuery.of(context).size.width, 450.0) - 72) / 3,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _checkAnswer(data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: data['color'],
                      foregroundColor: data['color'] == Colors.white ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      data['name'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver(AppLocalizations l10n) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(l10n.timeUp, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(l10n.yourFinalScore, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '$score',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _startNewGame,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                shape: const StadiumBorder(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.backToMenu),
            ),
          ],
        ),
      ),
    );
  }
}
