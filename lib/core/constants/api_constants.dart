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

  // Tự động nối với baseUrl để tránh lỗi "No host specified" trên Desktop/Mobile
  static String get branchPerformance => '$baseUrl/api/branch-performance';
  static String get purchaseOrders => '$baseUrl/api/PurchaseOrders';
  static String get branchDashboard => '$baseUrl/api/BranchDashboard';
  static String get branchReportSales => '$baseUrl/api/BranchReport/sales';
  static String get branchReportInventory => '$baseUrl/api/BranchReport/inventory';
}
