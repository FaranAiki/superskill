import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';
import 'package:superskill/core/soundfont_service.dart';

enum CupsGameState { idle, showing, shuffling, waitingForGuess, gameOver }

class MovingCupsScreen extends StatefulWidget {
  const MovingCupsScreen({super.key});

  @override
  State<MovingCupsScreen> createState() => _MovingCupsScreenState();
}

class _MovingCupsScreenState extends State<MovingCupsScreen> {
  int score = 0;
  CupsGameState _state = CupsGameState.idle;
  
  final int cupCount = 3;
  // This maps the logical cup index to its physical visual position index (0, 1, 2)
  List<int> cupPositions = [0, 1, 2];
  int ballLogicalIndex = 0;
  
  final Random _random = Random();
  int _shuffleCount = 0;
  Timer? _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    setState(() {
      _state = CupsGameState.showing;
      cupPositions = List.generate(cupCount, (i) => i);
      ballLogicalIndex = _random.nextInt(cupCount);
      _shuffleCount = 0;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startShuffling();
      }
    });
  }

  void _startShuffling() {
    setState(() {
      _state = CupsGameState.shuffling;
    });
    
    // We shuffle 5 + score times to make it harder as score goes up
    int totalShuffles = 5 + (score * 2);
    
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) return;
      
      if (_shuffleCount >= totalShuffles) {
        timer.cancel();
        setState(() {
          _state = CupsGameState.waitingForGuess;
        });
        return;
      }
      
      // Swap two random positions
      int idx1 = _random.nextInt(cupCount);
      int idx2;
      do {
        idx2 = _random.nextInt(cupCount);
      } while (idx1 == idx2);
      
      setState(() {
        int temp = cupPositions[idx1];
        cupPositions[idx1] = cupPositions[idx2];
        cupPositions[idx2] = temp;
        _shuffleCount++;
        SoundFontService.instance.playClick();
      });
    });
  }

  void _onCupTapped(int logicalIndex) {
    if (_state != CupsGameState.waitingForGuess) return;
    
    if (logicalIndex == ballLogicalIndex) {
      SoundFontService.instance.playCorrect();
      setState(() {
        score += 10;
        _state = CupsGameState.showing; // Reveal briefly
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _startRound();
      });
    } else {
      SoundFontService.instance.playIncorrect();
      HighScoreService.instance.saveScore("moving_cups", score);
      setState(() {
        _state = CupsGameState.gameOver;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    if (_state == CupsGameState.gameOver) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    "Game Over",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Score: $score",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        score = 0;
                        _startRound();
                      });
                    },
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
        title: Text(l10n.movingCups),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.scoreLabel(score), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 32),
              Text(
                _state == CupsGameState.showing ? "Watch the ball!" :
                _state == CupsGameState.shuffling ? "Follow the cup!" : "Where is it?",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(height: 64),
              
              SizedBox(
                height: 150,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cupWidth = constraints.maxWidth / cupCount;
                    
                    return Stack(
                      children: List.generate(cupCount, (logicalIndex) {
                        final physicalPos = cupPositions[logicalIndex];
                        final hasBall = logicalIndex == ballLogicalIndex;
                        final isRevealed = _state == CupsGameState.showing || _state == CupsGameState.gameOver;
                        
                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: physicalPos * cupWidth,
                          top: 0,
                          width: cupWidth,
                          height: 150,
                          child: GestureDetector(
                            onTap: () => _onCupTapped(logicalIndex),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // The cup itself
                                Container(
                                  width: cupWidth * 0.6,
                                  height: isRevealed ? 80 : 120, // Cup lifts up if revealed
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade700,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border.all(color: Colors.blueGrey.shade300, width: 2),
                                  ),
                                ),
                                if (isRevealed && hasBall)
                                  Container(
                                    width: 30,
                                    height: 30,
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else if (isRevealed)
                                  const SizedBox(height: 38)
                                else
                                  const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
