import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class PatternFoldScreen extends StatefulWidget {
  const PatternFoldScreen({super.key});

  @override
  State<PatternFoldScreen> createState() => _PatternFoldScreenState();
}

enum PatternFoldState { setup, playing, gameOver }

/// Represents a simple net pattern of a cube.
/// A cube net is composed of 6 squares arranged in an unfolded pattern.
/// We encode each net as a list of (row, col) relative positions of the 6 faces.
/// When folded, the center face becomes the front, and we define which face appears
/// on each side based on the net layout.
class CubeNet {
  final List<List<int>> cells; // [row, col] positions
  final Color Function(int index) colorAt;
  final String label;

  const CubeNet({required this.cells, required this.colorAt, required this.label});
}

class _PatternFoldScreenState extends State<PatternFoldScreen> with SingleTickerProviderStateMixin {
  PatternFoldState gameState = PatternFoldState.setup;
  int score = 0;
  int level = 1;
  int lives = 3;
  int timeLeft = 30;
  Timer? roundTimer;
  late AnimationController _scaleController;

  // For each question: we show a net and ask which 3D cube it folds into
  List<Color> _netColors = [];
  List<List<Color>> _cubeOptions = [];
  int _correctIndex = 0;
  int? _selectedIndex;
  bool showFeedback = false;
  bool feedbackCorrect = false;

  // Color palette for faces
  static const List<Color> _faceColors = [
    Color(0xFF38BDF8), // cyan
    Color(0xFFEC4899), // pink
    Color(0xFF10B981), // green
    Color(0xFFFACC15), // yellow
    Color(0xFF8B5CF6), // purple
    Color(0xFFF97316), // orange
  ];

