import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class HighScoreService {
  static final HighScoreService instance = HighScoreService._();
  HighScoreService._();

  Map<String, int> _scores = {};
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final file = await _getScoresFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> json = jsonDecode(content);
        _scores = json.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      debugPrint("Failed to load scores: $e");
    }
    _isInitialized = true;
  }

  Future<File> _getScoresFile() async {
    String home = "";
    if (Platform.isWindows) {
      home = Platform.environment['USERPROFILE'] ?? '.';
    } else {
      home = Platform.environment['HOME'] ?? '.';
    }
    final dir = Directory('$home/.superskill');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/scores.json');
  }

  int getHighScore(String gameId) {
    return _scores[gameId] ?? 0;
  }

  Future<bool> saveScore(String gameId, int score) async {
    await init();
    final currentHigh = getHighScore(gameId);
    if (score > currentHigh) {
      _scores[gameId] = score;
      try {
        final file = await _getScoresFile();
        await file.writeAsString(jsonEncode(_scores));
        return true; // New high score!
      } catch (e) {
        debugPrint("Failed to save score: $e");
      }
    }
    return false;
  }

  Map<String, int> getAllScores() {
    return Map.from(_scores);
  }
}
