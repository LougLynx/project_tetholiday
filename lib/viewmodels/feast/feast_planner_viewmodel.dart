import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';
import 'dart:math';

class FeastPlannerViewModel extends ChangeNotifier {
  List<RecipeInfo> _allRecipes = [];
  List<RecipeInfo> _suggestedRecipes = [];
  bool _isLoading = false;
  int _peopleCount = 4;
  int _totalCost = 0;

  List<RecipeInfo> get allRecipes => _allRecipes;
  List<RecipeInfo> get suggestedRecipes => _suggestedRecipes;
  bool get isLoading => _isLoading;
  int get peopleCount => _peopleCount;
  int get totalCost => _totalCost;

  FeastPlannerViewModel() {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allRecipes = await Di.recipeRepository.getRecipes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void incrementPeople() {
    _peopleCount++;
    notifyListeners();
  }

  void decrementPeople() {
    if (_peopleCount > 1) {
      _peopleCount--;
      notifyListeners();
    }
  }

  Future<void> generateFeast(String budgetStr) async {
    final int? budget = int.tryParse(budgetStr);
    if (budget == null || budget <= 0) {
      throw Exception('Vui lòng nhập ngân sách hợp lệ');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800)); // Giả lập AI suy nghĩ
      
      final budgetLimit = budget * 1000;
      final candidates = _allRecipes.toList();
      candidates.shuffle();

      final result = <RecipeInfo>[];
      int currentTotal = 0;

      for (var r in candidates) {
        final cost = getRecipeCost(r.id) * _peopleCount;
        if (currentTotal + cost <= budgetLimit) {
          result.add(r);
          currentTotal += cost;
        }
        if (result.length >= 5) break; // Tối đa 5 món cho 1 mâm
      }

      if (result.isEmpty) {
        throw Exception('Ngân sách quá thấp để gợi ý mâm cỗ cho $_peopleCount người');
      }

      _suggestedRecipes = result;
      _totalCost = currentTotal;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getRecipeCost(String id) {
    // Giả lập giá tiền dựa trên độ khó hoặc ID
    final random = Random(id.hashCode);
    // Trả về giá trị trong khoảng 30.000đ - 100.000đ mỗi người
    return (30 + random.nextInt(71)) * 1000;
  }

}
