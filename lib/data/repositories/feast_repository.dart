import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';
import 'package:project_tetholiday/domain/repositories/ifeast_repository.dart';

class FeastRepository implements IFeastRepository {
  final AppDatabase _db;
  FeastRepository(this._db);

  @override
  Future<List<FeastInfo>> getFeasts() => _db.getFeasts();

  @override
  Future<List<Map<String, dynamic>>> getFeastProgress(String recipeId) => _db.getFeastProgress(recipeId);
}
