import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/recipe_ingredient.dart';
import '../../models/tip.dart';

/// SQLite database cho món ăn và nguyên liệu.
/// Dùng [AppDatabase.instance] để truy cập.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'mam_co_viet.db';
  static const int _version = 7;

  Database? _db;
  final Completer<void> _ready = Completer<void>();

  /// Đảm bảo DB đã mở và seed (gọi khi app khởi động hoặc trước khi dùng).
  Future<void> ensureOpen() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await _seedIfEmpty();
    if (!_ready.isCompleted) _ready.complete();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        image_url TEXT NOT NULL,
        time TEXT,
        level TEXT,
        occasion TEXT,
        instructions TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        category TEXT NOT NULL,
        note_for_dish TEXT,
        checked INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE feasts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        image_url TEXT NOT NULL,
        badge TEXT NOT NULL,
        occasion TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tips (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT,
        image_url TEXT NOT NULL,
        category TEXT NOT NULL,
        content TEXT NOT NULL,
        view_count INTEGER NOT NULL DEFAULT 0,
        is_featured INTEGER NOT NULL DEFAULT 0,
        author_name TEXT,
        tags TEXT,
        card_style TEXT DEFAULT 'normal'
      )
    ''');
    await db.execute('''
      CREATE TABLE recipe_notes (
        recipe_id TEXT PRIMARY KEY,
        note TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE recipes ADD COLUMN occasion TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE recipes ADD COLUMN instructions TEXT');
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE feasts (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            image_url TEXT NOT NULL,
            badge TEXT NOT NULL,
            occasion TEXT NOT NULL
          )
        ''');
      } catch (_) {}
      await _backfillOccasionAndSeedFeasts(db);
    }
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE tips (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT,
            image_url TEXT NOT NULL,
            category TEXT NOT NULL,
            content TEXT NOT NULL,
            view_count INTEGER NOT NULL DEFAULT 0,
            is_featured INTEGER NOT NULL DEFAULT 0,
            author_name TEXT,
            tags TEXT,
            card_style TEXT DEFAULT 'normal'
          )
        ''');
      } catch (_) {}
      await _seedTipsIfEmpty(db);
    }
    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE recipe_notes (
            recipe_id TEXT PRIMARY KEY,
            note TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (recipe_id) REFERENCES recipes(id)
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 5) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS recipe_notes (
            recipe_id TEXT PRIMARY KEY,
            note TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (recipe_id) REFERENCES recipes(id)
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      await db.delete('recipe_notes');
      await db.delete('ingredients');
      await db.delete('recipes');
      await db.delete('feasts');
      await db.delete('tips');
      await _runFullSeed(db);
    }
    if (oldVersion < 7) {
      await db.delete('recipe_notes');
      await db.delete('ingredients');
      await db.delete('recipes');
      await db.delete('feasts');
      await db.delete('tips');
      await _runFullSeed(db);
    }
  }

  Future<void> _backfillOccasionAndSeedFeasts(Database db) async {
    final feastCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM feasts'));
    if (feastCount == null || feastCount == 0) await _insertFeastsSeed(db);
  }

  Future<void> _insertFeastsSeed(Database db) async {
    final feasts = [
      ('feast-tet-1', 'Mâm Cỗ Tết Miền Bắc', 'Bánh chưng, dưa hành, thịt đông - đậm đà bản sắc Hà Nội xưa.', 'https://picsum.photos/400/250?random=1', '8 Món', 'tet'),
      ('feast-trung-thu-1', 'Mâm Cỗ Trung Thu Phá Cỗ', 'Bánh nướng, bánh dẻo và mâm ngũ quả tạo hình nghệ thuật.', 'https://picsum.photos/400/250?random=4', '6 Món', 'trungThu'),
      ('feast-dam-cuoi-1', 'Mâm Cỗ Đám Cưới Miền Bắc', 'Chè, xôi, gà luộc - lễ thành hôn trọn vẹn.', 'https://picsum.photos/400/250?random=9', '12 Món', 'damCuoi'),
    ];
    for (final f in feasts) {
      await db.insert('feasts', {
        'id': f.$1, 'title': f.$2, 'subtitle': f.$3, 'image_url': f.$4, 'badge': f.$5, 'occasion': f.$6,
      });
    }
  }

  /// Chờ DB sẵn sàng (sau ensureOpen).
  Future<void> get ready => _ready.future;

  Database get _database {
    final db = _db;
    if (db == null) throw StateError('AppDatabase chưa mở. Gọi ensureOpen() trước.');
    return db;
  }

  /// Seed dữ liệu mẫu nếu bảng recipes trống.
  Future<void> _seedIfEmpty() async {
    final count = Sqflite.firstIntValue(
      await _database.rawQuery('SELECT COUNT(*) FROM recipes'),
    );
    if (count != null && count > 0) {
      final fc = Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) FROM feasts'));
      if (fc == null || fc == 0) await _insertFeastsSeed(_database);
      return;
    }
    await _runFullSeed(_database);
  }

  /// Chèn đủ recipes, ingredients, feasts, tips (dùng khi DB trống hoặc upgrade v6).
  Future<void> _runFullSeed(Database db) async {
    final batch = db.batch();

    final recipes = [
      ('recipe-1', 'Nem Công Chả Phượng', 'https://picsum.photos/300/200?random=1', '45p', 'Khó', 'tet', '1. Ướp thịt và tôm với nước mắm, đường, tiêu.\n2. Bào củ đậu, trộn nhân.\n3. Cuốn bánh tráng, chiên vàng.\n4. Ăn kèm rau sống và nước chấm.'),
      ('recipe-2', 'Xôi Gấc Chữ Hỷ', 'https://picsum.photos/300/200?random=2', '60p', 'Vừa', 'trungThu', '1. Nấu gạo nếp chín tới.\n2. Trộn thịt gấc, đường, dầu vào xôi.\n3. Đồ xôi lần hai cho chín đều, bóng đẹp.'),
      ('recipe-3', 'Thịt Kho Trứng Hột Vịt', 'https://picsum.photos/300/200?random=3', '120p', 'Dễ', 'tet', '1. Thịt ba chỉ cắt miếng vừa, ướp nước mắm, nước màu, đường.\n2. Kho với nước dừa, thêm trứng luộc bóc vỏ.\n3. Kho lửa nhỏ đến khi nước cạn sệt.'),
    ];

    for (final r in recipes) {
      batch.insert('recipes', {
        'id': r.$1, 'title': r.$2, 'image_url': r.$3, 'time': r.$4, 'level': r.$5, 'occasion': r.$6, 'instructions': r.$7,
      });
    }

    final ingredients = [
      ('recipe-1', 'Thịt ba chỉ', '300g', 'meat', 'Dùng cho nhân nem', 0),
      ('recipe-1', 'Tôm tươi', '200g', 'meat', 'Bóc vỏ, băm nhỏ', 0),
      ('recipe-1', 'Bánh tráng', '1 gói', 'other', 'Loại vừa, ướt', 0),
      ('recipe-1', 'Củ đậu', '1 củ', 'vegetables', 'Bào sợi', 0),
      ('recipe-1', 'Hành lá & Ngò rí', '1 bó', 'vegetables', null, 0),
      ('recipe-1', 'Nước mắm, đường, tiêu', 'Vừa đủ', 'spices', null, 0),
      ('recipe-2', 'Gạo nếp', '500g', 'other', 'Nếp cái hoa vàng', 0),
      ('recipe-2', 'Gấc chín', '1 quả', 'vegetables', 'Lấy thịt gấc', 0),
      ('recipe-2', 'Đường', '2 thìa', 'spices', null, 0),
      ('recipe-2', 'Dầu ăn', '2 thìa', 'spices', 'Cho xôi bóng', 0),
      ('recipe-3', 'Thịt ba chỉ', '2 kg', 'meat', null, 0),
      ('recipe-3', 'Trứng vịt', '6 quả', 'other', 'Luộc chín, bóc vỏ', 0),
      ('recipe-3', 'Nước mắm, nước màu', 'Vừa đủ', 'spices', null, 0),
    ];

    for (final i in ingredients) {
      batch.insert('ingredients', {
        'recipe_id': i.$1,
        'name': i.$2,
        'quantity': i.$3,
        'category': i.$4,
        'note_for_dish': i.$5,
        'checked': i.$6,
      });
    }

    await batch.commit(noResult: true);
    await _insertFeastsSeed(db);
    await _seedTipsIfEmpty(db);
  }

  Future<void> _seedTipsIfEmpty(Database db) async {
    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tips'));
      if (count != null && count > 0) return;
    } catch (_) {
      return;
    }
    final tips = [
      ('tip-1', 'Cách giữ màu xanh cho rau luộc từ đời Cụ Cố', 'Mẹo nhỏ với chanh và đá lạnh khiến rau luộc luôn mướt xanh.', 'https://picsum.photos/320/200?random=1', 'meoVat', '1. Luộc rau với nước sôi, thêm chút muối.\n2. Vớt ra thả ngay vào bát nước đá lạnh có vắt chanh.\n3. Để 1–2 phút rồi vớt ra, rau giòn xanh không bị nát.', 0, 1, null, null, 'normal'),
      ('tip-4', 'Nước mắm chua ngọt Bà Nội: 1-1-1-4', 'Mắm - Đường - Chanh - Nước lọc. Tỷ lệ chuẩn không cần chỉnh.', 'https://picsum.photos/320/200?random=4', 'tyLeVang', 'Công thức vàng: 1 thìa nước mắm, 1 thìa đường, 1 thìa nước cốt chanh, 4 thìa nước lọc. Khuấy đều, nếm chỉnh theo khẩu vị.', 0, 0, 'Bà Nội My', null, 'goldenRatio'),
      ('tip-7', 'Bảo quản bánh chưng qua Tết', 'Để tủ lạnh hoặc treo mát, tránh nắng.', 'https://picsum.photos/320/200?random=7', 'baoQuan', 'Bánh chưng sau khi luộc để nguội, bọc kín. Bảo quản ngăn mát 5–7 ngày. Muốn để lâu hơn cho vào ngăn đá.', 23, 0, null, null, 'normal'),
    ];
    for (final t in tips) {
      await db.insert('tips', {
        'id': t.$1, 'title': t.$2, 'subtitle': t.$3, 'image_url': t.$4, 'category': t.$5,
        'content': t.$6, 'view_count': t.$7, 'is_featured': t.$8, 'author_name': t.$9, 'tags': t.$10, 'card_style': t.$11,
      });
    }
  }

  /// Lấy danh sách món (không kèm nguyên liệu). [occasion] null = tất cả.
  Future<List<RecipeInfo>> getRecipes({Occasion? occasion}) async {
    await ready;
    final rows = occasion == null
        ? await _database.query('recipes', orderBy: 'title')
        : await _database.query(
            'recipes',
            where: 'occasion = ?',
            whereArgs: [occasion.name],
            orderBy: 'title',
          );
    return rows.map(_recipeFromRow).toList();
  }

  /// Tìm món ăn theo từ khóa (tên món hoặc nội dung công thức). Query rỗng = trả về tất cả.
  Future<List<RecipeInfo>> searchRecipes(String query) async {
    await ready;
    final q = query.trim();
    if (q.isEmpty) {
      return getRecipes();
    }
    final pattern = '%$q%';
    final rows = await _database.query(
      'recipes',
      where: 'title LIKE ? OR instructions LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'title',
    );
    return rows.map(_recipeFromRow).toList();
  }

  /// Số món theo dịp (để hiển thị badge "X Món" đúng thực tế).
  Future<int> getRecipeCountByOccasion(Occasion occasion) async {
    await ready;
    final r = await _database.rawQuery(
      'SELECT COUNT(*) FROM recipes WHERE occasion = ?',
      [occasion.name],
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  /// Ghi chú sau khi hoàn thành món (màn Hoàn thành). Mỗi món một bản ghi.
  Future<String?> getRecipeNote(String recipeId) async {
    await ready;
    final rows = await _database.query(
      'recipe_notes',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    if (rows.isEmpty) return null;
    return rows.first['note'] as String?;
  }

  /// Lưu ghi chú cho món (ghi đè nếu đã có).
  Future<void> saveRecipeNote(String recipeId, String note) async {
    await ready;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.insert(
      'recipe_notes',
      {'recipe_id': recipeId, 'note': note, 'updated_at': now},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy danh sách mâm cỗ (thư viện).
  Future<List<FeastInfo>> getFeasts() async {
    await ready;
    final rows = await _database.query('feasts', orderBy: 'title');
    return rows.map(_feastFromRow).toList();
  }

  /// Thêm món đặc biệt (tên, dịp, công thức, nguyên liệu).
  Future<String> insertRecipe({
    required String title,
    required String imageUrl,
    String? time,
    String? level,
    required Occasion occasion,
    String? instructions,
    required List<({String name, String quantity, MarketCategory category, String? note})> ingredients,
  }) async {
    await ready;
    final id = 'custom-${DateTime.now().millisecondsSinceEpoch}';
    await _database.insert('recipes', {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'time': time,
      'level': level,
      'occasion': occasion.name,
      'instructions': instructions,
    });
    for (final ing in ingredients) {
      await _database.insert('ingredients', {
        'recipe_id': id,
        'name': ing.name,
        'quantity': ing.quantity,
        'category': ing.category.name,
        'note_for_dish': ing.note,
        'checked': 0,
      });
    }
    return id;
  }

  /// Xoá món ăn (và nguyên liệu, ghi chú liên quan).
  Future<void> deleteRecipe(String recipeId) async {
    await ready;
    await _database.delete('ingredients', where: 'recipe_id = ?', whereArgs: [recipeId]);
    try {
      await _database.delete('recipe_notes', where: 'recipe_id = ?', whereArgs: [recipeId]);
    } catch (_) {
      // Bảng recipe_notes có thể chưa tồn tại trên DB cũ (trước khi có migration).
    }
    await _database.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
  }

  /// Lấy một món kèm đầy đủ nguyên liệu.
  Future<RecipeInfo?> getRecipeWithIngredients(String recipeId) async {
    await ready;
    final recipeRows = await _database.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );
    if (recipeRows.isEmpty) return null;
    final recipe = _recipeFromRow(recipeRows.first);

    final ingRows = await _database.query(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'id',
    );
    final ingredients = ingRows.map(_ingredientFromRow).toList();

    return RecipeInfo(
      id: recipe.id,
      title: recipe.title,
      imageUrl: recipe.imageUrl,
      time: recipe.time,
      level: recipe.level,
      occasion: recipe.occasion,
      instructions: recipe.instructions,
      ingredients: ingredients,
    );
  }

  /// Cập nhật trạng thái đã mua của nguyên liệu.
  Future<void> updateIngredientChecked(int ingredientId, bool checked) async {
    await ready;
    await _database.update(
      'ingredients',
      {'checked': checked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [ingredientId],
    );
  }

  /// Lấy danh sách bí kíp. [category] null hoặc [TipCategory.all] = tất cả.
  Future<List<TipInfo>> getTips({TipCategory? category}) async {
    await ready;
    final rows = (category == null || category == TipCategory.all)
        ? await _database.query('tips', orderBy: 'view_count DESC')
        : await _database.query(
            'tips',
            where: 'category = ?',
            whereArgs: [category.name],
            orderBy: 'view_count DESC',
          );
    return rows.map(_tipFromRow).toList();
  }

  /// Bí kíp nổi bật (is_featured = 1), lấy đầu tiên.
  Future<TipInfo?> getFeaturedTip() async {
    await ready;
    final rows = await _database.query(
      'tips',
      where: 'is_featured = 1',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _tipFromRow(rows.first);
  }

  /// Chi tiết một bí kíp theo id.
  Future<TipInfo?> getTipById(String id) async {
    await ready;
    final rows = await _database.query('tips', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _tipFromRow(rows.first);
  }

  /// Tăng lượt xem khi mở chi tiết.
  Future<void> incrementTipViewCount(String id) async {
    await ready;
    await _database.rawUpdate(
      'UPDATE tips SET view_count = view_count + 1 WHERE id = ?',
      [id],
    );
  }

  TipInfo _tipFromRow(Map<String, Object?> row) {
    final catStr = row['category'] as String?;
    final cat = catStr != null ? (TipCategory.values.asNameMap()[catStr] ?? TipCategory.meoVat) : TipCategory.meoVat;
    return TipInfo(
      id: row['id']! as String,
      title: row['title']! as String,
      subtitle: row['subtitle'] as String?,
      imageUrl: row['image_url']! as String,
      category: cat,
      content: row['content']! as String,
      viewCount: row['view_count'] as int? ?? 0,
      isFeatured: (row['is_featured'] as int?) == 1,
      authorName: row['author_name'] as String?,
      tags: row['tags'] as String?,
      cardStyle: TipCardStyle.fromString(row['card_style'] as String?),
    );
  }

  RecipeInfo _recipeFromRow(Map<String, Object?> row) {
    final occStr = row['occasion'] as String?;
    Occasion? occ;
    if (occStr != null) {
      try {
        occ = Occasion.values.byName(occStr);
      } catch (_) {}
    }
    return RecipeInfo(
      id: row['id']! as String,
      title: row['title']! as String,
      imageUrl: row['image_url']! as String,
      time: row['time'] as String?,
      level: row['level'] as String?,
      occasion: occ,
      instructions: row['instructions'] as String?,
      ingredients: const [],
    );
  }

  FeastInfo _feastFromRow(Map<String, Object?> row) {
    final occStr = row['occasion']! as String;
    Occasion occ;
    try {
      occ = Occasion.values.byName(occStr);
    } catch (_) {
      occ = Occasion.tet;
    }
    return FeastInfo(
      id: row['id']! as String,
      title: row['title']! as String,
      subtitle: row['subtitle']! as String,
      imageUrl: row['image_url']! as String,
      badge: row['badge']! as String,
      occasion: occ,
    );
  }

  MarketIngredient _ingredientFromRow(Map<String, Object?> row) {
    final categoryStr = row['category']! as String;
    final category = MarketCategory.values.asNameMap()[categoryStr] ?? MarketCategory.other;
    return MarketIngredient(
      id: row['id'] as int?,
      name: row['name']! as String,
      quantity: row['quantity']! as String,
      category: category,
      noteForDish: row['note_for_dish'] as String?,
      checked: (row['checked'] as int?) == 1,
    );
  }
}
