import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';

class ChimpGameScreen extends StatefulWidget {
  const ChimpGameScreen({super.key});

  @override
  State<ChimpGameScreen> createState() => _ChimpGameScreenState();
}

class _ChimpGameScreenState extends State<ChimpGameScreen> with TickerProviderStateMixin {
  int gridSize = 5;
  int totalNumbers = 4;
  int lives = 3;
  bool isShowingNumbers = true;
  bool isGameOver = false;
  
  // Board representation: contains number if tile has a number, else null
  late List<int?> board;
  int nextNumberToTap = 1;
  int? lastTappedIndex;
  
  // Shake animation controller for errors
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  // Success animation controllers for each tile
  late List<AnimationController> _successControllers;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
        
    _successControllers = List.generate(40, (index) => AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    ));

    _generateLevel();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (var controller in _successControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generateLevel() {
    setState(() {
      isShowingNumbers = true;
      nextNumberToTap = 1;
      lastTappedIndex = null;
      
      // Calculate cells
      int totalCells = gridSize * gridSize;
      board = List.generate(totalCells, (_) => null);
      
      // Randomly assign numbers 1 to totalNumbers to cells
      final random = Random();
      final List<int> availableIndices = List.generate(totalCells, (i) => i);
      
      for (int i = 1; i <= totalNumbers; i++) {
        int index = availableIndices.removeAt(random.nextInt(availableIndices.length));
        board[index] = i;
      }
    });
  }

  void _onTileTap(int index) {
    if (isGameOver) return;
    final value = board[index];
    if (value == null) return;

    if (value == nextNumberToTap) {
      // Correct Tap!
      setState(() {
        if (nextNumberToTap == 1) {
          isShowingNumbers = false;
        }
        _successControllers[index].forward(from: 0.0);
        nextNumberToTap++;
        lastTappedIndex = index;
        board[index] = null; // Clear it so it disappears
      });

      // Check win condition
      if (nextNumberToTap > totalNumbers) {
        // Won the round!
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              totalNumbers++;
              if (totalNumbers > 12 && gridSize == 5) {
                gridSize = 6;
              }
              _generateLevel();
            });
          }
        });
      }
    } else {
      // Incorrect Tap!
      _shakeController.forward(from: 0.0);
      setState(() {
        lives--;
        if (lives <= 0) {
          isGameOver = true;
        } else {
          // Restart level
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) _generateLevel();
          });
        }
      });
    }
  }

  void _restartGame() {
    setState(() {
      gridSize = 5;
      totalNumbers = 4;
      lives = 3;
      isGameOver = false;
      _generateLevel();
    });
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
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_very_dissatisfied, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    l10n.gameOverChimp(totalNumbers),
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _restartGame,
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
        title: Text(l10n.chimpGame),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Info Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.livesLabel(lives), style: theme.textTheme.titleMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    Text(l10n.numbersCount(totalNumbers), style: theme.textTheme.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  nextNumberToTap == 1 ? l10n.chimpTestStart : l10n.chimpTestInstructions,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: nextNumberToTap == 1 ? Colors.orangeAccent : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Shake Animation Wrapper
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    double offset = sin(_shakeController.value * pi * 8) * _shakeAnimation.value;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black.withOpacity(0.02) : const Color(0xFF1E293B).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, idx) {
                        final number = board[idx];
                        final hasNumber = number != null;
                        
                        return GestureDetector(
                          onTap: hasNumber ? () => _onTileTap(idx) : null,
                          child: AnimatedBuilder(
                            animation: _successControllers[idx],
                            builder: (context, child) {
                              double scale = 1.0 + 0.15 * sin(_successControllers[idx].value * pi);
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: hasNumber
                                    ? (isShowingNumbers 
                                        ? primaryColor.withOpacity(0.15) 
                                        : primaryColor.withOpacity(0.8))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: hasNumber
                                      ? primaryColor
                                      : primaryColor.withOpacity(0.05),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                hasNumber && isShowingNumbers ? number.toString() : "",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
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
