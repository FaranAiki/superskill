import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:superskill/l10n/app_localizations.dart';

import 'features/menu/presentation/menu_screen.dart';
import 'core/locale_provider.dart';
import 'core/settings_provider.dart';
import 'core/high_score_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HighScoreService.instance.init();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const Size windowSize = Size(450, 850);
    WindowOptions windowOptions = const WindowOptions(
      size: windowSize,
      minimumSize: Size(400, 700),
      maximumSize: Size(600, 1000),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Superskill Hub',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setSize(windowSize);
      await windowManager.setAspectRatio(450 / 850);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  TextTheme _getTextTheme(String fontFamily, TextTheme baseTheme) {
    switch (fontFamily) {
      case 'Roboto':
        return GoogleFonts.robotoTextTheme(baseTheme);
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme(baseTheme);
      case 'Orbitron':
        return GoogleFonts.orbitronTextTheme(baseTheme);
      default:
        return GoogleFonts.interTextTheme(baseTheme);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);

    final isLight = settings.themeMode == ThemeMode.light;

    final baseTextTheme = ThemeData(brightness: isLight ? Brightness.light : Brightness.dark).textTheme;
    var customTextTheme = _getTextTheme(settings.fontFamily, baseTextTheme).copyWith(
      displayLarge: TextStyle(fontSize: 48 * settings.fontSizeMultiplier, fontWeight: FontWeight.w900),
      displayMedium: TextStyle(fontSize: 38 * settings.fontSizeMultiplier, fontWeight: FontWeight.w800),
      displaySmall: TextStyle(fontSize: 32 * settings.fontSizeMultiplier, fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(fontSize: 28 * settings.fontSizeMultiplier, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24 * settings.fontSizeMultiplier, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22 * settings.fontSizeMultiplier, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 18 * settings.fontSizeMultiplier),
      bodyMedium: TextStyle(fontSize: 16 * settings.fontSizeMultiplier),
    ).apply(
      bodyColor: isLight ? const Color(0xFF0F172A) : Colors.white,
      displayColor: isLight ? const Color(0xFF0F172A) : Colors.white,
    );

    return MaterialApp(
      title: 'Superskill Hub',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: customTextTheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          primary: const Color(0xFF38BDF8),
          surface: const Color(0xFF0F172A),
          brightness: Brightness.dark,
        ),
        textTheme: customTextTheme,
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
        Locale('zh'),
        Locale('ja'),
      ],
      home: const MenuScreen(),
    );
  }
}
