import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BambooTubeWidget extends StatelessWidget {
  const BambooTubeWidget({
    super.key,
    required this.isShaking,
    required this.shakeCtrl,
    required this.stickOffsets,
  });

  final bool isShaking;
  final AnimationController shakeCtrl;
  final List<double> stickOffsets;

  static const Color _gold = Color(0xFFD4AF37);
  static const Color _bamboo = Color(0xFF8B7355);
  static const Color _bambooLight = Color(0xFFD4B483);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_bambooLight, _bamboo, Color(0xFF5C4A2A), _bamboo, _bambooLight],
          stops: [0, 0.2, 0.5, 0.8, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(4, 8)),
          BoxShadow(color: _bambooLight.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(-3, 0)),
        ],
        border: Border.all(color: _gold.withValues(alpha: 0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            ...List.generate(6, (i) => Positioned(
              top: 20.0 + i * 34,
              left: 0, right: 0,
              child: Container(
                height: 2,
                color: const Color(0xFF5C4A2A).withValues(alpha: 0.5),
              ),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(10, (i) {
                        final offset = stickOffsets[i];
                        return AnimatedBuilder(
                          animation: shakeCtrl,
                          builder: (context, child) {
                            final shake = isShaking ? sin(shakeCtrl.value * pi * 4 + i) * 6 : 0.0;
                            return Transform.translate(
                              offset: Offset(0, offset + shake),
                              child: Container(
                                width: 5,
                                height: 55,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: i % 3 == 0 ? _bambooLight : _bamboo,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Colors.black26, width: 0.5),
                                ),
                                child: i == 5
                                    ? Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          width: 4, height: 4,
                                          margin: const EdgeInsets.only(top: 2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red, shape: BoxShape.circle),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const Spacer(),
                  Container(height: 8, color: const Color(0xFF3D2B1A)),
                ],
              ),
            ),
            Positioned(
              top: 70, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('簽', style: GoogleFonts.plusJakartaSans(
                    fontSize: 28, color: _gold, fontWeight: FontWeight.bold, height: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleStickWidget extends StatelessWidget {
  const SingleStickWidget({super.key, this.highlight = false});

  final bool highlight;

  static const Color _gold = Color(0xFFD4AF37);
  static const Color _bamboo = Color(0xFF8B7355);
  static const Color _bambooLight = Color(0xFFD4B483);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlight
              ? const [_bambooLight, _gold, _bambooLight]
              : const [_bambooLight, _bamboo, _bambooLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _gold.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(color: _gold.withValues(alpha: 0.4), blurRadius: 12),
        ],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(width: 6, height: 6,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}
