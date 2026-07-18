class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5003';
  // Use 'http://localhost:5003' for web/desktop
  // Use 'http://10.0.2.2:5003' for Android emulator

  static const String login = '/api/Auth/login';
  static const String logout = '/api/Auth/logout';
  static const String changePassword = '/api/Auth/change-password';
  static const String medicines = '/api/Medicines';
  static const String categories = '/api/Categories';
  static const String sales = '/api/Sales';
  static const String branchPerformance = '/api/branch-performance';
  static const String purchaseOrders = '/api/PurchaseOrders';
  static const String branchDashboard = '/api/BranchDashboard';
  static const String branchReportSales = '/api/BranchReport/sales';
  static const String branchReportInventory = '/api/BranchReport/inventory';

}
