import 'package:project_tetholiday/data/database/app_database.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';
import 'package:project_tetholiday/domain/repositories/irecipe_repository.dart';

class RecipeRepository implements IRecipeRepository {
  final AppDatabase _db;
  RecipeRepository(this._db);

  @override
  Future<List<RecipeInfo>> getRecipes({Occasion? occasion}) => _db.getRecipes(occasion: occasion);

  @override
  Future<List<RecipeInfo>> searchRecipes(String query) => _db.searchRecipes(query);

  @override
  Future<int> getRecipeCountByOccasion(Occasion occasion) => _db.getRecipeCountByOccasion(occasion);

  @override
  Future<RecipeInfo?> getRecipeWithIngredients(String recipeId) => _db.getRecipeWithIngredients(recipeId);

  @override
  Future<void> updateIngredientChecked(int id, bool checked) => _db.updateIngredientChecked(id, checked);

  @override
  Future<void> addIngredient(String recipeId, MarketIngredient ing) => _db.addIngredient(recipeId, ing);

  @override
  Future<void> deleteRecipe(String id) => _db.deleteRecipe(id);

  @override
  Future<void> markRecipeAsCompleted(String recipeId) => _db.markRecipeAsCompleted(recipeId);

  @override
  Future<String?> getRecipeNote(String recipeId) => _db.getRecipeNote(recipeId);

  @override
  Future<void> saveRecipeNote(String recipeId, String note) => _db.saveRecipeNote(recipeId, note);

  @override
  Future<String> insertRecipe({
    required String title,
    required String imageUrl,
    String? time,
    String? level,
    required Occasion occasion,
    String? instructions,
    required List<({String name, String quantity, MarketCategory category, String? note})> ingredients,
  }) => _db.insertRecipe(
    title: title,
    imageUrl: imageUrl,
    time: time,
    level: level,
    occasion: occasion,
    instructions: instructions,
    ingredients: ingredients,
  );
}
