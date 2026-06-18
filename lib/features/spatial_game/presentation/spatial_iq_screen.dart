import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:superskill/l10n/app_localizations.dart';

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

  List<v.Vector3> _generateRandomShape(int size) {
    List<v.Vector3> shape = [v.Vector3(0, 0, 0)];
    Random r = Random();
    int count = size + 2; // More blocks for higher grid size

    while (shape.length < count) {
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
      
      // Keep within grid bounds
      if (next.x.abs() < size/2 && next.y.abs() < size/2 && next.z.abs() < size/2) {
        if (!shape.any((v) => v.x == next.x && v.y == next.y && v.z == next.z)) {
          shape.add(next);
        }
      }
    }
    return shape;
  }

  List<v.Vector3> _generateDecoy(List<v.Vector3> original, int size) {
    List<v.Vector3> decoy = List.from(original);
    Random r = Random();
    // Change one block
    int indexToRemove = r.nextInt(decoy.length);
    decoy.removeAt(indexToRemove);
    
    // Add a new one that doesn't exist
    while (decoy.length < original.length) {
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
      if (next.x.abs() < size/2 && next.y.abs() < size/2 && next.z.abs() < size/2) {
        if (!decoy.any((v) => v.x == next.x && v.y == next.y && v.z == next.z)) {
          decoy.add(next);
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
        title: Text(l10n.spatialIq),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
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
                bool isSelected = submitted && index == correctIndex;
                bool isWrong = submitted && !isCorrect && index != correctIndex;

                return GestureDetector(
                  onTap: submitted ? null : () {
                    setState(() {
                      submitted = true;
                      isCorrect = index == correctIndex;
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.gameSettings, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('${l10n.gridSize}: $gridSize x $gridSize x $gridSize', style: Theme.of(context).textTheme.bodyLarge),
              Slider(
                value: gridSize.toDouble(),
                min: 3,
                max: 5,
                divisions: 2,
                onChanged: (v) {
                  setState(() => gridSize = v.toInt());
                  setModalState(() {});
                  _generateLevel();
                },
              ),
              const SizedBox(height: 10),
              Text('${l10n.optionsCount}: $optionsCount', style: Theme.of(context).textTheme.bodyLarge),
              Slider(
                value: optionsCount.toDouble(),
                min: 3,
                max: 5,
                divisions: 2,
                onChanged: (v) {
                  setState(() => optionsCount = v.toInt());
                  setModalState(() {});
                  _generateLevel();
                },
              ),
            ],
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

  BlockPainter({
    required this.blocks,
    required this.angleX,
    required this.angleY,
    required this.gridSize,
    this.isSmall = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scale = isSmall ? size.width / (gridSize * 2.0) : size.width / (gridSize * 2.0);
    v.Matrix4 matrix = v.Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..rotateX(angleX)
      ..rotateY(angleY);

    List<_Face> faces = [];

    for (var block in blocks) {
      faces.addAll(_getCubeFaces(block, matrix, scale));
    }

    // Z-sorting for correct 3D rendering
    faces.sort((a, b) => b.averageZ.compareTo(a.averageZ));

    for (var face in faces) {
      final paint = Paint()
        ..color = face.color
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final path = Path();
      path.moveTo(face.points[0].x, face.points[0].y);
      for (int i = 1; i < face.points.length; i++) {
        path.lineTo(face.points[i].x, face.points[i].y);
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
      
      // Add a glossy highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, highlightPaint);
    }
  }

  List<_Face> _getCubeFaces(v.Vector3 pos, v.Matrix4 matrix, double scale) {
    List<_Face> cubeFaces = [];
    final List<v.Vector3> vertices = [
      v.Vector3(-0.5, -0.5, -0.5), v.Vector3(0.5, -0.5, -0.5),
      v.Vector3(0.5, 0.5, -0.5), v.Vector3(-0.5, 0.5, -0.5),
      v.Vector3(-0.5, -0.5, 0.5), v.Vector3(0.5, -0.5, 0.5),
      v.Vector3(0.5, 0.5, 0.5), v.Vector3(-0.5, 0.5, 0.5),
    ];

    List<v.Vector3> projected = vertices.map((vtx) {
      v.Vector3 worldPos = (vtx + pos)..scale(scale);
      v.Vector4 v4 = v.Vector4(worldPos.x, worldPos.y, worldPos.z, 1.0);
      v.Vector4 transformed = matrix.transform(v4);
      return v.Vector3(transformed.x, transformed.y, transformed.z);
    }).toList();

    // Define faces by vertex indices
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
      cubeFaces.add(_Face(points, faceColors[i], avgZ));
    }

    return cubeFaces;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Face {
  final List<v.Vector3> points;
  final Color color;
  final double averageZ;
  _Face(this.points, this.color, this.averageZ);
}
