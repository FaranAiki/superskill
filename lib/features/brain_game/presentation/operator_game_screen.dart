import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class OperatorGameScreen extends StatefulWidget {
  const OperatorGameScreen({super.key});

  @override
  State<OperatorGameScreen> createState() => _OperatorGameScreenState();
}

class _OperatorGameScreenState extends State<OperatorGameScreen> with SingleTickerProviderStateMixin {
  int score = 0;
  int timeLeft = 30;
  Timer? gameTimer;
  bool isGameOver = false;

  // Settings
  int numOperations = 1; // can be 1, 2, or 3

  // Math equation state
  List<int> numbers = [];
  List<String> correctOperators = [];
  List<String> playerOperators = [];
  int currentOperatorIndex = 0;
  int equationResult = 0;
  
  final List<String> operators = ['+', '-', '×', '÷'];
  
  // Slide up/fade transition controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    
    _startNewGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      _nextQuestion();
    });

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            isGameOver = true;
            HighScoreService.instance.saveScore("operator_rush", score);
            gameTimer?.cancel();
          }
        });
      }
    });
  }

  double _evaluate2(double a, String op, double b) {
    if (op == '+') return a + b;
    if (op == '-') return a - b;
    if (op == '×') return a * b;
    if (op == '÷') return b != 0 ? a / b : 0;
    return 0;
  }

  double _evaluateExpression(List<double> nums, List<String> ops) {
    List<double> workingNums = List.from(nums);
    List<String> workingOps = List.from(ops);

    // 1. MDAS: Multiplication and Division
    int i = 0;
    while (i < workingOps.length) {
      if (workingOps[i] == '×' || workingOps[i] == '÷') {
        double res = _evaluate2(workingNums[i], workingOps[i], workingNums[i + 1]);
        workingNums[i] = res;
        workingNums.removeAt(i + 1);
        workingOps.removeAt(i);
      } else {
        i++;
      }
    }

    // 2. MDAS: Addition and Subtraction
    i = 0;
    while (i < workingOps.length) {
      double res = _evaluate2(workingNums[i], workingOps[i], workingNums[i + 1]);
      workingNums[i] = res;
      workingNums.removeAt(i + 1);
      workingOps.removeAt(i);
    }

    return workingNums[0];
  }

  void _nextQuestion() {
    final random = Random();
    int maxRetries = 300;
    
    for (int retry = 0; retry < maxRetries; retry++) {
      List<int> candidateNums = [];
      List<String> candidateOps = [];
      
      // Keep number values small for multiple operations to prevent crazy numbers
      int maxNumVal = numOperations > 1 ? 12 : 30;
      
      for (int i = 0; i <= numOperations; i++) {
        candidateNums.add(random.nextInt(maxNumVal) + 1);
      }
      
      for (int i = 0; i < numOperations; i++) {
        candidateOps.add(operators[random.nextInt(4)]);
      }
      
      // Validate math division logic: divisors must divide cleanly without remainders
      bool isValid = true;
      List<double> tempNums = candidateNums.map((n) => n.toDouble()).toList();
      List<String> tempOps = List.from(candidateOps);
      
      int i = 0;
      while (i < tempOps.length) {
        if (tempOps[i] == '×' || tempOps[i] == '÷') {
          if (tempOps[i] == '÷') {
            if (tempNums[i + 1] == 0 || (tempNums[i] % tempNums[i + 1] != 0)) {
              isValid = false;
              break;
            }
          }
          double res = _evaluate2(tempNums[i], tempOps[i], tempNums[i + 1]);
          tempNums[i] = res;
          tempNums.removeAt(i + 1);
          tempOps.removeAt(i);
        } else {
          i++;
        }
      }
      
      if (!isValid) continue;
      
      i = 0;
      while (i < tempOps.length) {
        double res = _evaluate2(tempNums[i], tempOps[i], tempNums[i + 1]);
        tempNums[i] = res;
        tempNums.removeAt(i + 1);
        tempOps.removeAt(i);
      }
      
      double finalVal = tempNums[0];
      if (finalVal >= -10 && finalVal <= 120) {
        setState(() {
          numbers = candidateNums;
          correctOperators = candidateOps;
          playerOperators = List.filled(numOperations, "?");
          currentOperatorIndex = 0;
          equationResult = finalVal.toInt();
        });
        _fadeController.forward(from: 0.0);
        return;
      }
    }
    
    // Fallback if loop retries fail
    setState(() {
      numbers = [5, 3];
      correctOperators = ['+'];
      playerOperators = ['?'];
      currentOperatorIndex = 0;
      equationResult = 8;
    });
    _fadeController.forward(from: 0.0);
  }

  void _onOperatorTap(String selectedOp) {
    if (isGameOver) return;

    setState(() {
      playerOperators[currentOperatorIndex] = selectedOp;
      currentOperatorIndex++;
    });

    if (currentOperatorIndex == numOperations) {
      // Evaluate expression with player inputs
      double playerResult = _evaluateExpression(
        numbers.map((n) => n.toDouble()).toList(),
        playerOperators,
      );

      if (playerResult.toInt() == equationResult) {
        setState(() {
          score += 10;
        });
      } else {
        setState(() {
          score = max(0, score - 5);
        });
      }

      // Briefly pause or immediately show next question
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _nextQuestion();
          });
        }
      });
    }
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
              title: Text("Operator Rush Settings", style: TextStyle(color: theme.colorScheme.primary)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Number of Operations: $numOperations", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Slider(
                    value: numOperations.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (v) {
                      setDialogState(() => numOperations = v.toInt());
                    },
                  ),
                ],
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_outlined, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    l10n.gameOverOperator(score),
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

    // Build the equation displaying widgets
    List<Widget> equationWidgets = [];
    for (int i = 0; i < numbers.length; i++) {
      equationWidgets.add(
        Text(
          "${numbers[i]}",
          style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

      if (i < numbers.length - 1) {
        bool isCurrent = i == currentOperatorIndex;
        String playerOp = playerOperators[i];

        equationWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCurrent ? primaryColor.withOpacity(0.15) : primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? primaryColor : primaryColor.withOpacity(0.3),
                width: isCurrent ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              playerOp,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        );
      }
    }

    equationWidgets.add(
      Text(
        " = $equationResult",
        style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.operatorGame),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: _showSettingsDialog,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.timeLabel(timeLeft),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: timeLeft < 10 ? Colors.redAccent : Colors.green,
                ),
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
                backgroundColor: isLight ? Colors.black12 : Colors.white10,
                color: timeLeft < 10 ? Colors.red : Colors.green,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.scoreLabel(score),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.operatorGameDesc,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 64),
                      
                      // Equation display
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                              child: child,
                            );
                          },
                          child: RepaintBoundary(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: equationWidgets,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Operator buttons
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: operators.map((op) {
                          return SizedBox(
                            width: 80,
                            height: 80,
                            child: ElevatedButton(
                              onPressed: () => _onOperatorTap(op),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: primaryColor.withOpacity(0.3), width: 1.5),
                                ),
                                backgroundColor: isLight ? Colors.white : const Color(0xFF1E293B).withOpacity(0.6),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                op,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
