import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/viewmodels/recipe/cooking_complete_viewmodel.dart';
import 'package:project_tetholiday/views/home/main_page.dart';

/// Màn hoàn thành nấu ăn: chúc mừng, chụp ảnh, ghi chú, chia sẻ.
class CookingCompletePage extends StatefulWidget {
  const CookingCompletePage({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    this.recipeImageUrl,
  });

  final String recipeId;
  final String recipeTitle;
  final String? recipeImageUrl;

  @override
  State<CookingCompletePage> createState() => _CookingCompletePageState();
}

class _CookingCompletePageState extends State<CookingCompletePage> {
  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgLight = Color(0xFFF8F6F6);
  static const Color _bgDark = Color(0xFF181311);

  late CookingCompleteViewModel _viewModel;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _viewModel = CookingCompleteViewModel(widget.recipeId);
    _noteController = TextEditingController();
    _viewModel.initializeData().then((_) {
      if (mounted) {
        _noteController.text = _viewModel.note;
      }
    });
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    await _viewModel.saveNote(text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu ghi chú')),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _viewModel.dispose();
    super.dispose();
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
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHero(context, isDark),
                        if (_viewModel.feastProgress.isNotEmpty) _buildFeastProgressSection(isDark, _viewModel.feastProgress),
                        _buildFortuneSection(isDark, _viewModel),
                        _buildPhotoButton(context),
                        _buildNotesSection(context, isDark),
                        _buildShareSection(context, isDark),
                        _buildBackHome(context, isDark),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildHomeIndicator(isDark),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Expanded(
            child: Text(
              'HOÀN THÀNH',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.recipeImageUrl != null && widget.recipeImageUrl!.isNotEmpty)
                Image.network(
                  widget.recipeImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade700),
                )
              else
                Container(color: Colors.grey.shade700),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Thành tựu mới',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chúc mừng! Bạn đã hoàn thành ${widget.recipeTitle}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bạn đã chuẩn bị một bữa tiệc thật ấm cúng cho gia đình.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeastProgressSection(bool isDark, List<Map<String, dynamic>> progressList) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: progressList.map((f) {
          final double percent = f['total'] > 0 ? f['completed'] / f['total'] : 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tiến độ ${f['title']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '${f['completed']}/${f['total']} món',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  percent == 1.0 
                    ? 'Tuyệt vời! Bạn đã hoàn thiện toàn bộ mâm cỗ này.' 
                    : 'Cố lên! Chỉ còn ${f['total'] - f['completed']} món nữa là hoàn thành mâm cỗ.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFortuneSection(bool isDark, CookingCompleteViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: GestureDetector(
        onTap: vm.showFortune ? null : vm.pickFortune,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: vm.showFortune ? const Color(0xFFD43F33) : Colors.amber.shade700,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (vm.showFortune ? const Color(0xFFD43F33) : Colors.amber.shade700).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (!vm.showFortune) ...[
                const Icon(Icons.card_giftcard, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  'BỐC THẺ CẦU MAY',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Nhận lời chúc tốt lành cho năm mới',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                ),
              ] else ...[
                const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 30),
                const SizedBox(height: 16),
                Text(
                  vm.fortune ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LỜI CHÚC TẾT',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 10, letterSpacing: 2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.photo_camera),
        label: const Text('Chụp ảnh kỷ niệm'),
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? _primary.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? _primary.withValues(alpha: 0.2) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: _primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Ghi chú & Bí kíp rút kinh nghiệm',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ghi lại bí quyết riêng của bạn cho lần sau...',
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saveNote,
                child: Text(
                  'Lưu ghi chú',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection(BuildContext context, bool isDark) {
    final items = [
      (Icons.share, 'Facebook'),
      (Icons.chat_bubble_outline, 'Zalo'),
      (Icons.download, 'Tải về'),
      (Icons.more_horiz, 'Khác'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            'CHIA SẺ THÀNH QUẢ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((e) {
              return Column(
                children: [
                  Material(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(e.$1, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.$2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackHome(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (context) => const MainPage()),
            (route) => false,
          );
        },
        child: Text(
          'Quay lại Trang chủ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator(bool isDark) {
    return Container(
      height: 6,
      margin: const EdgeInsets.only(bottom: 8),
      width: 128,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
