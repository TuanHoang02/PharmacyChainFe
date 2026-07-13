import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/auth/services/auth_service.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  Future<String?> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = 'Mật khẩu xác nhận không khớp.';
      notifyListeners();
      return null;
    }

    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
      );

      // Save token and role to local storage
      await _storageService.saveLoginInfo(result.token, result.role);

      isLoading = false;
      notifyListeners();
      return result.role;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
