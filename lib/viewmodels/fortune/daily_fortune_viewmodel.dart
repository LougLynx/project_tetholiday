import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/fortune_data.dart';

class DailyFortuneViewModel extends ChangeNotifier {
  bool _hasDrawn = false;
  FortuneData? _fortune;

  bool get hasDrawn => _hasDrawn;
  FortuneData? get fortune => _fortune;

  Future<void> loadTodayFortune() async {
    try {
      final today = _todayKey();
      final saved = await Di.settingsRepository.getSetting('fortune_date');
      if (saved == today) {
        _fortune = await _generateFortuneAsync();
        _hasDrawn = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<FortuneData> drawFortune() async {
    final data = await _generateFortuneAsync();
    _fortune = data;
    _hasDrawn = true;
    
    // Lưu ngày bốc xăm vào settings qua Repository
    await Di.settingsRepository.saveSetting('fortune_date', _todayKey());
    
    notifyListeners();
    return data;
  }

  void resetTest() {
    _fortune = null;
    _hasDrawn = false;
    notifyListeners();
  }

  Future<FortuneData> _generateFortuneAsync() async {
    final data = await Di.fortuneRepository.generateDailyFortune();
    return FortuneData(
      queName: data['queName']!,
      queSymbol: data['queSymbol']!,
      fortuneLevel: data['fortuneLevel']!,
      stickNumber: data['stickNumber']!,
      verse: data['verse']!,
      dish: data['dish']!,
      dishMeaning: data['dishMeaning']!,
      imageUrl: data['imageUrl']!,
      advice: data['advice']!,
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

}
