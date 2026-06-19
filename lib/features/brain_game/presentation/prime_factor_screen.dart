import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class PrimeFactorScreen extends StatefulWidget {
  const PrimeFactorScreen({super.key});

  @override
  State<PrimeFactorScreen> createState() => _PrimeFactorScreenState();
}

enum PrimeFactorState { setup, playing, gameOver }

class _PrimeFactorScreenState extends State<PrimeFactorScreen> with TickerProviderStateMixin {
  PrimeFactorState gameState = PrimeFactorState.setup;

  int score = 0;
  int level = 1;
  int lives = 3;
  int timeLeft = 40;
  Timer? roundTimer;

  // Prime Settings
  double primeCountOption = 4.0; // Slider works with double
  final List<int> _allPrimes = [
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
    31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
    73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
    127, 131, 137, 139, 149, 151, 157, 163, 167, 173
  ];
  List<int> get activePrimes => _allPrimes.sublist(0, primeCountOption.round());

  // Question State
  BigInt originalNumber = BigInt.one;
  BigInt currentNumber = BigInt.one;
  List<int> foundFactors = [];
  List<int> currentOptions = []; // Active prime factors displayed as buttons
  bool showFeedback = false;
  bool feedbackCorrect = false;
  int? lastSelectedPrime;

  late AnimationController _shakeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      gameState = PrimeFactorState.playing;
      score = 0;
      level = 1;
      lives = 3;
    });
    _nextNumber();
  }

  void _nextNumber() {
    roundTimer?.cancel();
    final rng = Random();

    // Determine the number of prime factors to multiply based on level
    final factorCount = 3 + (level ~/ 2) + rng.nextInt(2);
    final primes = activePrimes;

    BigInt num = BigInt.one;
    for (int i = 0; i < factorCount; i++) {
      final prime = primes[rng.nextInt(primes.length)];
      // Prevent numbers from becoming too absurdly large (e.g. max 15 digits)
      if (num > BigInt.from(100000000000000)) break;
      num *= BigInt.from(prime);
    }

    // Determine active options for this round
    final uniqueFactors = <int>{};
    BigInt tempVal = num;
    for (final p in primes) {
      final pBig = BigInt.from(p);
      if (tempVal % pBig == BigInt.zero) {
        uniqueFactors.add(p);
      }
    }

    final optionPrimes = <int>{...uniqueFactors};
    final distractorPool = primes.where((p) => !uniqueFactors.contains(p)).toList();
    distractorPool.shuffle(rng);

    final targetOptionCount = min(primes.length, 8);
    while (optionPrimes.length < targetOptionCount && distractorPool.isNotEmpty) {
      optionPrimes.add(distractorPool.removeLast());
    }

    final displayedOptions = optionPrimes.toList()..sort();

    setState(() {
      originalNumber = num;
      currentNumber = num;
      foundFactors = [];
      currentOptions = displayedOptions;
      showFeedback = false;
      timeLeft = max(15, 45 - level * 3);
    });

    _startTimer();
  }

  void _startTimer() {
    roundTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        t.cancel();
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    setState(() {
      lives--;
      _shakeController.forward(from: 0);
    });

    if (lives <= 0) {
      _endGame();
    } else {
      _nextNumber();
    }
  }

  void _selectPrime(int prime) {
    if (showFeedback || gameState != PrimeFactorState.playing) return;

    final isFactor = currentNumber % BigInt.from(prime) == BigInt.zero;

    setState(() {
      lastSelectedPrime = prime;
      showFeedback = true;
      feedbackCorrect = isFactor;
    });

    if (isFactor) {
      _scaleController.forward(from: 0.5).then((_) => _scaleController.reverse());
      setState(() {
        currentNumber = currentNumber ~/ BigInt.from(prime);
        foundFactors.add(prime);
        score += level * 5;
      });

      // If fully factorized
      if (currentNumber == BigInt.one) {
        roundTimer?.cancel();
        score += level * 20; // Bonus points for full factorization
        Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            level++;
          });
          _nextNumber();
        });
      } else {
        // Reset feedback so they can keep factorizing the same number
        Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() {
            showFeedback = false;
            lastSelectedPrime = null;
          });
        });
      }
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        lives--;
      });

      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        if (lives <= 0) {
          _endGame();
        } else {
          setState(() {
            showFeedback = false;
            lastSelectedPrime = null;
          });
        }
      });
    }
  }

  void _endGame() {
    roundTimer?.cancel();
    HighScoreService.instance.saveScore('prime_factor', score);
    setState(() => gameState = PrimeFactorState.gameOver);
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

    if (gameState == PrimeFactorState.gameOver) {
      return _buildGameOver(context, l10n, theme, isLight, primary);
    }
    if (gameState == PrimeFactorState.setup) {
      return _buildSetup(context, l10n, theme, isLight, primary);
    }
    return _buildGame(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.primeFactor),
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
                      l10n.primeFactor,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.primeFactorDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLight ? Colors.black54 : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Allowed Primes Slider Card
                  _buildGlassCard(
                    isLight: isLight,
                    primary: primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.primeFactorMaxPrime,
                              style: theme.textTheme.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${primeCountOption.round()} Primes',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: primeCountOption,
                          min: 4,
                          max: 40,
                          divisions: 36,
                          activeColor: primary,
                          onChanged: (val) {
                            setState(() {
                              primeCountOption = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.calculate),
                      label: Text(l10n.primeFactorStart, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildGame(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.primeFactor),
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
                    value: timeLeft / max(15, 45 - level * 3),
                    backgroundColor: isLight ? Colors.black12 : Colors.white10,
                    color: timeLeft <= 5 ? Colors.redAccent : primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 32),

                  // Giant Number Card
                  ScaleTransition(
                    scale: _scaleController,
                    child: _buildGlassCard(
                      isLight: isLight,
                      primary: primary,
                      child: Column(
                        children: [
                          Text(
                            'Factorize This Number',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isLight ? Colors.black45 : Colors.white38,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              '$currentNumber',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: currentNumber == BigInt.one ? Colors.greenAccent : primary,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${l10n.primeFactorFound}${foundFactors.isEmpty ? "-" : foundFactors.join(" × ")}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: isLight ? Colors.black54 : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Prime Options Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: currentOptions.map((prime) {
                      final isSelected = showFeedback && lastSelectedPrime == prime;
                      Color btnColor = isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.07);
                      Color borderColor = primary.withOpacity(0.2);

                      if (isSelected) {
                        btnColor = feedbackCorrect ? Colors.greenAccent.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3);
                        borderColor = feedbackCorrect ? Colors.greenAccent : Colors.redAccent;
                      }

                      return GestureDetector(
                        onTap: showFeedback ? null : () => _selectPrime(prime),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '$prime',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? (feedbackCorrect ? Colors.greenAccent : Colors.redAccent)
                                    : (isLight ? Colors.black87 : Colors.white),
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
                          onPressed: () => setState(() => gameState = PrimeFactorState.setup),
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
