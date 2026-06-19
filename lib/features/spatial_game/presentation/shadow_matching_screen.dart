import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class ShadowMatchingScreen extends StatefulWidget {
  const ShadowMatchingScreen({super.key});

  @override
  State<ShadowMatchingScreen> createState() => _ShadowMatchingScreenState();
}

class _ShadowMatchingScreenState extends State<ShadowMatchingScreen> with TickerProviderStateMixin {
  int score = 0;
  int currentLevel = 1;
  int lives = 3;
  bool isGameOver = false;
  int highScore = 0;

  // Selected light direction for this round
  late String lightSource; // 'Top', 'Front', 'Side'
  late int correctIndex;
  int? selectedIndex;
  bool answered = false;

  // 3D Model rotation angles (continuously updated via ticker)
  double angleX = 0.5;
  double angleY = 0.6;
  late AnimationController _rotationController;
  bool _isAutoRotating = true;
  Timer? _resumeAutoRotationTimer;

  // Current block figure
  late List<v.Vector3> currentFigure;
  late List<List<List<bool>>> optionsGrids; // 4 options, each 3x3 grid

  // Defined figures (compositions of 3D unit blocks)
  final List<List<v.Vector3>> figures = [
    // 1. L-shape
    [
      v.Vector3(0, 0, 0), v.Vector3(1, 0, 0), v.Vector3(2, 0, 0),
      v.Vector3(0, 1, 0), v.Vector3(0, 2, 0), v.Vector3(0, 0, 1)
    ],
    // 2. T-shape
    [
      v.Vector3(0, 0, 0), v.Vector3(1, 0, 0), v.Vector3(2, 0, 0),
      v.Vector3(1, 1, 0), v.Vector3(1, 2, 0), v.Vector3(1, 0, 1)
    ],
    // 3. Corner Step
    [
      v.Vector3(0, 0, 0), v.Vector3(1, 0, 0), v.Vector3(0, 1, 0),
      v.Vector3(0, 0, 1), v.Vector3(1, 0, 1), v.Vector3(0, 1, 1)
    ],
    // 4. Hollow U-shape
    [
      v.Vector3(0, 0, 0), v.Vector3(1, 0, 0), v.Vector3(2, 0, 0),
      v.Vector3(0, 0, 1), v.Vector3(2, 0, 1),
      v.Vector3(0, 0, 2), v.Vector3(1, 0, 2), v.Vector3(2, 0, 2)
    ],
    // 5. Cross-shape
    [
      v.Vector3(1, 0, 0), v.Vector3(1, 1, 0), v.Vector3(1, 2, 0),
      v.Vector3(0, 1, 0), v.Vector3(2, 1, 0), v.Vector3(1, 1, 1)
    ],
    // 6. Z-shape step
    [
      v.Vector3(0, 0, 0), v.Vector3(1, 0, 0), v.Vector3(1, 1, 0),
      v.Vector3(2, 1, 0), v.Vector3(0, 0, 1), v.Vector3(2, 1, 1)
    ]
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    
    // Slow smooth infinite rotation for the 3D visualizer
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(() {
        if (_isAutoRotating) {
          setState(() {
            angleY = _rotationController.value * 2 * pi;
            angleX = sin(_rotationController.value * 2 * pi) * 0.3 + 0.4;
          });
        }
      })..repeat();

    _startNewGame();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _resumeAutoRotationTimer?.cancel();
    super.dispose();
  }

