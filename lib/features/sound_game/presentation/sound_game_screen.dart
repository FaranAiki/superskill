import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:superskill/l10n/app_localizations.dart';

class SoundGameScreen extends StatefulWidget {
  const SoundGameScreen({super.key});

  @override
  State<SoundGameScreen> createState() => _SoundGameScreenState();
}

class _SoundGameScreenState extends State<SoundGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> notes = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  
  late String targetNote;
  String? selectedNote;
  bool? isCorrect;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _generateNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateNewRound() {
    setState(() {
      targetNote = notes[Random().nextInt(notes.length)];
      selectedNote = null;
      isCorrect = null;
    });
    _playTargetNote();
  }

  Future<void> _playTargetNote() async {
    setState(() => isPlaying = true);
    try {
      debugPrint('Playing note: $targetNote');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => isPlaying = false);
  }

  void _checkAnswer(String note) {
    if (isCorrect != null) return;
    setState(() {
      selectedNote = note;
      isCorrect = note == targetNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.perfectPitchTrainer),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.listenAndGuess,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: isPlaying ? null : _playTargetNote,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isPlaying 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.volume_up : Icons.play_arrow,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: notes.map((note) {
                    final isSelected = selectedNote == note;
                    Color? btnColor;
                    if (isSelected) {
                      btnColor = isCorrect! ? Colors.green : Colors.red;
                    } else if (isCorrect != null && note == targetNote) {
                      btnColor = Colors.green.withOpacity(0.5);
                    }

                    return SizedBox(
                      width: 70,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _checkAnswer(note),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: btnColor,
                          foregroundColor: btnColor != null ? Colors.white : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          note,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                if (isCorrect != null) ...[
                  Text(
                    isCorrect! ? l10n.correct : l10n.wrongNote(targetNote),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCorrect! ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _generateNewRound,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.nextNote),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
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
}
