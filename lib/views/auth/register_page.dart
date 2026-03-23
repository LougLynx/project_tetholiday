import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_tetholiday/viewmodels/login/login_viewmodel.dart';

/// Màn hình Đăng ký tài khoản mới.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _hasNavigated = false;

  static const Color _primary = Color(0xFFEE5B2B);
  static const Color _bgLight = Color(0xFFF8F6F6);
  static const Color _bgDark = Color(0xFF221510);

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _onRegisterSuccess() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main');
  }

  void _submit() {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;

    widget.viewModel.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.session != null && !_hasNavigated) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _onRegisterSuccess());
        }

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: widget.viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          if (widget.viewModel.errorMessage != null) ...[
                            _buildErrorBanner(context),
                            const SizedBox(height: 20),
                          ],
                          _buildLabel('Họ và tên'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Nguyễn Văn A',
                            icon: Icons.person_outline,
                            nextFocus: _usernameFocus,
                            isDark: isDark,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Tên đăng nhập'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _usernameController,
                            hint: 'ten_dang_nhap',
                            icon: Icons.alternate_email,
                            focusNode: _usernameFocus,
                            nextFocus: _passwordFocus,
                            isDark: isDark,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên đăng nhập.';
                              if (v.trim().length < 3) return 'Tên đăng nhập tối thiểu 3 ký tự.';
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                                return 'Chỉ dùng chữ, số và dấu gạch dưới.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Mật khẩu'),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: _passwordController,
                            hint: 'Ít nhất 6 ký tự',
                            focusNode: _passwordFocus,
                            nextFocus: _confirmFocus,
                            obscure: _obscurePass,
                            onToggle: () => setState(() => _obscurePass = !_obscurePass),
                            isDark: isDark,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu.';
                              if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Xác nhận mật khẩu'),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: _confirmController,
                            hint: 'Nhập lại mật khẩu',
                            focusNode: _confirmFocus,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            isDark: isDark,
                            onSubmit: _submit,
                            validator: (v) {
                              if (v != _passwordController.text) return 'Mật khẩu không khớp.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          _buildRegisterButton(),
                          const SizedBox(height: 16),
                          _buildLoginLink(context),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _primary.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.person_add_outlined, color: _primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào mừng bạn,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Tạo tài khoản',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.viewModel.errorMessage!,
              style: GoogleFonts.plusJakartaSans(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        filled: true,
        fillColor: isDark ? _primary.withValues(alpha: 0.08) : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
      onFieldSubmitted: (_) {
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    VoidCallback? onSubmit,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey.shade500, size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? _primary.withValues(alpha: 0.08) : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          onSubmit?.call();
        }
      },
    );
  }

  Widget _buildRegisterButton() {
    return FilledButton(
      onPressed: _submit,
      style: FilledButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: _primary.withValues(alpha: 0.3),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((_) => Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        'Tạo tài khoản',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Đăng nhập ngay',
            style: GoogleFonts.plusJakartaSans(
              color: _primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
