import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superskill/l10n/app_localizations.dart';
import '../../color_game/presentation/color_game_screen.dart';
import '../../sound_game/presentation/sound_game_screen.dart';
import '../../brain_game/presentation/stroop_game_screen.dart';
import '../../brain_game/presentation/reflex_game_screen.dart';
import '../../brain_game/presentation/operator_game_screen.dart';
import '../../brain_game/presentation/game_24_screen.dart';
import '../../brain_game/presentation/speed_math_screen.dart';
import '../../brain_game/presentation/schulte_game_screen.dart';
import '../../memory_game/presentation/memory_sequence_screen.dart';
import '../../memory_game/presentation/chimp_game_screen.dart';
import '../../memory_game/presentation/color_memory_screen.dart';
import '../../spatial_game/presentation/spatial_iq_screen.dart';
import '../../spatial_game/presentation/maze_game_screen.dart';
import '../../spatial_game/presentation/dice_game_screen.dart';
import '../../spatial_game/presentation/shadow_matching_screen.dart';
import '../../color_game/presentation/gradient_sort_screen.dart';
import '../../color_game/presentation/odd_one_out_screen.dart';
import '../../temporal_game/presentation/time_estimator_screen.dart';
import '../../temporal_game/presentation/rhythm_sync_screen.dart';
import '../../../core/locale_provider.dart';
import '../../../core/settings_provider.dart';
import '../../../core/high_score_service.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String selectedCategory = "All"; // All, Visual, Audio, Brain, Numerical, Memory, Spatial

  String _getCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Visual':
        return l10n.visualGames;
      case 'Audio':
        return l10n.audioGames;
      case 'Brain':
        return l10n.brainGames;
      case 'Numerical':
        return l10n.numericalGames;
      case 'Memory':
        return l10n.memoryGames;
      case 'Spatial':
        return l10n.spatialGames;
      case 'Temporal':
        return l10n.temporalGames;
      default:
        return l10n.all;
    }
  }

  void _showScoreboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) {
        final scores = HighScoreService.instance.getAllScores();
        
        final trackedGames = [
          {'id': 'brain_reflex', 'name': l10n.brainReflex, 'icon': Icons.psychology_outlined, 'color': const Color(0xFF2DD4BF)},
          {'id': 'reflex_tap', 'name': l10n.reflexGame, 'icon': Icons.touch_app_outlined, 'color': const Color(0xFFFACC15)},
          {'id': 'operator_rush', 'name': l10n.operatorGame, 'icon': Icons.calculate_outlined, 'color': const Color(0xFF38BDF8)},
          {'id': 'game_24', 'name': l10n.game24, 'icon': Icons.filter_4, 'color': const Color(0xFF818CF8)},
          {'id': 'speed_math', 'name': l10n.speedMath, 'icon': Icons.flash_on_outlined, 'color': const Color(0xFFFACC15)},
          {'id': 'memory_sequence', 'name': l10n.memorySequence, 'icon': Icons.memory, 'color': const Color(0xFF38BDF8)},
          {'id': 'chimp_memory', 'name': l10n.chimpGame, 'icon': Icons.psychology, 'color': const Color(0xFF818CF8)},
          {'id': 'spatial_iq', 'name': l10n.spatialIq, 'icon': Icons.view_in_ar, 'color': const Color(0xFFF43F5E)},
          {'id': 'spatial_dice', 'name': l10n.diceGame, 'icon': Icons.casino_outlined, 'color': const Color(0xFFEC4899)},
          {'id': 'schulte_focus', 'name': l10n.schulteGame, 'icon': Icons.filter_9_plus_outlined, 'color': const Color(0xFFFB923C)},
          {'id': 'time_estimator', 'name': l10n.timeEstimator, 'icon': Icons.timer_outlined, 'color': const Color(0xFF10B981)},
          {'id': 'rhythm_sync', 'name': l10n.rhythmSync, 'icon': Icons.music_note_outlined, 'color': const Color(0xFF8B5CF6)},
        ];

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scoreboard,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: scores.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noScoresYet,
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: trackedGames.length,
                          itemBuilder: (context, index) {
                            final game = trackedGames[index];
                            final gameId = game['id'] as String;
                            final gameName = game['name'] as String;
                            final gameIcon = game['icon'] as IconData;
                            final gameColor = game['color'] as Color;
                            final highScore = scores[gameId] ?? 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isLight 
                                    ? Colors.black.withOpacity(0.02) 
                                    : const Color(0xFF1E293B).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isLight ? Colors.black12 : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: gameColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(gameIcon, color: gameColor, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      gameName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$highScore',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.ok,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;

    final categories = ['All', 'Visual', 'Audio', 'Brain', 'Numerical', 'Memory', 'Spatial', 'Temporal'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.emoji_events, color: Colors.amber),
              tooltip: l10n.scoreboard,
              onPressed: () => _showScoreboard(context),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF38BDF8)),
              onPressed: () => _showAdvancedSettings(context, ref),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.language, color: Color(0xFF38BDF8)),
              onPressed: () => _showLanguageSelector(context, ref),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.6),
                radius: 1.5,
                colors: Theme.of(context).brightness == Brightness.light
                    ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
                    : [const Color(0xFF0F172A), const Color(0xFF030712)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ScrollConfiguration(
                  behavior: NoScrollbarScrollBehavior(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                          ).createShader(bounds),
                          child: Text(
                            l10n.miniGamesHub,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(height: 2, width: 60, color: const Color(0xFF38BDF8).withOpacity(0.3)),
                        const SizedBox(height: 24),
                        
                        // Category selection dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLight 
                                ? Colors.white.withOpacity(0.9) 
                                : const Color(0xFF1E293B).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              dropdownColor: isLight ? Colors.white : const Color(0xFF0F172A),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLight ? const Color(0xFF0F172A) : Colors.white,
                              ),
                              icon: Icon(Icons.arrow_drop_down, color: primaryColor, size: 28),
                              items: categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(_getCategoryName(cat, l10n)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        if (selectedCategory == 'All' || selectedCategory == 'Visual')
                          _CategorySection(title: l10n.visualGames, children: [
                            _MenuButton(
                              title: l10n.tebakHexRgb,
                              subtitle: l10n.pointDiffSystem,
                              icon: Icons.palette_outlined,
                              gradient: const [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ColorGameScreen(mode: ColorGameMode.rgb)),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.tebakHexCmyk,
                              subtitle: l10n.cmykChallenge,
                              icon: Icons.color_lens_outlined,
                              gradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ColorGameScreen(mode: ColorGameMode.cmyk)),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.gradientSort,
                              subtitle: l10n.gradientSortDesc,
                              icon: Icons.filter_hdr_outlined,
                              gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GradientSortScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.oddOneOut,
                              subtitle: l10n.oddOneOutDesc,
                              icon: Icons.grain_outlined,
                              gradient: const [Color(0xFFEC4899), Color(0xFFD946EF)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OddOneOutScreen()),
                              ),
                            ),
                          ]),
                        
                        if (selectedCategory == 'All' || selectedCategory == 'Audio')
                          _CategorySection(title: l10n.audioGames, children: [
                            _MenuButton(
                              title: l10n.perfectPitch,
                              subtitle: l10n.trainMusicPitch,
                              icon: Icons.music_note_outlined,
                              gradient: const [Color(0xFF818CF8), Color(0xFF4F46E5)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SoundGameScreen()),
                              ),
                            ),
                          ]),

                        if (selectedCategory == 'All' || selectedCategory == 'Brain')
                          _CategorySection(title: l10n.brainGames, children: [
                            _MenuButton(
                              title: l10n.brainReflex,
                              subtitle: l10n.stroopTestDesc,
                              icon: Icons.psychology_outlined,
                              gradient: const [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const StroopGameScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.reflexGame,
                              subtitle: l10n.reflexGameDesc,
                              icon: Icons.touch_app_outlined,
                              gradient: const [Color(0xFFFACC15), Color(0xFFD97706)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ReflexGameScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.schulteGame,
                              subtitle: l10n.schulteGameDesc,
                              icon: Icons.filter_9_plus_outlined,
                              gradient: const [Color(0xFFFB923C), Color(0xFFEA580C)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SchulteGameScreen()),
                              ),
                            ),
                          ]),

                        if (selectedCategory == 'All' || selectedCategory == 'Numerical')
                          _CategorySection(title: l10n.numericalGames, children: [
                            _MenuButton(
                              title: l10n.operatorGame,
                              subtitle: l10n.operatorGameDesc,
                              icon: Icons.calculate_outlined,
                              gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OperatorGameScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.game24,
                              subtitle: l10n.game24Desc,
                              icon: Icons.filter_4,
                              gradient: const [Color(0xFF818CF8), Color(0xFF4F46E5)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const Game24Screen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.speedMath,
                              subtitle: l10n.speedMathDesc,
                              icon: Icons.flash_on_outlined,
                              gradient: const [Color(0xFFFACC15), Color(0xFFD97706)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SpeedMathScreen()),
                              ),
                            ),
                          ]),

                        if (selectedCategory == 'All' || selectedCategory == 'Memory')
                          _CategorySection(title: l10n.memoryGames, children: [
                            _MenuButton(
                              title: l10n.memorySequence,
                              subtitle: l10n.memorySequenceDesc,
                              icon: Icons.memory,
                              gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MemorySequenceScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.chimpGame,
                              subtitle: l10n.chimpGameDesc,
                              icon: Icons.psychology,
                              gradient: const [Color(0xFF818CF8), Color(0xFF4F46E5)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChimpGameScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.colorMemory,
                              subtitle: l10n.colorMemoryDesc,
                              icon: Icons.brightness_high_outlined,
                              gradient: const [Color(0xFF0EA5E9), Color(0xFF10B981)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ColorMemoryScreen()),
                              ),
                            ),
                          ]),

                        if (selectedCategory == 'All' || selectedCategory == 'Spatial')
                          _CategorySection(title: l10n.spatialGames, children: [
                            _MenuButton(
                              title: l10n.spatialIq,
                              subtitle: l10n.spatialIqDesc,
                              icon: Icons.view_in_ar,
                              gradient: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SpatialIqScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.mazeGame,
                              subtitle: l10n.mazeGameDesc,
                              icon: Icons.grid_on_outlined,
                              gradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MazeGameScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.diceGame,
                              subtitle: l10n.diceGameDesc,
                              icon: Icons.casino_outlined,
                              gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DiceGameScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.shadowMatching,
                              subtitle: l10n.shadowMatchingDesc,
                              icon: Icons.brightness_6_outlined,
                              gradient: const [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ShadowMatchingScreen()),
                              ),
                            ),
                          ]),

                        if (selectedCategory == 'All' || selectedCategory == 'Temporal')
                          _CategorySection(title: l10n.temporalGames, children: [
                            _MenuButton(
                              title: l10n.timeEstimator,
                              subtitle: l10n.timeEstimatorDesc,
                              icon: Icons.timer_outlined,
                              gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TimeEstimatorScreen()),
                              ),
                            ),
                            _MenuButton(
                              title: l10n.rhythmSync,
                              subtitle: l10n.rhythmSyncDesc,
                              icon: Icons.music_note_outlined,
                              gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RhythmSyncScreen()),
                              ),
                            ),
                          ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
            children: [
              Text(l10n.selectLanguage, style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              _LangTile(label: 'English', isSelected: ref.read(localeProvider).languageCode == 'en', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              }),
              _LangTile(label: 'Indonesia', isSelected: ref.read(localeProvider).languageCode == 'id', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('id');
                Navigator.pop(context);
              }),
              _LangTile(label: 'Mandarin', isSelected: ref.read(localeProvider).languageCode == 'zh', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('zh');
                Navigator.pop(context);
              }),
              _LangTile(label: 'Japanese', isSelected: ref.read(localeProvider).languageCode == 'ja', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('ja');
                Navigator.pop(context);
              }),
              _LangTile(label: 'Русский', isSelected: ref.read(localeProvider).languageCode == 'ru', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('ru');
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedSettings(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentSettings = ref.watch(settingsProvider);
          final isLight = currentSettings.themeMode == ThemeMode.light;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
              ),
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.advancedSettings, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),
                    
                    // Theme Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.themeMode, style: theme.textTheme.bodyMedium),
                        Row(
                          children: [
                            ChoiceChip(
                              label: Text(l10n.dark),
                              selected: !isLight,
                              onSelected: (selected) {
                                if (selected) {
                                  ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(l10n.light),
                              selected: isLight,
                              onSelected: (selected) {
                                if (selected) {
                                  ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.light);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Font Family Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.fontStyle, style: theme.textTheme.bodyMedium),
                        DropdownButton<String>(
                          value: currentSettings.fontFamily,
                          dropdownColor: theme.colorScheme.surface,
                          style: theme.textTheme.bodyMedium,
                          items: const [
                            DropdownMenuItem(value: 'Inter', child: Text("Inter")),
                            DropdownMenuItem(value: 'Roboto', child: Text("Roboto")),
                            DropdownMenuItem(value: 'Poppins', child: Text("Poppins")),
                            DropdownMenuItem(value: 'Orbitron', child: Text("Orbitron")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(settingsProvider.notifier).setFontFamily(val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Font Size Multiplier
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.fontSize((currentSettings.fontSizeMultiplier * 100).toInt().toString()), style: theme.textTheme.bodyMedium),
                        Slider(
                          value: currentSettings.fontSizeMultiplier,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            ref.read(settingsProvider.notifier).setFontSize(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _CategorySection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isLight
                  ? const Color(0xFF0284C7).withOpacity(0.8)
                  : const Color(0xFF38BDF8).withOpacity(0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children.expand((w) => [w, const SizedBox(height: 12)]),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _LangTile({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final themeColor = isLight ? const Color(0xFF0284C7) : const Color(0xFF38BDF8);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isSelected ? themeColor : (isLight ? Colors.black87 : Colors.white70),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: themeColor) : null,
      onTap: onTap,
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(isLight ? 0.08 : 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: isLight ? Colors.white.withOpacity(0.9) : const Color(0xFF1E293B).withOpacity(0.6),
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.gradient,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLight ? const Color(0xFF0F172A) : Colors.white,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isLight ? const Color(0xFF475569) : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: isLight ? Colors.black26 : Colors.white.withOpacity(0.2), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoScrollbarScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
