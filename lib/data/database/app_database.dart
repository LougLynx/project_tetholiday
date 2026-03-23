import 'dart:async';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/tip.dart';

/// SQLite database cho món ăn và nguyên liệu.
/// Dùng [AppDatabase.instance] để truy cập.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'mam_co_viet.db';
  static const int _version = 18;

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
    await _createTablesV8(db);
    await _createTablesV9(db);
    await _createTablesV10(db);
    await _createTablesV11(db);
  }

  Future<void> _createTablesV8(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS feast_recipes (
        feast_id TEXT NOT NULL,
        recipe_id TEXT NOT NULL,
        PRIMARY KEY (feast_id, recipe_id),
        FOREIGN KEY (feast_id) REFERENCES feasts(id),
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS completed_recipes (
        recipe_id TEXT PRIMARY KEY,
        completed_at INTEGER NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
      )
    ''');
  }

  Future<void> _createTablesV9(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTablesV10(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        display_name TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    // Seed tài khoản admin mặc định
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin',
      'display_name': 'Quản trị viên',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _createTablesV11(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fortune_hexagrams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        level TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fortune_dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        meaning TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fortune_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fortune_advices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL
      )
    ''');

    await db.delete('fortune_hexagrams');
    await db.delete('fortune_dishes');
    await db.delete('fortune_verses');
    await db.delete('fortune_advices');

    final hexagrams = [
      ('Quẻ Càn - Trời', '☰', 'Đại Cát'),
      ('Quẻ Khảm - Nước', '☵', 'Cát'),
      ('Quẻ Chấn - Sấm', '☳', 'Đại Cát'),
      ('Quẻ Cấn - Núi', '☶', 'Trung Bình'),
      ('Quẻ Ly - Lửa', '☲', 'Đại Cát'),
      ('Quẻ Tốn - Gió', '☴', 'Cát'),
      ('Quẻ Đoài - Đầm', '☱', 'Cát'),
      ('Quẻ Khôn - Đất', '☷', 'Trung Bình'),
      ('Quẻ Thái - Thái Bình', '䷊', 'Thượng Cát'),
      ('Quẻ Đồng Nhân - Tình Người', '䷌', 'Đại Cát'),
      ('Quẻ Đại Hữu - Sung Túc', '䷍', 'Thượng Cát'),
      ('Quẻ Khiêm - Nhún Nhường', '䷎', 'Cát'),
      ('Quẻ Ích - Gia Tăng', '䷩', 'Đại Cát'),
    ];
    for (final h in hexagrams) {
      await db.insert('fortune_hexagrams', {'name': h.$1, 'symbol': h.$2, 'level': h.$3});
    }

    final dishes = [
      ('Gà Luộc Lá Chanh', 'Gà luộc tượng trưng cho sự khởi đầu tinh khôi, da vàng óng mang lại tài lộc dồi dào. Lá chanh xanh tươi là biểu tượng của sức sống mãnh liệt và năm mới đầy hy vọng.', 'https://www.bing.com/images/search?view=detailV2&ccid=elcT8S2c&id=0DB729DC577ADDDF6EED22F505E30BBCB4F5E4F0&thid=OIP.elcT8S2cnZwxw-Y7wy4aBAHaFS&mediaurl=https%3a%2f%2fhaithuycatering.com%2fimage%2f5c9add30e4a8d65eafb70f55%2foriginal.jpg&cdnurl=https%3a%2f%2fth.bing.com%2fth%2fid%2fR.7a5713f12d9c9d9c31c3e63bc32e1a04%3frik%3d8OT1tLwL4wX1Ig%26pid%3dImgRaw%26r%3d0&exph=500&expw=700&q=g%c3%a0+lu%e1%bb%99c+l%c3%a1+chanh&FORM=IRPRST&ck=DA1EE514E3A7B895ED641496036CCED2&selectedIndex=0&itb=0'),
      ('Canh Khổ Qua Nhồi Thịt', 'Khổ qua là biểu tượng "qua đi cái đắng cay" — ăn để cầu bỏ lại khó khăn. Nhân thịt bên trong là phúc lộc được ươm chứa, đợi ngày nảy nở.', 'https://th.bing.com/th/id/OIP.LJr2jOE4Ul2mWFUPDXLkZAHaEK?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3'),
      ('Nem Rán Truyền Thống', 'Nem rán vàng giòn khối trụ tựa như những thỏi vàng. Tiếng nổ lốp bốp khi rán như pháo vui tai, mang lại năng lượng tràn trề để đón năm mới.', 'https://ttol.vietnamnetjsc.vn/images/2022/02/15/09/52/nem-ran-005.jpg'),
      ('Thịt Nấu Đông', 'Thịt đông cứng chắc như núi, cần sự kiên nhẫn và thời tiết lạnh giá để hoàn thành. Tượng trưng cho sự gắn kết gia đình và tầm nhìn vượt qua thử thách.', 'https://static.hawonkoo.vn/hwk02/images/2023/10/cach-nau-thit-dong-thom-ngon-chuan-vi-mien-bac.jpg'),
      ('Xôi Gấc', 'Màu đỏ của gấc là màu của lửa ấm, dương khí và tình yêu thương. Mâm xôi gấc đỏ sẫm là báo hiệu của thịnh vượng, duyên lành và hỷ sự.', 'https://tse4.mm.bing.net/th/id/OIP.Ps7mCPomW4KW5JDILBNHcQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3'),
      ('Gỏi Ngó Sen Tôm Thịt', 'Ngó sen vươn thẳng từ bùn đất mà vẫn giòn ngọt — tượng trưng cho sự thanh cao, không nhiễm bụi trần. Tôm tươi mang sắc đỏ tài vận dồi dào.', 'https://cooponline.vn/tin-tuc/wp-content/uploads/2025/10/goi-ngo-sen-tom-thit-cong-thuc-lam-mon-goi-thanh-mat-gion-ngot-chuan-vi-viet.png'),
      ('Chè Hạt Sen Nhãn Lồng', 'Hạt sen biểu tượng của sự thuần khiết và trí tuệ yên tĩnh. Nhãn lồng bọc ngoài mang đến sư bao bọc, chở che. Chè mang ý nghĩa êm ấm, hòa thuận.', 'https://th.bing.com/th/id/R.7c59100f35d82717e5c3622d06f31599?rik=EZCWSvqK3Mp6kQ&pid=ImgRaw&r=0'),
      ('Bánh Chưng', 'Bánh chưng hình vuông tượng trưng cho Đất — mẹ của muôn loài. Lớp lá dong ôm lấy nếp, đậu, thịt là hình ảnh của sự đùm bọc, no ấm trọn vẹn.', 'https://tse4.mm.bing.net/th/id/OIP.qwoUeGesj8Vo2Q2X8nz9wgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3'),
    ];
    for (final d in dishes) {
      await db.insert('fortune_dishes', {'name': d.$1, 'meaning': d.$2, 'image_url': d.$3});
    }

    final verses = [
      '"Trời cao lồng lộng, vận may theo gió xuân sang,\nHoa nở đầu ngõ, phúc lộc tràn đầy cửa nhà."',
      '"Nước chảy đá mòn, kiên trì qua sóng gió,\nBình an như nước, lòng người tự rộng mở."',
      '"Tiếng sấm vang rền, đất trời chuyển bĩ thành thái,\nNăng động như sấm, vạn sự ắt hanh thông."',
      '"Núi vững chãi giữa ngàn cơn gió táp,\nBình tĩnh như núi, tâm an vận tự thịnh."',
      '"Lửa rực sáng soi rõ bước đường muôn dặm,\nTâm sáng, khí thanh, hồng phúc bao phủ quanh năm."',
      '"Gió nhẹ đưa, muôn hoa thay áo mới,\nMềm mại vô tư, duyên tơ vương nẻo về."',
      '"Trong như mặt đầm, tâm thái an vui ngày nắng,\nNụ cười vô giá, vạn điều lành hội tụ."',
      '"Đất hiền từ ôm ấp mầm sống nhỏ,\nVun trồng nỗ lực, ngày mốt gặt vàng son."',
      '"Trăng khuyết rồi tròn, bĩ cực chờ thái lai,\nChớ luyến chuyện cũ, hoa gấm chờ tương lai."',
      '"Người gieo lộc đức, cành lá tỏa xanh tươi,\nNhà tích thiện tâm, vinh hoa đơm nụ cười."',
      '"Thuận theo tự nhiên, nước êm chảy thành sông,\nKhông vội không cầu, phúc lộc bước thong dong."',
      '"Chân thành đãi người, đá sỏi cũng nở hoa,\nKhoan dung xử thế, bão tố hóa ngọc ngà."',
      '"Đại đạo vô hình, cứ ngay thẳng mà bước,\nTâm vô tạp niệm, bận lòng chi được mất."',
      '"Trúc gầy đón gió nhưng quyết không gãy gập,\nMai qua sương giá mới tỏa ngát sầu vương."',
      '"Chim hót cành mai, mây trôi bầu trời tạnh,\nHòa ái nhường nhịn, phước lộc lớn vô vàn."'
    ];
    for (final v in verses) {
      await db.insert('fortune_verses', {'content': v});
    }

    final advices = [
      'Hôm nay là thời điểm tuyệt vời để khởi đầu việc lớn. Hãy chủ động, tự tin và rộng tay đón nhận may mắn đang tới.',
      'Kiên nhẫn là chìa khóa của bạn lúc này. Đừng vội vàng, hãy chắt lọc từng chút một và con đường sẽ tự mở ra.',
      'Hành động quyết đoán, đừng chần chừ. Một cơ hội hiếm có đang xuất hiện, chỉ dành cho người dám nắm lấy.',
      'Không phải là ngày chạy đua đua sắc. Hãy dành thời gian củng cố nền tảng. Những thứ chắc chắn mới bền vững dài lâu.',
      'Trái tim nhiệt thành của bạn sẽ truyền cảm hứng mạnh mẽ cho người xung quanh. Hãy chủ động chia sẻ niềm vui!',
      'Linh hoạt và nhẹ nhàng chính là vũ khí. Đừng quá cứng nhắc, đôi khi lùi một bước lại thấy cả bầu trời.',
      'Mỉm cười thường xuyên hơn. Niềm vui bạn vô tình trao đi hôm nay sẽ quay trở lại nhân lên gấp bội chiều nay.',
      'Dành thời gian chất lượng cho người thân. Sự ấm áp từ gia đình chính là lá bùa hộ mệnh vững chắc nhất.',
      'Đôi khi lựa chọn sáng suốt nhất là cho bản thân một khoảng lặng. Tái tạo năng lượng sẽ mang lại cái nhìn mới mẻ.',
      'Một lời khen chân thành hôm nay có giá trị hơn rất nhiều tài vật. Đừng ngần ngại nói những lời có cánh.',
      'Sự tỉ mỉ sẽ cứu bạn khỏi một rắc rối không đáng có. Đừng chủ quan, hãy xem xét kỹ các chi tiết nhỏ.',
      'Hôm nay đừng tranh cãi đúng sai. Cứ bao dung và nhường nhịn một chút, bạn sẽ thấy may mắn mỉm cười.',
      'Có một cơ hội tuyệt vời đang ngụy trang dưới vẻ ngoài xui xẻo. Hãy chậm lại để phân tích tình hình.',
      'Hào phóng chia sẻ tài năng hoặc kiến thức với người khác. Càng dang tay cho đi, phước báu càng hội tụ.',
      'Dọn dẹp lại không gian xung quanh. Vứt bỏ những thứ không cần thiết sẽ giúp dòng chảy tài lộc hanh thông trở lại.'
    ];
    for (final a in advices) {
      await db.insert('fortune_advices', {'content': a});
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      await _createTablesV8(db);
      await _seedFeastRecipes(db);
    }
    if (oldVersion < 9) {
      await _createTablesV9(db);
    }
    if (oldVersion < 10) {
      await _createTablesV10(db);
    }
    if (oldVersion < 11) {
      await _createTablesV11(db);
    }
    if (oldVersion < 12) {
      // Bổ sung các tip mới mà không xóa tip cũ
      await _seedTipsIfEmpty(db);
    }
    if (oldVersion < 18) {
      // BẮT BUỘC: Xoá dữ liệu từ các Cột con (có chứa FOREIGN KEY) trước để không bị lỗi Constraint Violation
      await db.delete('feast_recipes');
      await db.delete('completed_recipes', where: "recipe_id LIKE 'recipe-%'");
      await db.delete('recipe_notes', where: "recipe_id LIKE 'recipe-%'");
      await db.delete('ingredients', where: "recipe_id LIKE 'recipe-%'");

      // Xoá các bảng Cột cha sau đó
      await db.delete('recipes', where: "id LIKE 'recipe-%'");
      await db.delete('feasts', where: "id LIKE 'feast-%'");
      await db.delete('tips', where: "id LIKE 'tip-%'");
      
      // Xoá toàn bộ data của bảng xin quẻ (để build lại toàn bộ link ảnh mới)
      await db.delete('fortune_dishes');
      await db.delete('fortune_verses');
      await db.delete('fortune_advices');
      await db.delete('fortune_hexagrams');

      // Seed lại toàn bộ dữ liệu kèm cờ Replace chống trùng lập
      await _runFullSeed(db);
      await _createTablesV11(db); // Gọi hàm nạp lại quẻ
    }
  }

  Future<void> _seedFeastRecipes(Database db) async {
    final mapping = [
      ('feast-tet-1', 'recipe-1'),
      ('feast-tet-1', 'recipe-2'),
      ('feast-tet-1', 'recipe-4'),
      ('feast-tet-1', 'recipe-5'),
      ('feast-tet-1', 'recipe-6'),
      ('feast-tet-1', 'recipe-9'),
      ('feast-tet-1', 'recipe-10'),
      ('feast-tet-1', 'recipe-12'),
      ('feast-tet-2', 'recipe-3'),
      ('feast-tet-2', 'recipe-4'),
      ('feast-tet-2', 'recipe-8'),
      ('feast-tet-2', 'recipe-13'),
      ('feast-trung-thu-1', 'recipe-6'),
      ('feast-trung-thu-1', 'recipe-15'),
      ('feast-dam-cuoi-1', 'recipe-5'),
      ('feast-dam-cuoi-1', 'recipe-7'),
      ('feast-dam-cuoi-1', 'recipe-14'),
    ];
    for (final m in mapping) {
      await db.insert('feast_recipes', {'feast_id': m.$1, 'recipe_id': m.$2},
          conflictAlgorithm: ConflictAlgorithm.ignore);
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
    if (count != null && count > 0) return;
    await _runFullSeed(_database);
  }

  /// Chèn đủ recipes, ingredients, feasts, tips (dùng khi DB trống).
  Future<void> _runFullSeed(Database db) async {
    final batch = db.batch();

    final recipes = [
      ('recipe-1', 'Nem Rán Truyền Thống', 'https://rapido.vn/wp-content/uploads/2022/02/nem-ran-12.jpg', '45p', 'Khó', 'tet', '1. Ngâm miến, mộc nhĩ, nấm hương rồi băm nhỏ.\n2. Trộn các nguyên liệu với thịt băm, trứng và gia vị.\n3. Cuốn nem bằng bánh đa nem.\n4. Chiên ngập dầu nhỏ lửa cho đến khi vàng giòn.'),
      ('recipe-2', 'Xôi Gấc', 'https://thucthan.com/media/2019/04/xoi-gac-dau-xanh/xoi-gac-dau-xanh.jpg', '60p', 'Vừa', 'tet', '1. Ngâm gạo nếp qua đêm.\n2. Lấy xôi trộn với thịt gấc và một ít rượu trắng.\n3. Đem đồ xôi khoảng 30 - 45 phút cho chín mềm.\n4. Thêm đường và dầu ăn đảo đều trước khi bắc ra.'),
      ('recipe-3', 'Thịt Kho Hột Vịt', 'https://nghebep.com/wp-content/uploads/2018/06/thit-kho-hot-vit1.jpg', '120p', 'Dễ', 'tet', '1. Thịt ba chỉ cắt miếng to, ướp nước mắm, đường, hành tỏi.\n2. Trưng nước màu, cho thịt vào xào săn.\n3. Đổ nước dừa tươi vào nồi, thêm trứng vịt luộc bóc vỏ.\n4. Kho nhỏ lửa đến khi thịt mềm, nước cạn sánh.'),
      ('recipe-4', 'Bánh Chưng', 'https://th.bing.com/th/id/R.4a23ed7db0a76d3e3b4547f56ae94c74?rik=cGtWe6KYuriugA&pid=ImgRaw&r=0', '720p', 'Khó', 'tet', '1. Ngâm nếp, đỗ xanh qua đêm.\n2. Thịt lợn thái miếng to, ướp tiêu, hành, muối.\n3. Gói bánh bằng lá dong, từng lớp nếp, đỗ, thịt.\n4. Luộc bánh từ 10-12 tiếng cho chín nhừ.'),
      ('recipe-5', 'Gà Luộc Lá Chanh', 'https://tse2.mm.bing.net/th/id/OIP.a43hOsd5-XhyRjqYXm057gHaE8?rs=1&pid=ImgDetMain&o=7&rm=3', '40p', 'Vừa', 'tet', '1. Gà làm sạch, xát muối gừng.\n2. Đặt gà vào nồi, đổ ngập nước, đun sôi rồi hạ nhỏ lửa.\n3. Ngâm gà trong nồi nước thêm 15 phút cho chín đều.\n4. Chặt miếng vừa ăn, rắc lá chanh thái chỉ.'),
      ('recipe-6', 'Bánh Nướng Thập Cẩm', 'https://th.bing.com/th/id/OIP.iM5C5vFDmWfm_iBSbV3lywHaFi?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3', '90p', 'Khó', 'trungThu', '1. Trộn các nguyên liệu nhân thập cẩm, nặn thành viên.\n2. Chuẩn bị vỏ bánh nướng, cán mỏng, bọc nhân lại.\n3. Đóng khuôn tạo hình bánh.\n4. Nướng bánh nhiều lần, quết trứng vàng ươm.'),
      ('recipe-7', 'Gỏi Ngó Sen Tôm Thịt', 'https://th.bing.com/th/id/OIP.IU1qvruHbqzodY7_Edc6OAHaE8?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3', '30p', 'Dễ', 'damCuoi', '1. Ngó sen làm sạch, chẻ đôi, ngâm chua ngọt.\n2. Tôm luộc bóc vỏ, thịt ba chỉ luộc thái mỏng.\n3. Trộn ngó sen, tôm, thịt với nước mắm chua ngọt.\n4. Rắc đậu phộng rang và ngò rí lên trên.'),
      ('recipe-8', 'Canh Khổ Qua Nhồi Thịt', 'https://cdn.tgdd.vn/Files/2019/01/03/1142366/bi-quyet-nau-canh-kho-qua-don-thit-khong-bao-gio-bi-dang-202107301211370247.jpg', '45p', 'Vừa', 'tet', '1. Khổ qua mổ ruột, rửa sạch ngâm muối.\n2. Thịt xay trộn nạc, mộc nhĩ, gia vị.\n3. Nhồi thịt vào khổ qua thật chặt.\n4. Hầm lửa nhỏ đến khi khổ qua chín mềm, nêm ngò gai.'),
      ('recipe-9', 'Dưa Hành Ngâm', 'https://th.bing.com/th/id/OIP.h4CKwCX6-BRjzc4s2RSlUAHaFj?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3', '3p', 'Dễ', 'tet', '1. Hành củ ngâm tro, sấy héo.\n2. Lột vỏ ngoài, rửa sạch bằng nước muối loãng.\n3. Đun nước mắm đường chua ngọt để nguội.\n4. Ngâm hành trong lọ thủy tinh từ 3-5 ngày.'),
      ('recipe-10', 'Thịt Nấu Đông', 'https://media.cooky.vn/recipe/g5/44837/s/recipe44837-cook-step6-636833296712225497.jpg', '180p', 'Trung bình', 'tet', '1. Tai heo, thịt chân giò luộc sơ, thái miếng.\n2. Ướp nước mắm, tiêu sọ, mộc nhĩ.\n3. Ninh mềm thả mộc nhĩ vào đun sôi lại.\n4. Đổ ra khuôn để trong ngăn mát chờ đông.'),
      ('recipe-11', 'Canh Măng Bóng Bì', 'https://th.bing.com/th/id/R.7e92449b5d83df496394c1ccccfc4fc5?rik=BfpEo38pQMeWWg&pid=ImgRaw&r=0', '60p', 'Khó', 'tet', '1. Bóng bì ngâm rượu gừng tẩy mùi.\n2. Nấu nước dùng xương gà thật trong.\n3. Trần măng, tôm, su hào, cà rốt tạo hình.\n4. Xếp lồng canh và chan nước dùng nóng hổi.'),
      ('recipe-12', 'Chả Lụa', 'https://tse1.explicit.bing.net/th/id/OIP.8hPgcRnFoyp0HNhje_-lJgHaFj?rs=1&pid=ImgDetMain&o=7&rm=3', '120p', 'Khó', 'tet', '1. Thịt nạc mông giã nhuyễn với nước đá.\n2. Nêm bột năng, xíu nước mắm ngon.\n3. Gói lá chuối thật chặt tay.\n4. Luộc chín vớt ra để nguội hoàn toàn.'),
      ('recipe-13', 'Tôm Khô Củ Kiệu', 'https://th.bing.com/th/id/OIP.OMQtxTPQj6WA0vt1uO0KfgHaDk?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3', '10p', 'Dễ', 'tet', '1. Kiệu ngâm chua ngọt giòn rụm.\n2. Tôm khô ngâm nước ấm cho mềm, xào sơ.\n3. Xếp xen kẽ củ kiệu và tôm ra đĩa nhỏ.\n4. Rắc chút đường hoặc ớt bột ăn kèm bánh tét.'),
      ('recipe-14', 'Bò Xào Cần Tây', 'https://cdn.tgdd.vn/2021/05/CookRecipe/Avatar/thit-bo-xao-can-tay-thumbnail.jpg', '15p', 'Dễ', 'damCuoi', '1. Thịt bò thái mỏng ướp tỏi, tiêu, dầu hào.\n2. Cần tây, tỏi tây cắt khúc.\n3. Xào thịt bò lửa lớn chín tới múc ra đĩa.\n4. Xào rau, đổ thịt bò lại đảo đều rồi tắt bếp.'),
      ('recipe-15', 'Chè Hạt Sen Nhãn Lồng', 'https://tse4.mm.bing.net/th/id/OIP.qN6LcfBkkV5Xh2tZwwi9nAHaFj?pid=ImgDet&w=60&h=60&c=7&rs=1&o=7&rm=3', '40p', 'Vừa', 'trungThu', '1. Hạt sen ninh nhừ với đường phèn.\n2. Nhãn lồng bóc vỏ, bỏ hạt.\n3. Lồng hạt sen vào trong cùi nhãn.\n4. Đổ nước chè vào bát, ướp lạnh trước khi ăn.'),
    ];

    for (final r in recipes) {
      batch.insert('recipes', {
        'id': r.$1, 'title': r.$2, 'image_url': r.$3, 'time': r.$4, 'level': r.$5, 'occasion': r.$6, 'instructions': r.$7,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final ingredients = [
      ('recipe-1', 'Thịt lợn băm', '300g', 'meat', 'Chọn mỡ nạc đan xen', 0),
      ('recipe-1', 'Miến dong', '50g', 'other', 'Ngâm nở thái nhỏ', 0),
      ('recipe-2', 'Gạo nếp', '500g', 'other', 'Nếp cái hoa vàng', 0),
      ('recipe-2', 'Gấc chín', '1 quả', 'vegetables', 'Lấy thịt gấc đỏ', 0),
      ('recipe-3', 'Thịt ba chỉ', '1 kg', 'meat', 'Cắt miếng to', 0),
      ('recipe-3', 'Trứng vịt', '6 quả', 'other', 'Luộc chín bóc vỏ', 0),
      ('recipe-3', 'Nước dừa tươi', '1 quả', 'other', null, 0),
      ('recipe-4', 'Gạo nếp nương', '2 kg', 'other', 'Ngâm qua đêm', 0),
      ('recipe-4', 'Đỗ xanh', '500g', 'vegetables', 'Không vỏ', 0),
      ('recipe-4', 'Lá dong', '1 bó', 'other', 'Rửa sạch, lau khô', 0),
      ('recipe-5', 'Gà ta', '1 con (~1.5kg)', 'meat', 'Mổ moi', 0),
      ('recipe-5', 'Lá chanh', '10 lá', 'vegetables', 'Thái chỉ', 0),
      ('recipe-6', 'Bột mì', '300g', 'other', 'Cho vỏ bánh', 0),
      ('recipe-6', 'Hạt dưa, mứt bí', '200g', 'other', 'Cho nhân', 0),
      ('recipe-7', 'Ngó sen', '300g', 'vegetables', 'Làm sạch trắng', 0),
      ('recipe-7', 'Tôm thẻ', '200g', 'meat', 'Lấy chỉ lưng trắng', 0),
    ];

    for (final i in ingredients) {
      batch.insert('ingredients', {
        'recipe_id': i.$1, 'name': i.$2, 'quantity': i.$3, 'category': i.$4, 'note_for_dish': i.$5, 'checked': i.$6,
      });
    }

    await batch.commit(noResult: true);
    await _insertFeastsSeed(db);
    await _seedTipsIfEmpty(db);
    await _seedFeastRecipes(db);
  }

  Future<void> _insertFeastsSeed(Database db) async {
    final feasts = [
      ('feast-tet-1', 'Mâm Cỗ Tết Miền Bắc', 'Bánh chưng, dưa hành, thịt đông - đậm đà bản sắc Hà Nội xưa.', 'https://www.btaskee.com/wp-content/uploads/2022/01/mam-co-ngay-tet-mien-bac.jpg', '8 Món', 'tet'),
      ('feast-tet-2', 'Mâm Cỗ Tết Miền Nam', 'Bánh tét, thịt kho hột vịt, canh khổ qua - cầu mong năm mới sung túc.', 'https://tse1.mm.bing.net/th/id/OIP.h8PDKikNoXVyNcxmLvt7fgHaE7?rs=1&pid=ImgDetMain&o=7&rm=3', '6 Món', 'tet'),
      ('feast-trung-thu-1', 'Mâm Cỗ Trung Thu Phá Cỗ', 'Bánh nướng, bánh dẻo và mâm ngũ quả tạo hình nghệ thuật.', 'https://cdn.mediamart.vn/images/news/mam-c-trung-thu-co-nhng-gi-net-dc-dao-trong-mam-c-trung-thu-ba-min_2fec7a95.jpg', '6 Món', 'trungThu'),
      ('feast-dam-cuoi-1', 'Mâm Cỗ Đám Cưới Truyền Thống', 'Gỏi, xôi, gà luộc, các món truyền thống cho ngày đại hỷ.', 'https://icdn.24h.com.vn/upload/4-2024/images/2024-11-18/1731890335-co-cuoi-0954-width600height400.jpg', '10 Món', 'damCuoi'),
    ];
    for (final f in feasts) {
      await db.insert('feasts', {
        'id': f.$1, 'title': f.$2, 'subtitle': f.$3, 'image_url': f.$4, 'badge': f.$5, 'occasion': f.$6,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _seedTipsIfEmpty(Database db) async {
    final tips = [
      // MẸO VẶT
      ('tip-1', 'Cách luộc gà vàng ươm căng bóng', 'Mẹo luộc gà cúng đẹp mắt, không bị nứt da.', 'https://nhahangcontoc.com/wp-content/uploads/2023/01/ga-luoc.jpg', 'meoVat', 'Để luộc gà đẹp, xát nghệ và gừng lên da gà trước khi luộc. Nước luộc phải ngập gà và luộc ở lửa vừa rồi tắt bếp ngâm.', 150, 1, 'Bếp Trưởng Đạt', 'luộc gà', 'normal'),
      ('tip-3', 'Cách giữ màu xanh cho rau luộc', 'Mẹo nhỏ với chanh và đá lạnh khiến rau luộc luôn mướt xanh.', 'https://afamilycdn.com/150157425591193600/2021/8/28/rau-mue1bb91ng-lue1bb99c-recipe-main-photo-1630090122697489111738.jpg', 'meoVat', 'Luộc rau nước sôi bùng, cho vài hạt muối. Rau vớt ra nhúng nhanh vào âu nước đá lạnh sẽ giòn và giữ màu xanh đẹp mắt.', 50, 0, 'Minh Hà', 'rau củ', 'normal'),
      ('tip-8', 'Bí kíp khử mùi hôi thịt lợn (heo) hiệu quả', 'Sơ chế thịt lợn sạch thơm trước khi chế biến các món Tết.', 'https://image.voh.com.vn/voh/Image/2023/12/29/khu-mui-hoi-thit-heo-duc-voh.jpg?t=o', 'meoVat', 'Luộc sơ thịt với nước lạnh có pha chút muối, gừng đập dập và hành tím. Vớt bọt thường xuyên. Sau khi luộc sơ, rửa sạch thịt dưới vòi nước lạnh rồi mới bắt đầu chế biến chính.', 60, 0, 'Minh Hà', 'sơ chế', 'normal'),

      // TỶ LỆ VÀNG
      ('tip-6', 'Mẹo rán nem (chả giò) giòn lâu, vàng đều', 'Bí quyết để đĩa nem luôn giòn rụm trong suốt bữa tiệc.', 'https://bepmina.vn/wp-content/uploads/2021/05/cach-lam-nem-ran-gion-lau-1024x701.jpeg', 'tyLeVang', 'Trong nhân nem không nên cho quá nhiều trứng làm nem nhanh ỉu. Khi gói, quết một ít nước giấm pha loãng lên vỏ bánh đa nem. Rán làm 2 lần: lần 1 rán sơ, lần 2 rán vàng giòn trước khi ăn.', 310, 1, 'Bếp Trưởng Đạt', 'rán nem', 'large'),
      ('tip-9', 'Công thức nước mắm chua ngọt chuẩn vị', 'Tỷ lệ vàng 1-1-1-4 cho mọi món nem, gỏi ngày Tết.', 'https://tse3.mm.bing.net/th/id/OIP.EFfUvX4j-DDwZgNeTbPyYgHaEK?rs=1&pid=ImgDetMain&o=7&rm=3', 'tyLeVang', 'Tỷ lệ chuẩn: 1 thìa nước mắm ngon, 1 thìa đường, 1 thìa cốt chanh/giấm, 4 thìa nước lọc. Đánh tan đường trong nước trước, sau đó mới cho mắm và chanh. Cuối cùng thả tỏi ớt băm nhỏ lên trên để tỏi ớt nổi đẹp mắt.', 420, 0, 'Cô Ba Bình Dương', 'nước mắm', 'normal'),
      ('tip-10', 'Bí kíp pha bột bánh dẻo mịn thơm', 'Tỷ lệ bột và nước đường để bánh dẻo lâu không bị khô.', 'https://www.lorca.vn/wp-content/uploads/2023/08/1-25-scaled.jpg', 'tyLeVang', 'Tỷ lệ 1 phần bột bánh dẻo : 2 phần nước đường. Cho thêm một chút nước hoa bưởi để bánh thơm nồng nàn đặc trưng ngày đoàn viên.', 85, 0, 'Linh Chi', 'bánh dẻo', 'normal'),

      // BẢO QUẢN
      ('tip-4', 'Bí quyết muối dưa hành trắng giòn, không hăng', 'Mẹo khử mùi hăng và giữ hành luôn trắng đẹp cho ngày Tết.', 'https://nuocmamlegia.com/wp-content/uploads/2019/11/cach-muoi-dua-hanh-cho-ngay-tet-4.jpg', 'baoQuan', 'Hành trước khi muối nên ngâm vào nước tro hoặc nước vo gạo đậm đặc qua đêm. Khi muối, cho thêm vài lát riềng và dùng nước mắm đường chua ngọt đã đun sôi để nguội hoàn toàn.', 120, 0, 'Bà Nội', 'muối dưa', 'normal'),
      ('tip-5', 'Cách ngâm măng khô nở đều, trắng sạch', 'Mẹo xử lý măng khô cho bát canh măng ngày Tết tròn vị.', 'https://imgamp.phunutoday.vn/files/dataimages/201601/02/original/cach-ngam-mang-kho-nhanh-no-nhat-1-phunutodayvn_1451702268.jpg', 'baoQuan', 'Măng khô cần ngâm nước sạch ít nhất 3 ngày, mỗi ngày thay nước 2 lần. Sau đó luộc măng vài lần cho đến khi nước trong, vớt ra cắt miếng vừa ăn và tước nhỏ trước khi xào hầm.', 80, 0, 'Mẹ Đảm', 'măng khô', 'normal'),
      ('tip-11', 'Giữ bánh chưng lâu hỏng sau Tết', 'Cách xử lý khi bánh chưng bị lại nếp hoặc có dấu hiệu mốc.', 'https://tse1.explicit.bing.net/th/id/OIP.svOaAVH2t_sQKbRWpMqYSQHaFj?rs=1&pid=ImgDetMain&o=7&rm=3', 'baoQuan', 'Bánh chưng ăn không hết nên bảo quản trong ngăn mát tủ lạnh. Khi ăn, nên mang đi chiên hoặc hấp lại. Nếu lá bị mốc nhẹ bên ngoài, hãy gọt bỏ phần lá và dùng màng bọc thực phẩm bọc kín lại.', 215, 0, 'Bà Nội', 'bánh chưng', 'normal'),

      // SỔ TAY CỔ
      ('tip-2', 'Bí quyết gói bánh chưng vuông vức', 'Cách gói bánh đẹp không cần khuôn chuẩn vị truyền thống.', 'https://tse3.mm.bing.net/th/id/OIP.N7dOrdyN_xBkXAOTZqPLkwHaE8?rs=1&pid=ImgDetMain&o=7&rm=3', 'soTayCo', 'Nên xếp lá dong vuông góc kép, cho tỉ lệ gạo đỗ thịt đều nhau. Đặc biệt chú ý cách gấp góc lá thật kín để khi luộc nước không ngấm vào bánh.', 200, 1, 'Nghệ Nhân Lan', 'bánh chưng', 'large'),
      ('tip-7', 'Cách chọn gạo nếp cái hoa vàng chuẩn vị Tết', 'Mẹo phân biệt gạo nếp ngon để nấu xôi, làm bánh.', 'https://down-vn.img.susercontent.com/file/9c528a8ea821cd50dd4878e2d718764d', 'soTayCo', 'Gạo nếp cái hoa vàng chuẩn hạt phải tròn đều, màu trắng đục nhẹ (không quá trắng tinh). Cắn thử thấy vị ngọt tự nhiên, mùi thơm đặc trưng dù chưa nấu. Tránh chọn hạt bị nát hoặc có mùi ẩm mốc.', 95, 0, 'Nghệ Nhân Lan', 'gạo nếp', 'normal'),
      ('tip-12', 'c', 'Hướng dẫn bày mâm ngũ quả truyền thống 3 miền.', 'https://www.btaskee.com/wp-content/uploads/2022/01/mam-co-tet-mien-bac.jpg', 'soTayCo', 'Mâm ngũ quả thể hiện ước nguyện "Cầu - Sung - Vừa - Đủ - Xài". Màu sắc phải hài hòa theo ngũ hành: Kim (trắng), Mộc (xanh), Thủy (đen/tím), Hỏa (đỏ), Thổ (vàng).', 280, 0, 'Thầy Đồ Nam', 'mâm ngũ quả', 'normal'),
    ];
    for (final t in tips) {
      await db.insert('tips', {
        'id': t.$1, 'title': t.$2, 'subtitle': t.$3, 'image_url': t.$4, 'category': t.$5, 'content': t.$6, 'view_count': t.$7, 'is_featured': t.$8,
        'author_name': t.$9, 'tags': t.$10, 'card_style': t.$11,
      }, conflictAlgorithm: ConflictAlgorithm.replace); // To ensure they get updated categories if reused IDs
    }
  }

  Future<List<RecipeInfo>> getRecipes({Occasion? occasion}) async {
    await ready;
    final rows = occasion == null
        ? await _database.query('recipes', orderBy: 'title')
        : await _database.query('recipes', where: 'occasion = ?', whereArgs: [occasion.name], orderBy: 'title');
    return rows.map(_recipeFromRow).toList();
  }

  Future<List<RecipeInfo>> searchRecipes(String query) async {
    await ready;
    final q = query.trim();
    if (q.isEmpty) return getRecipes();
    final pattern = '%$q%';
    final rows = await _database.query(
      'recipes',
      where: 'title LIKE ? OR instructions LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'title',
    );
    return rows.map(_recipeFromRow).toList();
  }

  Future<int> getRecipeCountByOccasion(Occasion occasion) async {
    await ready;
    final r = await _database.rawQuery('SELECT COUNT(*) FROM recipes WHERE occasion = ?', [occasion.name]);
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<String?> getRecipeNote(String recipeId) async {
    await ready;
    final rows = await _database.query('recipe_notes', where: 'recipe_id = ?', whereArgs: [recipeId]);
    return rows.isEmpty ? null : rows.first['note'] as String?;
  }

  Future<void> saveRecipeNote(String recipeId, String note) async {
    await ready;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.insert('recipe_notes', {'recipe_id': recipeId, 'note': note, 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FeastInfo>> getFeasts() async {
    await ready;
    final rows = await _database.query('feasts', orderBy: 'title');
    return rows.map(_feastFromRow).toList();
  }

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

  Future<RecipeInfo?> getRecipeWithIngredients(String recipeId) async {
    await ready;
    final r = await _database.query('recipes', where: 'id = ?', whereArgs: [recipeId]);
    if (r.isEmpty) return null;
    final recipe = _recipeFromRow(r.first);
    final ingRows = await _database.query('ingredients', where: 'recipe_id = ?', whereArgs: [recipeId], orderBy: 'id');
    return RecipeInfo(
      id: recipe.id, title: recipe.title, imageUrl: recipe.imageUrl, time: recipe.time, level: recipe.level,
      occasion: recipe.occasion, instructions: recipe.instructions, ingredients: ingRows.map(_ingredientFromRow).toList(),
    );
  }

  Future<void> updateIngredientChecked(int id, bool checked) async {
    await ready;
    await _database.update('ingredients', {'checked': checked ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addIngredient(String recipeId, MarketIngredient ing) async {
    await ready;
    await _database.insert('ingredients', {
      'recipe_id': recipeId, 'name': ing.name, 'quantity': ing.quantity, 'category': ing.category.name,
      'note_for_dish': ing.noteForDish, 'checked': ing.checked ? 1 : 0,
    });
  }

  Future<void> deleteRecipe(String id) async {
    await ready;
    await _database.delete('ingredients', where: 'recipe_id = ?', whereArgs: [id]);
    await _database.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markRecipeAsCompleted(String recipeId) async {
    await ready;
    await _database.insert(
      'completed_recipes',
      {'recipe_id': recipeId, 'completed_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFeastProgress(String recipeId) async {
    await ready;
    final feasts = await _database.rawQuery('''
      SELECT f.id, f.title FROM feasts f
      JOIN feast_recipes fr ON f.id = fr.feast_id
      WHERE fr.recipe_id = ?
    ''', [recipeId]);

    final List<Map<String, dynamic>> results = [];
    for (final f in feasts) {
      final feastId = f['id'] as String;
      final feastTitle = f['title'] as String;
      final totalRes = await _database.rawQuery('SELECT COUNT(*) as cnt FROM feast_recipes WHERE feast_id = ?', [feastId]);
      final total = totalRes.first['cnt'] as int;
      final completedRes = await _database.rawQuery('''
        SELECT COUNT(*) as cnt FROM feast_recipes fr
        JOIN completed_recipes cr ON fr.recipe_id = cr.recipe_id
        WHERE fr.feast_id = ?
      ''', [feastId]);
      final completed = completedRes.first['cnt'] as int;

      results.add({'title': feastTitle, 'total': total, 'completed': completed});
    }
    return results;
  }

  // ── Sinh quẻ từ DB ──────────────────────────────────────────
  Future<Map<String, String>> generateDailyFortune() async {
    await ready;
    final db = _database;
    final hexagrams = await db.rawQuery('SELECT * FROM fortune_hexagrams ORDER BY RANDOM() LIMIT 1');
    final dishes = await db.rawQuery('SELECT * FROM fortune_dishes ORDER BY RANDOM() LIMIT 1');
    final verses = await db.rawQuery('SELECT * FROM fortune_verses ORDER BY RANDOM() LIMIT 1');
    final advices = await db.rawQuery('SELECT * FROM fortune_advices ORDER BY RANDOM() LIMIT 1');

    final h = hexagrams.isNotEmpty ? hexagrams.first : {'name': 'Quẻ Khẩn', 'symbol': '？', 'level': 'Bình'};
    final d = dishes.isNotEmpty ? dishes.first : {'name': 'Mâm Trống', 'meaning': 'Không có dữ liệu', 'image_url': ''};
    final v = verses.isNotEmpty ? verses.first : {'content': 'Chưa cập nhật'};
    final a = advices.isNotEmpty ? advices.first : {'content': 'Chưa cập nhật'};

    final rng = Random();
    final stickIdx = rng.nextInt(99) + 1;
    final stickPrefixes = ['Đệ Nhất', 'Đệ Nhị', 'Đệ Tam', 'Đệ Tứ', 'Đệ Ngũ', 'Đệ Lục', 'Đệ Thất', 'Đệ Bát', 'Đệ Cửu', 'Đệ Thập'];
    final stickNumber = stickIdx <= 10 ? '${stickPrefixes[stickIdx - 1]} Ký' : 'Số $stickIdx Ký';

    return {
      'queName': h['name'] as String,
      'queSymbol': h['symbol'] as String,
      'fortuneLevel': h['level'] as String,
      'dish': d['name'] as String,
      'dishMeaning': d['meaning'] as String,
      'imageUrl': d['image_url'] as String,
      'verse': v['content'] as String,
      'advice': a['content'] as String,
      'stickNumber': stickNumber,
    };
  }

  Future<List<TipInfo>> getTips({TipCategory? category}) async {
    await ready;
    final rows = (category == null || category == TipCategory.all)
        ? await _database.query('tips', orderBy: 'view_count DESC')
        : await _database.query('tips', where: 'category = ?', whereArgs: [category.name], orderBy: 'view_count DESC');
    return rows.map(_tipFromRow).toList();
  }

  Future<TipInfo?> getFeaturedTip() async {
    await ready;
    final rows = await _database.query('tips', where: 'is_featured = 1', limit: 1);
    return rows.isEmpty ? null : _tipFromRow(rows.first);
  }

  Future<TipInfo?> getTipById(String id) async {
    await ready;
    final rows = await _database.query('tips', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _tipFromRow(rows.first);
  }

  Future<void> incrementTipViewCount(String id) async {
    await ready;
    await _database.rawUpdate('UPDATE tips SET view_count = view_count + 1 WHERE id = ?', [id]);
  }

  RecipeInfo _recipeFromRow(Map<String, Object?> row) {
    final occStr = row['occasion'] as String?;
    return RecipeInfo(
      id: row['id']! as String, title: row['title']! as String, imageUrl: row['image_url']! as String,
      time: row['time'] as String?, level: row['level'] as String?,
      occasion: occStr != null ? Occasion.values.byName(occStr) : null,
      instructions: row['instructions'] as String?, ingredients: const [],
    );
  }

  FeastInfo _feastFromRow(Map<String, Object?> row) {
    return FeastInfo(
      id: row['id']! as String, title: row['title']! as String, subtitle: row['subtitle']! as String,
      imageUrl: row['image_url']! as String, badge: row['badge']! as String,
      occasion: Occasion.values.byName(row['occasion']! as String),
    );
  }

  MarketIngredient _ingredientFromRow(Map<String, Object?> row) {
    return MarketIngredient(
      id: row['id'] as int?, name: row['name']! as String, quantity: row['quantity']! as String,
      category: MarketCategory.values.asNameMap()[row['category']! as String] ?? MarketCategory.other,
      noteForDish: row['note_for_dish'] as String?, checked: (row['checked'] as int?) == 1,
    );
  }

  TipInfo _tipFromRow(Map<String, Object?> row) {
    return TipInfo(
      id: row['id']! as String, title: row['title']! as String, subtitle: row['subtitle'] as String?,
      imageUrl: row['image_url']! as String,
      category: TipCategory.values.asNameMap()[row['category'] as String] ?? TipCategory.meoVat,
      content: row['content']! as String, viewCount: row['view_count'] as int? ?? 0,
      isFeatured: (row['is_featured'] as int?) == 1, authorName: row['author_name'] as String?,
      tags: row['tags'] as String?, cardStyle: TipCardStyle.fromString(row['card_style'] as String?),
    );
  }

  // ── App Settings (key-value store) ──────────────────────────────────────
  Future<String?> getSetting(String key) async {
    await ready;
    final rows = await _database.query('app_settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await ready;
    await _database.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSetting(String key) async {
    await ready;
    await _database.delete('app_settings', where: 'key = ?', whereArgs: [key]);
  }

  // ── User Auth ────────────────────────────────────────────────────────────
  /// Đăng nhập: trả về map row nếu đúng, null nếu sai.
  Future<Map<String, Object?>?> loginUser(String username, String password) async {
    await ready;
    final rows = await _database.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim().toLowerCase(), password],
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Đăng ký: trả về id mới, ném Exception nếu username đã tồn tại.
  Future<int> registerUser({
    required String username,
    required String password,
    required String displayName,
  }) async {
    await ready;
    final existing = await _database.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) {
      throw Exception('Tên đăng nhập đã được sử dụng.');
    }
    return _database.insert('users', {
      'username': username.trim().toLowerCase(),
      'password': password,
      'display_name': displayName.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
