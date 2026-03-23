import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/domain/repositories/ifortune_repository.dart';

class FortuneRepository implements IFortuneRepository {
  final AppDatabase _db;
  FortuneRepository(this._db);

  @override
  Future<Map<String, String>> generateDailyFortune() => _db.generateDailyFortune();
}
