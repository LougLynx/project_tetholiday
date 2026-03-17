import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/models/recipe_ingredient.dart';
import 'package:project_tetholiday/views/recipe_cooking_page.dart';

/// Màn hình Danh Sách Đi Chợ — hiển thị nguyên liệu theo món đã chọn (tải từ SQLite).
class MarketListPage extends StatefulWidget {
  const MarketListPage({
    super.key,
    required this.recipeId,
  });

  final String recipeId;

  @override
  State<MarketListPage> createState() => _MarketListPageState();
}

class _MarketListPageState extends State<MarketListPage> {
  RecipeInfo? _recipe;
  List<MarketIngredient> _ingredients = [];
  bool _loading = true;
  String? _error;

  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgLight = Color(0xFFF8F6F6);
  static const Color _bgDark = Color(0xFF181311);

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final recipe = await AppDatabase.instance.getRecipeWithIngredients(widget.recipeId);
    if (!mounted) return;
    setState(() {
      _recipe = recipe;
      _ingredients = recipe?.ingredients.toList() ?? [];
      _loading = false;
      if (recipe == null) _error = 'Không tìm thấy món';
    });
  }

  int get _checkedCount =>
      _ingredients.where((e) => e.checked).length;
  int get _totalCount => _ingredients.length;
  double get _progress =>
      _totalCount > 0 ? _checkedCount / _totalCount : 0.0;

  Future<void> _toggle(int index) async {
    final ing = _ingredients[index];
    final newChecked = !ing.checked;
    if (ing.id != null) {
      await AppDatabase.instance.updateIngredientChecked(ing.id!, newChecked);
    }
    if (!mounted) return;
    setState(() {
      _ingredients[index] = ing.copyWith(checked: newChecked);
    });
  }

  Future<void> _showDeleteConfirm(BuildContext context, bool isDark) async {
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xoá món ăn',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn xoá món "${_recipe?.title ?? ''}"? Danh sách nguyên liệu và ghi chú sẽ bị xoá. Hành động này không thể hoàn tác.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await AppDatabase.instance.deleteRecipe(widget.recipeId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá món')),
    );
    navigator.pop(true); // true = đã xoá, để màn trước cập nhật lại danh sách
  }

  Map<MarketCategory, List<MarketIngredient>> get _byCategory {
    final map = <MarketCategory, List<MarketIngredient>>{};
    for (final ing in _ingredients) {
      map.putIfAbsent( ing.category, () => [] ).add(ing);
    }
    final order = [
      MarketCategory.meat,
      MarketCategory.vegetables,
      MarketCategory.spices,
      MarketCategory.other,
    ];
    for (final c in order) {
      map.putIfAbsent(c, () => []);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _recipe == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        body: Center(
          child: Text(_error ?? 'Không tìm thấy món', style: const TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildProgress(isDark)),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildRecipeAndStartCooking(context, isDark)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ..._byCategory.entries
                      .where((e) => e.value.isNotEmpty)
                      .map((e) => SliverToBoxAdapter(
                            child: _buildSection(
                              e.key,
                              e.value,
                              isDark,
                            ),
                          )),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: _primary,
          elevation: 8,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final bg = isDark ? _bgDark : _bgLight;
    return Material(
      color: bg.withValues(alpha: 0.8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Danh Sách Đi Chợ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') _showDeleteConfirm(context, isDark);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 22),
                          SizedBox(width: 12),
                          Text('Xoá món ăn', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _recipe!.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeAndStartCooking(BuildContext context, bool isDark) {
    final hasInstructions = _recipe!.instructions != null && _recipe!.instructions!.trim().isNotEmpty;
    final text = hasInstructions ? _recipe!.instructions! : 'Chưa có công thức chi tiết. Bạn vẫn có thể bắt đầu với danh sách nguyên liệu và tự nấu.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 22, color: _primary),
                    const SizedBox(width: 8),
                    Text(
                      'Công thức',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => RecipeCookingPage(recipe: _recipe!),
                ),
              );
            },
            icon: const Icon(Icons.restaurant, size: 22),
            label: const Text('Bắt đầu nấu'),
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ mua sắm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '$_checkedCount/$_totalCount món',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(_progress * 100).round()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(_primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    MarketCategory category,
    List<MarketIngredient> items,
    bool isDark,
  ) {
    final checkedInCategory = items.where((e) => e.checked).length;
    final icon = _categoryIcon(category);
    final color = _categoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 22, color: color),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$checkedInCategory/${items.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = _ingredients.indexOf(entry.value);
            return _buildIngredientItem(entry.value, index, isDark);
          }),
        ],
      ),
    );
  }

  IconData _categoryIcon(MarketCategory category) {
    switch (category) {
      case MarketCategory.meat:
        return Icons.restaurant;
      case MarketCategory.vegetables:
        return Icons.eco;
      case MarketCategory.spices:
        return Icons.breakfast_dining;
      case MarketCategory.other:
        return Icons.inventory_2_outlined;
    }
  }

  Color _categoryColor(MarketCategory category) {
    switch (category) {
      case MarketCategory.meat:
        return _primary;
      case MarketCategory.vegetables:
        return Colors.green.shade600;
      case MarketCategory.spices:
        return Colors.amber.shade700;
      case MarketCategory.other:
        return Colors.blue.shade600;
    }
  }

  Widget _buildIngredientItem(
    MarketIngredient ing,
    int index,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _toggle(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: ing.checked,
                    onChanged: (_) => _toggle(index),
                    activeColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ing.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: ing.checked ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey,
                          color: ing.checked ? Colors.grey : null,
                        ),
                      ),
                      if (ing.noteForDish != null && ing.noteForDish!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          ing.noteForDish!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  ing.quantity,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _primary,
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
