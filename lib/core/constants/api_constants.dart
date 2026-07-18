import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5003';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5003'; // Dùng cho máy ảo Android Emulator
      }
    } catch (_) {
      // Bắt ngoại lệ trên nền tảng không hỗ trợ dart:io như Web
    }
    return 'http://localhost:5003'; // Dùng cho Windows desktop / iOS
  }

  static const String login = '/api/Auth/login';
  static const String logout = '/api/Auth/logout';
  static const String changePassword = '/api/Auth/change-password';
  static const String branchPerformance = '/api/branch-performance';

  static const String purchaseOrders = '/api/PurchaseOrders';
  static const String branchDashboard = '/api/BranchDashboard';
  static const String branchReportSales = '/api/BranchReport/sales';
  static const String branchReportInventory = '/api/BranchReport/inventory';
}
