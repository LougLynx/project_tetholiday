import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

class RecipeSearchViewModel extends ChangeNotifier {
  List<RecipeInfo> _recipes = [];
  bool _isLoading = false;
  String _query = '';

  List<RecipeInfo> get recipes => _recipes;
  bool get isLoading => _isLoading;

  void initialize(String? initialQuery) {
    if (initialQuery != null && initialQuery.isNotEmpty) {
      onSearchChanged(initialQuery);
    } else {
      _recipes = [];
      _query = '';
      notifyListeners();
    }
  }

  Future<void> onSearchChanged(String query) async {
    _query = query;
    if (query.trim().isEmpty) {
      _recipes = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await Di.recipeRepository.searchRecipes(query);
    } finally {
      if (query == _query) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    await onSearchChanged(_query);
  }
}
