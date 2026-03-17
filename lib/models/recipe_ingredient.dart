/// Mã dịp (dùng trong DB và lọc).
enum Occasion {
  tet('Tết Nguyên Đán'),
  trungThu('Trung Thu'),
  gioChap('Giỗ Chạp'),
  damCuoi('Đám Cưới');

  const Occasion(this.label);
  final String label;
}

/// Thông tin mâm cỗ (thư viện).
class FeastInfo {
  const FeastInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badge,
    required this.occasion,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badge;
  final Occasion occasion;
}

/// Thông tin món ăn và nguyên liệu cho danh sách đi chợ.
class RecipeInfo {
  const RecipeInfo({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.time,
    this.level,
    this.occasion,
    this.instructions,
    this.ingredients = const [],
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? time;
  final String? level;
  /// Dịp (Tết, Trung Thu, Giỗ Chạp, Đám Cưới).
  final Occasion? occasion;
  /// Công thức nấu (các bước).
  final String? instructions;
  final List<MarketIngredient> ingredients;
}

/// Nguyên liệu trong danh sách đi chợ (có thể tick đã mua).
/// [id] là khoá chính trong DB, dùng khi cập nhật trạng thái checked.
class MarketIngredient {
  const MarketIngredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.noteForDish,
    this.checked = false,
  });

  final int? id;
  final String name;
  final String quantity;
  final MarketCategory category;
  final String? noteForDish;
  final bool checked;

  MarketIngredient copyWith({bool? checked, int? id}) {
    return MarketIngredient(
      id: id ?? this.id,
      name: name,
      quantity: quantity,
      category: category,
      noteForDish: noteForDish,
      checked: checked ?? this.checked,
    );
  }
}

enum MarketCategory {
  meat('Thịt (Meat)', 'skillet'),
  vegetables('Rau Củ (Vegetables)', 'eco'),
  spices('Gia vị', 'seasoning'),
  other('Khác', 'inventory_2');

  const MarketCategory(this.label, this.iconName);
  final String label;
  final String iconName;
}
