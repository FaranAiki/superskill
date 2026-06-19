import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class RhythmSyncScreen extends StatefulWidget {
  const RhythmSyncScreen({super.key});

  @override
  State<RhythmSyncScreen> createState() => _RhythmSyncScreenState();
}

class _RhythmSyncScreenState extends State<RhythmSyncScreen> with TickerProviderStateMixin {
  int bpm = 90; // Beats Per Minute
  double get beatInterval => 60.0 / bpm; // interval in seconds

  bool isListening = false;
  bool isTappingPhase = false;
  bool isFinished = false;

  int currentBeatIndex = 0; // Beat counter
  Timer? _playbackTimer;
  DateTime? startTime;

  List<double> userTapOffsets = []; // stores elapsed seconds of each user tap
  List<double> idealBeatOffsets = []; // stores ideal elapsed seconds of beats 4, 5, 6, 7, 8
  int calculatedScore = 0;
  double avgError = 0.0;

  // Pulse animation controller
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      isListening = true;
      isTappingPhase = false;
      isFinished = false;
      currentBeatIndex = 0;
      userTapOffsets.clear();
      idealBeatOffsets.clear();
    });

    _pulseController.reset();
    startTime = DateTime.now();
    
    // Calculate the ideal times for beats 4, 5, 6, 7, 8
    // Taps start at Beat 4 (which is at index 3: 3 * beatInterval)
    for (int i = 3; i < 8; i++) {
      idealBeatOffsets.add(i * beatInterval);
    }

    _scheduleNextBeat();
  }

  void _scheduleNextBeat() {
    final nextBeatTime = startTime!.add(
      Duration(milliseconds: (currentBeatIndex * beatInterval * 1000).round()),
    );
    final delay = nextBeatTime.difference(DateTime.now());

    _playbackTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      if (!mounted) return;

      setState(() {
        currentBeatIndex++;
      });

      // Pulse animation for the first 3 beats
      if (currentBeatIndex <= 3) {
        _pulseController.forward(from: 0.0);
      }

      if (currentBeatIndex < 3) {
        _scheduleNextBeat();
      } else {
        // Switch to user tapping phase!
        setState(() {
          isListening = false;
          isTappingPhase = true;
        });
        _scheduleTappingTimeout();
      }
    });
  }

  void _scheduleTappingTimeout() {
    // Timeout if user doesn't tap enough times (e.g. timeout after target duration + 3s)
    final timeoutDuration = Duration(
      milliseconds: ((8 * beatInterval + 3.0) * 1000).round(),
    );
    
    _playbackTimer?.cancel();
    _playbackTimer = Timer(timeoutDuration, () {
      if (mounted && isTappingPhase) {
        _finishGame();
      }
    });
  }

  void _handleTap() {
    if (!isTappingPhase || isFinished) return;

    final tapTime = DateTime.now();
    final double elapsed = tapTime.difference(startTime!).inMilliseconds / 1000.0;
    
    _pulseController.forward(from: 0.0);

    setState(() {
      userTapOffsets.add(elapsed);
      if (userTapOffsets.length >= 5) {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    _playbackTimer?.cancel();
    
    // Fill up empty taps if user stopped early
    while (userTapOffsets.length < 5) {
      userTapOffsets.add(0.0);
    }

    // Sort taps in chronological order
    userTapOffsets.sort();

    // Calculate errors
    double totalError = 0.0;
    for (int i = 0; i < 5; i++) {
      final double actual = userTapOffsets[i];
      final double ideal = idealBeatOffsets[i];
      
      // If tap was missed/unplaced, apply maximum penalty (e.g. 2s)
      final double error = actual == 0.0 ? 2.0 : (actual - ideal).abs();
      totalError += error;
    }

    final double avg = totalError / 5.0;
    
    // Score penalty calculation:
    // If difference > 1, then it's squared.
    // If difference < 1, then it's square-rooted.
    final double penalty = avg > 1.0 ? avg * avg : sqrt(avg);
    final int score = max(0, (1000 - penalty * 200).round());

    setState(() {
      isListening = false;
      isTappingPhase = false;
      isFinished = true;
      calculatedScore = score;
      avgError = avg;
    });

    HighScoreService.instance.saveScore("rhythm_sync", score);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rhythmSync),
        actions: [
          if (!isListening && !isTappingPhase)
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Instructions
                Card(
                  elevation: 0,
                  color: isLight ? Colors.black.withOpacity(0.02) : Colors.white.withOpacity(0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: isLight ? Colors.black12 : Colors.white10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          l10n.listenRhythm,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.rhythmSyncTap,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Beat visualizer / tapping pad
                GestureDetector(
                  onTap: (isTappingPhase && !isFinished) ? _handleTap : null,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 180,
                      width: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isTappingPhase
                            ? (isLight ? Colors.deepPurple.withOpacity(0.08) : Colors.deepPurple.withOpacity(0.15))
                            : (isListening ? primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.02)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTappingPhase 
                              ? Colors.deepPurple 
                              : (isListening ? primaryColor : primaryColor.withOpacity(0.2)),
                          width: 4,
                        ),
                        boxShadow: [
                          if (isTappingPhase)
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 24,
                            )
                          else if (isListening)
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 16,
                            )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isListening) ...[
                            Icon(Icons.volume_up, color: primaryColor, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              "Beat $currentBeatIndex / 3",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ] else if (isTappingPhase) ...[
                            const Icon(Icons.music_note, color: Colors.deepPurpleAccent, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              "Tap: ${userTapOffsets.length} / 5",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ] else
                            Text(
                              "Ready",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color?.withOpacity(0.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Results timeline visualization
                if (isFinished) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black.withOpacity(0.02) : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Avg Error: ${avgError.toStringAsFixed(3)}s",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        
                        // Mini timeline graphic
                        SizedBox(
                          height: 60,
                          child: CustomPaint(
                            painter: TimelinePainter(
                              idealBeats: idealBeatOffsets,
                              userTaps: userTapOffsets,
                              beatInterval: beatInterval,
                            ),
                            child: Container(),
                          ),
                        ),
                        
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                            const SizedBox(width: 8),
                             Text(
                               "${l10n.scoreLabel(calculatedScore)} Pts",
                               style: theme.textTheme.titleLarge?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.amber,
                               ),
                             ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (isListening || isTappingPhase) ? null : _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isFinished ? l10n.playAgain : l10n.startEstimating,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              children: [
                Text(l10n.gameSettings, style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                Text(
                  l10n.tempoLabel(bpm),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: bpm.toDouble(),
                  min: 60,
                  max: 150,
                  divisions: 6,
                  activeColor: primaryColor,
                  onChanged: (v) {
                    setState(() => bpm = v.toInt());
                    setModalState(() {});
                  },
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

class TimelinePainter extends CustomPainter {
  final List<double> idealBeats;
  final List<double> userTaps;
  final double beatInterval;

  TimelinePainter({
    required this.idealBeats,
    required this.userTaps,
    required this.beatInterval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal center line
    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    // Map timestamps to X coordinate
    // The timeline spans from 2.5 * beatInterval to 8.5 * beatInterval
    double startT = 2.5 * beatInterval;
    double endT = 8.5 * beatInterval;
    double duration = endT - startT;

    double getX(double t) {
      double pct = (t - startT) / duration;
      return pct.clamp(0.0, 1.0) * size.width;
    }

    // 1. Draw Ideal Beats as cyan ticks
    final idealPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3.5;
    for (int i = 0; i < idealBeats.length; i++) {
      double x = getX(idealBeats[i]);
      canvas.drawLine(
        Offset(x, size.height / 2 - 12),
        Offset(x, size.height / 2 + 12),
        idealPaint,
      );
    }

    // 2. Draw User Taps as purple dots / ticks
    final userPaint = Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < userTaps.length; i++) {
      double t = userTaps[i];
      if (t == 0.0) continue; // Skip missed taps
      
      double x = getX(t);
      // Draw as glowing circle
      canvas.drawCircle(Offset(x, size.height / 2), 6.0, userPaint);
      
      final glowPaint = Paint()
        ..color = Colors.deepPurpleAccent.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, size.height / 2), 12.0, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.beatInterval != beatInterval ||
        !listEquals(oldDelegate.idealBeats, idealBeats) ||
        !listEquals(oldDelegate.userTaps, userTaps);
  }
}
