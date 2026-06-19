import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class TypingSprintScreen extends StatefulWidget {
  const TypingSprintScreen({super.key});

  @override
  State<TypingSprintScreen> createState() => _TypingSprintScreenState();
}

enum TypingSprintState { setup, countdown, playing, gameOver }

class _TypingSprintScreenState extends State<TypingSprintScreen> {
  TypingSprintState gameState = TypingSprintState.setup;

  // Settings
  int gameDuration = 60;

  // Game state
  int timeLeft = 60;
  int score = 0;
  int wpm = 0;
  int wordsTyped = 0;
  int mistakes = 0;
  int countdown = 3;
  Timer? gameTimer;
  Timer? countdownTimer;

  // Words
  String currentWord = '';
  String typedText = '';
  bool isWrong = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const List<String> _wordList = [
    'flutter', 'dart', 'widget', 'state', 'build', 'render', 'context',
    'scaffold', 'column', 'row', 'text', 'button', 'image', 'container',
    'padding', 'margin', 'color', 'style', 'theme', 'async', 'await',
    'future', 'stream', 'list', 'map', 'string', 'integer', 'double',
    'bool', 'class', 'function', 'method', 'variable', 'constant', 'final',
    'abstract', 'extend', 'import', 'export', 'library', 'package', 'pub',
    'navigator', 'route', 'dialog', 'modal', 'snack', 'gesture', 'tap',
    'swipe', 'drag', 'scroll', 'animation', 'transition', 'curve', 'tween',
    'focus', 'keyboard', 'input', 'validation', 'form', 'submit', 'cancel',
    'refresh', 'reload', 'update', 'delete', 'create', 'read', 'write',
    'data', 'model', 'view', 'logic', 'service', 'provider', 'riverpod',
    'network', 'local', 'cache', 'storage', 'file', 'path', 'directory',
    'memory', 'brain', 'speed', 'reflex', 'focus', 'sharp', 'skill', 'power',
  ];

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      gameState = TypingSprintState.countdown;
      countdown = 3;
    });
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => countdown--);
      if (countdown <= 0) {
        t.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      gameState = TypingSprintState.playing;
      timeLeft = gameDuration;
      score = 0;
      wpm = 0;
      wordsTyped = 0;
      mistakes = 0;
      typedText = '';
      isWrong = false;
    });
    _controller.clear();
    _pickNextWord();
    _focusNode.requestFocus();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        timeLeft--;
        wpm = timeLeft < gameDuration
            ? (wordsTyped * 60 / (gameDuration - timeLeft)).round()
            : 0;
        if (timeLeft <= 0) {
          t.cancel();
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    final finalScore = score + wordsTyped * 2;
    HighScoreService.instance.saveScore('typing_sprint', finalScore);
    setState(() {
      gameState = TypingSprintState.gameOver;
      score = finalScore;
    });
  }

  void _pickNextWord() {
    final rng = Random();
    setState(() => currentWord = _wordList[rng.nextInt(_wordList.length)]);
    _controller.clear();
    typedText = '';
    isWrong = false;
  }

  void _onTextChanged(String value) {
    setState(() {
      typedText = value;
      if (value.endsWith(' ')) {
        final typed = value.trim();
        if (typed == currentWord) {
          score += currentWord.length * 2;
          wordsTyped++;
          isWrong = false;
          _pickNextWord();
        } else {
          mistakes++;
          isWrong = true;
          _controller.clear();
          typedText = '';
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => isWrong = false);
          });
        }
      } else {
        isWrong = value.isNotEmpty && !currentWord.startsWith(value);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = theme.colorScheme.primary;

    if (gameState == TypingSprintState.gameOver) {
      return _buildGameOver(context, l10n, theme, isLight, primary);
    }

    if (gameState == TypingSprintState.setup) {
      return _buildSetup(context, l10n, theme, isLight, primary);
    }

    if (gameState == TypingSprintState.countdown) {
      return _buildCountdown(context, l10n, theme, isLight, primary);
    }

    return _buildGame(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.typingSprint),
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
                      l10n.typingSprint,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.typingSprintDesc,
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
                        Text(l10n.gameDuration, style: theme.textTheme.titleSmall?.copyWith(color: primary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [30, 60, 90, 120].map((d) {
                            final selected = gameDuration == d;
                            return GestureDetector(
                              onTap: () => setState(() => gameDuration = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 64,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? LinearGradient(colors: [primary, primary.withOpacity(0.6)])
                                      : null,
                                  color: selected ? null : (isLight ? Colors.black.withOpacity(0.05) : Colors.white10),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: selected ? primary : Colors.transparent, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${d}s',
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startCountdown,
                      icon: const Icon(Icons.keyboard),
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

  Widget _buildCountdown(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.getReady, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$countdown',
                  key: ValueKey(countdown),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 96,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    final dangerColor = timeLeft <= 10 ? Colors.redAccent : primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.typingSprint),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                  color: dangerColor,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(l10n.timeLabel(timeLeft)),
              ),
            ),
          ),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stats bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statChip('$wpm WPM', Icons.speed, primary, theme, isLight),
                      _statChip('$wordsTyped Words', Icons.check, Colors.greenAccent, theme, isLight),
                      _statChip('$mistakes Errors', Icons.close, Colors.redAccent, theme, isLight),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timeLeft / gameDuration,
                    backgroundColor: isLight ? Colors.black12 : Colors.white10,
                    color: dangerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 40),
                  // Current word display
                  _buildGlassCard(
                    isLight: isLight,
                    primary: isWrong ? Colors.redAccent : primary,
                    child: Column(
                      children: [
                        Text(
                          l10n.typingSprintType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.black45 : Colors.white38,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Highlighted word
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(currentWord.length, (i) {
                            final typed = i < typedText.length;
                            final correct = typed && typedText[i] == currentWord[i];
                            final wrong = typed && typedText[i] != currentWord[i];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: typed ? (correct ? Colors.greenAccent : Colors.redAccent) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                currentWord[i],
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: wrong
                                      ? Colors.redAccent
                                      : (correct
                                          ? Colors.greenAccent
                                          : (isLight ? Colors.black54 : Colors.white54)),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        // Input field
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onTextChanged,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isWrong ? Colors.redAccent : (isLight ? Colors.black87 : Colors.white),
                            fontFamily: 'monospace',
                          ),
                          decoration: InputDecoration(
                            hintText: '...',
                            filled: true,
                            fillColor: isLight ? Colors.black.withOpacity(0.04) : Colors.white.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isWrong ? Colors.redAccent : primary.withOpacity(0.4),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isWrong ? Colors.redAccent : primary,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isWrong ? Colors.redAccent.withOpacity(0.5) : primary.withOpacity(0.2),
                              ),
                            ),
                          ),
                          autofocus: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.typingSprintHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLight ? Colors.black38 : Colors.white38,
                    ),
                    textAlign: TextAlign.center,
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.keyboard, color: primary, size: 64),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.timeUp, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
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
                        _statRowFull('$wpm WPM', Icons.speed, primary, theme),
                        const SizedBox(height: 8),
                        _statRowFull('$wordsTyped words typed', Icons.check_circle, Colors.greenAccent, theme),
                        const SizedBox(height: 8),
                        _statRowFull('$mistakes mistakes', Icons.cancel, Colors.redAccent, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => gameState = TypingSprintState.setup),
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

  Widget _statChip(String label, IconData icon, Color color, ThemeData theme, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statRowFull(String label, IconData icon, Color color, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
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
}
