import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superskill/l10n/app_localizations.dart';
import '../../color_game/presentation/color_game_screen.dart';
import '../../sound_game/presentation/sound_game_screen.dart';
import '../../brain_game/presentation/stroop_game_screen.dart';
import '../../memory_game/presentation/memory_sequence_screen.dart';
import '../../spatial_game/presentation/spatial_iq_screen.dart';
import '../../../core/locale_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.6),
                radius: 1.5,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF030712),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
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
                    const SizedBox(height: 40),
                    
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
                    ]),
                    
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
                    ]),

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
                    ]),

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
                    ]),
                  ],
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(l10n.selectLanguage, style: Theme.of(context).textTheme.titleLarge),
            ),
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
            const SizedBox(height: 24),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF38BDF8).withOpacity(0.7),
              fontSize: 12,
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      title: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF38BDF8) : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8)) : null,
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
                color: widget.gradient[0].withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: const Color(0xFF1E293B).withOpacity(0.6),
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
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.subtitle,
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 20),
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
