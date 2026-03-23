import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

class RecipeListByOccasionViewModel extends ChangeNotifier {
  List<RecipeInfo> _recipes = [];
  bool _isLoading = false;
  Occasion? _lastOccasion;

  List<RecipeInfo> get recipes => _recipes;
  bool get isLoading => _isLoading;

  RecipeListByOccasionViewModel([Occasion? initialOccasion]) {
    if (initialOccasion != null) {
      loadRecipes(initialOccasion);
    }
  }

  Future<void> loadRecipes(Occasion occasion) async {
    _lastOccasion = occasion;
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await Di.recipeRepository.getRecipes(occasion: occasion);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_lastOccasion != null) {
      await loadRecipes(_lastOccasion!);
    }
  }
}
