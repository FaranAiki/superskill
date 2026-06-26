import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';
import 'package:superskill/core/soundfont_service.dart';

class SimonSaysScreen extends StatefulWidget {
  const SimonSaysScreen({super.key});

  @override
  State<SimonSaysScreen> createState() => _SimonSaysScreenState();
}

class _SimonSaysScreenState extends State<SimonSaysScreen> {
  int score = 0;
  bool isGameOver = false;
  bool isPlayingSequence = false;
  
  List<int> sequence = [];
  int userSequenceIndex = 0;

  final int gridCount = 4;
  final Random _random = Random();
  
  // Colors for Simon Says
  final List<Color> _colors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.amberAccent,
  ];
  
  int _activeTile = -1;
  
  bool isSimonSays = true;
  String promptText = "";
  Timer? trickTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }
  
  @override
  void dispose() {
    trickTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    trickTimer?.cancel();
    setState(() {
      score = 0;
      isGameOver = false;
      sequence.clear();
      _nextRound();
    });
  }

  void _nextRound() {
    setState(() {
      sequence.add(_random.nextInt(gridCount));
      userSequenceIndex = 0;
      
      // 30% chance it's a trick
      isSimonSays = _random.nextDouble() > 0.3;
      if (isSimonSays) {
        promptText = "Simon says...";
      } else {
        List<String> tricks = [
          "Watch and listen...",
          "Repeat the pattern...",
          "Do this...",
          "Follow me..."
        ];
        promptText = tricks[_random.nextInt(tricks.length)];
      }
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() {
      isPlayingSequence = true;
    });
    
    // Initial delay before sequence starts
    await Future.delayed(const Duration(milliseconds: 1000));

    for (int i = 0; i < sequence.length; i++) {
      if (!mounted || isGameOver) return;
      
      int tileIndex = sequence[i];
      
      setState(() {
        _activeTile = tileIndex;
      });
      _playSoundForTile(tileIndex);
      
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (!mounted) return;
      setState(() {
        _activeTile = -1;
      });
      
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) {
      setState(() {
        isPlayingSequence = false;
      });
      
      if (!isSimonSays) {
        // User must NOT tap for 2.5 seconds to win the trick round
        trickTimer?.cancel();
        trickTimer = Timer(const Duration(milliseconds: 2500), () {
          if (mounted && !isGameOver) {
            score++;
            SoundFontService.instance.playCorrect();
            _nextRound();
          }
        });
      }
    }
  }

  void _playSoundForTile(int index) {
    SoundFontService.instance.playClick();
  }

  void _onTileTap(int index) {
    if (isGameOver || isPlayingSequence) return;
    
    if (!isSimonSays) {
      // Failed the trick!
      trickTimer?.cancel();
      setState(() {
        isGameOver = true;
        SoundFontService.instance.playIncorrect();
        HighScoreService.instance.saveScore("simon_says", score);
      });
      return;
    }
    
    _playSoundForTile(index);

    setState(() {
      _activeTile = index;
    });
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _activeTile = -1;
        });
      }
    });

    if (sequence[userSequenceIndex] == index) {
      userSequenceIndex++;
      if (userSequenceIndex == sequence.length) {
        score++;
        SoundFontService.instance.playCorrect();
        
        // Brief delay before next round
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _nextRound();
        });
      }
    } else {
      setState(() {
        isGameOver = true;
        SoundFontService.instance.playIncorrect();
        HighScoreService.instance.saveScore("simon_says", score);
      });
    }
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
                  Icon(Icons.cancel_outlined, size: 80, color: theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    !isSimonSays && userSequenceIndex == 0 
                        ? "Simon didn't say it!" 
                        : "Game Over",
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
        title: Text(l10n.simonSays),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.scoreLabel(score), style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text(
                  isPlayingSequence ? promptText : "Your turn!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: isPlayingSequence ? Colors.orangeAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                
                Flexible(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final isActive = _activeTile == index;
                        final color = _colors[index];
                        
                        return Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () => _onTileTap(index),
                            borderRadius: BorderRadius.circular(24),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isActive ? color : color.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isActive ? Colors.white : color.withValues(alpha: 0.5),
                                  width: isActive ? 4 : 2,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.8),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        )
                                      ]
                                    : [],
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