  void _loadHighScore() {
    setState(() {
      highScore = HighScoreService.instance.getHighScore('shadow_matching');
    });
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      currentLevel = 1;
      lives = 3;
      isGameOver = false;
    });
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    answered = false;
    selectedIndex = null;

    // Pick a random figure
    currentFigure = figures[random.nextInt(figures.length)];

    // Pick a random light direction
    const sources = ['Top', 'Front', 'Side'];
    lightSource = sources[random.nextInt(sources.length)];

    // 1. Calculate correct shadow grid
    final correctGrid = _projectShadow(currentFigure, lightSource);

    // 2. Generate distractors
    final List<List<List<bool>>> options = [correctGrid];

    // Distractor 1: Projection of current figure from a different light direction
    final otherSources = List.from(sources)..remove(lightSource);
    final otherDir = otherSources[random.nextInt(otherSources.length)];
    options.add(_projectShadow(currentFigure, otherDir));

    // Distractor 2: Projection of a different figure
    final otherFigures = List.from(figures)..remove(currentFigure);
    final otherFig = otherFigures[random.nextInt(otherFigures.length)];
    options.add(_projectShadow(otherFig, lightSource));

    // Distractor 3: A mutated version of the correct shadow grid
    options.add(_mutateGrid(correctGrid));

    // De-duplicate grids if there are any collisions
    while (options.toSet().length < 4) {
      // Add random mutations or random projections to make up 4 unique options
      options.add(_mutateGrid(correctGrid));
    }

    // Shuffle options and find the correct index
    final List<List<List<bool>>> uniqueOptions = options.take(4).toList();
    uniqueOptions.shuffle(random);
    
    optionsGrids = uniqueOptions;
    for (int i = 0; i < 4; i++) {
      if (_gridsEqual(optionsGrids[i], correctGrid)) {
        correctIndex = i;
        break;
      }
    }

    setState(() {});
  }

  List<List<bool>> _projectShadow(List<v.Vector3> figure, String dir) {
    // 3x3 grid initialization
    final grid = List.generate(3, (_) => List.generate(3, (_) => false));
    for (var block in figure) {
      int x = block.x.round().clamp(0, 2);
      int y = block.y.round().clamp(0, 2);
      int z = block.z.round().clamp(0, 2);

      if (dir == 'Top') {
        grid[x][z] = true;
      } else if (dir == 'Front') {
        grid[x][y] = true;
      } else { // 'Side'
        grid[y][z] = true;
      }
    }
    return grid;
  }

  List<List<bool>> _mutateGrid(List<List<bool>> src) {
    final random = Random();
    final mutated = List.generate(3, (r) => List<bool>.from(src[r]));
    int toggleR = random.nextInt(3);
    int toggleC = random.nextInt(3);
    mutated[toggleR][toggleC] = !mutated[toggleR][toggleC];
    return mutated;
  }

  bool _gridsEqual(List<List<bool>> a, List<List<bool>> b) {
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (a[r][c] != b[r][c]) return false;
      }
    }
    return true;
  }

  void _onOptionTap(int index) {
    if (answered || isGameOver) return;

    setState(() {
      selectedIndex = index;
      answered = true;

      if (index == correctIndex) {
        score += 10;
        currentLevel++;
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _generateQuestion();
        });
      } else {
        lives--;
        if (lives <= 0) {
          isGameOver = true;
          _handleGameOver();
        } else {
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) _generateQuestion();
          });
        }
      }
    });
  }

  void _handleGameOver() {
    HighScoreService.instance.saveScore('shadow_matching', score).then((isNewHigh) {
      if (isNewHigh) {
        _loadHighScore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = const Color(0xFF38BDF8); // neon blue

    String l10nSource = "";
    if (lightSource == 'Top') {
      l10nSource = l10n.shadowTop;
    } else if (lightSource == 'Front') {
      l10nSource = l10n.shadowFront;
    } else {
      l10nSource = l10n.shadowSide;
    }

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF030712),
      appBar: AppBar(
        title: Text(l10n.shadowMatching),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top stats
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : const Color(0xFF1E293B).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: List.generate(3, (idx) {
                              return Icon(
                                idx < lives ? Icons.favorite : Icons.favorite_border,
                                color: Colors.pinkAccent,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.highScore(highScore),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 32,
                        width: 1.5,
                        color: primaryColor.withOpacity(0.2),
                      ),
                      Column(
                        children: [
                          Text(
                            l10n.scoreLabel(score),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.brainTrainingCategory(l10n.spatialGames),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                Text(
                  l10n.shadowLightSource(l10nSource),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),

                Text(
                  l10n.shadowMatchingDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 24),

                // 3D Object Render Area (Interactive manual drag-to-rotate)
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _isAutoRotating = false;
                      angleY += details.delta.dx * 0.01;
                      angleX = (angleX - details.delta.dy * 0.01).clamp(-pi / 3, pi / 3);
                    });

                    _resumeAutoRotationTimer?.cancel();
                    _resumeAutoRotationTimer = Timer(const Duration(seconds: 4), () {
                      if (mounted) {
                        setState(() {
                          _isAutoRotating = true;
                        });
                      }
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isLight ? Colors.black.withOpacity(0.02) : const Color(0xFF1E293B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
                      ),
                      child: CustomPaint(
                        painter: ShadowMatching3DPainter(
                          blocks: currentFigure,
                          angleX: angleX,
                          angleY: angleY,
                          gridSize: 3,
                          labelSide: l10n.shadowSide,
                          labelTop: l10n.shadowTop,
                          labelFront: l10n.shadowFront,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Option Choice Grid (4 small grids)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, idx) {
                    final grid = optionsGrids[idx];
                    final isSelected = selectedIndex == idx;
                    final isCorrectOpt = idx == correctIndex;
                    
                    Color borderC = primaryColor.withOpacity(0.15);
                    Color fillBg = Colors.transparent;

                    if (answered) {
                      if (isCorrectOpt) {
                        borderC = const Color(0xFF10B981);
                        fillBg = const Color(0xFF10B981).withOpacity(0.05);
                      } else if (isSelected) {
                        borderC = Colors.redAccent;
                        fillBg = Colors.redAccent.withOpacity(0.05);
                      }
                    } else if (isSelected) {
                      borderC = primaryColor;
                    }

                    return GestureDetector(
                      onTap: () => _onOptionTap(idx),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: fillBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderC, width: isSelected ? 2.5 : 1.5),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.optionLabel(String.fromCharCode(65 + idx)),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? borderC : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _build2DShadowGrid(grid, isSelected ? borderC : primaryColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Game Over Card overlay inside layout
                if (isGameOver) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.gameOver,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.finalScorePoints(score),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _startNewGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(l10n.playAgain),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build2DShadowGrid(List<List<bool>> grid, Color activeColor) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(3, (r) {
            return Expanded(
              child: Row(
                children: List.generate(3, (c) {
                  final active = grid[r][c];
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: active ? activeColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: active ? activeColor : activeColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ShadowMatching3DPainter extends CustomPainter {
  final List<v.Vector3> blocks;
  final double angleX;
  final double angleY;
  final int gridSize;
  final String labelSide;
  final String labelTop;
  final String labelFront;

  ShadowMatching3DPainter({
    required this.blocks,
    required this.angleX,
    required this.angleY,
    required this.gridSize,
    required this.labelSide,
    required this.labelTop,
    required this.labelFront,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scale = size.width / (gridSize * 3.5);
    v.Matrix4 matrix = v.Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..rotateX(angleX)
      ..rotateY(angleY);

    if (blocks.isEmpty) return;

    // Centering offset
    double minX = blocks[0].x, maxX = blocks[0].x;
    double minY = blocks[0].y, maxY = blocks[0].y;
    double minZ = blocks[0].z, maxZ = blocks[0].z;
    for (var block in blocks) {
      if (block.x < minX) minX = block.x;
      if (block.x > maxX) maxX = block.x;
      if (block.y < minY) minY = block.y;
      if (block.y > maxY) maxY = block.y;
      if (block.z < minZ) minZ = block.z;
      if (block.z > maxZ) maxZ = block.z;
    }
    double centerX = (minX + maxX) / 2;
    double centerY = (minY + maxY) / 2;
    double centerZ = (minZ + maxZ) / 2;
    v.Vector3 centerOffset = v.Vector3(centerX, centerY, centerZ);

    List<_ShadowFaceRenderable> renderables = [];

    // Generate cube faces for each block
    for (var block in blocks) {
      v.Vector3 shiftedBlock = block - centerOffset;
      final List<v.Vector3> vertices = [
        v.Vector3(-0.5, -0.5, -0.5), v.Vector3(0.5, -0.5, -0.5),
        v.Vector3(0.5, 0.5, -0.5), v.Vector3(-0.5, 0.5, -0.5),
        v.Vector3(-0.5, -0.5, 0.5), v.Vector3(0.5, -0.5, 0.5),
        v.Vector3(0.5, 0.5, 0.5), v.Vector3(-0.5, 0.5, 0.5),
      ];

      List<v.Vector3> projected = vertices.map((vtx) {
        v.Vector3 worldPos = (vtx + shiftedBlock)..scale(scale);
        v.Vector4 v4 = v.Vector4(worldPos.x, worldPos.y, worldPos.z, 1.0);
        v.Vector4 transformed = matrix.transform(v4);
        return v.Vector3(transformed.x, transformed.y, transformed.z);
      }).toList();

      final List<List<int>> faceIndices = [
        [0, 1, 2, 3], // Back
        [4, 5, 6, 7], // Front
        [0, 1, 5, 4], // Bottom
        [2, 3, 7, 6], // Top
        [0, 3, 7, 4], // Left
        [1, 2, 6, 5], // Right
      ];

      // Curated neon styling colors
      final List<Color> faceColors = [
        const Color(0xFF0EA5E9).withOpacity(0.7),
        const Color(0xFF0284C7).withOpacity(0.7),
        const Color(0xFF0369A1).withOpacity(0.7),
        const Color(0xFF075985).withOpacity(0.7),
        const Color(0xFF0C4A6E).withOpacity(0.7),
        const Color(0xFF38BDF8).withOpacity(0.7),
      ];

      for (int i = 0; i < faceIndices.length; i++) {
        List<v.Vector3> points = faceIndices[i].map((idx) => projected[idx]).toList();
        double avgZ = points.map((p) => p.z).reduce((a, b) => a + b) / 4;
        renderables.add(_ShadowFaceRenderable(points, faceColors[i], avgZ));
      }
    }

    // Depth sorting (painter's algorithm)
    renderables.sort((a, b) => b.depth.compareTo(a.depth));

    // Paint all faces
    for (var renderable in renderables) {
      renderable.paint(canvas);
    }

    // Project the center and axes endpoints to paint the coordinate indicator axes
    v.Vector3 projectPoint(v.Vector3 localPt) {
      v.Vector3 worldPos = localPt * scale;
      v.Vector4 v4 = v.Vector4(worldPos.x, worldPos.y, worldPos.z, 1.0);
      v.Vector4 transformed = matrix.transform(v4);
      return v.Vector3(transformed.x, transformed.y, transformed.z);
    }

    v.Vector3 projCenter = projectPoint(v.Vector3.zero() - centerOffset);
    // Red Axis: X-axis (Side)
    v.Vector3 projSide = projectPoint(v.Vector3(2.4, 0, 0) - centerOffset);
    // Green Axis: Y-axis (Top)
    v.Vector3 projTop = projectPoint(v.Vector3(0, 2.4, 0) - centerOffset);
    // Cyan Axis: Z-axis (Front)
    v.Vector3 projFront = projectPoint(v.Vector3(0, 0, 2.4) - centerOffset);

    final paintSide = Paint()..color = Colors.redAccent..strokeWidth = 3.0..style = PaintingStyle.stroke;
    final paintTop = Paint()..color = Colors.greenAccent..strokeWidth = 3.0..style = PaintingStyle.stroke;
    final paintFront = Paint()..color = Colors.cyanAccent..strokeWidth = 3.0..style = PaintingStyle.stroke;

    Offset centerOffset2D = Offset(projCenter.x, projCenter.y);
    Offset sideOffset = Offset(projSide.x, projSide.y);
    Offset topOffset = Offset(projTop.x, projTop.y);
    Offset frontOffset = Offset(projFront.x, projFront.y);

    canvas.drawLine(centerOffset2D, sideOffset, paintSide);
    canvas.drawLine(centerOffset2D, topOffset, paintTop);
    canvas.drawLine(centerOffset2D, frontOffset, paintFront);

    // Draw little circles at the ends
    canvas.drawCircle(sideOffset, 4, Paint()..color = Colors.redAccent);
    canvas.drawCircle(topOffset, 4, Paint()..color = Colors.greenAccent);
    canvas.drawCircle(frontOffset, 4, Paint()..color = Colors.cyanAccent);

    // Draw Labels helper
    void drawAxisLabel(Offset pos, String text, Color color) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    drawAxisLabel(sideOffset + const Offset(0, -12), labelSide, Colors.redAccent);
    drawAxisLabel(topOffset + const Offset(0, -12), labelTop, Colors.greenAccent);
    drawAxisLabel(frontOffset + const Offset(0, -12), labelFront, Colors.cyanAccent);
  }

  @override
  bool shouldRepaint(covariant ShadowMatching3DPainter oldDelegate) {
    return oldDelegate.angleX != angleX ||
        oldDelegate.angleY != angleY ||
        oldDelegate.gridSize != gridSize ||
        !listEquals(oldDelegate.blocks, blocks);
  }
}

class _ShadowFaceRenderable {
  final List<v.Vector3> points;
  final Color color;
  final double depth;

  _ShadowFaceRenderable(this.points, this.color, this.depth);

  void paint(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(points[0].x, points[0].y)
      ..lineTo(points[1].x, points[1].y)
      ..lineTo(points[2].x, points[2].y)
      ..lineTo(points[3].x, points[3].y)
      ..close();

    canvas.drawPath(path, paint);

    // Subtle edge outline for wireframe look
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, borderPaint);
  }
}
