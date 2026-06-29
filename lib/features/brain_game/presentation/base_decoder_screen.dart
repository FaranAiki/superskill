import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class BaseDecoderScreen extends StatefulWidget {
  const BaseDecoderScreen({super.key});

  @override
  State<BaseDecoderScreen> createState() => _BaseDecoderScreenState();
}

enum BaseDecoderDirection { baseToDecimal, decimalToBase, mixed }
enum ActiveBase { binary, octal, hexadecimal, mixed }
enum BaseDecoderState { setup, playing, gameOver }

class _BaseDecoderScreenState extends State<BaseDecoderScreen> with SingleTickerProviderStateMixin {
  BaseDecoderDirection direction = BaseDecoderDirection.baseToDecimal;
  ActiveBase activeBase = ActiveBase.binary;
  BaseDecoderState gameState = BaseDecoderState.setup;

  int score = 0;
  int level = 1;
  int lives = 3;
  int timeLeft = 20;
  Timer? roundTimer;
  late AnimationController _shakeController;

  // Question State
  String questionDisplay = '';
  String targetBaseLabel = '';
  List<String> options = [];
  String correctAnswer = '';
  String? selectedAnswer;
  bool showFeedback = false;
  bool feedbackCorrect = false;
  String questionBase = '2';
  bool isBaseToDec = true;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      gameState = BaseDecoderState.playing;
      score = 0;
      level = 1;
      lives = 3;
    });
    _nextQuestion();
  }

  int get _maxValue => min(15 + level * 16, 255); // max value scales from 31 up to 255

  void _nextQuestion() {
    roundTimer?.cancel();
    final rng = Random();
    final maxVal = _maxValue;
    final value = rng.nextInt(maxVal - 1) + 1; // decimal value to convert

    // 1. Determine active base for this question
    int baseVal;
    String baseName;
    switch (activeBase) {
      case ActiveBase.binary:
        baseVal = 2;
        baseName = '2';
        break;
      case ActiveBase.octal:
        baseVal = 8;
        baseName = '8';
        break;
      case ActiveBase.hexadecimal:
        baseVal = 16;
        baseName = '16';
        break;
      case ActiveBase.mixed:
        final pick = rng.nextInt(3);
        if (pick == 0) {
          baseVal = 2;
          baseName = '2';
        } else if (pick == 1) {
          baseVal = 8;
          baseName = '8';
        } else {
          baseVal = 16;
          baseName = '16';
        }
        break;
    }

    // 2. Determine conversion direction for this question
    bool isBaseToDec;
    if (direction == BaseDecoderDirection.mixed) {
      isBaseToDec = rng.nextBool();
    } else {
      isBaseToDec = direction == BaseDecoderDirection.baseToDecimal;
    }

    String formattedInBase(int val) {
      String str = val.toRadixString(baseVal);
      if (baseVal == 2) {
        // Pad binary values to standard lengths (4 or 8 bits) for better aesthetic
        final pad = val < 16 ? 4 : 8;
        str = str.padLeft(pad, '0');
      } else if (baseVal == 16) {
        str = str.toUpperCase();
      }
      return str;
    }

    String qDisplay;
    String label;
    String correctAns;
    final opts = <String>{};

    if (isBaseToDec) {
      qDisplay = formattedInBase(value);
      label = 'Base $baseName → Decimal';
      correctAns = '$value';
      opts.add(correctAns);

      while (opts.length < 4) {
        final dist = value + (rng.nextInt(12) + 1) * (rng.nextBool() ? 1 : -1);
        if (dist > 0 && dist <= maxVal) {
          opts.add('$dist');
        }
      }
    } else {
      qDisplay = '$value';
      label = 'Decimal → Base $baseName';
      correctAns = formattedInBase(value);
      opts.add(correctAns);

      while (opts.length < 4) {
        final distVal = value + (rng.nextInt(12) + 1) * (rng.nextBool() ? 1 : -1);
        if (distVal > 0 && distVal <= maxVal) {
          opts.add(formattedInBase(distVal));
        }
      }
    }

    setState(() {
      questionDisplay = qDisplay;
      targetBaseLabel = label;
      correctAnswer = correctAns;
      options = opts.toList()..shuffle();
      selectedAnswer = null;
      showFeedback = false;
      timeLeft = max(8, 20 - level * 2);
      this.isBaseToDec = isBaseToDec;
      questionBase = baseName;
    });

    roundTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        t.cancel();
        _handleAnswer(null);
      }
    });
  }

  void _handleAnswer(String? answer) {
    roundTimer?.cancel();
    final correct = answer == correctAnswer;
    setState(() {
      selectedAnswer = answer ?? '';
      showFeedback = true;
      feedbackCorrect = correct;
      if (correct) {
        score += level * 10;
        level++;
      } else {
        lives--;
        _shakeController.forward(from: 0);
      }
    });

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (lives <= 0) {
        HighScoreService.instance.saveScore('base_decoder', score);
        setState(() => gameState = BaseDecoderState.gameOver);
      } else {
        _nextQuestion();
      }
    });
  }

  Color _optionColor(String opt, bool isLight, Color primary) {
    if (!showFeedback) return isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.07);
    if (opt == correctAnswer) return Colors.greenAccent.withOpacity(0.3);
    if (opt == selectedAnswer && !feedbackCorrect) return Colors.redAccent.withOpacity(0.3);
    return isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.07);
  }

  Color _optionBorderColor(String opt, bool isLight, Color primary) {
    if (!showFeedback) return primary.withOpacity(0.2);
    if (opt == correctAnswer) return Colors.greenAccent;
    if (opt == selectedAnswer && !feedbackCorrect) return Colors.redAccent;
    return primary.withOpacity(0.1);
  }

  BoxDecoration _bgDecoration(bool isLight) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0, -0.5),
        radius: 1.2,
        colors: isLight
            ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
            : [const Color(0xFF0F172A), const Color(0xFF030712)],
      ),
    );
  }

  Widget _buildGlassCard({required bool isLight, required Color primary, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.85) : const Color(0xFF1E293B).withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = theme.colorScheme.primary;

    if (gameState == BaseDecoderState.gameOver) {
      return _buildGameOver(context, l10n, theme, isLight, primary);
    }
    if (gameState == BaseDecoderState.setup) {
      return _buildSetup(context, l10n, theme, isLight, primary);
    }
    return _buildGame(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.baseDecoder),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                    ).createShader(b),
                    child: Text(
                      l10n.baseDecoder,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.baseDecoderDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLight ? Colors.black54 : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Option Card 1: Conversion Direction
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.baseDecoderMode, style: theme.textTheme.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _modeButton('X → 10', BaseDecoderDirection.baseToDecimal, theme, primary),
                            const SizedBox(width: 8),
                            _modeButton('10 → X', BaseDecoderDirection.decimalToBase, theme, primary),
                            const SizedBox(width: 8),
                            _modeButton(l10n.mixed, BaseDecoderDirection.mixed, theme, primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option Card 2: Select Bases
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.baseDecoderSelectBase, style: theme.textTheme.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _baseButton('Base 2', ActiveBase.binary, theme, primary),
                            _baseButton('Base 8', ActiveBase.octal, theme, primary),
                            _baseButton('Base 16', ActiveBase.hexadecimal, theme, primary),
                            _baseButton(l10n.mixed, ActiveBase.mixed, theme, primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.code),
                      label: Text(l10n.startGame, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
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

  Widget _modeButton(String label, BaseDecoderDirection dir, ThemeData theme, Color primary) {
    final sel = direction == dir;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => direction = dir),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? primary.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? primary : primary.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: sel ? primary : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _baseButton(String label, ActiveBase b, ThemeData theme, Color primary) {
    final sel = activeBase == b;
    return GestureDetector(
      onTap: () => setState(() => activeBase = b),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? primary.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? primary : primary.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: sel ? primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildGame(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.baseDecoder),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                l10n.scoreLabel(score),
                style: theme.textTheme.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: _bgDecoration(isLight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          3,
                          (i) => Icon(
                            i < lives ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                            size: 22,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level $level',
                          style: theme.textTheme.bodySmall?.copyWith(color: primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timeLeft / max(8, 20 - level * 2),
                    backgroundColor: isLight ? Colors.black12 : Colors.white10,
                    color: timeLeft <= 5 ? Colors.redAccent : primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 32),

                  // Question Card
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      children: [
                        Text(
                          targetBaseLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.black45 : Colors.white38,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            key: ValueKey(questionDisplay),
                            questionDisplay,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              color: primary,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isBaseToDec ? l10n.baseDecoderConvertToDecimal : l10n.baseDecoderConvertToBase(questionBase),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.black38 : Colors.white38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Options
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                    physics: const NeverScrollableScrollPhysics(),
                    children: options.map((opt) {
                      return GestureDetector(
                        onTap: showFeedback ? null : () => _handleAnswer(opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _optionColor(opt, isLight, primary),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _optionBorderColor(opt, isLight, primary), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              opt,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: showFeedback && opt == correctAnswer
                                    ? Colors.greenAccent
                                    : (showFeedback && opt == selectedAnswer && !feedbackCorrect
                                        ? Colors.redAccent
                                        : (isLight ? Colors.black87 : Colors.white)),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.sports_score, size: 80, color: primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.gameOver,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      children: [
                        Text(l10n.yourFinalScore, style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54)),
                        const SizedBox(height: 8),
                        Text(
                          '$score',
                          style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => gameState = BaseDecoderState.setup),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(l10n.backToMenu),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(l10n.playAgain),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
