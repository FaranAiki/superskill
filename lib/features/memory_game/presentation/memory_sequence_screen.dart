import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

enum GameSpeed {
  slow,
  medium,
  fast,
  superFast;

  int get flashMs => switch (this) {
        GameSpeed.slow => 1000,
        GameSpeed.medium => 600,
        GameSpeed.fast => 300,
        GameSpeed.superFast => 150,
      };

  int get gapMs => switch (this) {
        GameSpeed.slow => 400,
        GameSpeed.medium => 200,
        GameSpeed.fast => 100,
        GameSpeed.superFast => 50,
      };
}

class MemorySequenceScreen extends StatefulWidget {
  const MemorySequenceScreen({super.key});

  @override
  State<MemorySequenceScreen> createState() => _MemorySequenceScreenState();
}

class _MemorySequenceScreenState extends State<MemorySequenceScreen> {
  final List<Color> _allColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  List<Color> colors = [];
  List<int> sequence = [];
  List<int> userSequence = [];
  bool isShowingSequence = false;
  bool isGameOver = false;
  int? currentlyLit;
  bool _interruptSequence = false;

  int tileCount = 4;
  GameSpeed gameSpeed = GameSpeed.medium;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _updateColors();
    _startNewGame();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateColors() {
    setState(() {
      colors = _allColors.take(tileCount).toList();
    });
  }

  void _startNewGame() {
    setState(() {
      sequence = [];
      userSequence = [];
      isGameOver = false;
      _interruptSequence = false;
    });
    _nextLevel();
  }

  void _nextLevel() {
    setState(() {
      sequence.add(Random().nextInt(colors.length));
      userSequence = [];
      _interruptSequence = false;
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() {
      isShowingSequence = true;
      _interruptSequence = false;
    });
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    for (int index in sequence) {
      if (!mounted || _interruptSequence) break;
      await _lightUpTile(index);
      if (_interruptSequence) break;
      await Future.delayed(Duration(milliseconds: gameSpeed.gapMs));
    }
    
    if (mounted) {
      setState(() {
        isShowingSequence = false;
        currentlyLit = null;
      });
    }
  }

  Future<void> _lightUpTile(int index) async {
    setState(() => currentlyLit = index);
    _playSound(index);
    
    int duration = gameSpeed.flashMs;
    // Allow interruption during flash
    int steps = 5;
    int stepMs = (duration / steps).round();
    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: stepMs));
      if (_interruptSequence) break;
    }
    
    if (mounted) setState(() => currentlyLit = null);
  }

  void _playSound(int index) {
    _audioPlayer.play(AssetSource('sounds/tile_$index.mp3')).catchError((_) {
      // Ignore errors if sound files don't exist
    });
  }

  void _onTileTap(int index) async {
    if (isGameOver) return;
    
    if (isShowingSequence) {
      // Logic: If user clicks while sequence is playing, stop sequence and accept this as first input
      setState(() {
        _interruptSequence = true;
        isShowingSequence = false;
        userSequence = []; // Reset user sequence to start fresh for this turn
      });
      // We need to wait a tiny bit for the loop to break before processing the tap
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    if (currentlyLit != null) return;

    setState(() {
      userSequence.add(index);
    });

    // Provide visual feedback
    await _lightUpTile(index);

    if (userSequence.last != sequence[userSequence.length - 1]) {
      setState(() {
        isGameOver = true;
        HighScoreService.instance.saveScore("memory_sequence", sequence.isEmpty ? 0 : sequence.length - 1);
      });
    } else if (userSequence.length == sequence.length) {
      Future.delayed(const Duration(milliseconds: 500), _nextLevel);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text(l10n.gameSettings, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${l10n.tileCount}: $tileCount', style: Theme.of(context).textTheme.bodyMedium),
                  Slider(
                    value: tileCount.toDouble(),
                    min: 2,
                    max: 9,
                    divisions: 7,
                    onChanged: (value) {
                      setDialogState(() => tileCount = value.toInt());
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.gameSpeed, style: Theme.of(context).textTheme.bodyMedium),
                  DropdownButton<GameSpeed>(
                    value: gameSpeed,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: Theme.of(context).textTheme.bodyMedium,
                    items: [
                      DropdownMenuItem(
                        value: GameSpeed.slow,
                        child: Text(l10n.slow),
                      ),
                      DropdownMenuItem(
                        value: GameSpeed.medium,
                        child: Text(l10n.medium),
                      ),
                      DropdownMenuItem(
                        value: GameSpeed.fast,
                        child: Text(l10n.fast),
                      ),
                      DropdownMenuItem(
                        value: GameSpeed.superFast,
                        child: Text(l10n.superFast),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => gameSpeed = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateColors();
                    _startNewGame();
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

    if (isGameOver) {
      return _buildGameOver(l10n);
    }

    int crossAxisCount = tileCount <= 4 ? 2 : 3;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.memorySequence),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.levelLabel(sequence.length.toString()),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                isShowingSequence ? l10n.watchSequence : l10n.yourTurn,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isShowingSequence ? Colors.orange : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 40),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final isLit = currentlyLit == index;
                    return GestureDetector(
                      onTapDown: (_) => _onTileTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: colors[index].withOpacity(isLit ? 1.0 : 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLit ? Colors.white : colors[index].withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: isLit
                              ? [
                                  BoxShadow(
                                    color: colors[index].withOpacity(0.8),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(4, 4),
                                  )
                                ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildGameOver(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(l10n.timeUp, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(l10n.yourFinalScore, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${sequence.isEmpty ? 0 : sequence.length - 1}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _startNewGame,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 60),
                shape: const StadiumBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.backToMenu, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

