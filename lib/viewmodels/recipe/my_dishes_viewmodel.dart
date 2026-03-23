import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

class MyDishesViewModel extends ChangeNotifier {
  List<RecipeInfo> _seedRecipes = [];
  List<RecipeInfo> _myRecipes = [];
  bool _isLoading = false;

  List<RecipeInfo> get seedRecipes => _seedRecipes;
  List<RecipeInfo> get myRecipes => _myRecipes;
  bool get isLoading => _isLoading;

  MyDishesViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final all = await Di.recipeRepository.getRecipes();
      _seedRecipes = all.where((r) => !r.id.startsWith('custom-')).toList();
      _myRecipes = all.where((r) => r.id.startsWith('custom-')).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

}
