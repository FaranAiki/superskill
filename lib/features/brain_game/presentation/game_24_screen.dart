import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class Game24Screen extends StatefulWidget {
  const Game24Screen({super.key});

  @override
  State<Game24Screen> createState() => _Game24ScreenState();
}

class _Game24ScreenState extends State<Game24Screen> {
  // Settings
  int targetValue = 24;
  int cardsCount = 4;
  bool isTimeAttack = false;
  
  // Game state
  List<int> cards = [];
  bool hasSolution = false;
  String? foundSolutionStr;
  
  int score = 0;
  int puzzlesSolved = 0;
  
  // Answering states
  bool hasAnswered = false;
  bool isCorrectGuess = false;
  bool userGuessedYes = false;
  
  // Time attack fields
  int timeLeft = 60;
  Timer? gameTimer;
  bool isGameOver = false;

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
      puzzlesSolved = 0;
      isGameOver = false;
      timeLeft = 60;
      _generateNewPuzzle();
    });

    if (isTimeAttack) {
      _startTimer();
    } else {
      gameTimer?.cancel();
    }
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          isGameOver = true;
          HighScoreService.instance.saveScore("game_24", score);
          gameTimer?.cancel();
        }
      });
    });
  }

  // Generate puzzle: 50% chance solvable, 50% unsolvable
  void _generateNewPuzzle() {
    final random = Random();
    bool shouldBeSolvable = random.nextBool();
    int retries = 0;
    
    while (retries < 1500) {
      List<int> candidateCards = [];
      for (int i = 0; i < cardsCount; i++) {
        // Typical playing card values 1 to 13
        candidateCards.add(random.nextInt(13) + 1);
      }
      
      List<double> nums = candidateCards.map((c) => c.toDouble()).toList();
      List<String> exprs = candidateCards.map((c) => c.toString()).toList();
      String? solution = _solve(nums, exprs, targetValue.toDouble());
      bool solvable = solution != null;
      
      if (solvable == shouldBeSolvable) {
        setState(() {
          cards = candidateCards;
          hasSolution = solvable;
          foundSolutionStr = solution;
          hasAnswered = false;
        });
        return;
      }
      retries++;
    }
    
    // Fallback if loop retries limit hit
    setState(() {
      cards = shouldBeSolvable ? [3, 3, 8, 8] : [1, 1, 1, 1];
      hasSolution = shouldBeSolvable;
      foundSolutionStr = shouldBeSolvable ? "((8 - (8 ÷ 8)) × 3)" : null;
      hasAnswered = false;
    });
  }

  // DFS solver that returns the formatted solution string if found
  String? _solve(List<double> numbers, List<String> expressions, double target) {
    if (numbers.length == 1) {
      if ((numbers[0] - target).abs() < 1e-5) {
        return expressions[0];
      }
      return null;
    }
    
    for (int i = 0; i < numbers.length; i++) {
      for (int j = 0; j < numbers.length; j++) {
        if (i == j) continue;
        
        List<double> nextNums = [];
        List<String> nextExprs = [];
        for (int k = 0; k < numbers.length; k++) {
          if (k != i && k != j) {
            nextNums.add(numbers[k]);
            nextExprs.add(expressions[k]);
          }
        }
        
        double a = numbers[i];
        double b = numbers[j];
        String ea = expressions[i];
        String eb = expressions[j];
        
        // Try addition
        nextNums.add(a + b);
        nextExprs.add("($ea + $eb)");
        String? sol = _solve(nextNums, nextExprs, target);
        if (sol != null) return sol;
        nextNums.removeLast();
        nextExprs.removeLast();
        
        // Try subtraction
        nextNums.add(a - b);
        nextExprs.add("($ea - $eb)");
        sol = _solve(nextNums, nextExprs, target);
        if (sol != null) return sol;
        nextNums.removeLast();
        nextExprs.removeLast();
        
        // Try multiplication
        nextNums.add(a * b);
        nextExprs.add("($ea × $eb)");
        sol = _solve(nextNums, nextExprs, target);
        if (sol != null) return sol;
        nextNums.removeLast();
        nextExprs.removeLast();
        
        // Try division
        if (b != 0) {
          nextNums.add(a / b);
          nextExprs.add("($ea ÷ $eb)");
          sol = _solve(nextNums, nextExprs, target);
          if (sol != null) return sol;
          nextNums.removeLast();
          nextExprs.removeLast();
        }
      }
    }
    return null;
  }

  void _onAnswer(bool guessedYes) {
    if (isGameOver || hasAnswered) return;
    
    bool correct = guessedYes == hasSolution;
    setState(() {
      hasAnswered = true;
      userGuessedYes = guessedYes;
      isCorrectGuess = correct;
      if (correct) {
        score += 10;
        puzzlesSolved++;
      } else {
        score = max(0, score - 5);
      }
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text("Game 24 Settings", style: TextStyle(color: theme.colorScheme.primary)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Target value slider
                    Text("Target Value: $targetValue", style: theme.textTheme.bodyMedium),
                    Slider(
                      value: targetValue.toDouble(),
                      min: 10,
                      max: 99,
                      divisions: 89,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) {
                        setDialogState(() => targetValue = v.toInt());
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Cards count slider
                    Text("Cards Count: $cardsCount", style: theme.textTheme.bodyMedium),
                    Slider(
                      value: cardsCount.toDouble(),
                      min: 3,
                      max: 5,
                      divisions: 2,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) {
                        setDialogState(() => cardsCount = v.toInt());
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Time attack mode toggle
                    SwitchListTile(
                      title: Text("Time Attack (60s)", style: theme.textTheme.bodyMedium),
                      value: isTimeAttack,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) {
                        setDialogState(() => isTimeAttack = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewGame();
                  },
                  child: Text("Ok", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_very_dissatisfied, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    "Game Over!\nYou solved $puzzlesSolved puzzles.\nFinal Score: $score",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _startNewGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
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
        title: const Text("Game 24"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Info Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTimeAttack ? "Time: $timeLeft s" : "Casual Play",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isTimeAttack && timeLeft < 15 ? Colors.redAccent : primaryColor,
                      ),
                    ),
                    Text(
                      "Score: $score",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Prompt text
                Text(
                  l10n.game24CanBeMade(targetValue),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Cards display
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: List.generate(cards.length, (idx) {
                    return Container(
                      width: 75,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLight 
                              ? [Colors.white, Colors.grey.shade100]
                              : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cards[idx].toString(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    );
                  }),
                ),
                
                const Spacer(),
                
                // Choice Buttons or Explanation
                if (!hasAnswered) ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () => _onAnswer(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.game24Yes,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () => _onAnswer(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.game24No,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Feedback block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isCorrectGuess 
                          ? Colors.green.withOpacity(0.12) 
                          : Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isCorrectGuess ? Colors.green : Colors.redAccent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isCorrectGuess ? Icons.check_circle_outline : Icons.error_outline,
                          color: isCorrectGuess ? Colors.green : Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isCorrectGuess
                              ? (hasSolution 
                                  ? l10n.game24CorrectSolvable(foundSolutionStr!) 
                                  : l10n.game24CorrectUnsolvable)
                              : (hasSolution 
                                  ? l10n.game24WrongSolvable(foundSolutionStr!) 
                                  : l10n.game24WrongUnsolvable),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Next puzzle button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _generateNewPuzzle,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next Puzzle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
