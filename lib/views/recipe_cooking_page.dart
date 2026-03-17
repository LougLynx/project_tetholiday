import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/models/recipe_ingredient.dart';
import 'package:project_tetholiday/views/cooking_complete_page.dart';

/// Chế độ nấu ăn: từng bước + timer đếm ngược.
class RecipeCookingPage extends StatefulWidget {
  const RecipeCookingPage({
    super.key,
    required this.recipe,
  });

  final RecipeInfo recipe;

  @override
  State<RecipeCookingPage> createState() => _RecipeCookingPageState();
}

class _RecipeCookingPageState extends State<RecipeCookingPage> {
  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgLight = Color(0xFFF8F6F6);
  static const Color _bgDark = Color(0xFF221510);

  late List<String> _steps;
  int _currentStepIndex = 0;
  int _timerSeconds = 25 * 60; // 25 phút mặc định
  int _initialTimerSeconds = 25 * 60;
  bool _timerRunning = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _steps = _parseSteps(widget.recipe.instructions);
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerRunning) return;
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_timerSeconds <= 0) {
          _timer?.cancel();
          _timer = null;
          _timerRunning = false;
          return;
        }
        _timerSeconds--;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _timerRunning = false);
  }

  void _addOneMinute() {
    setState(() => _timerSeconds += 60);
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _timerRunning = false;
      _timerSeconds = _initialTimerSeconds;
    });
  }

  void _goNextStep() {
    if (_currentStepIndex >= _steps.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => CookingCompletePage(
            recipeId: widget.recipe.id,
            recipeTitle: widget.recipe.title,
            recipeImageUrl: widget.recipe.imageUrl,
          ),
        ),
      );
      return;
    }
    setState(() => _currentStepIndex++);
  }

  void _goPrevStep() {
    if (_currentStepIndex > 0) setState(() => _currentStepIndex--);
  }

  String get _timerLabel {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress =>
      _initialTimerSeconds > 0 ? 1 - (_timerSeconds / _initialTimerSeconds) : 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildProgressBar(isDark),
                    const SizedBox(height: 24),
                    _buildInstructionCard(isDark),
                    const SizedBox(height: 32),
                    _buildCircularTimer(isDark),
                    const SizedBox(height: 24),
                    _buildTimerControls(isDark),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Material(
      color: (isDark ? _bgDark : Colors.white).withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ĐANG NẤU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.recipe.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    final current = _currentStepIndex + 1;
    final total = _steps.length;
    final progress = total > 0 ? current / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ nấu ăn',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '$current / $total bước',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(_primary),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard(bool isDark) {
    final stepText = _steps[_currentStepIndex];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Bước ${_currentStepIndex + 1}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            stepText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTimer(bool isDark) {
    const size = 280.0;
    const strokeWidth = 12.0;
    return SizedBox(
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _TimerRingPainter(
                progress: _timerProgress,
                color: _primary,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timerLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _timerRunning ? Icons.pause_circle : Icons.play_circle,
                    size: 22,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timerRunning ? 'Đang đếm ngược' : 'Bắt đầu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (_timerRunning) _pauseTimer(); else _startTimer();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _timerRunning ? 'Tạm dừng' : 'Bắt đầu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _addOneMinute,
          icon: const Icon(Icons.replay, size: 20),
          label: const Text('+1p'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: _resetTimer,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
          child: const Text('Cài lại'),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: bgColor(isDark),
        border: Border(top: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Quay lại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: _goNextStep,
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: Text(_currentStepIndex >= _steps.length - 1 ? 'Hoàn thành' : 'Tiếp theo'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color bgColor(bool isDark) => isDark ? _bgDark : Colors.white;
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: r);

    final bg = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, bg);

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const startAngle = -1.5707963267948966; // -90°
    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, fg);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter old) =>
      old.progress != progress || old.color != color;
}
