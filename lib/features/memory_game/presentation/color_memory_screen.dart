import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class ColorMemoryScreen extends StatefulWidget {
  const ColorMemoryScreen({super.key});

  @override
  State<ColorMemoryScreen> createState() => _ColorMemoryScreenState();
}

enum GameState { memorizing, recalling, gameOver, levelComplete }

class _ColorMemoryScreenState extends State<ColorMemoryScreen> with TickerProviderStateMixin {
  int currentLevel = 1;
  int score = 0;
  int lives = 3;
  int highScore = 0;
  int optionCountSetting = 5; // Configurable: 3 to 9 options

  GameState gameState = GameState.memorizing;
  late List<Color> targetColors;
  late List<Color> optionColors; // Options for the currently active slot
  
  int activeRecallSlot = 0;
  List<bool> revealedSlots = [];

  // Countdown timer for Memorization phase
  double memorizeTimeLeft = 4.0;
  Timer? memorizeTimer;

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
    memorizeTimer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _loadHighScore() {
    setState(() {
      highScore = HighScoreService.instance.getHighScore('color_memory');
    });
  }

  void _startNewGame() {
    setState(() {
      currentLevel = 1;
      score = 0;
      lives = 3;
    });
    _generateLevel();
  }

  void _generateLevel() {
    final random = Random();
    
    // Number of target colors increases with level
    // Level 1-2: 3 colors
    // Level 3-4: 4 colors
    // Level 5+: 5 colors
    final int colorCount = min(5, 3 + (currentLevel - 1) ~/ 2);

    targetColors = [];
    for (int i = 0; i < colorCount; i++) {
      // Pick random distinct base colors
      targetColors.add(Color.fromARGB(
        255,
        random.nextInt(200) + 28,
        random.nextInt(200) + 28,
        random.nextInt(200) + 28,
      ));
    }

    revealedSlots = List.generate(colorCount, (_) => false);
    activeRecallSlot = 0;
    
    setState(() {
      gameState = GameState.memorizing;
      memorizeTimeLeft = 4.0;
    });

    _startMemorizeTimer();
  }

