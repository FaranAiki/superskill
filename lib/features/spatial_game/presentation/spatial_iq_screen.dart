import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class SpatialIqScreen extends StatefulWidget {
  const SpatialIqScreen({super.key});

  @override
  State<SpatialIqScreen> createState() => _SpatialIqScreenState();
}

class _SpatialIqScreenState extends State<SpatialIqScreen> {
  int gridSize = 3;
  int optionsCount = 3;
  late List<v.Vector3> targetShape;
  late List<List<v.Vector3>> options;
  late int correctIndex;
  double angleX = 0.2;
  double angleY = 0.5;
  bool isCorrect = false;
  bool submitted = false;
  bool enableRotation = false;
  bool showGrid = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      targetShape = _generateRandomShape(gridSize);
      correctIndex = Random().nextInt(optionsCount);
      options = [];

      for (int i = 0; i < optionsCount; i++) {
        if (i == correctIndex) {
          // Correct shape, but we will show it from a different fixed rotation in the option
          options.add(targetShape);
        } else {
          // Decoy: Slightly modified shape
          options.add(_generateDecoy(targetShape, gridSize));
        }
      }
      submitted = false;
      isCorrect = false;
    });
  }

  bool _fitsInSize(List<v.Vector3> shape, v.Vector3 next, int size) {
    double minX = next.x, maxX = next.x;
    double minY = next.y, maxY = next.y;
    double minZ = next.z, maxZ = next.z;
    for (var p in shape) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
      if (p.z < minZ) minZ = p.z;
      if (p.z > maxZ) maxZ = p.z;
    }
    return (maxX - minX + 1) <= size && (maxY - minY + 1) <= size && (maxZ - minZ + 1) <= size;
  }

  List<v.Vector3> _generateRandomShape(int size) {
    Random r = Random();
    int count;
    if (size == 3) {
      count = 6;
    } else if (size == 4) {
      count = 9;
    } else {
      count = 12; // size == 5
    }

    List<v.Vector3> fallbackShape = [v.Vector3(0, 0, 0)];

    for (int outer = 0; outer < 100; outer++) {
      List<v.Vector3> shape = [v.Vector3(0, 0, 0)];
      int attempts = 0;
      while (shape.length < count && attempts < 300) {
        attempts++;
        v.Vector3 current = shape[r.nextInt(shape.length)];
        v.Vector3 offset;
        int dir = r.nextInt(6);
        switch (dir) {
          case 0: offset = v.Vector3(1, 0, 0); break;
          case 1: offset = v.Vector3(-1, 0, 0); break;
          case 2: offset = v.Vector3(0, 1, 0); break;
          case 3: offset = v.Vector3(0, -1, 0); break;
          case 4: offset = v.Vector3(0, 0, 1); break;
          default: offset = v.Vector3(0, 0, -1); break;
        }
        v.Vector3 next = current + offset;
        
        if (_fitsInSize(shape, next, size)) {
          if (!shape.any((v) => v.x == next.x && v.y == next.y && v.z == next.z)) {
            shape.add(next);
          }
        }
      }

      if (shape.length == count) {
        fallbackShape = shape;
        // Check if it spans the full size in at least one dimension
        double minX = shape[0].x, maxX = shape[0].x;
        double minY = shape[0].y, maxY = shape[0].y;
        double minZ = shape[0].z, maxZ = shape[0].z;
        for (var p in shape) {
          if (p.x < minX) minX = p.x;
          if (p.x > maxX) maxX = p.x;
          if (p.y < minY) minY = p.y;
          if (p.y > maxY) maxY = p.y;
          if (p.z < minZ) minZ = p.z;
          if (p.z > maxZ) maxZ = p.z;
        }
        int spanX = (maxX - minX + 1).toInt();
        int spanY = (maxY - minY + 1).toInt();
        int spanZ = (maxZ - minZ + 1).toInt();
        
        int maxSpan = [spanX, spanY, spanZ].reduce(max);
        if (maxSpan == size) {
          return shape;
        }
      }
    }
    return fallbackShape;
  }

  List<v.Vector3> _generateDecoy(List<v.Vector3> original, int size) {
    List<v.Vector3> decoy = List.from(original);
    Random r = Random();
    
    for (int attempts = 0; attempts < 100; attempts++) {
      decoy = List.from(original);
      int indexToRemove = r.nextInt(decoy.length);
      decoy.removeAt(indexToRemove);
      
      int addAttempts = 0;
      while (decoy.length < original.length && addAttempts < 50) {
        addAttempts++;
        v.Vector3 current = decoy[r.nextInt(decoy.length)];
        int dir = r.nextInt(6);
        v.Vector3 offset;
        switch (dir) {
          case 0: offset = v.Vector3(1, 0, 0); break;
          case 1: offset = v.Vector3(-1, 0, 0); break;
          case 2: offset = v.Vector3(0, 1, 0); break;
          case 3: offset = v.Vector3(0, -1, 0); break;
          case 4: offset = v.Vector3(0, 0, 1); break;
          default: offset = v.Vector3(0, 0, -1); break;
        }
        v.Vector3 next = current + offset;
        if (_fitsInSize(decoy, next, size)) {
          if (!decoy.any((v) => v.x == next.x && v.y == next.y && v.z == next.z)) {
            decoy.add(next);
          }
        }
      }
      
      if (decoy.length == original.length) {
        bool isSame = true;
        for (var p in decoy) {
          if (!original.any((o) => o.x == p.x && o.y == p.y && o.z == p.z)) {
            isSame = false;
            break;
          }
        }
        if (!isSame) {
          return decoy;
        }
      }
    }
    return decoy;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("${l10n.spatialIq} (Score: $score)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l10n.matchRotatedShape, style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onPanUpdate: (details) {
                if (!enableRotation) return;
                setState(() {
                  angleY += details.delta.dx * 0.01;
                  angleX += details.delta.dy * 0.01;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.02) : Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white10),
                ),
                child: CustomPaint(
                  painter: BlockPainter(
                    blocks: targetShape,
                    angleX: angleX,
                    angleY: angleY,
                    gridSize: gridSize,
                    showGrid: showGrid,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: optionsCount > 3 ? 3 : optionsCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: optionsCount,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: submitted ? null : () {
                    setState(() {
                      submitted = true;
                      isCorrect = index == correctIndex;
                      if (isCorrect) {
                        score += 10;
                        HighScoreService.instance.saveScore("spatial_iq", score);
                      } else {
                        score = 0;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: submitted 
                          ? (index == correctIndex ? Colors.green : (isCorrect ? (Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white10) : Colors.red))
                          : (Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white10),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: BlockPainter(
                                blocks: options[index],
                                // Static but different rotations for options
                                angleX: 0.5 + (index * 0.5),
                                angleY: 0.8 + (index * 1.2),
                                gridSize: gridSize,
                                isSmall: true,
                                showGrid: showGrid,
                              ),
                              child: Container(),
                            ),
                          ),
                        ),
                        if (submitted && index == correctIndex)
                          const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        if (submitted && !isCorrect && index != correctIndex)
                          const Icon(Icons.cancel, color: Colors.red, size: 24),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (submitted)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _generateLevel,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFF0284C7),
                ),
                child: Text(l10n.playAgain),
              ),
            ),
        ],
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.gameSettings, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 20),
                  Text('${l10n.gridSize}: $gridSize x $gridSize x $gridSize', style: theme.textTheme.bodyLarge),
                  Slider(
                    value: gridSize.toDouble(),
                    min: 3,
                    max: 5,
                    divisions: 2,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() => gridSize = v.toInt());
                      setModalState(() {});
                      _generateLevel();
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('${l10n.optionsCount}: $optionsCount', style: theme.textTheme.bodyLarge),
                  Slider(
                    value: optionsCount.toDouble(),
                    min: 3,
                    max: 9,
                    divisions: 6,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() => optionsCount = v.toInt());
                      setModalState(() {});
                      _generateLevel();
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: Text(l10n.allowRotation, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(l10n.allowRotationDesc),
                    value: enableRotation,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() => enableRotation = v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: Text(l10n.showGrid, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(l10n.showGridDesc),
                    value: showGrid,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() => showGrid = v);
                      setModalState(() {});
                    },
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

