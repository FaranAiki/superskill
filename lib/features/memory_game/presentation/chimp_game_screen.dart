import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

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
  bool blindMode = false;
  bool hideOutlines = false;
  
  // Board representation: contains number if tile has a number, else null
  late List<int?> board;
  int nextNumberToTap = 1;
  int? lastTappedIndex;
  
  // Shake animation controller for errors
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  // Success animation controllers for each tile
  late List<AnimationController> _successControllers;
  late List<Animation<double>> _successAnimations;

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
        
    _successControllers = List.generate(200, (index) => AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    ));
    _successAnimations = _successControllers.map((controller) {
      return ChimpSuccessScaleTween().animate(controller);
    }).toList();

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
      
      // Make sure totalNumbers does not exceed available grid cells
      int numCount = min(totalNumbers, totalCells - 1);
      for (int i = 1; i <= numCount; i++) {
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
              int maxNumbers = (gridSize * gridSize) - 5;
              if (totalNumbers > maxNumbers) {
                if (gridSize < 8) {
                  gridSize++;
                } else {
                  totalNumbers = maxNumbers;
                }
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
          HighScoreService.instance.saveScore("chimp_memory", totalNumbers);
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
      lives = 3;
      isGameOver = false;
      _generateLevel();
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = AppLocalizations.of(context)!;
            int maxNumbers = (gridSize * gridSize) - 5;
            
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text(l10n.gameSettings, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Grid Size Selector
                    Text('${l10n.gridSize}: ${gridSize}x${gridSize}', style: Theme.of(context).textTheme.bodyMedium),
                    Slider(
                      value: gridSize.toDouble(),
                      min: 4,
                      max: 9,
                      divisions: 5,
                      onChanged: (value) {
                        setDialogState(() {
                          gridSize = value.toInt();
                          int newMax = (gridSize * gridSize) - 5;
                          if (totalNumbers > newMax) {
                            totalNumbers = newMax;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Starting Numbers Selector
                    Text('${l10n.startingNumbers}: $totalNumbers', style: Theme.of(context).textTheme.bodyMedium),
                    Slider(
                      value: totalNumbers.toDouble(),
                      min: 3,
                      max: maxNumbers.toDouble(),
                      divisions: maxNumbers - 3 > 0 ? maxNumbers - 3 : 1,
                      onChanged: (value) {
                        setDialogState(() => totalNumbers = value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Blind Mode Toggle
                    SwitchListTile(
                      title: Text(l10n.blindMode, style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text(l10n.blindModeDesc, style: Theme.of(context).textTheme.bodySmall),
                      value: blindMode,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setDialogState(() => blindMode = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Hide Outlines Toggle
                    SwitchListTile(
                      title: Text(l10n.hideOutlines, style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text(l10n.hideOutlinesDesc, style: Theme.of(context).textTheme.bodySmall),
                      value: hideOutlines,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (value) {
                        setDialogState(() => hideOutlines = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _restartGame();
                  },
                  child: Text(l10n.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
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
                  child: RepaintBoundary(
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
                            child: ScaleTransition(
                              scale: _successAnimations[idx],
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: hasNumber
                                      ? (isShowingNumbers 
                                          ? primaryColor.withOpacity(0.15) 
                                          : (blindMode ? Colors.transparent : primaryColor.withOpacity(0.8)))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: hasNumber
                                        ? (isShowingNumbers 
                                            ? primaryColor 
                                            : (hideOutlines 
                                                ? Colors.transparent 
                                                : (blindMode ? primaryColor.withOpacity(0.05) : primaryColor)))
                                        : (hideOutlines && !isShowingNumbers ? Colors.transparent : primaryColor.withOpacity(0.05)),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChimpSuccessScaleTween extends Animatable<double> {
  @override
  double transform(double t) {
    return 1.0 + 0.15 * sin(t * pi);
  }
}
