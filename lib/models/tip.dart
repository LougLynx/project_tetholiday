/// Danh mục bí kíp (Kho Bí Kíp Gia Truyền). [all] chỉ dùng cho filter, không lưu DB.
enum TipCategory {
  all('Tất cả'),
  meoVat('Mẹo vặt'),
  tyLeVang('Tỷ lệ vàng'),
  baoQuan('Bảo quản'),
  soTayCo('Sổ tay cổ');

  const TipCategory(this.label);
  final String label;

  /// Các category thực (bỏ all) để lưu DB / filter.
  static List<TipCategory> get valuesForDb =>
      [TipCategory.meoVat, TipCategory.tyLeVang, TipCategory.baoQuan, TipCategory.soTayCo];
}

/// Kiểu thẻ hiển thị (để layout khác nhau trong grid).
enum TipCardStyle {
  normal('normal'),
  goldenRatio('goldenRatio'),
  horizontal('horizontal');

  const TipCardStyle(this.dbValue);
  final String dbValue;

  static TipCardStyle fromString(String? v) {
    if (v == 'goldenRatio') return TipCardStyle.goldenRatio;
    if (v == 'horizontal') return TipCardStyle.horizontal;
    return TipCardStyle.normal;
  }
}

/// Một bí kíp / công thức trong Kho Bí Kíp Gia Truyền.
class TipInfo {
  const TipInfo({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.category,
    required this.content,
    this.viewCount = 0,
    this.isFeatured = false,
    this.authorName,
    this.tags,
    this.cardStyle = TipCardStyle.normal,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final TipCategory category;
  final String content;
  final int viewCount;
  final bool isFeatured;
  final String? authorName;
  final String? tags;
  final TipCardStyle cardStyle;
}