  void _startMemorizeTimer() {
    memorizeTimer?.cancel();
    memorizeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (gameState != GameState.memorizing) {
        timer.cancel();
        return;
      }
      setState(() {
        if (memorizeTimeLeft > 0.1) {
          memorizeTimeLeft -= 0.1;
        } else {
          memorizeTimeLeft = 0.0;
          timer.cancel();
          _switchToRecall();
        }
      });
    });
  }

  void _switchToRecall() {
    setState(() {
      gameState = GameState.recalling;
      _generateOptionsForSlot();
    });
  }

  void _generateOptionsForSlot() {
    final random = Random();
    final Color correctColor = targetColors[activeRecallSlot];

    // Generate similar options. Shifting offset decreases as level increases (harder!)
    // Lower level = larger offset (e.g. 15), Higher level = smaller offset (e.g. 6)
    final int shift = (16 - currentLevel).clamp(5, 18);

    final Set<Color> options = {correctColor};

    while (options.length < optionCountSetting) {
      // Create a slightly altered color
      int r = correctColor.red;
      int g = correctColor.green;
      int b = correctColor.blue;

      // Select random channel to shift
      int channel = random.nextInt(3);
      int offset = (random.nextBool() ? shift : -shift);

      if (channel == 0) {
        r = (r + offset).clamp(0, 255);
      } else if (channel == 1) {
        g = (g + offset).clamp(0, 255);
      } else {
        b = (b + offset).clamp(0, 255);
      }

      options.add(Color.fromARGB(255, r, g, b));
    }

    optionColors = options.toList()..shuffle(random);
  }

  void _onOptionSelected(Color selectedColor) {
    if (gameState != GameState.recalling) return;

    final Color correctColor = targetColors[activeRecallSlot];
    if (selectedColor == correctColor) {
      // Correct!
      setState(() {
        revealedSlots[activeRecallSlot] = true;
        score += 10;
        _flashColor = Colors.green.withOpacity(0.2);
      });
      
      _flashController.forward(from: 0.0).then((_) {
        setState(() => _flashColor = Colors.transparent);
      });

      if (activeRecallSlot < targetColors.length - 1) {
        // Go to next slot
        setState(() {
          activeRecallSlot++;
          _generateOptionsForSlot();
        });
      } else {
        // Level complete!
        setState(() {
          gameState = GameState.levelComplete;
        });
      }
    } else {
      // Incorrect! Deduct a life
      setState(() {
        lives--;
        _flashColor = Colors.red.withOpacity(0.3);
      });
      
      _flashController.forward(from: 0.0).then((_) {
        setState(() => _flashColor = Colors.transparent);
      });

      if (lives <= 0) {
        setState(() {
          gameState = GameState.gameOver;
        });
        _handleGameOver();
      }
    }
  }

  void _handleGameOver() {
    HighScoreService.instance.saveScore('color_memory', score).then((isNewHigh) {
      if (isNewHigh) {
        _loadHighScore();
      }
    });
  }

  void _nextLevel() {
    setState(() {
      currentLevel++;
      _generateLevel();
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: theme.brightness == Brightness.light ? Colors.white : const Color(0xFF1E293B),
              title: Text(l10n.numberOfOptions, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.optionsConfig(optionCountSetting), style: theme.textTheme.titleMedium),
                  Slider(
                    value: optionCountSetting.toDouble(),
                    min: 3,
                    max: 9,
                    divisions: 6,
                    activeColor: const Color(0xFF38BDF8),
                    onChanged: (val) {
                      setModalState(() {
                        optionCountSetting = val.toInt();
                      });
                      setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Regenerate level if we changed options in the middle of recall
                    if (gameState == GameState.recalling) {
                      _generateOptionsForSlot();
                    }
                  },
                  child: const Text("OK", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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
        title: Text(l10n.colorMemory),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF38BDF8)),
            onPressed: _showSettingsDialog,
          ),
        ],
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
                              Row(
                                children: List.generate(3, (idx) {
                                  return Icon(
                                    idx < lives ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.pinkAccent,
                                    size: 20,
                                  );
                                }),
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
                                l10n.levelLabel(currentLevel.toString()),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.scoreLabel(score),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Countdown timer for Memorize phase
                    if (gameState == GameState.memorizing) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: memorizeTimeLeft / 4.0,
                          backgroundColor: isLight ? Colors.black12 : Colors.white10,
                          color: primaryColor,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.memorizeColors,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ] else if (gameState == GameState.recalling) ...[
                      Text(
                        l10n.selectColorForSlot(activeRecallSlot + 1),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 8),

                    Text(
                      l10n.colorMemoryDesc,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Target Slots Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(targetColors.length, (idx) {
                        final color = targetColors[idx];
                        final isRevealed = revealedSlots[idx] || gameState == GameState.memorizing;
                        final isActive = gameState == GameState.recalling && activeRecallSlot == idx;

                        return Container(
                          width: 54,
                          height: 54,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isRevealed ? color : Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive 
                                  ? primaryColor 
                                  : (isRevealed ? Colors.white.withOpacity(0.3) : Colors.transparent),
                              width: isActive ? 3 : 1.5,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.8),
                                      blurRadius: 16,
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: !isRevealed
                              ? Text(
                                  "${idx + 1}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white60,
                                  ),
                                )
                              : (gameState == GameState.recalling && revealedSlots[idx])
                                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                                  : null,
                        );
                      }),
                    ),

                    const SizedBox(height: 48),

                    // Quick-skip Button during memorizing
                    if (gameState == GameState.memorizing) ...[
                      ElevatedButton.icon(
                        onPressed: _switchToRecall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text("Ready! Recall Now"),
                      ),
                    ],

                    // Option Grid (Only during Recalling)
                    if (gameState == GameState.recalling) ...[
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: optionColors.map((color) {
                          return GestureDetector(
                            onTap: () => _onOptionSelected(color),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Level Complete Screen
                    if (gameState == GameState.levelComplete) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 2),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF10B981),
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.levelComplete,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _nextLevel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text("Next Level"),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Game Over Screen
                    if (gameState == GameState.gameOver) ...[
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
