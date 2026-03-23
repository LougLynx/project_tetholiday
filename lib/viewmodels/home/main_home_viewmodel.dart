import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';

class MainHomeViewModel extends ChangeNotifier {
  List<(FeastInfo, int)> _feastCards = [];
  bool _isLoadingFeasts = true;
  
  List<(FeastInfo, int)> get feastCards => _feastCards;
  bool get isLoadingFeasts => _isLoadingFeasts;

  MainHomeViewModel() {
    loadFeastCards();
  }

  String get displayName {
    final session = Di.authRepository.currentSession;
    if (session == null) return 'Mâm Cỗ Việt';
    final name = session.user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = session.user.email;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Mâm Cỗ Việt';
  }

  Future<void> loadFeastCards() async {
    _isLoadingFeasts = true;
    notifyListeners();
    try {
      final feasts = await Di.feastRepository.getFeasts();
      final counts = await Future.wait(
        feasts.map((f) => Di.recipeRepository.getRecipeCountByOccasion(f.occasion)),
      );
      _feastCards = List.generate(feasts.length, (i) => (feasts[i], counts[i]));
    } finally {
      _isLoadingFeasts = false;
      notifyListeners();
    }
  }

}
