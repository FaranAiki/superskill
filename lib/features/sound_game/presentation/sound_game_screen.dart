import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cognitivegarden/l10n/app_localizations.dart';
import 'package:cognitivegarden/core/soundfont_service.dart';
import 'package:cognitivegarden/core/high_score_service.dart';

class SoundGameScreen extends StatefulWidget {
  const SoundGameScreen({super.key});

  @override
  State<SoundGameScreen> createState() => _SoundGameScreenState();
}

class _SoundGameScreenState extends State<SoundGameScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> notes = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  final List<Map<String, dynamic>> instruments = const [
    {'id': 0, 'name': 'Grand Piano', 'icon': Icons.piano},
    {'id': 11, 'name': 'Vibraphone', 'icon': Icons.music_note},
    {'id': 24, 'name': 'Nylon Guitar', 'icon': Icons.music_video},
    {'id': 80, 'name': 'Synth Lead', 'icon': Icons.keyboard},
    {'id': 21, 'name': 'Accordion', 'icon': Icons.piano_off},
    {'id': 40, 'name': 'Violin', 'icon': Icons.music_note_outlined},
    {'id': 56, 'name': 'Trumpet', 'icon': Icons.audiotrack},
    {'id': 73, 'name': 'Flute', 'icon': Icons.waves},
  ];
  
  late String targetNote;
  late int targetMidiKey;
  String? selectedNote;
  bool? isCorrect;
  bool isPlaying = false;
  bool isLoadingSoundFont = true;
  
  // Stats
  int score = 0;
  int streak = 0;

  // Settings
  bool randomizeOctave = false;
  bool randomizeInstrument = false;
  int selectedOctave = 4; // Default C4 octave
  int selectedInstrument = 0; // 0 = Piano default

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _initSoundFont();
  }

  Future<void> _initSoundFont() async {
    if (!SoundFontService.instance.isLoaded) {
      await SoundFontService.instance.init();
    }
    if (mounted) {
      setState(() {
        isLoadingSoundFont = false;
      });
      _generateNewRound();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateNewRound() {
    final rand = Random();
    final noteIndex = rand.nextInt(notes.length);
    final targetNoteTemp = notes[noteIndex];

    int octave = selectedOctave;
    if (randomizeOctave) {
      octave = 3 + rand.nextInt(3); // 3, 4, or 5
    }
    
    if (randomizeInstrument) {
      selectedInstrument = instruments[rand.nextInt(instruments.length)]['id'] as int;
    }
    
    // MIDI Key: 12 * (octave + 1) + noteIndex
    final targetMidiKeyTemp = 12 * (octave + 1) + noteIndex;

    setState(() {
      targetNote = targetNoteTemp;
      targetMidiKey = targetMidiKeyTemp;
      selectedNote = null;
      isCorrect = null;
    });
    
    _playTargetNote();
  }

  Future<void> _playTargetNote() async {
    if (isLoadingSoundFont) return;
    setState(() => isPlaying = true);
    
    try {
      final wavBytes = SoundFontService.instance.generateWavBytes(
        targetMidiKey,
        instrument: selectedInstrument,
        duration: 1.5,
      );
      await _audioPlayer.play(BytesSource(wavBytes));
    } catch (e) {
      debugPrint('Error playing note: $e');
    }
    
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => isPlaying = false);
  }

  void _checkAnswer(String note) {
    if (isCorrect != null) return;
    final correct = note == targetNote;
    setState(() {
      selectedNote = note;
      isCorrect = correct;
      if (correct) {
        score += 10;
        streak += 1;
        HighScoreService.instance.saveScore('perfect_pitch', score);
      } else {
        streak = 0;
      }
    });
    _playFeedbackSound(correct);
  }

  Future<void> _playFeedbackSound(bool correct) async {
    try {
      final wav = correct
          ? SoundFontService.instance.generateCorrectChime(instrument: selectedInstrument)
          : SoundFontService.instance.generateIncorrectChime(instrument: selectedInstrument);
      await _audioPlayer.play(BytesSource(wav));
    } catch (e) {
      debugPrint('Error playing feedback sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Neon colors according to constraints
    const darkBgColor = Color(0xFF030712);
    const neonBlue = Color(0xFF38BDF8);

    return Scaffold(
      backgroundColor: darkBgColor,
      appBar: AppBar(
        title: Text(
          l10n.perfectPitchTrainer,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoadingSoundFont) ...[
                  const SizedBox(height: 100),
                  const CircularProgressIndicator(color: neonBlue),
                  const SizedBox(height: 24),
                  const Text(
                    "Loading SoundFont Synth...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ] else ...[
                  // Score Panel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatTile(label: "Score", value: "$score", color: neonBlue),
                      _StatTile(label: "Streak", value: "$streak🔥", color: Colors.orangeAccent),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Glassmorphism card for settings
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: neonBlue.withOpacity(0.2), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Synthesizer Settings",
                          style: TextStyle(color: neonBlue, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Scrollable Instruments List
                        const Text(
                          "Choose Instrument",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: instruments.map((inst) {
                                final isSelected = selectedInstrument == inst['id'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    avatar: Icon(
                                      inst['icon'] as IconData, 
                                      size: 16, 
                                      color: isSelected ? Colors.black : Colors.white70
                                    ),
                                    label: Text(inst['name'] as String),
                                    selected: isSelected,
                                    selectedColor: neonBlue,
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    onSelected: randomizeInstrument ? null : (selected) {
                                      if (selected) {
                                        setState(() {
                                          selectedInstrument = inst['id'] as int;
                                        });
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Randomize Instrument", style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: const Text("Change instrument dynamically each round", style: TextStyle(color: Colors.white60, fontSize: 12)),
                          activeColor: neonBlue,
                          value: randomizeInstrument,
                          onChanged: (val) {
                            setState(() {
                              randomizeInstrument = val;
                            });
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Randomize Octave", style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: const Text("Test pitch hearing across multiple octaves", style: TextStyle(color: Colors.white60, fontSize: 12)),
                          activeColor: neonBlue,
                          value: randomizeOctave,
                          onChanged: (val) {
                            setState(() {
                              randomizeOctave = val;
                            });
                          },
                        ),
                        if (!randomizeOctave) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Fixed Octave", style: TextStyle(color: Colors.white, fontSize: 14)),
                              Row(
                                children: [3, 4, 5].map((oct) {
                                  final isSelected = selectedOctave == oct;
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ChoiceChip(
                                      label: Text("C$oct"),
                                      selected: isSelected,
                                      selectedColor: neonBlue,
                                      backgroundColor: Colors.white.withOpacity(0.05),
                                      labelStyle: const TextStyle(color: Colors.white),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => selectedOctave = oct);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.listenAndGuess,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  // Animated glowing play button
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.08);
                      return Transform.scale(
                        scale: isPlaying ? scale : 1.0,
                        child: GestureDetector(
                          onTap: isPlaying ? null : _playTargetNote,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [neonBlue, Color(0xFF0284C7)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: neonBlue.withOpacity(isPlaying ? 0.6 : 0.3),
                                  blurRadius: isPlaying ? 30 : 15,
                                  spreadRadius: isPlaying ? 8 : 2,
                                )
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.volume_up : Icons.play_arrow,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  // Glassmorphism keyboard layout
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: neonBlue.withOpacity(0.15), width: 1),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: notes.map((note) {
                        final isSelected = selectedNote == note;
                        Color? btnColor;
                        if (isSelected) {
                          btnColor = isCorrect! ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
                        } else if (isCorrect != null && note == targetNote) {
                          btnColor = const Color(0xFF10B981).withOpacity(0.4);
                        }

                        return SizedBox(
                          width: 80,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => _checkAnswer(note),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: btnColor ?? Colors.white.withOpacity(0.05),
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: btnColor != null 
                                  ? btnColor.withOpacity(0.8) 
                                  : neonBlue.withOpacity(0.2), 
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              note,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isCorrect != null) ...[
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Text(
                        isCorrect! ? l10n.correct : l10n.wrongNote(targetNote),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isCorrect! ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _generateNewRound,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.nextNote),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonBlue,
                        foregroundColor: darkBgColor,
                        minimumSize: const Size(220, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
