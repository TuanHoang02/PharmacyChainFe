import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/auth/controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final RegisterController _controller = RegisterController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final role = await _controller.register();

    if (!mounted) return;

    if (role != null) {
      _showSuccessAndNavigate(role);
    }
  }

  void _showSuccessAndNavigate(String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Đăng ký thành công! Đang đăng nhập...'),
          ],
        ),
        backgroundColor: const Color(0xFF00C48C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // According to AppRouter, if role is Customer, we go to /customer
    final normalizedRole = role.toLowerCase();
    if (normalizedRole == 'customer') {
      context.go('/customer');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // ── Background gradient blobs ──────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: _GlowBlob(
              color: const Color(0xFF1E88E5).withAlpha(60),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _GlowBlob(
              color: const Color(0xFF00C48C).withAlpha(50),
              size: 240,
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: -40,
            child: _GlowBlob(
              color: const Color(0xFF7C3AED).withAlpha(35),
              size: 180,
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Brand Section ─────────────────────────────
                        _buildBrandSection(),
                        const SizedBox(height: 32),

                        // ── Register Card ───────────────────────────────
                        _buildRegisterCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF00C48C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_pharmacy_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withAlpha(18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Full Name field ───────────────────────────────────────
            _buildLabel('Họ và Tên'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _controller.fullNameController,
              hint: 'Nguyễn Văn A',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Họ tên không được để trống.';
                }
                return null;
              },
              onChanged: (_) => _controller.clearError(),
            ),
            const SizedBox(height: 16),

            // ── Email field ───────────────────────────────────────
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _controller.emailController,
              hint: 'example@pharmcare.vn',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email không được để trống.';
                }
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value.trim())) {
                  return 'Email không đúng định dạng.';
                }
                return null;
              },
              onChanged: (_) => _controller.clearError(),
            ),
            const SizedBox(height: 16),
            
            // ── Phone field ───────────────────────────────────────
            _buildLabel('Số điện thoại'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _controller.phoneController,
              hint: '0912345678',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Số điện thoại không được để trống.';
                }
                return null;
              },
              onChanged: (_) => _controller.clearError(),
            ),
            const SizedBox(height: 16),

            // ── Password field ────────────────────────────────────
            _buildLabel('Mật khẩu'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _controller.passwordController,
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _controller.obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withAlpha(100),
                  size: 20,
                ),
                onPressed: _controller.togglePasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mật khẩu không được để trống.';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự.';
                }
                return null;
              },
              onChanged: (_) => _controller.clearError(),
            ),
            const SizedBox(height: 16),
            
            // ── Confirm Password field ────────────────────────────────────
            _buildLabel('Xác nhận mật khẩu'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _controller.confirmPasswordController,
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _controller.obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _controller.obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withAlpha(100),
                  size: 20,
                ),
                onPressed: _controller.toggleConfirmPasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu.';
                }
                if (value != _controller.passwordController.text) {
                  return 'Mật khẩu xác nhận không khớp.';
                }
                return null;
              },
              onChanged: (_) => _controller.clearError(),
            ),
            const SizedBox(height: 24),

            // ── Error message ─────────────────────────────────────
            if (_controller.errorMessage != null) ...[
              _buildErrorBanner(_controller.errorMessage!),
              const SizedBox(height: 16),
            ],

            // ── Register button ──────────────────────────────────────
            _buildRegisterButton(),
            const SizedBox(height: 24),
            
            // ── Back to Login ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã có tài khoản?',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Đăng nhập ngay',
                    style: TextStyle(
                      color: Color(0xFF00C48C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withAlpha(180),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withAlpha(60), fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withAlpha(100), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFFF7070),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF5252).withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF7070), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF9090), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _controller.isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _controller.isLoading
                ? LinearGradient(
                    colors: [
                      const Color(0xFF1E88E5).withAlpha(120),
                      const Color(0xFF00C48C).withAlpha(120),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF00C48C)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _controller.isLoading
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _controller.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Decorative glow blob widget ────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
