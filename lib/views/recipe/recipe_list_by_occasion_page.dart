import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';
import 'package:project_tetholiday/viewmodels/recipe/recipe_list_by_occasion_viewmodel.dart';
import 'package:project_tetholiday/views/feast/market_list_page.dart';

/// Màn danh sách món theo dịp (sau khi chọn một mâm cỗ).
class RecipeListByOccasionPage extends StatefulWidget {
  const RecipeListByOccasionPage({
    super.key,
    required this.occasion,
  });

  final Occasion occasion;

  @override
  State<RecipeListByOccasionPage> createState() => _RecipeListByOccasionPageState();
}

class _RecipeListByOccasionPageState extends State<RecipeListByOccasionPage> {


  late RecipeListByOccasionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RecipeListByOccasionViewModel(widget.occasion);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.occasion.label,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return _buildBody(context, isDark);
        }
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final recipes = _viewModel.recipes;
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có món nào cho dịp ${widget.occasion.label}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final r = recipes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecipeTile(
                  recipe: r,
                  isDark: isDark,
                  onTap: () async {
                    final deleted = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (context) => MarketListPage(recipeId: r.id),
                      ),
                    );
                    if (deleted == true && mounted) _viewModel.refresh();
                  },
                ),
              );
            },
          );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.recipe,
    required this.isDark,
    required this.onTap,
  });

  final RecipeInfo recipe;
  final bool isDark;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFFEE5B2B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (recipe.time != null || recipe.level != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (recipe.time != null) recipe.time,
                          if (recipe.level != null) recipe.level,
                        ].join(' • '),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _primary),
            ],
          ),
        ),
      ),
    );
  }
}
