import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class SpeedCountScreen extends StatefulWidget {
  const SpeedCountScreen({super.key});

  @override
  State<SpeedCountScreen> createState() => _SpeedCountScreenState();
}

enum SpeedCountState { setup, flashing, inputting, feedback, gameOver }

class _SpeedCountScreenState extends State<SpeedCountScreen> with SingleTickerProviderStateMixin {
  SpeedCountState gameState = SpeedCountState.setup;
  int score = 0;
  int level = 1;
  int lives = 3;

  // Settings
  int flashDurationMs = 600;
  String difficulty = 'normal'; // easy, normal, hard

  // Round state
  int correctCount = 0;
  List<Offset> dotPositions = [];
  bool showDots = false;
  int? userAnswer;
  String feedbackMessage = '';
  bool feedbackCorrect = false;

  // Input
  int? selectedAnswer;
  Timer? flashTimer;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    flashTimer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  int get _flashMs {
    switch (difficulty) {
      case 'easy': return 1000;
      case 'hard': return 350;
      default: return 600;
    }
  }

  int get _dotCount => min(3 + level, 12);
  List<int> get _answerOptions {
    final opts = <int>{correctCount};
    final rng = Random();
    while (opts.length < 4) {
      final offset = rng.nextInt(4) + 1;
      opts.add(correctCount + (rng.nextBool() ? offset : -offset));
    }
    return (opts.where((v) => v >= 1).toList()..shuffle(rng)).take(4).toList();
  }

