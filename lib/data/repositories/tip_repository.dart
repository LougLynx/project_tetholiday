import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/domain/entities/tip.dart';
import 'package:project_tetholiday/domain/repositories/itip_repository.dart';

class TipRepository implements ITipRepository {
  final AppDatabase _db;
  TipRepository(this._db);

  @override
  Future<List<TipInfo>> getTips({TipCategory? category}) => _db.getTips(category: category);

  @override
  Future<TipInfo?> getFeaturedTip() => _db.getFeaturedTip();

  @override
  Future<TipInfo?> getTipById(String id) => _db.getTipById(id);

  @override
  Future<void> incrementTipViewCount(String id) => _db.incrementTipViewCount(id);
}
