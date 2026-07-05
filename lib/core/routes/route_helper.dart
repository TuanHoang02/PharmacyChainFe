import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/features/admin/views/admin_home_screen.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/views/branch_manager_home_screen.dart';
import 'package:pharmacy_chain_fe/features/customer/views/customer_home_screen.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/views/pharmacist_home_screen.dart';
import 'package:pharmacy_chain_fe/features/auth/views/login_screen.dart';

class RouteHelper {
  static void navigateBasedOnRole(BuildContext context, String role) {
    Widget homeScreen;

    switch (role.toLowerCase()) {
      case 'admin':
        homeScreen = const AdminHomeScreen();
        break;
      case 'branchmanager':
      case 'branch manager':
        homeScreen = const BranchManagerHomeScreen();
        break;
      case 'pharmacist':
        homeScreen = const PharmacistHomeScreen();
        break;
      case 'customer':
        homeScreen = const CustomerHomeScreen();
        break;
      default:
        // Cố tình fallback về Customer hoặc Login nếu role không hợp lệ
        homeScreen = const LoginScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => homeScreen),
    );
  }
}
