import 'dart:async';
import 'package:flutter/foundation.dart';

class RecipeCookingViewModel extends ChangeNotifier {
  late List<String> _steps;
  int _currentStepIndex = 0;
  
  int _timerSeconds = 25 * 60; // 25 phút mặc định
  final int _initialTimerSeconds = 25 * 60;
  bool _timerRunning = false;
  Timer? _timer;

  List<String> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  int get timerSeconds => _timerSeconds;
  bool get timerRunning => _timerRunning;
  int get initialTimerSeconds => _initialTimerSeconds;

  String get currentStepText => _steps.isNotEmpty ? _steps[_currentStepIndex] : '';
  bool get isLastStep => _currentStepIndex >= _steps.length - 1;

  String get timerLabel {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get timerProgress =>
      _initialTimerSeconds > 0 ? 1 - (_timerSeconds / _initialTimerSeconds) : 0.0;

  void initialize(String? instructions) {
    _steps = _parseSteps(instructions);
    if (_steps.isEmpty) _steps.add('Làm theo hướng dẫn công thức.');
  }

  static List<String> _parseSteps(String? instructions) {
    if (instructions == null || instructions.trim().isEmpty) return [];
    final lines = instructions.trim().split(RegExp(r'\n'));
    final steps = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final match = RegExp(r'^\d+\.\s*').firstMatch(trimmed);
      final text = match != null ? trimmed.substring(match.end).trim() : trimmed;
      if (text.isNotEmpty) steps.add(text);
    }
    return steps.isEmpty ? [instructions.trim()] : steps;
  }

  void startTimer() {
    if (_timerRunning) return;
    _timerRunning = true;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerSeconds <= 0) {
        _timer?.cancel();
        _timer = null;
        _timerRunning = false;
        notifyListeners();
        return;
      }
      _timerSeconds--;
      notifyListeners();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _timerRunning = false;
    notifyListeners();
  }

  void addOneMinute() {
    _timerSeconds += 60;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _timerRunning = false;
    _timerSeconds = _initialTimerSeconds;
    notifyListeners();
  }

  void goNextStep() {
    if (!isLastStep) {
      _currentStepIndex++;
      notifyListeners();
    }
  }

  void goPrevStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
