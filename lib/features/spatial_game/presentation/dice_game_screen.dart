import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class DiceGameScreen extends StatefulWidget {
  const DiceGameScreen({super.key});

  @override
  State<DiceGameScreen> createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen> {
  int optionsCount = 3;
  late List<List<int>> options; // 6 values per dice option
  late int correctIndex;
  int selectedOptionIndex = 0;
  
  double angleX = 0.5;
  double angleY = 0.6;
  bool enableRotation = true;
  
  bool submitted = false;
  bool isCorrect = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      options = [];
      correctIndex = Random().nextInt(optionsCount);
      selectedOptionIndex = 0;
      submitted = false;
      isCorrect = false;
      
      // Reset rotation angles to a standard isometric view
      angleX = 0.5;
      angleY = 0.6;

      for (int i = 0; i < optionsCount; i++) {
        if (i == correctIndex) {
          options.add(_generateValidDice());
        } else {
          options.add(_generateInvalidDice());
        }
      }
    });
  }

  // A standard dice has opposite faces summing to 7:
  // Face Pairs: [Back(0), Front(1)], [Bottom(2), Top(3)], [Left(4), Right(5)]
  List<int> _generateValidDice() {
    final random = Random();
    List<int> dice = List.filled(6, 0);

    // Shuffle the three opposite pairs
    List<List<int>> pairs = [
      [1, 6],
      [2, 5],
      [3, 4]
    ];
    pairs.shuffle(random);

    // Assign pair 0 to Back/Front
    if (random.nextBool()) {
      dice[0] = pairs[0][0];
      dice[1] = pairs[0][1];
    } else {
      dice[0] = pairs[0][1];
      dice[1] = pairs[0][0];
    }

    // Assign pair 1 to Bottom/Top
    if (random.nextBool()) {
      dice[2] = pairs[1][0];
      dice[3] = pairs[1][1];
    } else {
      dice[2] = pairs[1][1];
      dice[3] = pairs[1][0];
    }

    // Assign pair 2 to Left/Right
    if (random.nextBool()) {
      dice[4] = pairs[2][0];
      dice[5] = pairs[2][1];
    } else {
      dice[4] = pairs[2][1];
      dice[5] = pairs[2][0];
    }

    return dice;
  }

  List<int> _generateInvalidDice() {
    final random = Random();
    List<int> dice = [1, 2, 3, 4, 5, 6];
    
    // Shuffle numbers randomly until we get an invalid opposite face sum
    while (true) {
      dice.shuffle(random);
      // Check if at least one pair does not sum to 7
      if (dice[0] + dice[1] != 7 || dice[2] + dice[3] != 7 || dice[4] + dice[5] != 7) {
        return dice;
      }
    }
  }

  void _submitAnswer() {
    if (submitted) return;
    setState(() {
      submitted = true;
      isCorrect = selectedOptionIndex == correctIndex;
      if (isCorrect) {
        score += 10;
        HighScoreService.instance.saveScore("spatial_dice", score);
      } else {
        score = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text("${l10n.diceGame} (Score: $score)"),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  l10n.diceGameInstruction,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Big 3D Dice Inspection Viewport
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (!enableRotation) return;
                    setState(() {
                      angleY += details.delta.dx * 0.01;
                      angleX += details.delta.dy * 0.01;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black.withOpacity(0.02) : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isLight ? Colors.black12 : Colors.white10,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CustomPaint(
                      painter: DicePainter(
                        faceValues: options[selectedOptionIndex],
                        angleX: angleX,
                        angleY: angleY,
                        primaryColor: primaryColor,
                        isLight: isLight,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),

              // Selected Indicator & Interactive Prompt
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  l10n.inspectingDiceOption(selectedOptionIndex + 1),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dice Option Grid
              Expanded(
                flex: 2,
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: optionsCount > 3 ? 3 : optionsCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: optionsCount,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedOptionIndex;
                    Color borderColor = isLight ? Colors.black12 : Colors.white10;
                    if (submitted) {
                      if (index == correctIndex) {
                        borderColor = Colors.green;
                      } else if (index == selectedOptionIndex) {
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      borderColor = primaryColor;
                    }

                    return GestureDetector(
                      onTap: () {
                        if (submitted) return;
                        setState(() {
                          selectedOptionIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLight 
                              ? Colors.black.withOpacity(0.04) 
                              : const Color(0xFF1E293B).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected || submitted ? 2.5 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            IgnorePointer(
                              child: CustomPaint(
                                painter: DicePainter(
                                  faceValues: options[index],
                                  angleX: 0.5,
                                  angleY: 0.6,
                                  primaryColor: primaryColor,
                                  isLight: isLight,
                                  isSmall: true,
                                ),
                                child: Container(),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "#${index + 1}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            if (submitted && index == correctIndex)
                              const Positioned(
                                top: 6,
                                right: 6,
                                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                              ),
                            if (submitted && !isCorrect && index == selectedOptionIndex)
                              const Positioned(
                                top: 6,
                                right: 6,
                                child: Icon(Icons.cancel, color: Colors.red, size: 20),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Action button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    if (submitted)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generateLevel,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(l10n.playAgain),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(l10n.submitAnswer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                  ],
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.gameSettings, style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                Text('${l10n.optionsCount}: $optionsCount', style: theme.textTheme.bodyLarge),
                Slider(
                  value: optionsCount.toDouble(),
                  min: 3,
                  max: 9,
                  divisions: 6,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DicePainter extends CustomPainter {
  final List<int> faceValues;
  final double angleX;
  final double angleY;
  final Color primaryColor;
  final bool isLight;
  final bool isSmall;

  DicePainter({
    required this.faceValues,
    required this.angleX,
    required this.angleY,
    required this.primaryColor,
    required this.isLight,
    this.isSmall = false,
  });

  List<List<double>> _getDotCoords(int value) {
    switch (value) {
      case 1:
        return [
          [0.5, 0.5]
        ];
      case 2:
        return [
          [0.25, 0.25],
          [0.75, 0.75]
        ];
      case 3:
        return [
          [0.25, 0.25],
          [0.5, 0.5],
          [0.75, 0.75]
        ];
      case 4:
        return [
          [0.25, 0.25],
          [0.75, 0.25],
          [0.25, 0.75],
          [0.75, 0.75]
        ];
      case 5:
        return [
          [0.25, 0.25],
          [0.75, 0.25],
          [0.5, 0.5],
          [0.25, 0.75],
          [0.75, 0.75]
        ];
      case 6:
        return [
          [0.25, 0.25],
          [0.75, 0.25],
          [0.25, 0.5],
          [0.75, 0.5],
          [0.25, 0.75],
          [0.75, 0.75]
        ];
      default:
        return [];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double scale = isSmall ? size.width / 3.2 : size.width / 3.0;
    v.Matrix4 matrix = v.Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..rotateX(angleX)
      ..rotateY(angleY);

    List<_DiceFace> faces = _getDiceFaces(matrix, scale);

    // Z-sorting: Draw back-most faces first
    faces.sort((a, b) => b.averageZ.compareTo(a.averageZ));

    for (var face in faces) {
      final paint = Paint()
        ..color = face.color
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = primaryColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSmall ? 1.0 : 2.0;

      final path = Path();
      path.moveTo(face.points[0].x, face.points[0].y);
      for (int i = 1; i < face.points.length; i++) {
        path.lineTo(face.points[i].x, face.points[i].y);
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
      
      // Add neon glass highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, highlightPaint);

      // Render dots only if face is visible (normal facing camera)
      if (face.isFacingCamera) {
        final dotPaint = Paint()
          ..style = PaintingStyle.fill;
        
        final dotColor = Colors.black;
        dotPaint.color = dotColor;

        double dotRadius = isSmall ? scale * 0.07 : scale * 0.1;
        
        final dotCoords = _getDotCoords(face.value);
        for (var coord in dotCoords) {
          double du = coord[0];
          double dv = coord[1];
          
          // Bilinear interpolation to get the exact 2D position on the rotated face
          v.Vector3 top = face.points[0] * (1.0 - du) + face.points[1] * du;
          v.Vector3 bottom = face.points[3] * (1.0 - du) + face.points[2] * du;
          v.Vector3 pt = top * (1.0 - dv) + bottom * dv;
          
          canvas.drawCircle(Offset(pt.x, pt.y), dotRadius, dotPaint);
          
          // Tiny glossy highlight inside the dot
          final dotHighlight = Paint()
            ..color = Colors.white.withOpacity(0.2)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(pt.x - dotRadius * 0.3, pt.y - dotRadius * 0.3), dotRadius * 0.25, dotHighlight);
        }
      }
    }
  }

  List<_DiceFace> _getDiceFaces(v.Matrix4 matrix, double scale) {
    // Standard cube vertices
    final List<v.Vector3> vertices = [
      v.Vector3(-0.5, -0.5, -0.5), v.Vector3(0.5, -0.5, -0.5),
      v.Vector3(0.5, 0.5, -0.5), v.Vector3(-0.5, 0.5, -0.5),
      v.Vector3(-0.5, -0.5, 0.5), v.Vector3(0.5, -0.5, 0.5),
      v.Vector3(0.5, 0.5, 0.5), v.Vector3(-0.5, 0.5, 0.5),
    ];

    List<v.Vector3> projected = vertices.map((vtx) {
      v.Vector3 worldPos = vtx * scale;
      v.Vector4 v4 = v.Vector4(worldPos.x, worldPos.y, worldPos.z, 1.0);
      v.Vector4 transformed = matrix.transform(v4);
      return v.Vector3(transformed.x, transformed.y, transformed.z);
    }).toList();

    // Faces mappings: Index to vertex indices
    final List<List<int>> faceIndices = [
      [1, 0, 3, 2], // Back (0)
      [4, 5, 6, 7], // Front (1)
      [0, 1, 5, 4], // Bottom (2)
      [7, 6, 2, 3], // Top (3)
      [0, 4, 7, 3], // Left (4)
      [5, 1, 2, 6], // Right (5)
    ];

    // Local face normals (pointing outwards)
    final List<v.Vector3> localNormals = [
      v.Vector3(0, 0, -1),
      v.Vector3(0, 0, 1),
      v.Vector3(0, -1, 0),
      v.Vector3(0, 1, 0),
      v.Vector3(-1, 0, 0),
      v.Vector3(1, 0, 0),
    ];

    // Colors for the dice faces (shades of white/light gray for realistic 3D shadowing)
    final List<Color> faceColors = [
      const Color(0xFFE5E7EB).withOpacity(0.95), // Back
      const Color(0xFFF9FAFB).withOpacity(0.95), // Front
      const Color(0xFFD1D5DB).withOpacity(0.95), // Bottom
      const Color(0xFFFFFFFF).withOpacity(0.95), // Top
      const Color(0xFFE5E7EB).withOpacity(0.95), // Left
      const Color(0xFFF3F4F6).withOpacity(0.95), // Right
    ];

    List<_DiceFace> diceFaces = [];
    
    // Rotation matrix for normals (to check face direction)
    v.Matrix4 rotationMatrix = matrix.clone()..setTranslation(v.Vector3.zero());

    for (int i = 0; i < faceIndices.length; i++) {
      List<v.Vector3> points = faceIndices[i].map((idx) => projected[idx]).toList();
      double avgZ = points.map((p) => p.z).reduce((a, b) => a + b) / 4;
      
      // Calculate 2D center of the face
      double avgX = points.map((p) => p.x).reduce((a, b) => a + b) / 4;
      double avgY = points.map((p) => p.y).reduce((a, b) => a + b) / 4;
      v.Vector2 center2D = v.Vector2(avgX, avgY);

      // Calculate camera normal direction
      v.Vector3 normalCam = rotationMatrix.transform3(localNormals[i]);
      bool isFacingCamera = normalCam.z < 0;

      diceFaces.add(_DiceFace(
        points: points,
        color: faceColors[i],
        averageZ: avgZ,
        center2D: center2D,
        isFacingCamera: isFacingCamera,
        value: faceValues[i],
      ));
    }

    return diceFaces;
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) {
    return oldDelegate.angleX != angleX ||
        oldDelegate.angleY != angleY ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.isLight != isLight ||
        oldDelegate.isSmall != isSmall ||
        !listEquals(oldDelegate.faceValues, faceValues);
  }
}

class _DiceFace {
  final List<v.Vector3> points;
  final Color color;
  final double averageZ;
  final v.Vector2 center2D;
  final bool isFacingCamera;
  final int value;

  _DiceFace({
    required this.points,
    required this.color,
    required this.averageZ,
    required this.center2D,
    required this.isFacingCamera,
    required this.value,
  });
}
