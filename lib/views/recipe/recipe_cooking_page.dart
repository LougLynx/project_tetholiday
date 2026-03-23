import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/domain/entities/recipe_ingredient.dart';
import 'package:project_tetholiday/viewmodels/recipe/recipe_cooking_viewmodel.dart';
import 'package:project_tetholiday/views/recipe/cooking_complete_page.dart';

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

  late RecipeCookingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RecipeCookingViewModel();
    _viewModel.initialize(widget.recipe.instructions);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNextStep() {
    if (_viewModel.isLastStep) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => CookingCompletePage(
            recipeId: widget.recipe.id,
            recipeTitle: widget.recipe.title,
            recipeImageUrl: widget.recipe.imageUrl,
          ),
        ),
      );
    } else {
      _viewModel.goNextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
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
            );
          }
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
    final current = _viewModel.currentStepIndex + 1;
    final total = _viewModel.steps.length;
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
            'Bước ${_viewModel.currentStepIndex + 1}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _viewModel.currentStepText,
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
                progress: _viewModel.timerProgress,
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
                _viewModel.timerLabel,
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
                    _viewModel.timerRunning ? Icons.pause_circle : Icons.play_circle,
                    size: 22,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _viewModel.timerRunning ? 'Đang đếm ngược' : 'Bắt đầu',
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
                  if (_viewModel.timerRunning) {
                    _viewModel.pauseTimer();
                  } else {
                    _viewModel.startTimer();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _viewModel.timerRunning ? 'Tạm dừng' : 'Bắt đầu',
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
          onPressed: _viewModel.addOneMinute,
          icon: const Icon(Icons.replay, size: 20),
          label: const Text('+1p'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: _viewModel.resetTimer,
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
        color: isDark ? _bgDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (_viewModel.currentStepIndex > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _viewModel.goPrevStep,
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: _handleNextStep,
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: Text(_viewModel.isLastStep ? 'Hoàn thành' : 'Tiếp theo'),
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
