import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';
import 'package:project_tetholiday/viewmodels/feast/feast_planner_viewmodel.dart';
import 'package:project_tetholiday/views/recipe/recipe_cooking_page.dart';

class FeastPlannerPage extends StatefulWidget {
  const FeastPlannerPage({super.key});

  @override
  State<FeastPlannerPage> createState() => _FeastPlannerPageState();
}

class _FeastPlannerPageState extends State<FeastPlannerPage> {
  static const Color _primary = Color(0xFFEE5B2B);

  late FeastPlannerViewModel _viewModel;
  final TextEditingController _budgetController = TextEditingController(text: '500');

  @override
  void initState() {
    super.initState();
    _viewModel = FeastPlannerViewModel();
    _viewModel.loadRecipes();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateFeast() async {
    try {
      await _viewModel.generateFeast(_budgetController.text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF221510) : const Color(0xFFF8F6F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Gợi Ý Mâm Cỗ AI',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (Các Container tĩnh mình giữ nguyên)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trợ lý Ẩm Thực',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hôm nay nhà có khách, ngân sách có hạn? Để AI giúp bạn thiết kế mâm cơm vừa vặn túi tiền!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.auto_awesome, color: _primary, size: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Thiết lập yêu cầu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Số người ăn:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withAlpha(76)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: _viewModel.decrementPeople,
                          ),
                          Text(
                            '${_viewModel.peopleCount}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: _viewModel.incrementPeople,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  'Ngân sách dự kiến (Nghìn VNĐ):',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.white,
                    hintText: 'VD: 500',
                    suffixText: '.000 đ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _handleGenerateFeast,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _viewModel.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'LÊN THỰC ĐƠN',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                ),

                if (_viewModel.suggestedRecipes.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kết quả lý tưởng:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        _formatCurrency(_viewModel.totalCost),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cho ${_viewModel.peopleCount} người (${_viewModel.suggestedRecipes.length} món)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._viewModel.suggestedRecipes.map((r) => _buildRecipeItem(r, isDark, _viewModel)),
                ]
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildRecipeItem(RecipeInfo r, bool isDark, FeastPlannerViewModel vm) {
    int expectedCost = vm.getRecipeCost(r.id) * vm.peopleCount;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? Colors.black26 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            r.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60, height: 60, color: Colors.grey.shade300,
            ),
          ),
        ),
        title: Text(
          r.title,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatCurrency(expectedCost),
          style: GoogleFonts.plusJakartaSans(color: _primary),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () async {
          final db = AppDatabase.instance;
          final details = await db.getRecipeWithIngredients(r.id);
          if (details != null && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RecipeCookingPage(recipe: details),
              ),
            );
          }
        },
      ),
    );
  }
}
