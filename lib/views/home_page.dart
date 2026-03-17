import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Màn chào mừng / onboarding - Mâm Cơm Việt.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _primary = Color(0xFFEC131E);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _backgroundDark = Color(0xFF221011);

  static const List<String> _slideImages = [
    'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2022/12/31/an-gi-76-1671587875403698617712-1672490579795-16724905798991236674306.jpg',
    'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2022/12/31/an-gi-60-16715878770101462967206-1672490577107-1672490577433399364482.jpg',
    'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2022/12/31/an-gi-86-1671587874815864690913-1672490573365-16724905734441065231730.jpg',
    'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2022/12/31/an-gi-98-16715878746801816647254-1672490572210-16724905723011174481148.jpg',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  static const Duration _slideDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(_slideDuration, (_) {
      if (!_pageController.hasClients) return;
      final next = (_currentPage + 1) % _slideImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _backgroundDark,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full screen background slide (tự động chuyển mỗi 4 giây, vẫn có thể vuốt tay)
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _startAutoSlide(); // reset timer khi user vuốt
              },
              itemCount: _slideImages.length,
              itemBuilder: (context, index) => Image.network(
                _slideImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: _backgroundDark),
              ),
            ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _backgroundDark,
                    _backgroundDark,
                    _backgroundDark.withValues(alpha: 0.4),
                    _backgroundDark.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Top bar: logo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant,
                          color: _accentGold,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mâm Cơm Việt',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Bottom card content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decorative accent
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 32,
                              color: _accentGold.withValues(alpha: 0.5),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Tinh Hoa Ẩm Thực',
                                style: GoogleFonts.plusJakartaSans(
                                  color: _accentGold,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              height: 1,
                              width: 32,
                              color: _accentGold.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Main heading
                        Text(
                          'Gìn giữ tinh hoa ẩm thực Việt qua từng mâm cỗ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtext
                        Text(
                          'Khám phá hàng ngàn công thức nấu ăn truyền thống và bí quyết chuẩn vị mâm cơm gia đình Việt.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Pagination dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slideImages.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _dot(active: index == _currentPage),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Primary button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _goToLogin(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              elevation: 8,
                              shadowColor: _primary.withValues(alpha: 0.3),
                            ).copyWith(
                              overlayColor: WidgetStateProperty.resolveWith((_) =>
                                  Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bắt đầu ngay',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward, size: 22),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Footer login link
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: 'Bạn đã có tài khoản? '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () => _goToLogin(context),
                                  child: Text(
                                    'Đăng nhập',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _accentGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _accentGold.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Safe area bottom
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      width: active ? 24 : 6,
      decoration: BoxDecoration(
        color: active ? _primary : Colors.white30,
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }
}
