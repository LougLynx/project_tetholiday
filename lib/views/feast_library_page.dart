import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/models/recipe_ingredient.dart';
import 'package:project_tetholiday/views/recipe_list_by_occasion_page.dart';

Future<List<(FeastInfo, int)>> _getFeastsWithCounts() async {
  final feasts = await AppDatabase.instance.getFeasts();
  final counts = await Future.wait(
    feasts.map((f) => AppDatabase.instance.getRecipeCountByOccasion(f.occasion)),
  );
  return List.generate(feasts.length, (i) => (feasts[i], counts[i]));
}

/// Màn Thư viện Mâm Cỗ — danh sách các mâm cỗ, bấm vào xem danh sách món theo dịp.
class FeastLibraryPage extends StatelessWidget {
  const FeastLibraryPage({super.key});

  static const Color _primary = Color(0xFFEE5B2B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thư viện Mâm Cỗ',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<(FeastInfo, int)>>(
        future: _getFeastsWithCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return Center(
              child: Text(
                'Chưa có mâm cỗ nào',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final pair = list[index];
              final f = pair.$1;
              final count = pair.$2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FeastTile(
                  feast: f,
                  dishCount: count,
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => RecipeListByOccasionPage(occasion: f.occasion),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FeastTile extends StatelessWidget {
  const _FeastTile({
    required this.feast,
    required this.dishCount,
    required this.isDark,
    required this.onTap,
  });

  final FeastInfo feast;
  final int dishCount;
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 90,
                child: Image.network(
                  feast.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feast.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feast.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$dishCount Món',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12, top: 30),
                child: Icon(Icons.chevron_right, color: _primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
