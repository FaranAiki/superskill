import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class StroopArithmeticScreen extends StatefulWidget {
  const StroopArithmeticScreen({super.key});

  @override
  State<StroopArithmeticScreen> createState() => _StroopArithmeticScreenState();
}

class _StroopArithmeticScreenState extends State<StroopArithmeticScreen> {
  final Random _random = Random();
  
  // Game rules (randomized per game session to keep it fresh)
  late int redAdd;
  late int greenSub;
  late int blueMul;

  // Round data
  late int num1;
  late int num2;
  late int color1; // 0=Red, 1=Green, 2=Blue
  late int color2; // 0=Red, 1=Green, 2=Blue
  late int opColor; // 0=Red, 1=Green, 2=Blue
  late String opSymbolText; // Symbol displayed visually
  
  late int correctAnswer;
  late List<int> options;

  int score = 0;
  int lives = 3;
  int timeLeft = 20;
  Timer? timer;
  bool isGameOver = false;
  bool hasStarted = false;

  @override
  void initState() {
    super.initState();
    _initGameRules();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _initGameRules() {
    // Generate rules: Red (+1..4), Green (-1..3), Blue (*2..3)
    redAdd = _random.nextInt(4) + 1;
    greenSub = _random.nextInt(3) + 1;
    blueMul = _random.nextBool() ? 2 : 3;
  }

  void _startGame() {
    setState(() {
      score = 0;
      lives = 3;
      timeLeft = 20;
      isGameOver = false;
      hasStarted = true;
      _nextRound();
    });
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && hasStarted && !isGameOver) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            _loseLife();
          }
        });
      }
    });
  }

  void _loseLife() {
    setState(() {
      lives--;
      if (lives <= 0) {
        isGameOver = true;
        HighScoreService.instance.saveScore("stroop_arithmetic", score);
        timer?.cancel();
      } else {
        timeLeft = 20;
        _nextRound();
      }
    });
  }

  void _nextRound() {
    // Generate numbers between 2 and 9
    num1 = _random.nextInt(8) + 2;
    num2 = _random.nextInt(8) + 2;
    
    color1 = _random.nextInt(3);
    color2 = _random.nextInt(3);
    opColor = _random.nextInt(3);
    
    // Pick random operator symbol text to show (Stroop effect!)
    final opSymbols = ['+', '-', '×'];
    opSymbolText = opSymbols[_random.nextInt(opSymbols.length)];

    // Evaluate modified numbers
    int val1 = _modifyNumber(num1, color1);
    int val2 = _modifyNumber(num2, color2);

    // Evaluate operation based on COLOR (Red=+, Green=-, Blue=*)
    if (opColor == 0) {
      correctAnswer = val1 + val2;
    } else if (opColor == 1) {
      correctAnswer = val1 - val2;
    } else {
      correctAnswer = val1 * val2;
    }

    // Generate option list (4 choices)
    Set<int> optionSet = {correctAnswer};
    
    // Generate logical distractors
    // Distractor 1: evaluating literal symbol instead of color
    int literalOp = opSymbols.indexOf(opSymbolText);
    int literalAns = correctAnswer;
    if (literalOp == 0) literalAns = val1 + val2;
    else if (literalOp == 1) literalAns = val1 - val2;
    else literalAns = val1 * val2;
    optionSet.add(literalAns);

    // Distractor 2: unmodified numbers
    int unmodAns = correctAnswer;
    if (opColor == 0) unmodAns = num1 + num2;
    else if (opColor == 1) unmodAns = num1 - num2;
    else unmodAns = num1 * num2;
    optionSet.add(unmodAns);

    // Generic distractors
    while (optionSet.length < 4) {
      int offset = (_random.nextInt(6) + 1) * (_random.nextBool() ? 1 : -1);
      optionSet.add(correctAnswer + offset);
    }

    options = optionSet.toList()..shuffle();
    timeLeft = 20; // Reset timer for this round
  }

  int _modifyNumber(int base, int colorCode) {
    if (colorCode == 0) return base + redAdd;
    if (colorCode == 1) return base - greenSub;
    return base * blueMul;
  }

  Color _getColor(int colorCode) {
    if (colorCode == 0) return const Color(0xFFEF4444); // Red
    if (colorCode == 1) return const Color(0xFF10B981); // Green
    return const Color(0xFF38BDF8); // Blue (Cyan neon)
  }

  void _checkAnswer(int selected) {
    if (isGameOver) return;
    
    if (selected == correctAnswer) {
      setState(() {
        score += 10 + timeLeft; // Faster answers give more points
        _nextRound();
      });
    } else {
      _loseLife();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stroopArithmetic),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: !hasStarted
              ? _buildStartScreen(l10n, theme, primaryColor, isLight)
              : isGameOver
                  ? _buildGameOverScreen(l10n, theme, primaryColor)
                  : _buildGamePlayScreen(l10n, theme, primaryColor, isLight),
        ),
      ),
    );
  }

  Widget _buildStartScreen(AppLocalizations l10n, ThemeData theme, Color primaryColor, bool isLight) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology, size: 80, color: primaryColor),
          const SizedBox(height: 24),
          Text(
            l10n.stroopArithmetic,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.stroopArithmeticDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          
          // Rule demonstration card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isLight ? Colors.black.withOpacity(0.02) : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.activeRules,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRuleRow(l10n.rulePlus(redAdd), const Color(0xFFEF4444), theme),
                const SizedBox(height: 12),
                _buildRuleRow(l10n.ruleMinus(greenSub), const Color(0xFF10B981), theme),
                const SizedBox(height: 12),
                _buildRuleRow(l10n.ruleMultiply(blueMul), const Color(0xFF38BDF8), theme),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.startGame, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGamePlayScreen(AppLocalizations l10n, ThemeData theme, Color primaryColor, bool isLight) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.scoreLabel(score),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(
                  3,
                  (index) => Icon(
                    index < lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Linear timer bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timeLeft / 20.0,
              minHeight: 8,
              backgroundColor: isLight ? Colors.black12 : Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                timeLeft > 5 ? const Color(0xFF38BDF8) : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Main neon calculation container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isLight ? Colors.black.withOpacity(0.02) : const Color(0xFF1E293B).withOpacity(0.4),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Num 1
                      Text(
                        '$num1',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: _getColor(color1),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Operator (Stroop text)
                      Text(
                        opSymbolText,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: _getColor(opColor),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Num 2
                      Text(
                        '$num2',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: _getColor(color2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            l10n.whatIsResult,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // 2x2 grid of options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final val = options[index];
              return ElevatedButton(
                onPressed: () => _checkAnswer(val),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLight ? Colors.white : const Color(0xFF1E293B),
                  foregroundColor: isLight ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '$val',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(AppLocalizations l10n, ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(
            l10n.gameOver,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.finalScorePoints(score),
            style: theme.textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.playAgain, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
