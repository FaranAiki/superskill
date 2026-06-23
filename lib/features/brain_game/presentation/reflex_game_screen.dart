import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';
import 'package:superskill/core/soundfont_service.dart';

class ReflexGameScreen extends StatefulWidget {
  const ReflexGameScreen({super.key});

  @override
  State<ReflexGameScreen> createState() => _ReflexGameScreenState();
}

class FloatingScore {
  final int id;
  final double x;
  final double y;
  FloatingScore(this.id, this.x, this.y);
}

class _ReflexGameScreenState extends State<ReflexGameScreen> with TickerProviderStateMixin {
  int score = 0;
  int timeLeft = 20;
  Timer? gameTimer;
  bool isGameOver = false;
  
  int activeTileIndex = -1;
  final int gridCount = 16; // 4x4
  
  final List<FloatingScore> _floaters = [];
  int _floaterIdCounter = 0;
  
  late List<AnimationController> _tapControllers;
  late List<Animation<double>> _tapAnimations;

  @override
  void initState() {
    super.initState();
    _tapControllers = List.generate(gridCount, (idx) => AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    ));
    _tapAnimations = _tapControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.9).animate(controller);
    }).toList();
    _startNewGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    for (var controller in _tapControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 20;
      isGameOver = false;
      _floaters.clear();
      _nextTile();
    });
    
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            isGameOver = true;
            HighScoreService.instance.saveScore("reflex_tap", score);
            gameTimer?.cancel();
          }
        });
      }
    });
  }

  void _nextTile() {
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(gridCount);
    } while (newIndex == activeTileIndex);
    
    setState(() {
      activeTileIndex = newIndex;
    });
  }

  void _onTileTap(int index, BuildContext context, TapUpDetails details) {
    if (isGameOver) return;
    
    _tapControllers[index].forward(from: 0.0);
    
    if (index == activeTileIndex) {
      // Correct!
      setState(() {
        score += 10;
        
        // Add floater at tap coordinates
        final localPos = details.localPosition;
        _floaters.add(FloatingScore(_floaterIdCounter++, localPos.dx, localPos.dy));
        
        _nextTile();
      });
      SoundFontService.instance.playCorrect();
    } else {
      // Incorrect!
      setState(() {
        score = max(0, score - 5);
      });
      SoundFontService.instance.playIncorrect();
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_off_outlined, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    l10n.gameOverReflex(score),
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reflexGame),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.timeLabel(timeLeft),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: timeLeft < 5 ? Colors.redAccent : Colors.orangeAccent,
                ),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  l10n.scoreLabel(score),
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.reflexGameDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 4x4 Grid of Tiles
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black.withOpacity(0.02) : const Color(0xFF1E293B).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
                    ),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: gridCount,
                      itemBuilder: (context, idx) {
                        final isActive = idx == activeTileIndex;
                        
                        return GestureDetector(
                          onTapUp: (details) => _onTileTap(idx, context, details),
                          child: ScaleTransition(
                            scale: _tapAnimations[idx],
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isActive ? Colors.white : primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(0.8),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        : [],
                                  ),
                                ),
                                // Floating text stack overlays
                                ..._floaters.where((f) => isActive).map((floater) {
                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey(floater.id),
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 600),
                                    onEnd: () {
                                      setState(() {
                                        _floaters.removeWhere((f) => f.id == floater.id);
                                      });
                                    },
                                    child: Text(
                                      "+10",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    builder: (context, val, child) {
                                      return Positioned(
                                        left: 0,
                                        right: 0,
                                        top: -30.0 - (val * 40.0), // float up
                                        child: Opacity(
                                          opacity: 1.0 - val, // fade out
                                          child: Center(
                                            child: child,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
