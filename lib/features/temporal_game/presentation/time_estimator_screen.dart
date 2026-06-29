import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class TimeEstimatorScreen extends StatefulWidget {
  const TimeEstimatorScreen({super.key});

  @override
  State<TimeEstimatorScreen> createState() => _TimeEstimatorScreenState();
}

class _TimeEstimatorScreenState extends State<TimeEstimatorScreen> {
  double targetTime = 8.0; // target duration in seconds
  bool isRunning = false;
  bool isFinished = false;
  
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  double _elapsedSeconds = 0.0;
  
  double? estimatedTimeResult;
  int calculatedScore = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      isRunning = true;
      isFinished = false;
      estimatedTimeResult = null;
      _elapsedSeconds = 0.0;
    });
    
    _stopwatch.reset();
    _stopwatch.start();
    
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
        });
      }
    });
  }

  void _stop() {
    _stopwatch.stop();
    _timer?.cancel();
    
    final finalElapsed = _stopwatch.elapsedMilliseconds / 1000.0;
    final double diff = (finalElapsed - targetTime).abs();
    
    // Scoring system:
    // If difference > 1, then it's squared.
    // If difference < 1, then it's square-rooted.
    final double penalty = diff > 1.0 ? diff * diff : sqrt(diff);
    final int score = max(0, (1000 - penalty * 200).round());
    
    setState(() {
      isRunning = false;
      isFinished = true;
      _elapsedSeconds = finalElapsed;
      estimatedTimeResult = finalElapsed;
      calculatedScore = score;
    });

    HighScoreService.instance.saveScore("time_estimator", score);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isLight = theme.brightness == Brightness.light;

    // Show timer only for the first 3 seconds
    final bool showTimerValue = _elapsedSeconds <= 3.0 && isRunning;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timeEstimator),
        actions: [
          if (!isRunning)
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
                // Instruction block
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
                          l10n.waitTargetTime(targetTime.toStringAsFixed(1)),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.hideTimerDesc,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Timer display
                Container(
                  height: 180,
                  width: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.black.withOpacity(0.01) : Colors.white.withOpacity(0.01),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRunning 
                          ? (showTimerValue ? primaryColor : Colors.amber.withOpacity(0.3))
                          : (isFinished ? Colors.green : primaryColor.withOpacity(0.2)),
                      width: 4,
                    ),
                    boxShadow: [
                      if (isRunning && showTimerValue)
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                        )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRunning) ...[
                        if (showTimerValue)
                          Text(
                            _elapsedSeconds.toStringAsFixed(2),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          )
                        else
                          Column(
                            children: [
                              const Icon(Icons.visibility_off_outlined, color: Colors.amber, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                "Estimating...",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                      ] else if (isFinished) ...[
                        Text(
                          _elapsedSeconds.toStringAsFixed(2),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Result",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ] else
                        Text(
                          "0.00",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.headlineLarge?.color?.withOpacity(0.4),
                            fontFamily: 'monospace',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Scoring / Feedback block
                if (isFinished && estimatedTimeResult != null) ...[
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Target",
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${targetTime.toStringAsFixed(2)}s",
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Actual",
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${estimatedTimeResult!.toStringAsFixed(2)}s",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Error",
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${(estimatedTimeResult! - targetTime) >= 0 ? '+' : ''}${(estimatedTimeResult! - targetTime).toStringAsFixed(2)}s",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: (estimatedTimeResult! - targetTime).abs() <= 0.2 ? Colors.green : Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Colors.green),
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
                  ),
                  const SizedBox(height: 40),
                ],

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isRunning ? _stop : _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.red.shade600 : primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isRunning 
                          ? l10n.stopEstimating 
                          : (isFinished ? l10n.playAgain : l10n.startEstimating),
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
                  l10n.targetDurationLabel(targetTime.toStringAsFixed(1)),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: targetTime,
                  min: 5,
                  max: 15,
                  divisions: 10,
                  activeColor: primaryColor,
                  onChanged: (v) {
                    setState(() => targetTime = v);
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
