import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class WordMemoryScreen extends StatefulWidget {
  const WordMemoryScreen({super.key});

  @override
  State<WordMemoryScreen> createState() => _WordMemoryScreenState();
}

enum WordMemoryState { setup, memorizing, recalling, result, gameOver }

class _WordMemoryScreenState extends State<WordMemoryScreen> with SingleTickerProviderStateMixin {
  WordMemoryState gameState = WordMemoryState.setup;
  int score = 0;
  int level = 1;
  int memorizeSeconds = 5;
  int timeLeft = 5;
  Timer? memorizeTimer;
  late AnimationController _flashController;

  List<String> wordBank = [];
  List<String> shownWords = [];
  List<String> recallOptions = [];
  Map<String, bool?> userSelections = {}; // word -> selected?
  bool showResults = false;

  static const List<String> _allWords = [
    'Apple', 'Bridge', 'Cloud', 'Dream', 'Eagle', 'Forest', 'Galaxy', 'Honey',
    'Island', 'Journey', 'Kingdom', 'Lantern', 'Mirror', 'Night', 'Ocean',
    'Prism', 'Quartz', 'River', 'Shadow', 'Thunder', 'Universe', 'Violet',
    'Whisper', 'Xenon', 'Yellow', 'Zephyr', 'Amber', 'Blaze', 'Crystal',
    'Dagger', 'Eclipse', 'Flame', 'Ghost', 'Horizon', 'Illusion', 'Jewel',
    'Knight', 'Lotus', 'Meteor', 'Nebula', 'Obsidian', 'Phoenix', 'Quest',
    'Raven', 'Sapphire', 'Tidal', 'Umber', 'Vortex', 'Wave', 'Xylem',
  ];

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    memorizeTimer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  int get _wordCount => min(4 + level, 10);

  void _startGame() {
    final rng = Random();
    final shuffled = List<String>.from(_allWords)..shuffle(rng);
    final shown = shuffled.take(_wordCount).toList();
    final distractors = shuffled.skip(_wordCount).take(_wordCount).toList();
    final options = [...shown, ...distractors]..shuffle(rng);

    setState(() {
      gameState = WordMemoryState.memorizing;
      shownWords = shown;
      recallOptions = options;
      userSelections = {};
      showResults = false;
      timeLeft = memorizeSeconds;
    });

    _startMemorizeTimer();
  }

