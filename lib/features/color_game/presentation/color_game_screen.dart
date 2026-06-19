import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superskill/l10n/app_localizations.dart';

enum ColorGameMode { rgb, cmyk, ryb }

class ColorGameScreen extends ConsumerStatefulWidget {
  final ColorGameMode mode;
  const ColorGameScreen({super.key, required this.mode});

  @override
  ConsumerState<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends ConsumerState<ColorGameScreen> {
  late Color targetColor;
  double r = 0, g = 0, b = 0;
  double c = 0, m = 0, y = 0, k = 0;
  double ryb_r = 128, ryb_y = 128, ryb_b = 128;
  double? score;
  bool submitted = false;

  bool showTargetHex = false;
  bool showUserPreview = true;

  @override
  void initState() {
    super.initState();
    _generateNewColor();
  }

  void _generateNewColor() {
    setState(() {
      final random = Random();
      if (widget.mode == ColorGameMode.ryb) {
        double tempR = random.nextDouble() * 255.0;
        double tempY = random.nextDouble() * 255.0;
        double tempB = random.nextDouble() * 255.0;
        targetColor = _rybToColor(tempR, tempY, tempB);
      } else {
        targetColor = Color.fromARGB(
          255,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
      }
      submitted = false;
      score = null;
      
      r = g = b = 128;
      c = m = y = k = 0;
      ryb_r = ryb_y = ryb_b = 128;
      showTargetHex = false;
    });
  }

  void _calculateScore() {
    double distance = 0;
    if (widget.mode == ColorGameMode.rgb) {
      distance = sqrt(
        pow(targetColor.red - r, 2) +
        pow(targetColor.green - g, 2) +
        pow(targetColor.blue - b, 2)
      );
    } else if (widget.mode == ColorGameMode.ryb) {
      Color userColor = _rybToColor(ryb_r, ryb_y, ryb_b);
      distance = sqrt(
        pow(targetColor.red - userColor.red, 2) +
        pow(targetColor.green - userColor.green, 2) +
        pow(targetColor.blue - userColor.blue, 2)
      );
    } else {
      double userR = 255 * (1 - c / 100) * (1 - k / 100);
      double userG = 255 * (1 - m / 100) * (1 - k / 100);
      double userB = 255 * (1 - y / 100) * (1 - k / 100);
      
      distance = sqrt(
        pow(targetColor.red - userR, 2) +
        pow(targetColor.green - userG, 2) +
        pow(targetColor.blue - userB, 2)
      );
    }
    
    setState(() {
      score = distance;
      submitted = true;
      showTargetHex = true;
      showUserPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userColor = widget.mode == ColorGameMode.rgb 
        ? Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt())
        : widget.mode == ColorGameMode.ryb
            ? _rybToColor(ryb_r, ryb_y, ryb_b)
            : _cmykToColor(c, m, y, k);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == ColorGameMode.rgb 
            ? l10n.tebakHexRgb 
            : widget.mode == ColorGameMode.ryb
                ? l10n.tebakHexRyb
                : l10n.tebakHexCmyk),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF38BDF8)),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ColorBox(
                        label: l10n.target,
                        subLabel: showTargetHex 
                            ? 'HEX: #${targetColor.value.toRadixString(16).substring(2).toUpperCase()}'
                            : '???',
                        color: targetColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ColorBox(
                        label: l10n.yourResult,
                        subLabel: showUserPreview ? l10n.previewActive : l10n.hidden,
                        color: showUserPreview ? userColor : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      if (widget.mode == ColorGameMode.rgb) ...[
                        _buildSlider(l10n.red, r, 0, 255, (v) => setState(() => r = v), const Color(0xFFEF4444)),
                        _buildSlider(l10n.green, g, 0, 255, (v) => setState(() => g = v), const Color(0xFF10B981)),
                        _buildSlider(l10n.blue, b, 0, 255, (v) => setState(() => b = v), const Color(0xFF3B82F6)),
                      ] else if (widget.mode == ColorGameMode.ryb) ...[
                        _buildSlider(l10n.red, ryb_r, 0, 255, (v) => setState(() => ryb_r = v), const Color(0xFFEF4444)),
                        _buildSlider(l10n.yellow, ryb_y, 0, 255, (v) => setState(() => ryb_y = v), const Color(0xFFFACC15)),
                        _buildSlider(l10n.blue, ryb_b, 0, 255, (v) => setState(() => ryb_b = v), const Color(0xFF3B82F6)),
                      ] else ...[
                        _buildSlider(l10n.cyan, c, 0, 100, (v) => setState(() => c = v), const Color(0xFF22D3EE), isCmyk: true),
                        _buildSlider(l10n.pink, m, 0, 100, (v) => setState(() => m = v), const Color(0xFFF472B6), isCmyk: true),
                        _buildSlider(l10n.yellow, y, 0, 100, (v) => setState(() => y = v), const Color(0xFFFACC15), isCmyk: true),
                        _buildSlider(l10n.white, k, 0, 100, (v) => setState(() => k = v), Colors.grey, isCmyk: true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (submitted)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: ((score ?? 100) < 30 ? Colors.green : Colors.orange).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (score ?? 100) < 30 ? Colors.green : Colors.orange),
                    ),
                    child: Text(
                      '${l10n.difference}: ${score?.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: (score ?? 100) < 30 ? Colors.greenAccent : Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: submitted ? _generateNewColor : _calculateScore,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      submitted ? l10n.playAgain : l10n.checkScore,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.gameSettings, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.showUserPreview),
                  activeColor: const Color(0xFF38BDF8),
                  value: showUserPreview,
                  onChanged: (v) {
                    setState(() => showUserPreview = v);
                    setModalState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.showTargetHex),
                  activeColor: const Color(0xFF38BDF8),
                  value: showTargetHex,
                  onChanged: (v) {
                    setState(() => showTargetHex = v);
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

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, Color activeColor, {bool isCmyk = false}) {
    int hexVal = isCmyk ? (value * 2.55).toInt() : value.toInt();
    String hexString = '0x${hexVal.toRadixString(16).padLeft(2, '0').toUpperCase()}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.bold)),
              InkWell(
                onTap: submitted ? null : () => _showManualInput(label, value, isCmyk, onChanged),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: activeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    hexString,
                    style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: activeColor),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: activeColor.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: activeColor.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: submitted ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInput(String label, double currentVal, bool isCmyk, ValueChanged<double> onChanged) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    int hexVal = isCmyk ? (currentVal * 2.55).toInt() : currentVal.toInt();
    controller.text = hexVal.toRadixString(16).toUpperCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(l10n.inputHexFor(label)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: l10n.hexHint,
            prefixText: '0x ',
            prefixStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: const OutlineInputBorder(),
          ),
          maxLength: 2,
          onSubmitted: (val) {
            _processHexInput(val, isCmyk, onChanged);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              _processHexInput(controller.text, isCmyk, onChanged);
              Navigator.pop(context);
            },
            child: Text(l10n.ok, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _processHexInput(String val, bool isCmyk, ValueChanged<double> onChanged) {
    try {
      int? parsed = int.tryParse(val, radix: 16);
      if (parsed != null && parsed >= 0 && parsed <= 255) {
        double finalVal = isCmyk ? parsed / 2.55 : parsed.toDouble();
        onChanged(finalVal);
      }
    } catch (_) {}
  }

  Color _cmykToColor(double c, double m, double y, double k) {
    double r = 255 * (1 - c / 100) * (1 - k / 100);
    double g = 255 * (1 - m / 100) * (1 - k / 100);
    double b = 255 * (1 - y / 100) * (1 - k / 100);
    return Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt());
  }

  Color _rybToColor(double r, double y, double b) {
    // Normalize to 0..1
    double R = r / 255.0;
    double Y = y / 255.0;
    double B = b / 255.0;

    // 8 corners of the RYB interpolation cube in RGB
    final c000 = [255, 255, 255]; // White
    final c100 = [255, 0, 0];     // Red
    final c010 = [255, 255, 0];   // Yellow
    final c001 = [0, 0, 255];     // Blue
    final c110 = [255, 128, 0];   // Orange
    final c011 = [0, 168, 51];    // Green
    final c101 = [127, 0, 127];   // Purple/Violet
    final c111 = [32, 24, 16];    // Dark Brown/Black

    double redVal = 
        c000[0] * (1 - R) * (1 - Y) * (1 - B) +
        c100[0] * R * (1 - Y) * (1 - B) +
        c010[0] * (1 - R) * Y * (1 - B) +
        c001[0] * (1 - R) * (1 - Y) * B +
        c110[0] * R * Y * (1 - B) +
        c101[0] * R * (1 - Y) * B +
        c011[0] * (1 - R) * Y * B +
        c111[0] * R * Y * B;

    double greenVal = 
        c000[1] * (1 - R) * (1 - Y) * (1 - B) +
        c100[1] * R * (1 - Y) * (1 - B) +
        c010[1] * (1 - R) * Y * (1 - B) +
        c001[1] * (1 - R) * (1 - Y) * B +
        c110[1] * R * Y * (1 - B) +
        c101[1] * R * (1 - Y) * B +
        c011[1] * (1 - R) * Y * B +
        c111[1] * R * Y * B;

    double blueVal = 
        c000[2] * (1 - R) * (1 - Y) * (1 - B) +
        c100[2] * R * (1 - Y) * (1 - B) +
        c010[2] * (1 - R) * Y * (1 - B) +
        c001[2] * (1 - R) * (1 - Y) * B +
        c110[2] * R * Y * (1 - B) +
        c101[2] * R * (1 - Y) * B +
        c011[2] * (1 - R) * Y * B +
        c111[2] * R * Y * B;

    return Color.fromARGB(
      255,
      redVal.clamp(0, 255).toInt(),
      greenVal.clamp(0, 255).toInt(),
      blueVal.clamp(0, 255).toInt(),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final String label;
  final String subLabel;
  final Color color;

  const _ColorBox({required this.label, required this.subLabel, required this.color});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6))),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.1), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