  void _startRound() {
    final rng = Random();
    final count = max(1, rng.nextInt(_dotCount) + 1);
    final positions = <Offset>[];

    // Generate non-overlapping dot positions in a 300x300 canvas
    for (int i = 0; i < count; i++) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        final x = rng.nextDouble() * 0.8 + 0.1; // 10%-90%
        final y = rng.nextDouble() * 0.8 + 0.1;
        final newPos = Offset(x, y);
        bool overlaps = positions.any((p) => (p - newPos).distance < 0.18);
        if (!overlaps) {
          positions.add(newPos);
          placed = true;
        }
        attempts++;
      }
      if (!placed) positions.add(Offset(rng.nextDouble(), rng.nextDouble()));
    }

    setState(() {
      gameState = SpeedCountState.flashing;
      correctCount = count;
      dotPositions = positions;
      showDots = true;
      selectedAnswer = null;
    });

    flashTimer?.cancel();
    flashTimer = Timer(Duration(milliseconds: _flashMs), () {
      if (!mounted) return;
      setState(() {
        showDots = false;
        gameState = SpeedCountState.inputting;
      });
    });
  }

  void _handleAnswer(int answer) {
    if (gameState != SpeedCountState.inputting) return;
    final correct = answer == correctCount;
    setState(() {
      selectedAnswer = answer;
      gameState = SpeedCountState.feedback;
      feedbackCorrect = correct;
      feedbackMessage = correct
          ? 'Correct! There were $correctCount dots.'
          : 'Wrong! There were $correctCount dots.';
      if (correct) {
        score += level * 10;
        level++;
      } else {
        lives--;
      }
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (lives <= 0) {
        HighScoreService.instance.saveScore('speed_count', score);
        setState(() => gameState = SpeedCountState.gameOver);
      } else {
        _startRound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = theme.colorScheme.primary;

    if (gameState == SpeedCountState.gameOver) return _buildGameOver(context, l10n, theme, isLight, primary);
    if (gameState == SpeedCountState.setup) return _buildSetup(context, l10n, theme, isLight, primary);
    return _buildGame(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.speedCount), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: _bgDecoration(isLight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF818CF8)]).createShader(b),
                    child: Text(l10n.speedCount, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.speedCountDesc, style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  _buildGlassCard(isLight: isLight, primary: primary, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.difficulty, style: theme.textTheme.titleSmall?.copyWith(color: primary)),
                      const SizedBox(height: 12),
                      Row(
                        children: ['easy', 'normal', 'hard'].map((d) {
                          final sel = difficulty == d;
                          final label = d == 'easy' ? l10n.speedCountEasy : (d == 'hard' ? l10n.speedCountHard : l10n.speedCountNormal);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => difficulty = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: sel ? LinearGradient(colors: [primary, primary.withOpacity(0.6)]) : null,
                                  color: sel ? null : (isLight ? Colors.black.withOpacity(0.05) : Colors.white10),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: sel ? primary : Colors.transparent, width: 2),
                                ),
                                child: Center(
                                  child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: sel ? Colors.white : (isLight ? Colors.black87 : Colors.white70),
                                  )),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Center(child: Text(l10n.speedCountFlashTime(_flashMs), style: theme.textTheme.bodySmall?.copyWith(color: isLight ? Colors.black45 : Colors.white38))),
                    ],
                  )),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() { gameState = SpeedCountState.flashing; });
                        _startRound();
                      },
                      icon: const Icon(Icons.visibility),
                      label: Text(l10n.startGame, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGame(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    final isFlashing = gameState == SpeedCountState.flashing;
    final isInput = gameState == SpeedCountState.inputting;
    final isFeedback = gameState == SpeedCountState.feedback;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.speedCount),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(l10n.scoreLabel(score), style: theme.textTheme.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: Container(
        decoration: _bgDecoration(isLight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lives & level
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: List.generate(3, (i) => Icon(i < lives ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent, size: 22))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text('Level $level', style: theme.textTheme.bodySmall?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Flash area
                  _buildGlassCard(
                    isLight: isLight, primary: primary,
                    child: Column(
                      children: [
                        Text(
                          isFlashing ? l10n.speedCountWatch : (isFeedback ? (feedbackCorrect ? l10n.correct : l10n.wrong) : l10n.speedCountHowMany),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isFeedback ? (feedbackCorrect ? Colors.greenAccent : Colors.redAccent) : (isLight ? Colors.black87 : Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AspectRatio(
                          aspectRatio: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = constraints.maxWidth;
                              return Container(
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.black.withOpacity(0.04) : Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: primary.withOpacity(0.2)),
                                ),
                                child: Stack(
                                  children: [
                                    if (showDots || isFeedback)
                                      ...dotPositions.map((pos) {
                                        final dotColor = isFeedback && feedbackCorrect ? Colors.greenAccent : primary;
                                        return Positioned(
                                          left: pos.dx * size - 10,
                                          top: pos.dy * size - 10,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: dotColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)],
                                            ),
                                          ),
                                        );
                                      }),
                                    if (!showDots && !isFeedback)
                                      Center(
                                        child: Text(
                                          '?',
                                          style: theme.textTheme.displayLarge?.copyWith(
                                            color: isLight ? Colors.black26 : Colors.white24,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Answer buttons
                  if (isInput || isFeedback)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _answerOptions.map((opt) {
                        final isSelected = selectedAnswer == opt;
                        final isCorrectOpt = opt == correctCount;
                        Color borderColor = primary.withOpacity(0.25);
                        Color bgColor = isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.07);
                        if (isFeedback && isCorrectOpt) {
                          borderColor = Colors.greenAccent;
                          bgColor = Colors.greenAccent.withOpacity(0.2);
                        }
                        if (isFeedback && isSelected && !feedbackCorrect) {
                          borderColor = Colors.redAccent;
                          bgColor = Colors.redAccent.withOpacity(0.2);
                        }
                        return GestureDetector(
                          onTap: isInput ? () => _handleAnswer(opt) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '$opt',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isFeedback && isCorrectOpt ? Colors.greenAccent : (isFeedback && isSelected && !feedbackCorrect ? Colors.redAccent : (isLight ? Colors.black87 : Colors.white)),
                                ),
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
        ),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      body: Container(
        decoration: _bgDecoration(isLight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: primary.withOpacity(0.15), shape: BoxShape.circle), child: Icon(Icons.visibility, color: primary, size: 64)),
                  const SizedBox(height: 24),
                  Text(l10n.gameOver, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(l10n.finalScorePoints(score), style: theme.textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildGlassCard(isLight: isLight, primary: primary, child: Column(children: [
                    _statRow('Level $level reached', Icons.trending_up, primary, theme),
                    const SizedBox(height: 8),
                    _statRow('$difficulty mode', Icons.speed, const Color(0xFF818CF8), theme),
                  ])),
                  const SizedBox(height: 32),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(
                    onPressed: () => setState(() { gameState = SpeedCountState.setup; score = 0; level = 1; lives = 3; }),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryAgain, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  )),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.backToMenu)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _bgDecoration(bool isLight) => BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.2,
          colors: isLight ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)] : [const Color(0xFF0F172A), const Color(0xFF030712)],
        ),
      );

  Widget _buildGlassCard({required bool isLight, required Color primary, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.85) : const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _statRow(String label, IconData icon, Color color, ThemeData theme) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }
}
