import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundFontService {
  SoundFontService._();
  static final SoundFontService instance = SoundFontService._();

  Synthesizer? _synthesizer;
  bool _isLoaded = false;
  ByteData? _soundFontData;
  
  // Shared feedback player removed to allow non-blocking concurrent sounds

  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      debugPrint('Loading SoundFont asset...');
      _soundFontData = await rootBundle.load('assets/sounds/GeneralUser GS v1.471.sf2');
      debugPrint('SoundFont asset loaded. Size: ${_soundFontData!.lengthInBytes} bytes. Initializing Synthesizer...');
      _synthesizer = Synthesizer.loadByteData(
        _soundFontData!,
        SynthesizerSettings(
          sampleRate: 44100,
          blockSize: 64,
          maximumPolyphony: 64,
          enableReverbAndChorus: true,
        ),
      );
      _isLoaded = true;
      debugPrint('SoundFont Synthesizer loaded successfully.');
    } catch (e) {
      debugPrint('Error loading SoundFont: $e');
    }
  }

  /// Synthesizes a MIDI note and returns a WAV byte array.
  /// [midiKey] MIDI key number (e.g., 60 for C4).
  /// [instrument] MIDI program number (0 for Piano, etc.).
  /// [duration] duration of the sound in seconds.
  Uint8List generateWavBytes(int midiKey, {int instrument = 0, double duration = 1.5}) {
    if (!_isLoaded || _synthesizer == null) {
      throw StateError("SoundFontService is not loaded. Call init() first.");
    }

    final synth = _synthesizer!;
    synth.selectPreset(channel: 0, preset: instrument);
    synth.noteOn(channel: 0, key: midiKey, velocity: 100);

    const sampleRate = 44100;
    final numSamples = (sampleRate * duration).toInt();
    final buf16 = ArrayInt16.zeros(numShorts: numSamples);
    
    synth.renderMonoInt16(buf16);

    final pcmBytes = buf16.bytes.buffer.asUint8List();
    return _pcmToWav(pcmBytes, sampleRate, 1, 16);
  }

  /// Generates a positive/correct arpeggio chime sound.
  Uint8List generateCorrectChime({int instrument = 0}) {
    if (!_isLoaded || _synthesizer == null) {
      throw StateError("SoundFontService is not loaded. Call init() first.");
    }
    final synth = _synthesizer!;
    synth.selectPreset(channel: 0, preset: instrument);
    
    // Play C major arpeggio/chime
    synth.noteOn(channel: 0, key: 72, velocity: 100); // C5
    synth.noteOn(channel: 0, key: 76, velocity: 90);  // E5
    synth.noteOn(channel: 0, key: 79, velocity: 90);  // G5
    synth.noteOn(channel: 0, key: 84, velocity: 100); // C6

    const sampleRate = 44100;
    final numSamples = (sampleRate * 0.8).toInt();
    final buf16 = ArrayInt16.zeros(numShorts: numSamples);
    synth.renderMonoInt16(buf16);

    final pcmBytes = buf16.bytes.buffer.asUint8List();
    return _pcmToWav(pcmBytes, sampleRate, 1, 16);
  }

  /// Generates a low, dissonant buzz sound for incorrect answers.
  Uint8List generateIncorrectChime({int instrument = 0}) {
    if (!_isLoaded || _synthesizer == null) {
      throw StateError("SoundFontService is not loaded. Call init() first.");
    }
    final synth = _synthesizer!;
    synth.selectPreset(channel: 0, preset: instrument);
    
    // Play dissonant low cluster
    synth.noteOn(channel: 0, key: 45, velocity: 100); // A2
    synth.noteOn(channel: 0, key: 46, velocity: 100); // A#2

    const sampleRate = 44100;
    final numSamples = (sampleRate * 0.6).toInt();
    final buf16 = ArrayInt16.zeros(numShorts: numSamples);
    synth.renderMonoInt16(buf16);

    final pcmBytes = buf16.bytes.buffer.asUint8List();
    return _pcmToWav(pcmBytes, sampleRate, 1, 16);
  }

  /// Plays the correct chime sound.
  Future<void> playCorrect({int instrument = 0}) async {
    try {
      if (!_isLoaded) await init();
      final wav = generateCorrectChime(instrument: instrument);
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(BytesSource(wav));
    } catch (e) {
      debugPrint('Error playing correct sound feedback: $e');
    }
  }

  /// Plays the incorrect buzz sound.
  Future<void> playIncorrect({int instrument = 0}) async {
    try {
      if (!_isLoaded) await init();
      final wav = generateIncorrectChime(instrument: instrument);
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(BytesSource(wav));
    } catch (e) {
      debugPrint('Error playing incorrect sound feedback: $e');
    }
  }

  /// Plays a short button click tick sound.
  Future<void> playClick({int instrument = 0}) async {
    try {
      if (!_isLoaded) await init();
      final synth = _synthesizer;
      if (synth == null) return;
      synth.selectPreset(channel: 0, preset: instrument);
      synth.noteOn(channel: 0, key: 76, velocity: 80); // E5
      const sampleRate = 44100;
      final numSamples = (sampleRate * 0.05).toInt();
      final buf16 = ArrayInt16.zeros(numShorts: numSamples);
      synth.renderMonoInt16(buf16);
      final pcmBytes = buf16.bytes.buffer.asUint8List();
      final wav = _pcmToWav(pcmBytes, sampleRate, 1, 16);
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(BytesSource(wav));
    } catch (e) {
      debugPrint('Error playing click sound feedback: $e');
    }
  }

  Uint8List _pcmToWav(Uint8List pcmBytes, int sampleRate, int numChannels, int bitsPerSample) {
    final header = Uint8List(44);
    final fileLength = pcmBytes.length + 36;
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);

    final bd = ByteData.view(header.buffer);
    
    // "RIFF"
    bd.setUint8(0, 0x52); // R
    bd.setUint8(1, 0x49); // I
    bd.setUint8(2, 0x46); // F
    bd.setUint8(3, 0x46); // F
    
    // File size - 8
    bd.setUint32(4, fileLength, Endian.little);
    
    // "WAVE"
    bd.setUint8(8, 0x57); // W
    bd.setUint8(9, 0x41); // A
    bd.setUint8(10, 0x56); // V
    bd.setUint8(11, 0x45); // E
    
    // "fmt "
    bd.setUint8(12, 0x66); // f
    bd.setUint8(13, 0x6D); // m
    bd.setUint8(14, 0x74); // t
    bd.setUint8(15, 0x20); //  
    
    // Subchunk1Size (16 for PCM)
    bd.setUint32(16, 16, Endian.little);
    
    // AudioFormat (1 for PCM)
    bd.setUint16(20, 1, Endian.little);
    
    // NumChannels
    bd.setUint16(22, numChannels, Endian.little);
    
    // SampleRate
    bd.setUint32(24, sampleRate, Endian.little);
    
    // ByteRate
    bd.setUint32(28, byteRate, Endian.little);
    
    // BlockAlign
    bd.setUint16(32, blockAlign, Endian.little);
    
    // BitsPerSample
    bd.setUint16(34, bitsPerSample, Endian.little);
    
    // "data"
    bd.setUint8(36, 0x64); // d
    bd.setUint8(37, 0x61); // a
    bd.setUint8(38, 0x74); // t
    bd.setUint8(39, 0x61); // a
    
    // Subchunk2Size (data size)
    bd.setUint32(40, pcmBytes.length, Endian.little);

    final wavBytes = Uint8List(44 + pcmBytes.length);
    wavBytes.setRange(0, 44, header);
    wavBytes.setRange(44, wavBytes.length, pcmBytes);
    return wavBytes;
  }
}
