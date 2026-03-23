import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

abstract interface class IRecipeRepository {
  Future<List<RecipeInfo>> getRecipes({Occasion? occasion});
  Future<List<RecipeInfo>> searchRecipes(String query);
  Future<int> getRecipeCountByOccasion(Occasion occasion);
  Future<RecipeInfo?> getRecipeWithIngredients(String recipeId);
  Future<void> updateIngredientChecked(int id, bool checked);
  Future<void> addIngredient(String recipeId, MarketIngredient ing);
  Future<void> deleteRecipe(String id);
  Future<void> markRecipeAsCompleted(String recipeId);
  Future<String?> getRecipeNote(String recipeId);
  Future<void> saveRecipeNote(String recipeId, String note);
  Future<String> insertRecipe({
    required String title,
    required String imageUrl,
    String? time,
    String? level,
    required Occasion occasion,
    String? instructions,
    required List<({String name, String quantity, MarketCategory category, String? note})> ingredients,
  });
}
