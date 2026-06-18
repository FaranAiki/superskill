// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get miniGamesHub => 'Superskill Hub';

  @override
  String get visualGames => 'Game Visual';

  @override
  String get audioGames => 'Game Audio';

  @override
  String get brainGames => 'Game Otak';

  @override
  String get memoryGames => 'Game Memori';

  @override
  String get spatialGames => 'Game Spasial';

  @override
  String get tebakHexRgb => 'Tebak HEX/RGB';

  @override
  String get pointDiffSystem => 'Sistem poin selisih warna';

  @override
  String get tebakHexCmyk => 'Tebak HEX/CMYK';

  @override
  String get cmykChallenge => 'Tantangan warna CMYK';

  @override
  String get perfectPitch => 'Perfect Pitch';

  @override
  String get trainMusicPitch => 'Latih pendengaran nada musik';

  @override
  String get brainReflex => 'Brain Reflex';

  @override
  String get stroopTestDesc => 'Stroop Test: Latih fokus & akurasi';

  @override
  String get target => 'Target';

  @override
  String get yourResult => 'Hasil Kamu';

  @override
  String get previewActive => 'Preview Aktif';

  @override
  String get hidden => 'Hidden';

  @override
  String get red => 'Merah';

  @override
  String get green => 'Hijau';

  @override
  String get blue => 'Biru';

  @override
  String get cyan => 'Sian';

  @override
  String get pink => 'Merah Muda';

  @override
  String get yellow => 'Kuning';

  @override
  String get white => 'Putih';

  @override
  String get difference => 'Selisih';

  @override
  String get playAgain => 'Main Lagi';

  @override
  String get checkScore => 'Cek Skor';

  @override
  String get gameSettings => 'Pengaturan Game';

  @override
  String get showUserPreview => 'Tampilkan Preview Warna Kamu';

  @override
  String get showTargetHex => 'Tampilkan Kode HEX Target';

  @override
  String inputHexFor(String label) {
    return 'Input HEX untuk $label';
  }

  @override
  String get hexHint => 'misal: FF atau 80';

  @override
  String get cancel => 'Batal';

  @override
  String get ok => 'Ok';

  @override
  String get perfectPitchTrainer => 'Pelatih Perfect Pitch';

  @override
  String get listenAndGuess => 'Dengarkan nada dan tebak!';

  @override
  String get correct => 'Benar!';

  @override
  String wrongNote(String targetNote) {
    return 'Salah! Itu adalah nada $targetNote';
  }

  @override
  String get nextNote => 'Nada selanjutnya';

  @override
  String get brainReflexStroop => 'Brain Reflex: Stroop';

  @override
  String timeLabel(int timeLeft) {
    return 'Waktu: $timeLeft';
  }

  @override
  String scoreLabel(int score) {
    return 'Skor: $score';
  }

  @override
  String get pickInkColor => 'Pilih warna tinta';

  @override
  String get pickWordMeaning => 'Pilih arti kata';

  @override
  String get timeUp => 'Waktu habis!';

  @override
  String get yourFinalScore => 'Skor Akhir Kamu:';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get backToMenu => 'Kembali ke menu';

  @override
  String get language => 'Bahasa';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get memorySequence => 'Urutan Memori';

  @override
  String get memorySequenceDesc => 'Ingat dan ulangi urutan warna';

  @override
  String get watchSequence => 'Perhatikan urutannya!';

  @override
  String get yourTurn => 'Giliranmu!';

  @override
  String levelLabel(String level) {
    return 'Level: $level';
  }

  @override
  String get tileCount => 'Jumlah Kotak';

  @override
  String get gameSpeed => 'Kecepatan Game';

  @override
  String get fast => 'Cepat';

  @override
  String get medium => 'Sedang';

  @override
  String get slow => 'Lambat';

  @override
  String get superFast => 'Sangat Cepat';

  @override
  String get spatialIq => 'IQ Spasial';

  @override
  String get spatialIqDesc => 'Latih rotasi mental dan kognisi ruang 3D';

  @override
  String get gridSize => 'Ukuran Grid';

  @override
  String get optionsCount => 'Jumlah Opsi';

  @override
  String get matchRotatedShape => 'Temukan bentuk yang cocok!';
}
