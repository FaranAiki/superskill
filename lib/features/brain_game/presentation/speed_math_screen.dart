import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class SpeedMathScreen extends StatefulWidget {
  const SpeedMathScreen({super.key});

  @override
  State<SpeedMathScreen> createState() => _SpeedMathScreenState();
}

enum SpeedMathState {
  setup,
  countdown,
  flashing,
  input,
  result,
  gameOver
}

class _SpeedMathScreenState extends State<SpeedMathScreen> {
  // Settings
  String speedMode = "normal"; // slow, normal, fast, very_fast
  int maxDigits = 2; // 1-digit, 2-digit, 3-digit numbers
  
  // Game Play State
  SpeedMathState gameState = SpeedMathState.setup;
  int currentLevel = 1;
  int score = 0;
  int lives = 3;
  
  List<String> sequence = [];
  int correctResult = 0;
  
  // Flash animation states
  String displayItem = "";
  int flashIndex = 0;
  int countdownVal = 3;
  Timer? flashTimer;
  
  // Input states
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String? feedbackMessage;
  bool isAnswerCorrect = false;

  int _getSpeedMs() {
    switch (speedMode) {
      case 'slow':
        return 800;
      case 'fast':
        return 300;
      case 'very_fast':
        return 150;
      case 'normal':
      default:
        return 500;
    }
  }

  void _generateLevelSequence() {
    final random = Random();
    sequence.clear();
    
    // Sequence length starts at 3 and increases with level: 3, 5, 7, 9...
    // Let's make it sequence length = 3 + (currentLevel - 1)
    int length = 3 + (currentLevel - 1);
    
    // Scale digits with level: start with maxDigits and add 1 digit every 2 levels
    int levelDigits = maxDigits + (currentLevel - 1) ~/ 2;
    if (levelDigits > 5) levelDigits = 5; // Cap at 5 digits
    
    int minVal = pow(10, levelDigits - 1).toInt();
    int maxVal = pow(10, levelDigits).toInt() - 1;
    
    // Generate first number
    int runningSum = random.nextInt(maxVal - minVal + 1) + minVal;
    sequence.add(runningSum.toString());
    
    for (int i = 1; i < length; i++) {
      // Add operator
      String op = random.nextBool() ? "+" : "-";
      sequence.add(op);
      
      // Add number
      int nextNum = random.nextInt(maxVal - minVal + 1) + minVal;
      // Make sure sum doesn't go below 0 to keep it clean, or allow negative
      if (op == "-") {
        while (runningSum - nextNum < 0) {
          nextNum = random.nextInt(maxVal - minVal + 1) + minVal;
        }
        runningSum -= nextNum;
      } else {
        runningSum += nextNum;
      }
      sequence.add(nextNum.toString());
    }
    
    correctResult = runningSum;
  }