  // Net layouts [row, col] for each of the 6 faces
  // We use a T-cross net as a standard: center=(1,1), up=(0,1), left=(1,0), right=(1,2), down=(2,1), far=(3,1)
  static const List<List<int>> _standardNet = [
    [0, 1], // top
    [1, 0], // left
    [1, 1], // front (center)
    [1, 2], // right
    [2, 1], // bottom
    [3, 1], // back
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      gameState = PatternFoldState.playing;
      score = 0;
      level = 1;
      lives = 3;
    });
    _nextQuestion();
  }

  void _nextQuestion() {
    roundTimer?.cancel();
    final rng = Random();

    // Assign unique colors to each face randomly
    final colors = List<Color>.from(_faceColors)..shuffle(rng);
    // Net colors correspond to: top, left, front, right, bottom, back (matching _standardNet order)

    // The "correct" cube option shows faces in a rotated isometric-like view:
    // We show: Front, Right, Top in a 3-face L-shape layout
    // front = colors[2], right = colors[3], top = colors[0]
    final correctFaces = [colors[2], colors[3], colors[0]]; // front, right, top

    // Generate 3 wrong options by swapping/replacing face colors
    final wrongs = <List<Color>>[];
    while (wrongs.length < 3) {
      final swapA = rng.nextInt(3);
      final swapB = rng.nextInt(3);
      if (swapA == swapB) continue;
      final wrongFaces = List<Color>.from(correctFaces);
      // Either swap two visible faces or replace one with a different face
      if (rng.nextBool()) {
        final tmp = wrongFaces[swapA];
        wrongFaces[swapA] = wrongFaces[swapB];
        wrongFaces[swapB] = tmp;
      } else {
        wrongFaces[swapA] = colors[3 + rng.nextInt(3)]; // use back/bottom/left
      }
      if (wrongFaces.join() != correctFaces.join()) {
        wrongs.add(wrongFaces);
      }
    }

    final correctIdx = rng.nextInt(4);
    final opts = List<List<Color>>.from(wrongs);
    opts.insert(correctIdx, correctFaces);

    setState(() {
      _netColors = colors;
      _cubeOptions = opts;
      _correctIndex = correctIdx;
      _selectedIndex = null;
      showFeedback = false;
      timeLeft = max(10, 30 - level * 3);
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

  void _handleAnswer(int? index) {
    roundTimer?.cancel();
    final correct = index == _correctIndex;
    setState(() {
      _selectedIndex = index ?? -1;
      showFeedback = true;
      feedbackCorrect = correct;
      if (correct) {
        score += level * 10;
        level++;
      } else {
        lives--;
      }
    });

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (lives <= 0) {
        HighScoreService.instance.saveScore('pattern_fold', score);
        setState(() => gameState = PatternFoldState.gameOver);
      } else {
        _nextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primary = theme.colorScheme.primary;

    if (gameState == PatternFoldState.gameOver) return _buildGameOver(context, l10n, theme, isLight, primary);
    if (gameState == PatternFoldState.setup) return _buildSetup(context, l10n, theme, isLight, primary);
    return _buildGame(context, l10n, theme, isLight, primary);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isLight, Color primary) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.patternFold), backgroundColor: Colors.transparent, elevation: 0),
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
                    child: Text(
                      l10n.patternFold,
                      style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.patternFoldDesc, style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  _buildGlassCard(isLight: isLight, primary: primary, child: Column(
                    children: [
                      Icon(Icons.view_in_ar, color: primary, size: 48),
                      const SizedBox(height: 12),
                      Text(l10n.patternFoldHowTo, style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black87 : Colors.white70, height: 1.6), textAlign: TextAlign.center),
                    ],
                  )),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.view_in_ar),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patternFold),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timeLeft / max(10, 30 - level * 3),
                    backgroundColor: isLight ? Colors.black12 : Colors.white10,
                    color: timeLeft <= 5 ? Colors.redAccent : primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.patternFoldInstruction, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  // Net display
                  _buildGlassCard(
                    isLight: isLight, primary: primary,
                    child: Column(
                      children: [
                        Text(l10n.patternFoldNet, style: theme.textTheme.bodySmall?.copyWith(color: isLight ? Colors.black45 : Colors.white38, letterSpacing: 1.2)),
                        const SizedBox(height: 16),
                        _buildNet(isLight, primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.patternFoldPickCube, style: theme.textTheme.bodyMedium?.copyWith(color: isLight ? Colors.black54 : Colors.white54)),
                  const SizedBox(height: 12),
                  // Cube options in 2x2 grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(_cubeOptions.length, (i) {
                      final opt = _cubeOptions[i];
                      final isSelected = _selectedIndex == i;
                      final isCorrect = i == _correctIndex;
                      Color borderColor = primary.withOpacity(0.25);
                      if (showFeedback && isCorrect) borderColor = Colors.greenAccent;
                      if (showFeedback && isSelected && !feedbackCorrect) borderColor = Colors.redAccent;
                      return GestureDetector(
                        onTap: showFeedback ? null : () => _handleAnswer(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isLight ? Colors.white.withOpacity(0.85) : const Color(0xFF1E293B).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: isSelected || (showFeedback && isCorrect)
                                ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 12)]
                                : null,
                          ),
                          child: Center(child: _buildIsoCube(opt, 52)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a flat net of the cube using colored squares
  Widget _buildNet(bool isLight, Color primary) {
    const cellSize = 32.0;
    const maxRow = 4;
    const maxCol = 3;
    return SizedBox(
      width: maxCol * (cellSize + 4),
      height: maxRow * (cellSize + 4),
      child: Stack(
        children: List.generate(6, (i) {
          final pos = _standardNet[i];
          final color = _netColors[i];
          return Positioned(
            top: pos[0] * (cellSize + 4),
            left: pos[1] * (cellSize + 4),
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Draws a simple isometric cube with 3 visible faces
  Widget _buildIsoCube(List<Color> faces, double size) {
    // faces[0] = front, faces[1] = right, faces[2] = top
    return CustomPaint(
      size: Size(size * 1.6, size * 1.4),
      painter: _IsoCubePainter(front: faces[0], right: faces[1], top: faces[2]),
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
                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: primary.withOpacity(0.15), shape: BoxShape.circle), child: Icon(Icons.view_in_ar, color: primary, size: 64)),
                  const SizedBox(height: 24),
                  Text(l10n.gameOver, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(l10n.finalScorePoints(score), style: theme.textTheme.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildGlassCard(isLight: isLight, primary: primary, child: Column(children: [
                    _statRow('Level $level reached', Icons.trending_up, primary, theme),
                    const SizedBox(height: 8),
                    _statRow('$lives lives remaining', Icons.favorite, Colors.redAccent, theme),
                  ])),
                  const SizedBox(height: 32),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(
                    onPressed: _startGame,
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

class _IsoCubePainter extends CustomPainter {
  final Color front;
  final Color right;
  final Color top;

  const _IsoCubePainter({required this.front, required this.right, required this.top});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.55;
    final dx = w * 0.3;
    final dy = h * 0.22;
    final dz = h * 0.38;

    // Top face
    final topPath = Path()
      ..moveTo(cx, cy - dz)
      ..lineTo(cx + dx, cy - dz + dy)
      ..lineTo(cx, cy - dz + dy * 2)
      ..lineTo(cx - dx, cy - dz + dy)
      ..close();
    canvas.drawPath(topPath, Paint()..color = top);
    canvas.drawPath(topPath, Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1);

    // Left (front) face
    final frontPath = Path()
      ..moveTo(cx - dx, cy - dz + dy)
      ..lineTo(cx, cy - dz + dy * 2)
      ..lineTo(cx, cy + dz)
      ..lineTo(cx - dx, cy + dz - dy)
      ..close();
    canvas.drawPath(frontPath, Paint()..color = front);
    canvas.drawPath(frontPath, Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1);

    // Right face
    final rightPath = Path()
      ..moveTo(cx, cy - dz + dy * 2)
      ..lineTo(cx + dx, cy - dz + dy)
      ..lineTo(cx + dx, cy + dz - dy)
      ..lineTo(cx, cy + dz)
      ..close();
    final rightPaint = Paint()..color = right;
    canvas.drawPath(rightPath, rightPaint);
    canvas.drawPath(rightPath, Paint()..color = Colors.white.withOpacity(0.08)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_IsoCubePainter oldDelegate) =>
      oldDelegate.front != front || oldDelegate.right != right || oldDelegate.top != top;
}
