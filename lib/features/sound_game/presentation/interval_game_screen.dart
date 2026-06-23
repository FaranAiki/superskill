import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:superskill/l10n/app_localizations.dart';
import 'package:superskill/core/soundfont_service.dart';
import 'package:superskill/core/high_score_service.dart';

class IntervalInfo {
  final int semitones;
  final String nameKey;
  final String englishName;

  const IntervalInfo(this.semitones, this.nameKey, this.englishName);
}

class IntervalGameScreen extends StatefulWidget {
  const IntervalGameScreen({super.key});

  @override
  State<IntervalGameScreen> createState() => _IntervalGameScreenState();
}

class _IntervalGameScreenState extends State<IntervalGameScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<IntervalInfo> intervals = const [
    IntervalInfo(1, 'minor2nd', 'Minor 2nd'),
    IntervalInfo(2, 'major2nd', 'Major 2nd'),
    IntervalInfo(3, 'minor3rd', 'Minor 3rd'),
    IntervalInfo(4, 'major3rd', 'Major 3rd'),
    IntervalInfo(5, 'perfect4th', 'Perfect 4th'),
    IntervalInfo(6, 'tritone', 'Tritone'),
    IntervalInfo(7, 'perfect5th', 'Perfect 5th'),
    IntervalInfo(8, 'minor6th', 'Minor 6th'),
    IntervalInfo(9, 'major6th', 'Major 6th'),
    IntervalInfo(10, 'minor7th', 'Minor 7th'),
    IntervalInfo(11, 'major7th', 'Major 7th'),
    IntervalInfo(12, 'perfectOctave', 'Perfect Octave'),
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

  late IntervalInfo correctIntervalInfo;
  late int note1MidiKey;
  late int note2MidiKey;
  List<IntervalInfo> options = [];
  IntervalInfo? selectedOption;
  bool? isCorrect;
  bool isPlaying = false;
  int activeNoteIndex = 0; // 0 = Idle, 1 = First Note, 2 = Second Note
  bool isLoadingSoundFont = true;

  // Stats
  int score = 0;
  int streak = 0;

  // Settings
  String selectedDirection = 'Ascending'; // Ascending, Descending
  int selectedInstrument = 0; // 0 = Piano default

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    
    // Choose correct interval
    correctIntervalInfo = intervals[rand.nextInt(intervals.length)];
    
    // Choose base note midi key: G3 (55) to G4 (67)
    final baseMidiKey = 55 + rand.nextInt(13);
    note1MidiKey = baseMidiKey;
    
    // Calculate second note based on direction
    if (selectedDirection == 'Ascending') {
      note2MidiKey = baseMidiKey + correctIntervalInfo.semitones;
    } else {
      note2MidiKey = baseMidiKey - correctIntervalInfo.semitones;
    }
    
    // Generate wrong options
    final wrongOptions = intervals.where((element) => element.semitones != correctIntervalInfo.semitones).toList();
    wrongOptions.shuffle();
    
    options = [
      correctIntervalInfo,
      wrongOptions[0],
      wrongOptions[1],
      wrongOptions[2],
    ];
    options.shuffle();

    setState(() {
      selectedOption = null;
      isCorrect = null;
      activeNoteIndex = 0;
    });
    
    _playInterval();
  }

  Future<void> _playInterval() async {
    if (isLoadingSoundFont || isPlaying) return;
    setState(() {
      isPlaying = true;
      activeNoteIndex = 1;
    });

    try {
      // Play note 1
      final wav1 = SoundFontService.instance.generateWavBytes(
        note1MidiKey,
        instrument: selectedInstrument,
        duration: 1.0,
      );
      await _audioPlayer.play(BytesSource(wav1));
      
      await Future.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      
      setState(() {
        activeNoteIndex = 2;
      });

      // Play note 2
      final wav2 = SoundFontService.instance.generateWavBytes(
        note2MidiKey,
        instrument: selectedInstrument,
        duration: 1.2,
      );
      await _audioPlayer.play(BytesSource(wav2));
    } catch (e) {
      debugPrint('Error playing interval: $e');
    }

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        isPlaying = false;
        activeNoteIndex = 0;
      });
    }
  }

  void _checkAnswer(IntervalInfo opt) {
    if (isCorrect != null) return;
    final correct = opt.semitones == correctIntervalInfo.semitones;
    setState(() {
      selectedOption = opt;
      isCorrect = correct;
      if (correct) {
        score += 10;
        streak += 1;
        HighScoreService.instance.saveScore('sound_interval', score);
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

  String _getIntervalName(IntervalInfo info, AppLocalizations l10n) {
    switch (info.nameKey) {
      case 'minor2nd': return l10n.minor2nd;
      case 'major2nd': return l10n.major2nd;
      case 'minor3rd': return l10n.minor3rd;
      case 'major3rd': return l10n.major3rd;
      case 'perfect4th': return l10n.perfect4th;
      case 'tritone': return l10n.tritone;
      case 'perfect5th': return l10n.perfect5th;
      case 'minor6th': return l10n.minor6th;
      case 'major6th': return l10n.major6th;
      case 'minor7th': return l10n.minor7th;
      case 'major7th': return l10n.major7th;
      case 'perfectOctave': return l10n.perfectOctave;
      default: return info.englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    const darkBgColor = Color(0xFF030712);
    const neonBlue = Color(0xFF38BDF8);

    return Scaffold(
      backgroundColor: darkBgColor,
      appBar: AppBar(
        title: Text(
          l10n.soundIntervalGame,
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
                  // Score panel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatTile(label: "Score", value: "$score", color: neonBlue),
                      _StatTile(label: "Streak", value: "$streak🔥", color: Colors.orangeAccent),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Settings Panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: neonBlue.withOpacity(0.15), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Settings",
                          style: TextStyle(color: neonBlue, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        // Scrollable Instruments List
                        const Text(
                          "Choose Instrument",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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
                                    onSelected: (selected) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.intervalDirection, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            Row(
                              children: ['Ascending', 'Descending'].map((dir) {
                                final isSel = selectedDirection == dir;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: ChoiceChip(
                                    label: Text(dir == 'Ascending' ? l10n.intervalAscending : l10n.intervalDescending),
                                    selected: isSel,
                                    selectedColor: neonBlue,
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    labelStyle: const TextStyle(color: Colors.white),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          selectedDirection = dir;
                                        });
                                        _generateNewRound();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Notes visualization
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NoteIndicator(
                        label: l10n.firstNote,
                        active: activeNoteIndex == 1,
                        pulseController: _pulseController,
                        color: neonBlue,
                      ),
                      const SizedBox(width: 48),
                      _NoteIndicator(
                        label: l10n.secondNote,
                        active: activeNoteIndex == 2,
                        pulseController: _pulseController,
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Play Button
                  GestureDetector(
                    onTap: isPlaying ? null : _playInterval,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.white.withOpacity(0.05) : neonBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: neonBlue, width: 1.5),
                        boxShadow: [
                          if (!isPlaying)
                            BoxShadow(
                              color: neonBlue.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlaying ? Icons.music_note : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.playInterval,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Option buttons
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.2,
                    children: options.map((opt) {
                      final isSelected = selectedOption == opt;
                      Color? buttonColor;
                      if (isSelected) {
                        buttonColor = isCorrect! ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
                      } else if (isCorrect != null && opt.semitones == correctIntervalInfo.semitones) {
                        buttonColor = const Color(0xFF10B981).withOpacity(0.4);
                      }

                      return ElevatedButton(
                        onPressed: isPlaying ? null : () => _checkAnswer(opt),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor ?? Colors.white.withOpacity(0.04),
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: buttonColor != null 
                              ? buttonColor.withOpacity(0.8) 
                              : neonBlue.withOpacity(0.15),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _getIntervalName(opt, l10n),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 36),
                  
                  if (isCorrect != null) ...[
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Text(
                        isCorrect! 
                          ? l10n.correct 
                          : l10n.wrongInterval(_getIntervalName(correctIntervalInfo, l10n)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isCorrect! ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _generateNewRound,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.nextInterval),
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

class _NoteIndicator extends StatelessWidget {
  final String label;
  final bool active;
  final AnimationController pulseController;
  final Color color;

  const _NoteIndicator({
    required this.label,
    required this.active,
    required this.pulseController,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            final double glowScale = 1.0 + (pulseController.value * 0.15);
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? color : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: active ? color : color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 15 * glowScale,
                      spreadRadius: 2 * glowScale,
                    )
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  color: active ? Colors.white : Colors.white24,
                  size: 32,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white60,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        )
      ],
    );
  }
}
