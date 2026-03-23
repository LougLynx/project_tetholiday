import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/views/recipe/my_dishes_page.dart';
import 'package:project_tetholiday/views/recipe/explore_dish.dart';
import 'package:project_tetholiday/views/home/main_home_content.dart';
import 'package:project_tetholiday/views/profile/profile_page.dart';
import 'package:project_tetholiday/views/fortune/daily_fortune_page.dart';

/// Màn chính sau khi đăng nhập: bottom nav. Trang chủ | Khám phá | Của tôi (thêm món) | Cá nhân.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  VoidCallback? _refreshHomeFeastCards;

  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgDark = Color(0xFF221510);

  List<Widget> _buildTabs() => [
    MainHomeContent(
      onNavigateToExplore: () => setState(() => _currentIndex = 1),
      onRegisterRefresh: (cb) => _refreshHomeFeastCards = cb,
    ),
    const ExploreDishPage(),
    const DailyFortunePage(),
    const CuaToiPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? _bgDark.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.9);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildTabs(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(
              color: isDark ? _primary.withValues(alpha: 0.1) : Colors.grey.shade200,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home,
                    label: 'Trang chủ',
                    selected: _currentIndex == 0,
                    onTap: () {
                      setState(() => _currentIndex = 0);
                      _refreshHomeFeastCards?.call();
                    },
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.explore_outlined,
                    label: 'Khám phá',
                    selected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
                // Gieo Quẻ nút nổi bật ở giữa
                Expanded(
                  child: _NavItem(
                    icon: Icons.auto_awesome,
                    label: 'Gieo Quẻ',
                    selected: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                    highlight: true,
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.restaurant_menu,
                    label: 'Của tôi',
                    selected: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_outline,
                    label: 'Cá nhân',
                    selected: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;

  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final activeColor = highlight ? _gold : _primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            highlight && selected
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primary, _gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: _gold.withValues(alpha: 0.4), blurRadius: 8),
                      ],
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  )
                : Icon(
                    icon,
                    size: 24,
                    color: selected ? activeColor : Colors.grey.shade400,
                  ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? activeColor : Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
