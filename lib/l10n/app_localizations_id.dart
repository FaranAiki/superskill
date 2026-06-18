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

  @override
  String get mazeGame => 'Labirin Neon';

  @override
  String get mazeGameDesc => 'Temukan jalan keluar dari kisi-kisi neon';

  @override
  String get reachTheExit => 'Sampai ke pintu keluar!';

  @override
  String get levelComplete => 'Level Selesai!';

  @override
  String get advancedSettings => 'Pengaturan Lanjutan';

  @override
  String get themeMode => 'Mode Tema';

  @override
  String get dark => 'Gelap';

  @override
  String get light => 'Terang / Putih';

  @override
  String get fontStyle => 'Gaya Huruf';

  @override
  String fontSize(String percent) {
    return 'Ukuran Huruf: $percent%';
  }

  @override
  String get suddenDeath => 'Mati Mendadak (Nabrak = Mati)';

  @override
  String get suddenDeathDesc => 'Kembali ke posisi awal jika menyentuh dinding';

  @override
  String get suddenDeathMessage => 'Yah! Kena Dinding - Balik ke Awal!';

  @override
  String get memorizationMode => 'Mode Hafalan';

  @override
  String get memorizationModeDesc => 'Dinding hilang setelah hitung mundur';

  @override
  String memorizeMaze(int seconds) {
    return 'Hafalkan Labirin: $seconds s';
  }

  @override
  String get resetShowAgain => 'Ulang / Tampilkan Lagi';

  @override
  String get chimpGame => 'Memori Simpanse';

  @override
  String get chimpGameDesc => 'Ingat dan ketuk angka tersembunyi berurutan';

  @override
  String livesLabel(int count) {
    return 'Nyawa: $count';
  }

  @override
  String numbersCount(int count) {
    return 'Jumlah Angka: $count';
  }

  @override
  String get chimpTestStart =>
      'Ketuk 1 untuk memulai dan menyembunyikan angka!';

  @override
  String get chimpTestInstructions =>
      'Ketuk kotak secara berurutan (1, 2, 3...)';

  @override
  String gameOverChimp(int level) {
    return 'Permainan Selesai! Tingkat memori akhir Anda adalah $level angka.';
  }

  @override
  String get blindMode => 'Mode Buta';

  @override
  String get blindModeDesc => 'Sembunyikan bingkai kotak setelah mengetuk 1';

  @override
  String get startingNumbers => 'Angka Awal';

  @override
  String get reflexGame => 'Ketuk Refleks';

  @override
  String get reflexGameDesc => 'Ketuk kotak menyala secepat yang Anda bisa';

  @override
  String gameOverReflex(int score) {
    return 'Permainan Selesai! Skor akhir Anda adalah $score.';
  }

  @override
  String get operatorGame => 'Serbuan Operator';

  @override
  String get operatorGameDesc =>
      'Temukan operator matematika yang hilang secara cepat';

  @override
  String gameOverOperator(int score) {
    return 'Permainan Selesai! Skor akhir Anda adalah $score.';
  }

  @override
  String get numericalGames => 'Game Numerik';

  @override
  String get game24 => 'Game 24';

  @override
  String get game24Desc =>
      'Tentukan apakah kartu bisa digabung untuk mencapai target';

  @override
  String get speedMath => 'Matematika Cepat';

  @override
  String get speedMathDesc =>
      'Hitung deretan angka & operator yang berkedip cepat';

  @override
  String get hideOutlines => 'Sembunyikan Bingkai';

  @override
  String get hideOutlinesDesc =>
      'Sembunyikan bingkai kotak setelah angka menghilang';

  @override
  String get game24Yes => 'Ya (Bisa)';

  @override
  String get game24No => 'Tidak Bisa';

  @override
  String game24CanBeMade(int target) {
    return 'Apakah bisa dibuat $target?';
  }

  @override
  String game24CorrectSolvable(String solution) {
    return 'Benar! Ini solusinya:\n$solution';
  }

  @override
  String get game24CorrectUnsolvable => 'Benar! Memang tidak ada solusi.';

  @override
  String game24WrongSolvable(String solution) {
    return 'Salah! Sebenarnya bisa. Solusi:\n$solution';
  }

  @override
  String get game24WrongUnsolvable =>
      'Salah! Memang tidak ada solusi matematika.';

  @override
  String get diceGame => 'Dadu Spasial';

  @override
  String get diceGameDesc =>
      'Temukan dadu yang valid dengan jumlah sisi berlawanan adalah 7';

  @override
  String get diceGameInstruction =>
      'Putar dadu untuk memeriksa semua sisi. Sisi yang berlawanan harus berjumlah 7!';

  @override
  String get all => 'Semua';

  @override
  String get scoreboard => 'Papan Skor';

  @override
  String highScore(int score) {
    return 'Skor Tertinggi: $score';
  }

  @override
  String get noScoresYet => 'Belum ada skor tercatat!';

  @override
  String get allowRotation => 'Izinkan Rotasi';

  @override
  String get allowRotationDesc => 'Matikan untuk mencegah bentuk berputar';

  @override
  String get showGrid => 'Tampilkan Batas Kisi';

  @override
  String get showGridDesc =>
      'Tampilkan garis kisi neon untuk membantu memvisualisasikan balok';

  @override
  String get schulteGame => 'Fokus Schulte';

  @override
  String get schulteGameDesc =>
      'Ketuk angka secara berurutan secepat mungkin untuk melatih fokus';

  @override
  String get schulteOrder => 'Urutan Angka';

  @override
  String get ascending => 'Naik (Ascending)';

  @override
  String get descending => 'Turun (Descending)';

  @override
  String get gridColorMode => 'Mode Warna';

  @override
  String get monochrome => 'Satu Warna';

  @override
  String get rainbow => 'Pelangi';

  @override
  String tapNextNumber(int number) {
    return 'Ketuk berikutnya: $number';
  }

  @override
  String get temporalGames => 'Kontrol Temporal';

  @override
  String get timeEstimator => 'Estimasi Waktu';

  @override
  String get timeEstimatorDesc => 'Hentikan jam tepat pada waktu target';

  @override
  String get rhythmSync => 'Penyelaras Irama';

  @override
  String get rhythmSyncDesc => 'Ketuk selaras dengan irama';

  @override
  String waitTargetTime(Object seconds) {
    return 'Tunggu tepat $seconds detik';
  }

  @override
  String get hideTimerDesc =>
      'Berhenti ketika Anda mengira waktu telah mencapai target!';

  @override
  String get startEstimating => 'Mulai';

  @override
  String get stopEstimating => 'Berhenti';

  @override
  String get tapOnBeat => 'Ketuk!';

  @override
  String get listenRhythm => 'Dengarkan irama...';

  @override
  String get rhythmSyncTap => 'Ketuk pada ketukan 4, 5, 6, 7, 8!';
}
