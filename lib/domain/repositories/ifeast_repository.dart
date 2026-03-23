import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

abstract interface class IFeastRepository {
  Future<List<FeastInfo>> getFeasts();
  Future<List<Map<String, dynamic>>> getFeastProgress(String recipeId);
}
