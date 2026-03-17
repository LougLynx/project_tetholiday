import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/models/recipe_ingredient.dart';
import 'package:project_tetholiday/views/feast_library_page.dart';
import 'package:project_tetholiday/views/recipe_list_by_occasion_page.dart';
import 'package:project_tetholiday/views/recipe_search_page.dart';

/// Nội dung trang chủ Mâm Cỗ Việt — hiển thị sau khi đăng nhập.
class MainHomeContent extends StatefulWidget {
  const MainHomeContent({
    super.key,
    this.onNavigateToExplore,
    this.onRegisterRefresh,
  });

  final VoidCallback? onNavigateToExplore;
  /// Gọi với callback refresh (số món Thư viện Mâm Cỗ) khi cần cập nhật.
  final void Function(VoidCallback)? onRegisterRefresh;

  @override
  State<MainHomeContent> createState() => _MainHomeContentState();
}

class _MainHomeContentState extends State<MainHomeContent> {
  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgLight = Color(0xFFF8F6F6);
  static const Color _bgDark = Color(0xFF221510);

  Future<List<(FeastInfo, int)>>? _feastCardsFuture;

  @override
  void initState() {
    super.initState();
    _feastCardsFuture ??= _getFeastsWithCounts();
    widget.onRegisterRefresh?.call(refreshFeastCards);
  }

  @override
  void didUpdateWidget(covariant MainHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onRegisterRefresh != widget.onRegisterRefresh) {
      widget.onRegisterRefresh?.call(refreshFeastCards);
    }
  }

  void refreshFeastCards() {
    setState(() {
      _feastCardsFuture = _getFeastsWithCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    return Container(
      color: bg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(child: _buildSearchBar(context, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildFeastLibraryHeader(context)),
          SliverToBoxAdapter(child: _buildFeastCards(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildFamilyTipsBanner(context, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  String _displayName() {
    final session = Di.authRepository.currentSession;
    if (session == null) return 'Mâm Cỗ Việt';
    final name = session.user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = session.user.email;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Mâm Cỗ Việt';
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final bg = isDark ? _bgDark : _bgLight;
    return Material(
      color: bg.withOpacity(0.8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.local_florist, color: _primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào bạn,',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _displayName(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const RecipeSearchPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: IgnorePointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm mâm cỗ, món ăn...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
              suffixIcon: Icon(Icons.filter_list, color: _primary.withOpacity(0.5), size: 22),
              filled: true,
              fillColor: isDark ? _primary.withOpacity(0.05) : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeastLibraryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thư viện Mâm Cỗ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Khám phá nét đẹp truyền thống',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const FeastLibraryPage(),
                ),
              );
            },
            child: Text(
              'Xem tất cả',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<(FeastInfo, int)>> _getFeastsWithCounts() async {
    final feasts = await AppDatabase.instance.getFeasts();
    final counts = await Future.wait(
      feasts.map((f) => AppDatabase.instance.getRecipeCountByOccasion(f.occasion)),
    );
    return List.generate(feasts.length, (i) => (feasts[i], counts[i]));
  }

  Widget _buildFeastCards(BuildContext context) {
    _feastCardsFuture ??= _getFeastsWithCounts();
    return FutureBuilder<List<(FeastInfo, int)>>(
      future: _feastCardsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final list = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: list.map<Widget>((pair) {
              final f = pair.$1;
              final count = pair.$2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _FeastCard(
                  imageUrl: f.imageUrl,
                  title: f.title,
                  subtitle: f.subtitle,
                  badge: '$count Món',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => RecipeListByOccasionPage(occasion: f.occasion),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFamilyTipsBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onNavigateToExplore,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primary.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primary.withOpacity(0.2)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ĐẶC BIỆT',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bí kíp gia truyền',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tuyệt chiêu luộc gà vàng bóng, không nứt da từ nghệ nhân.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Khám phá ngay ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: _primary, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.menu_book, color: _primary.withOpacity(0.2), size: 56),
                  ],
                ),
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Icon(Icons.local_florist, color: _primary.withOpacity(0.1), size: 72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _FeastCard extends StatelessWidget {
  const _FeastCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback? onTap;

  static const Color _primary = Color(0xFFEE5B2B);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                ),
              ),
              DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 56,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Material(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

