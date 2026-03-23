import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';

class CookingCompleteViewModel extends ChangeNotifier {
  final String recipeId;
  
  List<Map<String, dynamic>> _feastProgress = [];
  bool _isSaving = false;
  String _note = '';
  bool _showFortune = false;
  String? _fortune;

  List<Map<String, dynamic>> get feastProgress => _feastProgress;
  bool get isSaving => _isSaving;
  String get note => _note;
  bool get showFortune => _showFortune;
  String? get fortune => _fortune;

  CookingCompleteViewModel(this.recipeId);

  Future<void> initializeData() async {
    _isSaving = true;
    notifyListeners();

    await Di.recipeRepository.markRecipeAsCompleted(recipeId);

    // Load progress
    _feastProgress = await Di.feastRepository.getFeastProgress(recipeId);

    // Load notes
    final savedNote = await Di.recipeRepository.getRecipeNote(recipeId);
    _note = savedNote ?? '';

    _isSaving = false;
    notifyListeners();
  }

  Future<void> saveNote(String text) async {
    _note = text;
    await Di.recipeRepository.saveRecipeNote(recipeId, text);
    notifyListeners();
  }

  Future<void> pickFortune() async {
    if (_showFortune) return;
    
    final data = await Di.fortuneRepository.generateDailyFortune();
    _fortune = "Chúc mừng! Bạn nhận được quẻ: ${data['queName']}. ${data['advice']}";
    _showFortune = true;
    notifyListeners();
  }
}
