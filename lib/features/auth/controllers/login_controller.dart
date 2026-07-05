import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/auth/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<String?> login() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
