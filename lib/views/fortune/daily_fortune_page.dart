import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/domain/entities/fortune_data.dart';
import 'package:project_tetholiday/viewmodels/fortune/daily_fortune_viewmodel.dart';
import 'package:project_tetholiday/views/fortune/widgets/bamboo_tube_widget.dart';
import 'package:project_tetholiday/views/fortune/widgets/fortune_result_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class DailyFortunePage extends StatefulWidget {
  const DailyFortunePage({super.key});

  @override
  State<DailyFortunePage> createState() => _DailyFortunePageState();
}

class _DailyFortunePageState extends State<DailyFortunePage>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _bgColor = Color(0xFF1A0A00);
  static const Color _bamboo = Color(0xFF8B7355);
  static const Color _bambooLight = Color(0xFFD4B483);

  late DailyFortuneViewModel _viewModel;
  bool _isShaking = false;
  bool _showFallingStick = false;

  // Shake animation (xóc ống xăm)
  late AnimationController _shakeCtrl;
  // Stick fall animation (thẻ rơi ra)
  late AnimationController _fallCtrl;
  // Result reveal
  late AnimationController _revealCtrl;

  late Animation<double> _shakeX;
  late Animation<double> _shakeAngle;
  late Animation<double> _fallY;
  late Animation<double> _fallOpacity;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  final Random _rng = Random();
  // Các thẻ tre trong ống (vị trí ngẫu nhiên nhẹ)
  late final List<double> _stickOffsets;

  @override
  void initState() {
    super.initState();
    _stickOffsets = List.generate(10, (_) => (_rng.nextDouble() - 0.5) * 8);

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fallCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _revealCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _shakeAngle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.25, end: 0.25), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // fallY: bắt đầu từ miệng ống (offset 0) → rơi xuống 220px
    _fallY = Tween<double>(begin: 0, end: 220).animate(
      CurvedAnimation(parent: _fallCtrl, curve: Curves.easeIn),
    );
    _fallOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.2), weight: 3),
    ]).animate(_fallCtrl);

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _revealCtrl, curve: Curves.easeInOut),
    );
    _scaleIn = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutBack),
    );

    _viewModel = DailyFortuneViewModel();
    _viewModel.loadTodayFortune().then((_) {
      if (_viewModel.hasDrawn && mounted) {
        _revealCtrl.forward(from: 1);
      }
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _fallCtrl.dispose();
    _revealCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _xocOng() async {
    if (_isShaking || _viewModel.hasDrawn) return;
    HapticFeedback.heavyImpact();
    setState(() { _isShaking = true; _showFallingStick = false; });

    // Xóc ống 2 lần
    await _shakeCtrl.forward();
    _shakeCtrl.reset();
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _shakeCtrl.forward();
    _shakeCtrl.reset();

    // Thẻ rơi ra
    setState(() => _showFallingStick = true);
    await _fallCtrl.forward();

    await _viewModel.drawFortune();

    if (!mounted) return;
    setState(() {
      _isShaking = false;
      _showFallingStick = false;
    });
    _revealCtrl.forward(from: 0);
  }



  String _buildDateLabel() {
    final now = DateTime.now();
    const days = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    return '${days[now.weekday - 1]}, ngày ${now.day}/${now.month}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _bgColor,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _viewModel.hasDrawn && _viewModel.fortune != null
                      ? _buildFortuneResult(_viewModel.fortune!)
                      : _buildXocOngPrompt(),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.2,
          colors: [_primary.withValues(alpha: 0.4), _bgColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏮', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Text('Xin Xăm Đầu Ngày',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Lắc ống xăm · Thẻ rơi ra · Nhận duyên lành',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: _gold.withValues(alpha: 0.85), height: 1.4)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.35)),
                ),
                child: Text(_buildDateLabel(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: _gold, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Xóc Ống Xăm ─────────────────────────────────────────────────────────
  Widget _buildXocOngPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Cái ống xăm + thẻ đang tung lên
          GestureDetector(
            onTap: _xocOng,
            child: SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ống tre
                  AnimatedBuilder(
                    animation: _shakeCtrl,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeX.value, 0),
                      child: Transform.rotate(
                        alignment: Alignment.bottomCenter,
                        angle: _shakeAngle.value,
                        child: child,
                      ),
                    ),
                    child: BambooTubeWidget(
                      isShaking: _isShaking,
                      shakeCtrl: _shakeCtrl,
                      stickOffsets: _stickOffsets,
                    ),
                  ),
                  // Thẻ đang rơi ra — dùng Align + Transform thay Positioned
                  if (_showFallingStick)
                    Align(
                      alignment: const Alignment(0.4, -1),
                      child: AnimatedBuilder(
                        animation: _fallCtrl,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _fallY.value),
                          child: Opacity(
                            opacity: _fallOpacity.value,
                            child: child,
                          ),
                        ),
                        child: Transform.rotate(
                          angle: 0.35,
                          child: const SingleStickWidget(highlight: true),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Chạm vào ống xăm để xóc',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Lắc ống đến khi một thẻ tre rơi ra.\nMỗi ngày chỉ được xin một lần.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: Colors.white38, height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 32),
          if (_isShaking)
            Text('Đang xóc...', style: GoogleFonts.plusJakartaSans(color: _gold, fontSize: 14))
          else
            GestureDetector(
              onTap: _xocOng,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_bamboo, _bambooLight],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(color: _bamboo.withValues(alpha: 0.5),
                    blurRadius: 16, offset: const Offset(0, 6))],
                  border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎋', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text('XÓC ỐNG XĂM', style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }



  // ── Fortune Result ────────────────────────────────────────────────────────
  Widget _buildFortuneResult(FortuneData f) {
    return FortuneResultWidget(
      f: f,
      fadeIn: _fadeIn,
      scaleIn: _scaleIn,
      onResetTest: () {
        _revealCtrl.reset();
        _fallCtrl.reset();
        _shakeCtrl.reset();
        setState(() {
          _isShaking = false;
          _showFallingStick = false;
        });
        _viewModel.resetTest();
      },
    );
  }
}
