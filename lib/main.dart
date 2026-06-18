import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:superskill/l10n/app_localizations.dart';

import 'features/menu/presentation/menu_screen.dart';
import 'core/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Superskill Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030712),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          primary: const Color(0xFF38BDF8),
          surface: const Color(0xFF0F172A),
          brightness: Brightness.dark,
        ),
        // Switch to Inter - very professional and clear
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).copyWith(
          displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
          displayMedium: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
          displaySmall: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyLarge: const TextStyle(fontSize: 18),
          bodyMedium: const TextStyle(fontSize: 16),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
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
