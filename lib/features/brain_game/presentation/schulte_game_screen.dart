import 'dart:async';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class SchulteGameScreen extends StatefulWidget {
  const SchulteGameScreen({super.key});

  @override
  State<SchulteGameScreen> createState() => _SchulteGameScreenState();
}

class _SchulteGameScreenState extends State<SchulteGameScreen> {
  // Settings
  int gridSize = 3; // 3x3, 4x4, 5x5
  bool isAscending = true;
  String colorMode = 'monochrome'; // monochrome, rainbow

  // Game state
  List<int> gridNumbers = [];
  int nextNumber = 1;
  bool isPlaying = false;
  bool isCompleted = false;
  
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  double _elapsedSeconds = 0.0;
  int? _wrongIndex;
  Timer? _wrongTimer;
  int? _correctTapIndex;
  Timer? _correctTimer;

  // Custom colors for rainbow mode
  final List<Color> _rainbowColors = [
    const Color(0xFFF87171), // Red
    const Color(0xFFFB923C), // Orange
    const Color(0xFFFACC15), // Yellow
    const Color(0xFF4ADE80), // Green
    const Color(0xFF2DD4BF), // Teal
    const Color(0xFF38BDF8), // Light Blue
    const Color(0xFF818CF8), // Indigo
    const Color(0xFFC084FC), // Purple
    const Color(0xFFF472B6), // Pink
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _wrongTimer?.cancel();
    _correctTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    final maxNum = gridSize * gridSize;
    final List<int> list = List.generate(maxNum, (index) => index + 1);
    list.shuffle();

    setState(() {
      gridNumbers = list;
      nextNumber = isAscending ? 1 : maxNum;
      isPlaying = true;
      isCompleted = false;
      _elapsedSeconds = 0.0;
      _wrongIndex = null;
      _correctTapIndex = null;
    });

    _stopwatch.reset();
    _stopwatch.start();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
        });
      }
    });
  }

  void _handleTap(int index) {
    if (!isPlaying || isCompleted) return;

    final tappedVal = gridNumbers[index];
    final maxNum = gridSize * gridSize;

    if (tappedVal == nextNumber) {
      // Correct number clicked!
      _correctTimer?.cancel();
      setState(() {
        _wrongIndex = null; // Clear previous wrong flag
        _correctTapIndex = index;
        
        if (isAscending) {
          if (nextNumber < maxNum) {
            nextNumber++;
          } else {
            _finishGame();
          }
        } else {
          if (nextNumber > 1) {
            nextNumber--;
          } else {
            _finishGame();
          }
        }
      });
      _correctTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _correctTapIndex = null;
          });
        }
      });
    } else {
      // Wrong number clicked!
      _wrongTimer?.cancel();
      setState(() {
        _wrongIndex = index;
      });
      _wrongTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _wrongIndex = null;
          });
        }
      });
    }
  }

  void _finishGame() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      isCompleted = true;
      isPlaying = false;
    });

    // Score: 10000 divided by elapsed seconds (faster = higher score!)
    int finalScore = 0;
    if (_elapsedSeconds > 0.1) {
      finalScore = (10000 / _elapsedSeconds).round();
    }
    
    HighScoreService.instance.saveScore("schulte_focus", finalScore);
  }

  Color _getCellColor(int val, int index, bool isLight, Color primaryColor) {
    if (submittedWrongCell(index)) {
      return Colors.red.shade800.withOpacity(0.8);
    }
    if (_correctTapIndex == index) {
      return Colors.green.shade800.withOpacity(0.8);
    }
    
    if (colorMode == 'rainbow') {
      final colorIndex = val % _rainbowColors.length;
      return _rainbowColors[colorIndex].withOpacity(isLight ? 0.15 : 0.25);
    } else {
      return isLight 
          ? Colors.black.withOpacity(0.04) 
          : const Color(0xFF1E293B).withOpacity(0.5);
    }
  }

  bool submittedWrongCell(int index) {
    return _wrongIndex == index;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.schulteGame),
        actions: [
          if (!isPlaying && !isCompleted)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettings(context),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Info Section
                if (isPlaying || isCompleted) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.tapNextNumber(nextNumber),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        "Time: ${_elapsedSeconds.toStringAsFixed(2)}s",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Grid Table Display
                Expanded(
                  child: isPlaying
                      ? GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: gridNumbers.length,
                          itemBuilder: (context, index) {
                            final val = gridNumbers[index];
                            final cellColor = _getCellColor(val, index, isLight, primaryColor);
                            final isCorrectTap = _correctTapIndex == index;
                            final isWrongTap = _wrongIndex == index;
                            
                            double scale = 1.0;
                            if (isCorrectTap) {
                              scale = 0.9;
                            } else if (isWrongTap) {
                              scale = 0.95;
                            }
                            
                            return GestureDetector(
                              onTap: () => _handleTap(index),
                              child: AnimatedScale(
                                scale: scale,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isWrongTap 
                                          ? Colors.red 
                                          : (isCorrectTap 
                                              ? Colors.green 
                                              : (colorMode == 'rainbow' ? cellColor : primaryColor.withOpacity(0.3))),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      if (isCorrectTap)
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        )
                                      else if (isWrongTap)
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        )
                                      else if (colorMode == 'rainbow')
                                        BoxShadow(
                                          color: cellColor.withOpacity(0.1),
                                          blurRadius: 8,
                                        )
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$val",
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isLight ? const Color(0xFF0F172A) : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : isCompleted
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade500),
                                const SizedBox(height: 24),
                                Text(
                                  "Complete!",
                                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Time Taken: ${_elapsedSeconds.toStringAsFixed(2)} seconds\nFinal Score: ${(10000 / _elapsedSeconds).round()}",
                                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 48),
                                ElevatedButton.icon(
                                  onPressed: _startGame,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(l10n.playAgain),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 60),
                                    shape: const StadiumBorder(),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_9_plus_outlined, size: 80, color: primaryColor),
                                const SizedBox(height: 24),
                                Text(
                                  l10n.schulteGame,
                                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.schulteGameDesc,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 48),
                                ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 60),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text("Start Game", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                              ],
                            ),
                ),
                
                // Back Button
                if (!isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.backToMenu),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(l10n.gameSettings, style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: 24),
                
                // Grid Size selector
                Text("${l10n.gridSize}: ${gridSize}x$gridSize", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Slider(
                  value: gridSize.toDouble(),
                  min: 3,
                  max: 5,
                  divisions: 2,
                  activeColor: primaryColor,
                  onChanged: (v) {
                    setState(() => gridSize = v.toInt());
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                
                // Order selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.schulteOrder, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ToggleButtons(
                      isSelected: [isAscending, !isAscending],
                      onPressed: (index) {
                        setState(() {
                          isAscending = index == 0;
                        });
                        setModalState(() {});
                      },
                      borderRadius: BorderRadius.circular(12),
                      selectedColor: Colors.white,
                      fillColor: primaryColor,
                      constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
                      children: [
                        Text(l10n.ascending),
                        Text(l10n.descending),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Color selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.gridColorMode, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ToggleButtons(
                      isSelected: [colorMode == 'monochrome', colorMode == 'rainbow'],
                      onPressed: (index) {
                        setState(() {
                          colorMode = index == 0 ? 'monochrome' : 'rainbow';
                        });
                        setModalState(() {});
                      },
                      borderRadius: BorderRadius.circular(12),
                      selectedColor: Colors.white,
                      fillColor: primaryColor,
                      constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
                      children: [
                        Text(l10n.monochrome),
                        Text(l10n.rainbow),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
