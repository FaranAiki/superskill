import re

with open("lib/features/menu/presentation/menu_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add search variables
state_vars = """  String selectedCategory = "All"; // All, Visual, Audio, Brain, Numerical, Memory, Spatial
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Widget? _buildMenuButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    if (searchQuery.isNotEmpty) {
      if (!title.toLowerCase().contains(searchQuery) &&
          !subtitle.toLowerCase().contains(searchQuery)) {
        return null;
      }
    }
    return _MenuButton(
      title: title,
      subtitle: subtitle,
      icon: icon,
      gradient: gradient,
      onTap: onTap,
    );
  }
"""
content = re.sub(r'  String selectedCategory = "All"; // All, Visual, Audio, Brain, Numerical, Memory, Spatial', state_vars, content)

# Update _CategorySection children to use _buildMenuButton and filter nulls
content = content.replace('_MenuButton(', '_buildMenuButton(')
content = re.sub(r'_CategorySection\(title: (.*?), children: \[', r'_CategorySection(title: \1, children: [', content)

# Wait, _CategorySection expects List<Widget>. If _buildMenuButton returns Widget?, we need to filter.
# Let's replace `children: [` with `children: <Widget?>[` and then `.whereType<Widget>().toList()` at the end of the section.
# Actually, a simpler way is to just define a helper method for _CategorySection that does the filtering.
category_section_def = """
class _CategorySection extends StatelessWidget {
  final String title;
  final List<Widget?> children;

  const _CategorySection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final validChildren = children.whereType<Widget>().toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();
"""
content = content.replace('class _CategorySection extends StatelessWidget {', category_section_def)
# Need to update the constructor of _CategorySection
content = re.sub(
    r'final List<Widget> children;\s+const _CategorySection\(\{required this\.title, required this\.children\}\);',
    '',
    content
)

# Add Search Bar below Category Dropdown
search_bar = """
                        // Search Bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white.withOpacity(0.9)
                                : const Color(0xFF1E293B).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: isLight ? Colors.black : Colors.white),
                            decoration: InputDecoration(
                              hintText: l10n.search,
                              prefixIcon: Icon(Icons.search, color: primaryColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (val) {
                              setState(() {
                                searchQuery = val.toLowerCase();
                              });
                            },
                          ),
                        ),
"""
content = content.replace('const SizedBox(height: 28),', 'const SizedBox(height: 28),' + search_bar)

# Add new languages to the Language Selector
lang_selector = """
              _LangTile(label: 'Español', isSelected: ref.read(localeProvider).languageCode == 'es', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('es');
                Navigator.pop(context);
              }),
              _LangTile(label: 'العربية', isSelected: ref.read(localeProvider).languageCode == 'ar', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('ar');
                Navigator.pop(context);
              }),
              _LangTile(label: 'हिन्दी', isSelected: ref.read(localeProvider).languageCode == 'hi', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('hi');
                Navigator.pop(context);
              }),
              _LangTile(label: 'Français', isSelected: ref.read(localeProvider).languageCode == 'fr', onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('fr');
                Navigator.pop(context);
              }),
            ],
"""
content = content.replace('            ],', lang_selector, 1)

with open("lib/features/menu/presentation/menu_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("menu_screen.dart patched.")