class BlockPainter extends CustomPainter {
  final List<v.Vector3> blocks;
  final double angleX;
  final double angleY;
  final int gridSize;
  final bool isSmall;
  final bool showGrid;

  BlockPainter({
    required this.blocks,
    required this.angleX,
    required this.angleY,
    required this.gridSize,
    this.isSmall = false,
    this.showGrid = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scale = size.width / (gridSize * 2.0);
    v.Matrix4 matrix = v.Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..rotateX(angleX)
      ..rotateY(angleY);

    if (blocks.isEmpty) return;

    // Compute the center of the bounding box of the blocks
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

    List<_Renderable> renderables = [];

    // 1. Generate Block Faces
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

      final List<Color> faceColors = [
        const Color(0xFF0EA5E9).withOpacity(0.8),
        const Color(0xFF0284C7).withOpacity(0.8),
        const Color(0xFF0369A1).withOpacity(0.8),
        const Color(0xFF075985).withOpacity(0.8),
        const Color(0xFF0C4A6E).withOpacity(0.8),
        const Color(0xFF38BDF8).withOpacity(0.8),
      ];

      for (int i = 0; i < faceIndices.length; i++) {
        List<v.Vector3> points = faceIndices[i].map((idx) => projected[idx]).toList();
        double avgZ = points.map((p) => p.z).reduce((a, b) => a + b) / 4;
        renderables.add(_FaceRenderable(points, faceColors[i], avgZ));
      }
    }

    if (showGrid) {
      // 2. Generate Cage Outline (12 main edges of the bounding cube)
      final half = gridSize / 2.0;
      final List<v.Vector3> cageVertices = [
        v.Vector3(-half, -half, -half),
        v.Vector3(half, -half, -half),
        v.Vector3(half, half, -half),
        v.Vector3(-half, half, -half),
        v.Vector3(-half, -half, half),
        v.Vector3(half, -half, half),
        v.Vector3(half, half, half),
        v.Vector3(-half, half, half),
      ];

      List<v.Vector3> projectedCage = cageVertices.map((vtx) {
        v.Vector3 worldPos = vtx * scale;
        v.Vector4 v4 = v.Vector4(worldPos.x, worldPos.y, worldPos.z, 1.0);
        v.Vector4 transformed = matrix.transform(v4);
        return v.Vector3(transformed.x, transformed.y, transformed.z);
      }).toList();

      final List<List<int>> cageEdges = [
        [0, 1], [1, 2], [2, 3], [3, 0], // Back
        [4, 5], [5, 6], [6, 7], [7, 4], // Front
        [0, 4], [1, 5], [2, 6], [3, 7], // Connections
      ];

      final cageColor = const Color(0xFF38BDF8).withOpacity(0.4);
      for (var edge in cageEdges) {
        v.Vector3 p1 = projectedCage[edge[0]];
        v.Vector3 p2 = projectedCage[edge[1]];
        double avgZ = (p1.z + p2.z) / 2;
        renderables.add(_LineRenderable(p1, p2, cageColor, 2.0, avgZ));
      }

      // 3. Generate Cage Grid Lines
      for (int i = 1; i < gridSize; i++) {
        double offsetVal = -half + i;
        final gridLineSegments = [
          // On X faces:
          [v.Vector3(-half, -half, offsetVal), v.Vector3(-half, half, offsetVal)],
          [v.Vector3(-half, offsetVal, -half), v.Vector3(-half, offsetVal, half)],
          [v.Vector3(half, -half, offsetVal), v.Vector3(half, half, offsetVal)],
          [v.Vector3(half, offsetVal, -half), v.Vector3(half, offsetVal, half)],

          // On Y faces:
          [v.Vector3(-half, -half, offsetVal), v.Vector3(half, -half, offsetVal)],
          [v.Vector3(offsetVal, -half, -half), v.Vector3(offsetVal, -half, half)],
          [v.Vector3(-half, half, offsetVal), v.Vector3(half, half, offsetVal)],
          [v.Vector3(offsetVal, half, -half), v.Vector3(offsetVal, half, half)],

          // On Z faces:
          [v.Vector3(-half, offsetVal, -half), v.Vector3(half, offsetVal, -half)],
          [v.Vector3(offsetVal, -half, -half), v.Vector3(offsetVal, half, -half)],
          [v.Vector3(-half, offsetVal, half), v.Vector3(half, offsetVal, half)],
          [v.Vector3(offsetVal, -half, half), v.Vector3(offsetVal, half, half)],
        ];

        final gridLineColor = const Color(0xFF38BDF8).withOpacity(0.15);
        for (var segment in gridLineSegments) {
          v.Vector3 p1Local = segment[0];
          v.Vector3 p2Local = segment[1];

          // Project p1
          v.Vector3 p1World = p1Local * scale;
          v.Vector4 v4_1 = v.Vector4(p1World.x, p1World.y, p1World.z, 1.0);
          v.Vector4 t1 = matrix.transform(v4_1);
          v.Vector3 p1Proj = v.Vector3(t1.x, t1.y, t1.z);

          // Project p2
          v.Vector3 p2World = p2Local * scale;
          v.Vector4 v4_2 = v.Vector4(p2World.x, p2World.y, p2World.z, 1.0);
          v.Vector4 t2 = matrix.transform(v4_2);
          v.Vector3 p2Proj = v.Vector3(t2.x, t2.y, t2.z);

          double avgZ = (p1Proj.z + p2Proj.z) / 2;
          renderables.add(_LineRenderable(p1Proj, p2Proj, gridLineColor, 1.0, avgZ));
        }
      }
    }

    // Z-sorting
    renderables.sort((a, b) => b.depth.compareTo(a.depth));

    // Paint all
    for (var renderable in renderables) {
      renderable.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant BlockPainter oldDelegate) {
    return oldDelegate.angleX != angleX ||
        oldDelegate.angleY != angleY ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.showGrid != showGrid ||
        !listEquals(oldDelegate.blocks, blocks);
  }
}

abstract class _Renderable {
  double get depth;
  void paint(Canvas canvas);
}

class _FaceRenderable extends _Renderable {
  final List<v.Vector3> points;
  final Color color;
  @override
  final double depth;

  _FaceRenderable(this.points, this.color, this.depth);

  @override
  void paint(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(points[0].x, points[0].y);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, highlightPaint);
  }
}

class _LineRenderable extends _Renderable {
  final v.Vector3 p1;
  final v.Vector3 p2;
  final Color color;
  final double strokeWidth;
  @override
  final double depth;

  _LineRenderable(this.p1, this.p2, this.color, this.strokeWidth, this.depth);

  @override
  void paint(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
  }
}
