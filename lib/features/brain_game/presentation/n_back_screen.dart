import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class NBackScreen extends StatefulWidget {
  const NBackScreen({super.key});

  @override
  State<NBackScreen> createState() => _NBackScreenState();
}

enum NBackState { setup, playing, gameOver }

class _NBackScreenState extends State<NBackScreen> with TickerProviderStateMixin {
  // Settings
  int nLevel = 2; // N in N-Back

  // Game State
  NBackState gameState = NBackState.setup;
  int score = 0;
  int totalRounds = 20;
  int currentRound = 0;
  int correctAnswers = 0;
  int mistakes = 0;
  List<int> sequence = [];
  int? currentPosition;
  bool? userAnswer;
  bool showFeedback = false;
  bool feedbackCorrect = false;
  Timer? roundTimer;
  Timer? feedbackTimer;
  late AnimationController _pulseController;
  late AnimationController _feedbackController;

  final int gridSize = 3; // 3x3 grid

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    feedbackTimer?.cancel();
    _pulseController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      gameState = NBackState.playing;
      score = 0;
      currentRound = 0;
      correctAnswers = 0;
      mistakes = 0;
      sequence = [];
      currentPosition = null;
      userAnswer = null;
      showFeedback = false;
    });
    _nextRound();
  }

  void _nextRound() {
    if (currentRound >= totalRounds) {
      _endGame();
      return;
    }
    final rng = Random();
    // ~30% chance of a match when we have enough history
    int nextPos;
    if (sequence.length >= nLevel && rng.nextDouble() < 0.3) {
      nextPos = sequence[sequence.length - nLevel];
    } else {
      nextPos = rng.nextInt(gridSize * gridSize);
    }

    setState(() {
      sequence.add(nextPos);
      currentPosition = nextPos;
      userAnswer = null;
      showFeedback = false;
      currentRound++;
    });
    _pulseController.forward(from: 0);

    roundTimer?.cancel();
    roundTimer = Timer(const Duration(milliseconds: 2000), () {
      _evaluateRound(null); // Time up — treat as no answer
    });
  }

  bool _isMatch() {
    if (sequence.length <= nLevel) return false;
    return sequence[sequence.length - 1] == sequence[sequence.length - 1 - nLevel];
  }

  void _evaluateRound(bool? tapped) {
    roundTimer?.cancel();
    final match = _isMatch();
    // tapped == true means user said "match"
    // tapped == null means user said nothing (no match)
    final answeredMatch = tapped ?? false;
    final correct = answeredMatch == match;

    setState(() {
      userAnswer = tapped;
      showFeedback = true;
      feedbackCorrect = correct;
      if (correct) {
        correctAnswers++;
        score += 10 * nLevel;
      } else {
        mistakes++;
        score = max(0, score - 5);
      }
    });
    _feedbackController.forward(from: 0);

    feedbackTimer = Timer(const Duration(milliseconds: 700), _nextRound);
  }

  void _endGame() {
    roundTimer?.cancel();
    HighScoreService.instance.saveScore('n_back', score);
    setState(() => gameState = NBackState.gameOver);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = theme.colorScheme.primary;

    if (gameState == NBackState.gameOver) {
      return _buildGameOver(context, l10n, theme, primary);
    }

    if (gameState == NBackState.setup) {
      return _buildSetup(context, l10n, theme, isLight, primary);
    }

    return _buildGame(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nBack),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: isLight
                ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
                : [const Color(0xFF0F172A), const Color(0xFF030712)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                    ).createShader(b),
                    child: Text(
                      l10n.nBack,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.nBackDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLight ? Colors.black54 : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.nBackLevel, style: theme.textTheme.titleSmall?.copyWith(color: primary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [1, 2, 3, 4].map((n) {
                            final selected = nLevel == n;
                            return GestureDetector(
                              onTap: () => setState(() => nLevel = n),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? LinearGradient(colors: [primary, primary.withOpacity(0.6)])
                                      : null,
                                  color: selected ? null : (isLight ? Colors.black.withOpacity(0.05) : Colors.white10),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected ? primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$n-Back',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: selected ? Colors.white : (isLight ? Colors.black87 : Colors.white70),
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
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Text(
                      l10n.nBackHowTo(nLevel),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isLight ? Colors.black87 : Colors.white70,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(l10n.startGame, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final hasEnoughHistory = sequence.length > nLevel;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nBack),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                l10n.scoreLabel(score),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: isLight
                ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
                : [const Color(0xFF0F172A), const Color(0xFF030712)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currentRound / $totalRounds',
                        style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54),
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 4),
                          Text('$correctAnswers', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.greenAccent)),
                          const SizedBox(width: 12),
                          Icon(Icons.cancel, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 4),
                          Text('$mistakes', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.redAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: LinearProgressIndicator(
                    value: currentRound / totalRounds,
                    backgroundColor: isLight ? Colors.black12 : Colors.white10,
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 24),
                // N-Back label
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    '$nLevel-Back Challenge',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, i) {
                        final isActive = currentPosition == i;
                        final isFeedback = showFeedback && isActive;
                        Color cellColor;
                        if (isFeedback) {
                          cellColor = feedbackCorrect ? Colors.greenAccent : Colors.redAccent;
                        } else if (isActive) {
                          cellColor = primary;
                        } else {
                          cellColor = isLight ? Colors.black.withOpacity(0.06) : Colors.white.withOpacity(0.06);
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: cellColor.withOpacity(isActive ? 0.9 : 0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive ? cellColor : (isLight ? Colors.black12 : Colors.white12),
                              width: isActive ? 2 : 1,
                            ),
                            boxShadow: isActive
                                ? [BoxShadow(color: cellColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Answer button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedOpacity(
                    opacity: hasEnoughHistory ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: hasEnoughHistory && !showFeedback
                            ? () => _evaluateRound(true)
                            : null,
                        icon: const Icon(Icons.flash_on, size: 20),
                        label: Text(
                          l10n.nBackMatch,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hasEnoughHistory ? l10n.nBackHint : l10n.nBackWaiting(nLevel),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isLight ? Colors.black45 : Colors.white38,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, AppLocalizations l10n, ThemeData theme, Color primary) {
    final isLight = theme.brightness == Brightness.light;
    final accuracy = totalRounds > 0 ? (correctAnswers / totalRounds * 100).toInt() : 0;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: isLight
                ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
                : [const Color(0xFF0F172A), const Color(0xFF030712)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.psychology, color: primary, size: 64),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.gameOver, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.finalScorePoints(score),
                    style: theme.textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      children: [
                        _statRow(l10n.nBackAccuracy(accuracy), Icons.track_changes, Colors.greenAccent, theme),
                        const SizedBox(height: 8),
                        _statRow('$correctAnswers correct / $mistakes wrong', Icons.bar_chart, primary, theme),
                        const SizedBox(height: 8),
                        _statRow('$nLevel-Back Level', Icons.psychology, const Color(0xFF818CF8), theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.tryAgain, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.backToMenu),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
