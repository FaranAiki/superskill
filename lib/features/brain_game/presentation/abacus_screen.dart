import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';
import 'package:cognitivegarden/core/soundfont_service.dart';

enum AbacusGameMode {
  abacusToNumber,
  numberToAbacus,
}

class AbacusScreen extends StatefulWidget {
  const AbacusScreen({super.key});

  @override
  State<AbacusScreen> createState() => _AbacusScreenState();
}

class _AbacusScreenState extends State<AbacusScreen> {
  int score = 0;
  int timeLeft = 60;
  Timer? gameTimer;
  bool isGameOver = false;

  int columnCount = 5;
  AbacusGameMode mode = AbacusGameMode.abacusToNumber;

  int targetNumber = 0;
  List<int> currentAbacus = [];
  String userInput = "";

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
      _generateQuestion();
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
          HighScoreService.instance.saveScore("abacus_game", score);
        }
      });
    });
  }

  void _generateQuestion() {
    userInput = "";
    int maxVal = pow(10, columnCount).toInt() - 1;
    targetNumber = _random.nextInt(maxVal + 1);

    if (mode == AbacusGameMode.abacusToNumber) {
      // Set the abacus to the target number
      currentAbacus = _numberToColumns(targetNumber, columnCount);
    } else {
      // Set the abacus to 0, user has to match targetNumber
      currentAbacus = List.filled(columnCount, 0);
    }
  }

  List<int> _numberToColumns(int number, int cols) {
    List<int> result = List.filled(cols, 0);
    int temp = number;
    for (int i = cols - 1; i >= 0; i--) {
      result[i] = temp % 10;
      temp ~/= 10;
    }
    return result;
  }

  int _columnsToNumber(List<int> cols) {
    int num = 0;
    for (int val in cols) {
      num = num * 10 + val;
    }
    return num;
  }

  void _onAbacusChanged(int colIndex, int newValue) {
    if (isGameOver || mode == AbacusGameMode.abacusToNumber) return;
    setState(() {
      currentAbacus[colIndex] = newValue;
      SoundFontService.instance.playClick();
    });
  }

  void _submitNumberToAbacus() {
    if (isGameOver) return;
    int currentNum = _columnsToNumber(currentAbacus);
    if (currentNum == targetNumber) {
      SoundFontService.instance.playCorrect();
      setState(() {
        score += 10;
        _generateQuestion();
      });
    } else {
      SoundFontService.instance.playIncorrect();
    }
  }

  void _onNumberPadTap(String val) {
    if (isGameOver || mode == AbacusGameMode.numberToAbacus) return;
    SoundFontService.instance.playClick();
    setState(() {
      if (val == "DEL") {
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
      } else if (val == "ENTER") {
        if (userInput.isEmpty) return;
        int parsed = int.tryParse(userInput) ?? -1;
        if (parsed == targetNumber) {
          SoundFontService.instance.playCorrect();
          score += 10;
          _generateQuestion();
        } else {
          SoundFontService.instance.playIncorrect();
          userInput = "";
        }
      } else {
        if (userInput.length < columnCount) {
          userInput += val;
        }
      }
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;
            return Dialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.abacusSettings, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.columns, style: theme.textTheme.titleMedium),
                        DropdownButton<int>(
                          value: columnCount,
                          items: [3, 4, 5, 6, 7].map((c) => DropdownMenuItem(value: c, child: Text("$c"))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => columnCount = val);
                              setState(() {
                                columnCount = val;
                                _startNewGame();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.gameMode, style: theme.textTheme.titleMedium),
                        DropdownButton<AbacusGameMode>(
                          value: mode,
                          items: [
                            DropdownMenuItem(value: AbacusGameMode.abacusToNumber, child: Text(l10n.abacusToNumber)),
                            DropdownMenuItem(value: AbacusGameMode.numberToAbacus, child: Text(l10n.numberToAbacus)),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => mode = val);
                              setState(() {
                                mode = val;
                                _startNewGame();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              ),
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
                    l10n.timeUp,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.abacusGame),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.scoreLabel(score), style: theme.textTheme.titleLarge),
                    if (mode == AbacusGameMode.numberToAbacus)
                      Text(
                        "Target: $targetNumber",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF38BDF8),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF38BDF8)),
                        ),
                        child: Text(
                          userInput.isEmpty ? "?" : userInput,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown.shade700, width: 8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(columnCount, (index) {
                            return _AbacusColumnWidget(
                              value: currentAbacus[index],
                              onChanged: mode == AbacusGameMode.numberToAbacus
                                  ? (val) => _onAbacusChanged(index, val)
                                  : null,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (mode == AbacusGameMode.numberToAbacus)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: _submitNumberToAbacus,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.submit, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2,
                    children: [
                      for (int i = 1; i <= 9; i++)
                        _buildNumButton(i.toString(), theme),
                      _buildNumButton("DEL", theme, color: Colors.redAccent),
                      _buildNumButton("0", theme),
                      _buildNumButton("ENTER", theme, color: const Color(0xFF38BDF8)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumButton(String label, ThemeData theme, {Color? color}) {
    return Material(
      color: color ?? (theme.brightness == Brightness.light ? Colors.grey.shade200 : const Color(0xFF334155)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onNumberPadTap(label),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color != null ? Colors.white : (theme.brightness == Brightness.light ? Colors.black : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _AbacusColumnWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _AbacusColumnWidget({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool topUp = value < 5; // Top bead up means it's inactive (value < 5)
    int bottomCount = value % 5; // Number of bottom beads UP

    return SizedBox(
      width: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The rod
          Container(
            width: 6,
            color: Colors.grey.shade400,
          ),
          Column(
            children: [
              // Top section
              SizedBox(
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 150),
                      top: topUp ? 5 : 45,
                      child: GestureDetector(
                        onTap: () {
                          if (onChanged != null) {
                            onChanged!(value >= 5 ? value - 5 : value + 5);
                          }
                        },
                        child: _buildBead(),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 8,
                width: 60,
                color: Colors.brown.shade600,
              ),
              // Bottom section
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(4, (index) {
                    // index 0 is top-most bottom bead.
                    // If bottomCount is 3, beads 0, 1, 2 are UP, bead 3 is DOWN.
                    bool isUp = index < bottomCount;
                    
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 150),
                      top: isUp ? (index * 24.0 + 5) : (index * 24.0 + 65),
                      child: GestureDetector(
                        onTap: () {
                          if (onChanged != null) {
                            if (isUp) {
                              onChanged!(value - (bottomCount - index));
                            } else {
                              onChanged!(value + (index + 1 - bottomCount));
                            }
                          }
                        },
                        child: _buildBead(),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBead() {
    return Container(
      width: 48,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFFFACC15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade700, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 2)
        ],
      ),
    );
  }
}