  void _startMemorizeTimer() {
    memorizeTimer?.cancel();
    memorizeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        t.cancel();
        setState(() => gameState = WordMemoryState.recalling);
      }
    });
  }

  void _toggleWord(String word) {
    if (showResults) return;
    setState(() {
      if (userSelections.containsKey(word)) {
        userSelections.remove(word);
      } else {
        userSelections[word] = true;
      }
    });
  }

  void _submitRecall() {
    memorizeTimer?.cancel();
    final shownSet = shownWords.toSet();
    int correct = 0;
    int wrong = 0;

    for (final word in recallOptions) {
      final selected = userSelections.containsKey(word);
      final wasShown = shownSet.contains(word);
      if (selected == wasShown) correct++;
      else wrong++;
    }

    final roundScore = max(0, correct * 10 - wrong * 5);
    setState(() {
      score += roundScore;
      showResults = true;
    });

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (wrong > _wordCount ~/ 2) {
        HighScoreService.instance.saveScore('word_memory', score);
        setState(() => gameState = WordMemoryState.gameOver);
      } else {
        setState(() => level++);
        _startGame();
      }
    });
  }

  Color _wordChipColor(String word, bool isLight, Color primary) {
    final selected = userSelections.containsKey(word);
    if (!showResults) {
      return selected ? primary.withOpacity(0.25) : (isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.07));
    }
    final wasShown = shownWords.contains(word);
    if (wasShown && selected) return Colors.greenAccent.withOpacity(0.3);
    if (wasShown && !selected) return Colors.orangeAccent.withOpacity(0.3);
    if (!wasShown && selected) return Colors.redAccent.withOpacity(0.3);
    return isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.04);
  }

  Color _wordChipBorder(String word, bool isLight, Color primary) {
    final selected = userSelections.containsKey(word);
    if (!showResults) {
      return selected ? primary : primary.withOpacity(0.2);
    }
    final wasShown = shownWords.contains(word);
    if (wasShown && selected) return Colors.greenAccent;
    if (wasShown && !selected) return Colors.orangeAccent;
    if (!wasShown && selected) return Colors.redAccent;
    return primary.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = theme.colorScheme.primary;

    if (gameState == WordMemoryState.gameOver) {
      return _buildGameOver(context, l10n, theme, isLight, primary);
    }
    if (gameState == WordMemoryState.setup) {
      return _buildSetup(context, l10n, theme, isLight, primary);
    }
    if (gameState == WordMemoryState.memorizing) {
      return _buildMemorize(context, l10n, theme, isLight, primary);
    }
    return _buildRecall(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wordMemory), backgroundColor: Colors.transparent, elevation: 0),
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
                      l10n.wordMemory,
                      style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.wordMemoryDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildGlassCard(
                    isLight: isLight, primary: primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.memorizeTime, style: theme.textTheme.titleSmall?.copyWith(color: primary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [3, 5, 8, 12].map((s) {
                            final sel = memorizeSeconds == s;
                            return GestureDetector(
                              onTap: () => setState(() => memorizeSeconds = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: sel ? LinearGradient(colors: [primary, primary.withOpacity(0.6)]) : null,
                                  color: sel ? null : (isLight ? Colors.black.withOpacity(0.05) : Colors.white10),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: sel ? primary : Colors.transparent, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${s}s',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: sel ? Colors.white : (isLight ? Colors.black87 : Colors.white70),
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
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.menu_book),
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

  Widget _buildMemorize(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wordMemory), backgroundColor: Colors.transparent, elevation: 0),
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
                  Text(
                    l10n.memorizeColors,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.wordMemoryMemorizeHint,
                    style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Timer bar
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 0.0),
                    duration: Duration(seconds: memorizeSeconds),
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: isLight ? Colors.black12 : Colors.white10,
                      color: value < 0.3 ? Colors.redAccent : primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$timeLeft s',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: timeLeft <= 3 ? Colors.redAccent : primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: shownWords.map((word) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [primary.withOpacity(0.3), primary.withOpacity(0.1)]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primary.withOpacity(0.4), width: 1.5),
                        ),
                        child: Text(
                          word,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLight ? Colors.black87 : Colors.white,
                          ),
                        ),
                      )).toList(),
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

  Widget _buildRecall(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wordMemory),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(l10n.scoreLabel(score), style: theme.textTheme.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
                  Text(
                    showResults ? l10n.wordMemoryResults : l10n.wordMemoryRecallHint,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.wordMemoryRecallDesc(_wordCount),
                    style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    isLight: isLight, primary: primary,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: recallOptions.map((word) {
                        final selected = userSelections.containsKey(word);
                        return GestureDetector(
                          onTap: () => _toggleWord(word),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _wordChipColor(word, isLight, primary),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _wordChipBorder(word, isLight, primary), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selected) ...[
                                  const Icon(Icons.check, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  word,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isLight ? Colors.black87 : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!showResults)
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _submitRecall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: Text(l10n.submitAnswer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  if (showResults)
                    _buildResultLegend(theme, isLight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultLegend(ThemeData theme, bool isLight) {
    return Column(
      children: [
        _legendRow('Correct recall', Colors.greenAccent, theme),
        const SizedBox(height: 4),
        _legendRow('Missed word', Colors.orangeAccent, theme),
        const SizedBox(height: 4),
        _legendRow('False positive', Colors.redAccent, theme),
      ],
    );
  }

  Widget _legendRow(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: primary.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(Icons.menu_book, color: primary, size: 64),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.gameOver, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(l10n.finalScorePoints(score), style: theme.textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    isLight: isLight, primary: primary,
                    child: Column(
                      children: [
                        _statRow('Level $level reached', Icons.trending_up, primary, theme),
                        const SizedBox(height: 8),
                        _statRow('$_wordCount words at peak', Icons.text_fields, const Color(0xFF818CF8), theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() { gameState = WordMemoryState.setup; score = 0; level = 1; });
                      },
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
          colors: isLight
              ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
              : [const Color(0xFF0F172A), const Color(0xFF030712)],
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
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
