import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

class MarketListViewModel extends ChangeNotifier {
  final String recipeId;
  RecipeInfo? _recipe;
  bool _isLoading = true;
  String? _error;

  RecipeInfo? get recipe => _recipe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MarketIngredient> get ingredients => _recipe?.ingredients ?? [];
  int get totalCount => ingredients.length;
  int get checkedCount => ingredients.where((e) => e.checked).length;
  double get progress => totalCount > 0 ? checkedCount / totalCount : 0.0;

  Map<MarketCategory, List<MarketIngredient>> get byCategory {
    final Map<MarketCategory, List<MarketIngredient>> map = {};
    for (var cat in MarketCategory.values) {
      map[cat] = ingredients.where((e) => e.category == cat).toList();
    }
    return map;
  }

  MarketListViewModel(this.recipeId) {
    loadData(recipeId);
  }

  Future<void> loadData(String recipeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final recipe = await Di.recipeRepository.getRecipeWithIngredients(recipeId);
      if (recipe == null) {
        _error = 'Không tìm thấy món';
      } else {
        _recipe = recipe;
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleIngredient(int indexInList) async {
    final ing = ingredients[indexInList];
    final originalState = ing.checked;
    final newState = !originalState;
    
    // Update local state by creating a new list with a copy of the ingredient
    if (_recipe != null) {
      final newList = List<MarketIngredient>.from(_recipe!.ingredients);
      newList[indexInList] = newList[indexInList].copyWith(checked: newState);
      _recipe = _recipe!.copyWith(ingredients: newList);
      notifyListeners();
    }

    try {
      await Di.recipeRepository.updateIngredientChecked(ing.id!, newState);
    } catch (_) {
      // rollback UI
      if (_recipe != null) {
        final newList = List<MarketIngredient>.from(_recipe!.ingredients);
        newList[indexInList] = newList[indexInList].copyWith(checked: originalState);
        _recipe = _recipe!.copyWith(ingredients: newList);
        notifyListeners();
      }
    }
  }

  Future<void> deleteRecipe() async {
    await Di.recipeRepository.deleteRecipe(recipeId);
  }

  Future<void> addIngredient(String name, String qty, MarketCategory category) async {
    if (name.trim().isEmpty) return;
    
    final newIng = MarketIngredient(name: name, quantity: qty, category: category);
    await Di.recipeRepository.addIngredient(recipeId, newIng);
    await loadData(recipeId);
  }
}
