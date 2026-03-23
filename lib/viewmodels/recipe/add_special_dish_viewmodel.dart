import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

class AddSpecialDishViewModel extends ChangeNotifier {
  bool _saving = false;
  Occasion _occasion = Occasion.tet;

  bool get saving => _saving;
  Occasion get occasion => _occasion;

  void setOccasion(Occasion o) {
    _occasion = o;
    notifyListeners();
  }

  Future<String> saveRecipe({
    required String title,
    String? time,
    String? level,
    String? instructions,
    required List<({String name, String quantity, MarketCategory category, String? note})> ingredients,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      final id = await Di.recipeRepository.insertRecipe(
        title: title,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop', // Default image
        time: time,
        level: level,
        occasion: _occasion,
        instructions: instructions,
        ingredients: ingredients,
      );
      return id;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
