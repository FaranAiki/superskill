import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';
import 'package:superskill/core/soundfont_service.dart';

enum ReactionState { waiting, ready, tapped, early }

class ReactionTimeScreen extends StatefulWidget {
  const ReactionTimeScreen({super.key});

  @override
  State<ReactionTimeScreen> createState() => _ReactionTimeScreenState();
}

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  ReactionState _state = ReactionState.waiting;
  
  Timer? _waitTimer;
  DateTime? _readyTime;
  
  int _currentAttempt = 0;
  final int _maxAttempts = 5;
  List<int> _reactionTimes = [];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startAttempt();
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  void _startAttempt() {
    setState(() {
      _state = ReactionState.waiting;
    });
    
    // Wait between 1.5 to 5.0 seconds
    int delayMs = 1500 + _random.nextInt(3500);
    
    _waitTimer?.cancel();
    _waitTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          _state = ReactionState.ready;
          _readyTime = DateTime.now();
        });
      }
    });
  }

  void _handleTap() {
    if (_state == ReactionState.waiting) {
      // Tapped too early
      _waitTimer?.cancel();
      SoundFontService.instance.playIncorrect();
      setState(() {
        _state = ReactionState.early;
      });
    } else if (_state == ReactionState.ready && _readyTime != null) {
      // Good tap
      final now = DateTime.now();
      final reactionTimeMs = now.difference(_readyTime!).inMilliseconds;
      
      SoundFontService.instance.playCorrect();
      
      setState(() {
        _reactionTimes.add(reactionTimeMs);
        _state = ReactionState.tapped;
        _currentAttempt++;
      });
      
      if (_currentAttempt >= _maxAttempts) {
        // Game Over
        int avg = _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length;
        int score = max(0, 10000 - avg);
        HighScoreService.instance.saveScore("reaction_time", score);
      }
    } else if (_state == ReactionState.early || _state == ReactionState.tapped) {
      // Proceed to next attempt if not game over
      if (_currentAttempt < _maxAttempts) {
        _startAttempt();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    if (_currentAttempt >= _maxAttempts && _state == ReactionState.tapped) {
      int avg = _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length;
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    "Average: ${avg}ms",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentAttempt = 0;
                        _reactionTimes.clear();
                        _startAttempt();
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

    Color bgColor;
    String mainText;
    String subText;
    
    switch (_state) {
      case ReactionState.waiting:
        bgColor = Colors.redAccent.shade700;
        mainText = "Wait...";
        subText = "Tap when it turns green";
        break;
      case ReactionState.ready:
        bgColor = Colors.greenAccent.shade700;
        mainText = "TAP!";
        subText = "";
        break;
      case ReactionState.tapped:
        bgColor = const Color(0xFF030712); // Dark background
        mainText = "${_reactionTimes.last} ms";
        subText = "Tap to continue";
        break;
      case ReactionState.early:
        bgColor = Colors.orangeAccent.shade700;
        mainText = "Too soon!";
        subText = "Tap to try again";
        break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l10n.reactionTime),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainText,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subText,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 64),
              Text(
                "Attempt ${_currentAttempt + 1} of $_maxAttempts",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
