import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';
import 'package:cognitivegarden/core/soundfont_service.dart';

class TargetSumScreen extends StatefulWidget {
  const TargetSumScreen({super.key});

  @override
  State<TargetSumScreen> createState() => _TargetSumScreenState();
}

class _TargetSumScreenState extends State<TargetSumScreen> {
  int score = 0;
  int timeLeft = 60;
  Timer? gameTimer;
  bool isGameOver = false;

  int targetSum = 0;
  List<int> gridNumbers = [];
  Set<int> selectedIndices = {};

  final int gridCount = 16;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      isGameOver = false;
      _generateBoard();
    });
    
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          isGameOver = true;
          gameTimer?.cancel();
          HighScoreService.instance.saveScore("target_sum", score);
        }
      });
    });
  }

  void _generateBoard() {
    selectedIndices.clear();
    gridNumbers.clear();

    // Determine how many numbers should make up the target sum
    int numComponents = _random.nextInt(3) + 2; // 2 to 4 numbers

    List<int> solution = [];
    int sum = 0;
    for (int i = 0; i < numComponents; i++) {
      int val = _random.nextInt(15) + 1;
      solution.add(val);
      sum += val;
    }
    targetSum = sum;

    gridNumbers.addAll(solution);

    // Fill the rest of the grid
    while (gridNumbers.length < gridCount) {
      gridNumbers.add(_random.nextInt(15) + 1);
    }

    gridNumbers.shuffle(_random);
  }

  void _onTileTap(int index) {
    if (isGameOver) return;
    
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
        SoundFontService.instance.playClick();
      } else {
        selectedIndices.add(index);
        SoundFontService.instance.playClick();
      }

      _checkSum();
    });
  }

  void _checkSum() {
    int currentSum = 0;
    for (int index in selectedIndices) {
      currentSum += gridNumbers[index];
    }

    if (currentSum == targetSum) {
      SoundFontService.instance.playCorrect();
      score += 10;
      _generateBoard();
    } else if (currentSum > targetSum) {
      SoundFontService.instance.playIncorrect();
      // Reset selection if it exceeds
      selectedIndices.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    if (isGameOver) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_off_outlined, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    "Time's Up!",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Score: $score",
                    style: theme.textTheme.headlineSmall,
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.backToMenu),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    int currentSum = 0;
    for (int index in selectedIndices) {
      currentSum += gridNumbers[index];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.targetSum),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.timeLabel(timeLeft),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: timeLeft < 10 ? Colors.redAccent : Colors.orangeAccent,
                ),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.scoreLabel(score), style: theme.textTheme.titleLarge),
                    Text(
                      "Target: $targetSum",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: targetSum > 0 ? (currentSum / targetSum).clamp(0.0, 1.0) : 0,
                  backgroundColor: isLight ? Colors.black12 : Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    currentSum > targetSum ? Colors.redAccent : const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Current Sum: $currentSum",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: currentSum > targetSum ? Colors.redAccent : Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: gridCount,
                    itemBuilder: (context, index) {
                      final isSelected = selectedIndices.contains(index);
                      
                      return Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () => _onTileTap(index),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? primaryColor 
                                  : (isLight ? Colors.white : const Color(0xFF1E293B)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Colors.white : primaryColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.6),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                "${gridNumbers[index]}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : (isLight ? Colors.black87 : Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
