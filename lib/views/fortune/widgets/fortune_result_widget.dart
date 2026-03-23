import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/domain/entities/fortune_data.dart';

class FortuneResultWidget extends StatelessWidget {
  const FortuneResultWidget({
    super.key,
    required this.f,
    required this.fadeIn,
    required this.scaleIn,
    this.onResetTest,
  });

  final FortuneData f;
  final Animation<double> fadeIn;
  final Animation<double> scaleIn;
  final VoidCallback? onResetTest;

  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _bamboo = Color(0xFF8B7355);
  static const Color _bambooLight = Color(0xFFD4B483);

  Color _fortuneColor(String level) {
    switch (level) {
      case 'Đại Cát': return const Color(0xFFD4AF37);
      case 'Cát':     return const Color(0xFF4CAF50);
      case 'Trung Bình': return const Color(0xFFFF9800);
      default:        return _primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lvlColor = _fortuneColor(f.fortuneLevel);
    return FadeTransition(
      opacity: fadeIn,
      child: ScaleTransition(
        scale: scaleIn,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Thẻ tre kết quả
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultStick(f, lvlColor),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.stickNumber,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: _gold.withValues(alpha: 0.7), letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(f.queSymbol, style: TextStyle(fontSize: 44, color: lvlColor)),
                        Text(f.queName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: lvlColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: lvlColor.withValues(alpha: 0.5)),
                          ),
                          child: Text('✦ ${f.fortuneLevel} ✦',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, fontWeight: FontWeight.bold,
                              color: lvlColor, letterSpacing: 1.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Câu thơ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: lvlColor.withValues(alpha: 0.3)),
                ),
                child: Text(f.verse,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: Colors.white70, height: 1.8, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 20),

              // Món ăn
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _gold.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(f.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade900,
                            child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 48))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('MÓN NÊN NẤU HÔM NAY',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10, fontWeight: FontWeight.bold,
                                color: _primary, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 8),
                          Text(f.dish,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🍀 ', style: TextStyle(fontSize: 16)),
                              Expanded(
                                child: Text(f.dishMeaning,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14, color: Colors.white60, height: 1.6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Lời khuyên
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_gold.withValues(alpha: 0.12), _primary.withValues(alpha: 0.07)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text('Lời Khuyên Hôm Nay',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.bold, color: _gold)),
                    ]),
                    const SizedBox(height: 10),
                    Text(f.advice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: Colors.white70, height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('🎋 Thẻ của bạn đã được ghi lại đến hết hôm nay',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white24),
                textAlign: TextAlign.center),
              const SizedBox(height: 16),
              // Nút Test
              if (onResetTest != null)
                TextButton.icon(
                  onPressed: onResetTest,
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white38),
                  label: Text('Xóc lại (Test)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white38)),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStick(FortuneData f, Color lvlColor) {
    return Container(
      width: 44,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_bambooLight, _bamboo, Color(0xFF5C4A2A), _bamboo, _bambooLight],
          stops: [0, 0.2, 0.5, 0.8, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: lvlColor.withValues(alpha: 0.4), blurRadius: 14, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          const Spacer(),
          RotatedBox(
            quarterTurns: 3,
            child: Text(f.stickNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9, color: _gold, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const Spacer(),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            height: 1, color: Colors.black38)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
