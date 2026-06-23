import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';
import 'package:superskill/core/soundfont_service.dart';

class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({super.key});

  @override
  State<OddOneOutScreen> createState() => _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<OddOneOutScreen> with SingleTickerProviderStateMixin {
  int score = 0;
  int currentLevel = 1;
  double timeLeft = 15.0;
  Timer? gameTimer;
  bool isGameOver = false;
  int highScore = 0;

  late Color baseColor;
  late Color oddColor;
  late int oddIndex;
  late int gridSize;
  late int totalTiles;

  late AnimationController _flashController;
  Color _flashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startNewGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _loadHighScore() {
    setState(() {
      highScore = HighScoreService.instance.getHighScore('odd_one_out');
    });
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      currentLevel = 1;
      timeLeft = 15.0;
      isGameOver = false;
    });
    _generateLevel();
    _startTimer();
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        if (timeLeft > 0.1) {
          timeLeft -= 0.1;
        } else {
          timeLeft = 0.0;
          isGameOver = true;
          timer.cancel();
          _handleGameOver();
        }
      });
    });
  }

  void _generateLevel() {
    final random = Random();
    
    // Grid Size increases with levels:
    // Level 1-2: 3x3
    // Level 3-4: 4x4
    // Level 5-6: 5x5
    // Level 7+: 6x6
    if (currentLevel <= 2) {
      gridSize = 3;
    } else if (currentLevel <= 4) {
      gridSize = 4;
    } else if (currentLevel <= 6) {
      gridSize = 5;
    } else {
      gridSize = 6;
    }
    
    totalTiles = gridSize * gridSize;
    oddIndex = random.nextInt(totalTiles);

    // Pick a random base color
    int r = random.nextInt(200) + 20; // keep it within range to avoid overflow/underflow when offsetting
    int g = random.nextInt(200) + 20;
    int b = random.nextInt(200) + 20;
    baseColor = Color.fromARGB(255, r, g, b);

    // Calculate color difference based on current level
    // Harder as levels increase
    int diff;
    if (currentLevel <= 1) {
      diff = 15;
    } else if (currentLevel <= 3) {
      diff = 12;
    } else if (currentLevel <= 5) {
      diff = 9;
    } else if (currentLevel <= 8) {
      diff = 7;
    } else if (currentLevel <= 12) {
      diff = 5;
    } else {
      diff = 4;
    }

    // Determine direction of difference
    int channel = random.nextInt(3); // 0 = Red, 1 = Green, 2 = Blue
    bool addDiff = random.nextBool();
    if (channel == 0) {
      int newR = addDiff ? (r + diff) : (r - diff);
      newR = newR.clamp(0, 255);
      // If clamp made no difference, reverse the sign
      if (newR == r) newR = !addDiff ? (r + diff) : (r - diff);
      oddColor = Color.fromARGB(255, newR, g, b);
    } else if (channel == 1) {
      int newG = addDiff ? (g + diff) : (g - diff);
      newG = newG.clamp(0, 255);
      if (newG == g) newG = !addDiff ? (g + diff) : (g - diff);
      oddColor = Color.fromARGB(255, r, newG, b);
    } else {
      int newB = addDiff ? (b + diff) : (b - diff);
      newB = newB.clamp(0, 255);
      if (newB == b) newB = !addDiff ? (b + diff) : (b - diff);
      oddColor = Color.fromARGB(255, r, g, newB);
    }
  }

  void _onTileTap(int idx) {
    if (isGameOver) return;

    if (idx == oddIndex) {
      // Correct!
      setState(() {
        score += 10;
        currentLevel++;
        // Add time reward
        timeLeft = min(15.0, timeLeft + 3.0);
        _flashColor = Colors.green.withOpacity(0.2);
      });
      _flashController.forward(from: 0.0).then((_) {
        setState(() => _flashColor = Colors.transparent);
      });
      _generateLevel();
      SoundFontService.instance.playCorrect();
    } else {
      // Wrong tap! Deduct 2 seconds
      setState(() {
        timeLeft = max(0.0, timeLeft - 2.0);
        _flashColor = Colors.red.withOpacity(0.3);
      });
      _flashController.forward(from: 0.0).then((_) {
        setState(() => _flashColor = Colors.transparent);
      });
      SoundFontService.instance.playIncorrect();
    }
  }

  void _handleGameOver() {
    HighScoreService.instance.saveScore('odd_one_out', score).then((isNewHigh) {
      if (isNewHigh) {
        _loadHighScore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = const Color(0xFF38BDF8); // neon blue

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF030712),
      appBar: AppBar(
        title: Text(l10n.oddOneOut),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Stats card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : const Color(0xFF1E293B).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                l10n.levelLabel(currentLevel.toString()),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                               Text(
                                l10n.highScore(highScore),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 32,
                            width: 1.5,
                            color: primaryColor.withOpacity(0.2),
                          ),
                          Column(
                            children: [
                              Text(
                                l10n.scoreLabel(score),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                               Text(
                                l10n.brainTrainingCategory(l10n.brainGames),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Linear Timer Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: timeLeft / 15.0,
                        backgroundColor: isLight ? Colors.black12 : Colors.white10,
                        color: timeLeft < 4 ? Colors.redAccent : primaryColor,
                        minHeight: 8,
                      ),
                    ),
                    
                    const SizedBox(height: 12),

                    Text(
                      l10n.timeLabel(timeLeft.toInt()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: timeLeft < 4 ? Colors.redAccent : primaryColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      l10n.oddOneOutDesc,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Grid Board
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.black.withOpacity(0.02) : const Color(0xFF1E293B).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: totalTiles,
                          itemBuilder: (context, idx) {
                            final isOdd = idx == oddIndex;
                            return GestureDetector(
                              onTap: () => _onTileTap(idx),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isOdd ? oddColor : baseColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isOdd ? oddColor : baseColor).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Game Over Screen inside same layout
                    if (isGameOver) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Game Over!",
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your final score: $score points",
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _startNewGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(l10n.playAgain),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Flash overlay on Tap (Green/Red)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _flashController,
              builder: (context, child) {
                return Container(
                  color: Color.lerp(
                    _flashColor,
                    Colors.transparent,
                    _flashController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
