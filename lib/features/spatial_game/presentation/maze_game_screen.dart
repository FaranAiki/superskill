import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:superskill/l10n/app_localizations.dart';

class MazeCell {
  final int r;
  final int c;
  bool top = true;
  bool right = true;
  bool bottom = true;
  bool left = true;
  bool isPath = false;

  MazeCell(this.r, this.c);
}

class MazeGameScreen extends StatefulWidget {
  const MazeGameScreen({super.key});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen> with SingleTickerProviderStateMixin {
  int gridSize = 5;
  bool suddenDeath = false;
  bool memorizationMode = false;
  
  late List<List<MazeCell>> cells;
  late int playerR;
  late int playerC;
  bool hasWon = false;
  
  // Memorization countdown fields
  int countdownSeconds = 0;
  bool isCountingDown = false;
  bool hideWalls = false;
  Timer? _countdownTimer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _generateNewMaze();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  int _getMemorizationDuration(int size) {
    if (size <= 6) return 3;
    if (size <= 8) return 4;
    if (size <= 10) return 5;
    if (size <= 12) return 6;
    if (size <= 14) return 7;
    return 8;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (!memorizationMode) {
      setState(() {
        isCountingDown = false;
        hideWalls = false;
      });
      return;
    }

    setState(() {
      countdownSeconds = _getMemorizationDuration(gridSize);
      isCountingDown = true;
      hideWalls = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (countdownSeconds > 1) {
          countdownSeconds--;
        } else {
          countdownSeconds = 0;
          isCountingDown = false;
          hideWalls = true;
          _countdownTimer?.cancel();
        }
      });
    });
  }

  void _generateNewMaze() {
    setState(() {
      playerR = 0;
      playerC = 0;
      hasWon = false;
      
      // 1. Initialize grid
      cells = List.generate(gridSize, (r) => List.generate(gridSize, (c) => MazeCell(r, c)));

      // 2. Generate primary path from (0,0) to (gridSize-1, gridSize-1)
      List<Point<int>> primaryPath = _generatePrimaryPath();
      Set<Point<int>> connected = {};

      for (int i = 0; i < primaryPath.length; i++) {
        var p = primaryPath[i];
        cells[p.x][p.y].isPath = true;
        connected.add(p);
        if (i > 0) {
          var prev = primaryPath[i - 1];
          _breakWalls(prev.x, prev.y, p.x, p.y);
        }
      }

      // 3. Wilson's algorithm for the remaining cells
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          var startPt = Point(r, c);
          if (connected.contains(startPt)) continue;

          List<Point<int>> walk = [startPt];
          while (!connected.contains(walk.last)) {
            var current = walk.last;
            var neighbors = _getNeighbors(current.x, current.y);
            var next = neighbors[Random().nextInt(neighbors.length)];

            int idx = walk.indexOf(next);
            if (idx != -1) {
              walk = walk.sublist(0, idx + 1);
            } else {
              walk.add(next);
            }
          }

          for (int i = 0; i < walk.length - 1; i++) {
            var p1 = walk[i];
            var p2 = walk[i + 1];
            _breakWalls(p1.x, p1.y, p2.x, p2.y);
            connected.add(p1);
          }
        }
      }
    });

    _startCountdown();
  }

  List<Point<int>> _generatePrimaryPath() {
    List<List<bool>> visited = List.generate(gridSize, (_) => List.filled(gridSize, false));
    List<Point<int>> path = [];

    bool dfs(int r, int c) {
      visited[r][c] = true;
      path.add(Point(r, c));

      if (r == gridSize - 1 && c == gridSize - 1) return true;

      var dirs = [Point(0, 1), Point(1, 0), Point(0, -1), Point(-1, 0)];
      dirs.shuffle();

      for (var dir in dirs) {
        int nr = r + dir.x;
        int nc = c + dir.y;
        if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize && !visited[nr][nc]) {
          if (dfs(nr, nc)) return true;
        }
      }

      path.removeLast();
      return false;
    }

    dfs(0, 0);
    return path;
  }

  List<Point<int>> _getNeighbors(int r, int c) {
    List<Point<int>> neighbors = [];
    if (r > 0) neighbors.add(Point(r - 1, c));
    if (r < gridSize - 1) neighbors.add(Point(r + 1, c));
    if (c > 0) neighbors.add(Point(r, c - 1));
    if (c < gridSize - 1) neighbors.add(Point(r, c + 1));
    return neighbors;
  }

  void _breakWalls(int r1, int c1, int r2, int c2) {
    if (r1 == r2) {
      if (c1 < c2) {
        cells[r1][c1].right = false;
        cells[r2][c2].left = false;
      } else {
        cells[r1][c1].left = false;
        cells[r2][c2].right = false;
      }
    } else {
      if (r1 < r2) {
        cells[r1][c1].bottom = false;
        cells[r2][c2].top = false;
      } else {
        cells[r1][c1].top = false;
        cells[r2][c2].bottom = false;
      }
    }
  }

  void _move(int dr, int dc) {
    final l10n = AppLocalizations.of(context)!;
    if (hasWon || isCountingDown) return;

    int nr = playerR + dr;
    int nc = playerC + dc;

    if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) return;

    bool canMove = false;
    if (dr == -1 && !cells[playerR][playerC].top) canMove = true;
    if (dr == 1 && !cells[playerR][playerC].bottom) canMove = true;
    if (dc == -1 && !cells[playerR][playerC].left) canMove = true;
    if (dc == 1 && !cells[playerR][playerC].right) canMove = true;

    if (canMove) {
      setState(() {
        playerR = nr;
        playerC = nc;
        if (playerR == gridSize - 1 && playerC == gridSize - 1) {
          hasWon = true;
        }
      });
    } else {
      // Hitting a wall
      if (suddenDeath) {
        setState(() {
          playerR = 0;
          playerC = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.suddenDeathMessage),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mazeGame),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.primary),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalIntent(dr: -1, dc: 0),
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalIntent(dr: 1, dc: 0),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalIntent(dr: 0, dc: -1),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalIntent(dr: 0, dc: 1),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DirectionalIntent: CallbackAction<DirectionalIntent>(
              onInvoke: (intent) => _move(intent.dr, intent.dc),
            ),
          },
          child: Focus(
            autofocus: true,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCountingDown) ...[
                        Text(
                          l10n.memorizeMaze(countdownSeconds),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          l10n.reachTheExit,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      
                      // Maze Container
                      GestureDetector(
                        onPanEnd: (details) {
                          if (details.velocity.pixelsPerSecond.dx.abs() > details.velocity.pixelsPerSecond.dy.abs()) {
                            if (details.velocity.pixelsPerSecond.dx > 200) {
                              _move(0, 1);
                            } else if (details.velocity.pixelsPerSecond.dx < -200) {
                              _move(0, -1);
                            }
                          } else {
                            if (details.velocity.pixelsPerSecond.dy > 200) {
                              _move(1, 0);
                            } else if (details.velocity.pixelsPerSecond.dy < -200) {
                              _move(-1, 0);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light ? Colors.black.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return TweenAnimationBuilder<Offset>(
                                  tween: Tween<Offset>(
                                    begin: Offset(playerC.toDouble(), playerR.toDouble()),
                                    end: Offset(playerC.toDouble(), playerR.toDouble()),
                                  ),
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeOutQuad,
                                  builder: (context, animatedOffset, child) {
                                    return CustomPaint(
                                      painter: MazePainter(
                                        cells: cells,
                                        gridSize: gridSize,
                                        playerR: animatedOffset.dy,
                                        playerC: animatedOffset.dx,
                                        pulseValue: _pulseController.value,
                                        hideWalls: hideWalls,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Memorization Refresh button
                      if (memorizationMode) ...[
                        ElevatedButton.icon(
                          onPressed: _generateNewMaze,
                          icon: const Icon(Icons.visibility),
                          label: Text(l10n.resetShowAgain),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildDPad(),
                      
                      const SizedBox(height: 24),
                      
                      if (hasWon) ...[
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  l10n.levelComplete,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _generateNewMaze,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: Text(l10n.playAgain),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDPad() {
    return Column(
      children: [
        _buildDPadButton(Icons.keyboard_arrow_up, () => _move(-1, 0)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDPadButton(Icons.keyboard_arrow_left, () => _move(0, -1)),
            const SizedBox(width: 48),
            _buildDPadButton(Icons.keyboard_arrow_right, () => _move(0, 1)),
          ],
        ),
        const SizedBox(height: 8),
        _buildDPadButton(Icons.keyboard_arrow_down, () => _move(1, 0)),
      ],
    );
  }

  Widget _buildDPadButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.gameSettings, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                Text('${l10n.gridSize}: $gridSize x $gridSize', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                Slider(
                  value: gridSize.toDouble(),
                  min: 5,
                  max: 15,
                  divisions: 10,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: Colors.white10,
                  onChanged: (v) {
                    setState(() => gridSize = v.toInt());
                    setModalState(() {});
                    _generateNewMaze();
                  },
                ),
                const SizedBox(height: 16),
                
                // Sudden Death Toggle
                SwitchListTile(
                  title: Text(l10n.suddenDeath, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(l10n.suddenDeathDesc, style: Theme.of(context).textTheme.bodyMedium),
                  value: suddenDeath,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) {
                    setState(() => suddenDeath = v);
                    setModalState(() {});
                  },
                ),
                
                // Memorization Mode Toggle
                SwitchListTile(
                  title: Text(l10n.memorizationMode, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(l10n.memorizationModeDesc, style: Theme.of(context).textTheme.bodyMedium),
                  value: memorizationMode,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) {
                    setState(() => memorizationMode = v);
                    setModalState(() {});
                    _generateNewMaze();
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DirectionalIntent extends Intent {
  final int dr;
  final int dc;
  const DirectionalIntent({required this.dr, required this.dc});
}

class MazePainter extends CustomPainter {
  final List<List<MazeCell>> cells;
  final int gridSize;
  final double playerR;
  final double playerC;
  final double pulseValue;
  final bool hideWalls;

  MazePainter({
    required this.cells,
    required this.gridSize,
    required this.playerR,
    required this.playerC,
    required this.pulseValue,
    required this.hideWalls,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cellW = size.width / gridSize;
    double cellH = size.height / gridSize;

    // Draw Background paths/grid subtly
    final bgGridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.02)
      ..style = PaintingStyle.fill;
    
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        canvas.drawRect(Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH), bgGridPaint);
      }
    }

    // Paint Goal/Exit Glow
    final goalPaint = Paint()
      ..color = const Color(0xFFF43F5E).withOpacity(0.2 + 0.2 * pulseValue)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 4 * pulseValue);
    
    canvas.drawCircle(
      Offset((gridSize - 0.5) * cellW, (gridSize - 0.5) * cellH),
      min(cellW, cellH) * 0.4,
      goalPaint,
    );

    final goalCorePaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset((gridSize - 0.5) * cellW, (gridSize - 0.5) * cellH),
      min(cellW, cellH) * 0.2,
      goalCorePaint,
    );

    // Paint Walls unless they are hidden in Memorization Mode
    if (!hideWalls) {
      final wallPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, 3.5 - (gridSize * 0.1))
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          var cell = cells[r][c];
          double x1 = c * cellW;
          double y1 = r * cellH;
          double x2 = (c + 1) * cellW;
          double y2 = (r + 1) * cellH;

          if (cell.top) canvas.drawLine(Offset(x1, y1), Offset(x2, y1), wallPaint);
          if (cell.right) canvas.drawLine(Offset(x2, y1), Offset(x2, y2), wallPaint);
          if (cell.bottom) canvas.drawLine(Offset(x1, y2), Offset(x2, y2), wallPaint);
          if (cell.left) canvas.drawLine(Offset(x1, y1), Offset(x1, y2), wallPaint);
        }
      }
    }

    // Paint Player
    final playerGlowPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    double playerX = (playerC + 0.5) * cellW;
    double playerY = (playerR + 0.5) * cellH;
    
    canvas.drawCircle(Offset(playerX, playerY), min(cellW, cellH) * 0.35, playerGlowPaint);

    final playerPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(playerX, playerY), min(cellW, cellH) * 0.22, playerPaint);
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) => true;
}

