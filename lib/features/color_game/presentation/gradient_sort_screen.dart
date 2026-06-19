import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/high_score_service.dart';

class GradientSortScreen extends StatefulWidget {
  const GradientSortScreen({super.key});

  @override
  State<GradientSortScreen> createState() => _GradientSortScreenState();
}

class _GradientSortScreenState extends State<GradientSortScreen> {
  int currentLevel = 1;
  int moves = 0;
  bool isFinished = false;
  int highScore = 0;

  late Color startColor;
  late Color endColor;
  late List<Color> targetColors;
  late List<Color> playerColors; // Only the middle draggable colors

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _generateGradientLevel();
  }

  void _loadHighScore() {
    setState(() {
      highScore = HighScoreService.instance.getHighScore('gradient_sort');
    });
  }

  void _generateGradientLevel() {
    final random = Random();
    
    // Choose starting HSL
    final double startHue = random.nextDouble() * 360.0;
    // Difference of 70 to 150 degrees for distinct gradient
    final double hueDiff = 70.0 + random.nextDouble() * 80.0;
    final double endHue = (startHue + (random.nextBool() ? hueDiff : -hueDiff)) % 360.0;
    
    final double startSat = 0.65 + random.nextDouble() * 0.25;
    final double endSat = 0.65 + random.nextDouble() * 0.25;
    
    final double startLight = 0.35 + random.nextDouble() * 0.25;
    final double endLight = 0.35 + random.nextDouble() * 0.25;

    // Number of total blocks increases with levels
    // Level 1: 5 blocks (2 pinned, 3 draggable)
    // Level 5: 7 blocks
    // Level 10+: 9 blocks (max to keep it readable on screens)
    final int totalBlocks = min(9, 5 + (currentLevel - 1) ~/ 2);

    targetColors = [];
    for (int i = 0; i < totalBlocks; i++) {
      double pct = i / (totalBlocks - 1);
      
      // Interpolate hue cleanly (handle cyclic wrap-around if needed, but linear is fine for the selected range)
      double h = startHue + pct * (endHue - startHue);
      double s = startSat + pct * (endSat - startSat);
      double l = startLight + pct * (endLight - startLight);
      
      targetColors.add(HSLColor.fromAHSL(1.0, h % 360.0, s, l).toColor());
    }

    startColor = targetColors.first;
    endColor = targetColors.last;

    // The middle draggable colors
    final List<Color> middleColors = targetColors.sublist(1, totalBlocks - 1);
    
    // Shuffle them until they are not in the correct order
    playerColors = List.from(middleColors);
    while (_isSorted(playerColors, middleColors) && middleColors.length > 1) {
      playerColors.shuffle(random);
    }

    setState(() {
      moves = 0;
      isFinished = false;
    });
  }

  bool _isSorted(List<Color> current, List<Color> target) {
    for (int i = 0; i < current.length; i++) {
      if (current[i] != target[i]) return false;
    }
    return true;
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (isFinished) return;
    
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Color item = playerColors.removeAt(oldIndex);
      playerColors.insert(newIndex, item);
      moves++;

      // Check win condition
      final List<Color> correctMiddle = targetColors.sublist(1, targetColors.length - 1);
      if (_isSorted(playerColors, correctMiddle)) {
        isFinished = true;
        _handleWin();
      }
    });
  }

  void _handleWin() {
    HighScoreService.instance.saveScore('gradient_sort', currentLevel).then((isNewHigh) {
      if (isNewHigh) {
        _loadHighScore();
      }
    });
  }

  void _nextLevel() {
    setState(() {
      currentLevel++;
      _generateGradientLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = const Color(0xFF38BDF8); // neon blue

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF030712),
      appBar: AppBar(
        title: Text(l10n.gradientSort),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Stats Card (Glassmorphism border)
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
                          Text(
                            l10n.levelLabel(currentLevel.toString()),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.highLevel(highScore),
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
                            l10n.movesCount(moves),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.brainTrainingCategory(l10n.visualGames),
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
                  l10n.gradientSortDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 48),

                // Pinned start, reorderable list, and pinned end in horizontal row
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      // Left anchor (startColor)
                      _buildGradientBlock(startColor, isLocked: true),
                      
                      const SizedBox(width: 8),

                      // Reorderable middle colors
                      Expanded(
                        child: ReorderableListView.builder(
                          scrollDirection: Axis.horizontal,
                          onReorder: _onReorder,
                          itemCount: playerColors.length,
                          itemBuilder: (context, index) {
                            return _buildGradientBlock(
                              playerColors[index],
                              key: ValueKey(playerColors[index].value),
                              isLocked: false,
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 8),

                      // Right anchor (endColor)
                      _buildGradientBlock(endColor, isLocked: true),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Success / Win Modal overlay inside layout
                if (isFinished) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF10B981),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.levelComplete,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You sorted the gradient in $moves moves!",
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _nextLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("Next Level"),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _generateGradientLevel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Reset Shuffling"),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBlock(Color color, {Key? key, required bool isLocked}) {
    return Container(
      key: key,
      width: 48,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isLocked
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
