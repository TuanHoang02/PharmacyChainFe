import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Fake a small delay so the user sees the beautiful splash screen :)
    await Future.delayed(const Duration(seconds: 2));

    final token = await _storageService.getToken();
    final role = await _storageService.getRole();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Tùy theo role để chuyển trang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chào mừng trở lại! Vai trò: $role'),
          backgroundColor: const Color(0xFF00C48C),
        ),
      );
      
      final normalizedRole = role?.toLowerCase() ?? '';
      if (normalizedRole == 'admin') {
        context.go('/admin');
      } else if (normalizedRole == 'branchmanager' || normalizedRole == 'branch manager') {
        context.go('/manager');
      } else if (normalizedRole == 'pharmacist') {
        context.go('/pharmacist');
      } else if (normalizedRole == 'customer') {
        context.go('/customer');
      } else {
        context.go('/login');
      }
    } else {
      // Chưa có token -> Về màn hình Đăng nhập
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF00C48C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withAlpha(100),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PharmaCare',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF00C48C),
            ),
          ],
        ),
      ),
    );
  }
}