  void _startLevel() {
    _generateLevelSequence();
    _inputController.clear();
    feedbackMessage = null;
    isAnswerCorrect = false;
    
    setState(() {
      gameState = SpeedMathState.countdown;
      countdownVal = 3;
    });
    
    // Start countdown
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (countdownVal > 1) {
          countdownVal--;
        } else {
          timer.cancel();
          _startFlashing();
        }
      });
    });
  }

  void _startFlashing() {
    setState(() {
      gameState = SpeedMathState.flashing;
      flashIndex = 0;
      displayItem = "";
    });
    
    _flashNext();
  }

  void _flashNext() async {
    if (!mounted) return;
    if (flashIndex >= sequence.length) {
      // Done flashing, go to input state
      setState(() {
        gameState = SpeedMathState.input;
        displayItem = "?";
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _inputFocusNode.requestFocus();
        }
      });
      return;
    }
    
    // 1. Show the item
    setState(() {
      displayItem = sequence[flashIndex];
    });
    
    // Wait for the duration
    await Future.delayed(Duration(milliseconds: _getSpeedMs()));
    if (!mounted) return;
    
    // 2. Clear item for blank buffer (100ms) to make transition distinct
    setState(() {
      displayItem = "";
    });
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    // 3. Increment index and flash next
    flashIndex++;
    _flashNext();
  }

  void _submitAnswer() {
    int? userAns = int.tryParse(_inputController.text);
    if (userAns == null) {
      setState(() {
        feedbackMessage = "Please enter a valid number!";
      });
      return;
    }
    
    bool correct = userAns == correctResult;
    setState(() {
      isAnswerCorrect = correct;
      gameState = SpeedMathState.result;
      if (correct) {
        score += 10 * currentLevel;
        feedbackMessage = "Correct!";
      } else {
        lives--;
        feedbackMessage = "Wrong! Correct: $correctResult";
      }
    });
  }

  void _nextLevel() {
    setState(() {
      if (isAnswerCorrect) {
        currentLevel++;
      }
      if (lives <= 0) {
        gameState = SpeedMathState.gameOver;
        HighScoreService.instance.saveScore("speed_math", score);
      } else {
        _startLevel();
      }
    });
  }

  void _onNumpadTap(String key) {
    if (gameState != SpeedMathState.input) return;
    setState(() {
      if (key == "⌫") {
        if (_inputController.text.isNotEmpty) {
          _inputController.text = _inputController.text.substring(0, _inputController.text.length - 1);
        }
      } else if (key == "-") {
        if (_inputController.text.startsWith("-")) {
          _inputController.text = _inputController.text.substring(1);
        } else {
          _inputController.text = "-" + _inputController.text;
        }
      } else {
        _inputController.text += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    if (gameState == SpeedMathState.gameOver) {
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
                    "Game Over!\nYou reached Level $currentLevel.\nFinal Score: $score",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        lives = 3;
                        score = 0;
                        currentLevel = 1;
                        gameState = SpeedMathState.setup;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Play Again"),
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
        title: const Text("Speed Math"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              children: [
                // Setup / Menu Screen
                if (gameState == SpeedMathState.setup) ...[
                  const Spacer(),
                  Icon(Icons.flash_on, size: 80, color: primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    "Mental Flash Arithmetic",
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Numbers and operators will flash rapidly. Calculate the sum!",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Digits selector
                  Text("Number Digits: $maxDigits", style: theme.textTheme.titleMedium),
                  Slider(
                    value: maxDigits.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() => maxDigits = v.toInt());
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Speed Mode selector
                  Text("Flash Speed", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSpeedChip("slow", "Slow (0.8s)"),
                      _buildSpeedChip("normal", "Normal (0.5s)"),
                      _buildSpeedChip("fast", "Fast (0.3s)"),
                      _buildSpeedChip("very_fast", "Extreme (0.15s)"),
                    ],
                  ),
                  
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _startLevel,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Start Game", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Countdown Screen
                if (gameState == SpeedMathState.countdown) ...[
                  const Spacer(),
                  Text(
                    "Get Ready!",
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "$countdownVal",
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      fontSize: 100,
                    ),
                  ),
                  const Spacer(),
                ],
                
                // Flashing Screen
                if (gameState == SpeedMathState.flashing) ...[
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 50),
                    child: Text(
                      displayItem,
                      key: ValueKey<String>(displayItem),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 90,
                        color: displayItem == "+" || displayItem == "-" ? Colors.orangeAccent : primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
                
                // Input and Result states
                if (gameState == SpeedMathState.input || gameState == SpeedMathState.result) ...[
                  // Header stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Level $currentLevel", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                      Text("Lives: $lives", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      Text("Score: $score", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Question / Answer block
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Enter the Final Result", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          // Input box (with physical keyboard integration)
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: isLight ? Colors.black.withOpacity(0.02) : const Color(0xFF1E293B).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                            ),
                            child: TextField(
                              controller: _inputController,
                              focusNode: _inputFocusNode,
                              keyboardType: const TextInputType.numberWithOptions(signed: true),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) {
                                if (gameState == SpeedMathState.input) {
                                  _submitAnswer();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (feedbackMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isAnswerCorrect ? Colors.green.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isAnswerCorrect ? Colors.green : Colors.redAccent),
                              ),
                              child: Text(
                                feedbackMessage!,
                                style: TextStyle(
                                  color: isAnswerCorrect ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Custom numpad
                          if (gameState == SpeedMathState.input) ...[
                            _buildNumpad(),
                          ] else ...[
                            ElevatedButton(
                              onPressed: _nextLevel,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(isAnswerCorrect ? "Next Level →" : "Continue", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedChip(String speed, String label) {
    bool isSelected = speedMode == speed;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => setState(() => speedMode = speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label.split(" ").first, // Show just the name (Slow, Normal, etc.)
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? primaryColor : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    List<List<String>> keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["-", "0", "⌫"]
    ];

    return Column(
      children: [
        ...keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: SizedBox(
                  width: 70,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _onNumpadTap(key),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                      ),
                      backgroundColor: Theme.of(context).brightness == Brightness.light 
                          ? Colors.white 
                          : const Color(0xFF1E293B).withOpacity(0.5),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: key == "⌫" ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
        const SizedBox(height: 12),
        SizedBox(
          width: 232,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
