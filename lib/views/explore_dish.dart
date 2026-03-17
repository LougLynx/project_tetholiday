import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/models/tip.dart';
import 'package:project_tetholiday/views/tip_detail_page.dart';

/// Tab Khám phá — Kho Bí Kíp Gia Truyền. Dữ liệu load từ DB.
class ExploreDishPage extends StatefulWidget {
  const ExploreDishPage({super.key});

  @override
  State<ExploreDishPage> createState() => _ExploreDishPageState();
}

class _ExploreDishPageState extends State<ExploreDishPage> {
  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgLight = Color(0xFFF8F6F6);
  static const Color _bgDark = Color(0xFF1A0F0B);

  TipCategory _selectedCategory = TipCategory.all;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildCategoryTabs(isDark)),
                  if (_searchQuery.isEmpty)
                    SliverToBoxAdapter(child: _buildFeaturedSection(context, isDark)),
                  _buildTipGrid(context, isDark),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? _bgDark : _bgLight).withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: _primary.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _showSearch
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm bí kíp, công thức...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: _primary, size: 22),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _showSearch = false;
                            _searchQuery = '';
                          });
                        },
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  )
                : Text(
                    'Bí Kíp Gia Truyền',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          if (!_showSearch)
            SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: _primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () {
                    setState(() => _showSearch = true);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: Icon(Icons.search, size: 22, color: _primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static bool _matchesSearch(TipInfo tip, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return tip.title.toLowerCase().contains(q) ||
        (tip.subtitle?.toLowerCase().contains(q) ?? false) ||
        tip.content.toLowerCase().contains(q) ||
        tip.category.label.toLowerCase().contains(q) ||
        (tip.tags?.toLowerCase().contains(q) ?? false);
  }

  Widget _buildCategoryTabs(bool isDark) {
    final categories = [
      TipCategory.all,
      TipCategory.meoVat,
      TipCategory.tyLeVang,
      TipCategory.baoQuan,
      TipCategory.soTayCo,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: categories.map((c) {
          final selected = _selectedCategory == c;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: selected
                  ? _primary
                  : _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = c),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: selected ? null : Border.all(color: _primary.withValues(alpha: 0.2)),
                    boxShadow: selected ? [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Text(
                    c.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, bool isDark) {
    return FutureBuilder<TipInfo?>(
      future: AppDatabase.instance.getFeaturedTip(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
        final tip = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: GestureDetector(
              onTap: () => _openTipDetail(context, tip.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        tip.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade700),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              const Color(0xFF1A0F0B).withValues(alpha: 0.9),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BÍ KÍP NỔI BẬT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tip.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (tip.subtitle != null && tip.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                tip.subtitle!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipGrid(BuildContext context, bool isDark) {
    final category = _selectedCategory == TipCategory.all ? null : _selectedCategory;
    return FutureBuilder<List<TipInfo>>(
      future: AppDatabase.instance.getTips(category: category),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        var list = snapshot.data!;
        list = list.where((t) => !t.isFeatured).toList();
        if (_searchQuery.isNotEmpty) {
          list = list.where((t) => _matchesSearch(t, _searchQuery)).toList();
        }
        if (list.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _searchQuery.isEmpty ? 'Chưa có bí kíp nào' : 'Không tìm thấy bí kíp phù hợp',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          );
        }
        final children = <Widget>[];
        var i = 0;
        while (i < list.length) {
          final tip = list[i];
          if (tip.cardStyle == TipCardStyle.horizontal) {
            children.add(Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 150,
                child: _TipCard(
                  tip: tip,
                  isDark: isDark,
                  onTap: () => _openTipDetail(context, tip.id),
                ),
              ),
            ));
            i++;
            continue;
          }
          final rowChildren = <Widget>[];
          while (rowChildren.length < 2 && i < list.length) {
            final t = list[i];
            if (t.cardStyle == TipCardStyle.horizontal) break;
            rowChildren.add(Expanded(
              child: SizedBox(
                height: 220,
                child: _TipCard(
                  tip: t,
                  isDark: isDark,
                  onTap: () => _openTipDetail(context, t.id),
                ),
              ),
            ));
            i++;
          }
          if (rowChildren.isNotEmpty) {
            if (rowChildren.length == 2) {
              children.add(Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rowChildren[0],
                    const SizedBox(width: 16),
                    rowChildren[1],
                  ],
                ),
              ));
            } else {
              children.add(Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rowChildren[0],
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ));
            }
          }
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        );
      },
    );
  }

  void _openTipDetail(BuildContext context, String tipId) {
    AppDatabase.instance.incrementTipViewCount(tipId);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TipDetailPage(tipId: tipId),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.isDark,
    required this.onTap,
  });

  final TipInfo tip;
  final bool isDark;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFFEE5B2B);

  @override
  Widget build(BuildContext context) {
    if (tip.cardStyle == TipCardStyle.goldenRatio) {
      return _buildGoldenRatioCard(context);
    }
    if (tip.cardStyle == TipCardStyle.horizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildNormalCard(context);
  }

  Widget _buildNormalCard(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  tip.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 14, color: _primary),
                      const SizedBox(width: 4),
                      Text(
                        tip.category.label.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tip.viewCount} lượt xem',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Icon(Icons.bookmark_border, size: 20, color: _primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldenRatioCard(BuildContext context) {
    return Material(
      color: _primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.balance, size: 16, color: _primary),
                      const SizedBox(width: 4),
                      Text(
                        tip.category.label.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tip.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      tip.subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              if (tip.authorName != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _primary.withValues(alpha: 0.2),
                      child: Icon(Icons.person, size: 14, color: _primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tip.authorName!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 100,
                child: Image.network(
                  tip.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flare, size: 12, color: _primary),
                        const SizedBox(width: 4),
                        Text(
                          tip.category.label.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tip.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        tip.subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tip.tags != null && tip.tags!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: tip.tags!.split(',').map((t) {
                          final tag = t.trim();
                          if (tag.isEmpty) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '#$tag',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: _primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
