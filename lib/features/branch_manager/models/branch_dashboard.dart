class BranchDashboard {
  final String branchName;
  final DateTime generatedAt;
  final SalesSummary sales;
  final InventoryStatus inventory;
  final List<LowStockMedicine> lowStockMedicines;
  final int pendingPurchaseOrders;

  const BranchDashboard({
    required this.branchName,
    required this.generatedAt,
    required this.sales,
    required this.inventory,
    required this.lowStockMedicines,
    required this.pendingPurchaseOrders,
  });

  factory BranchDashboard.fromJson(Map<String, dynamic> json) {
    return BranchDashboard(
      branchName: json['branchName'] as String? ?? '',
      generatedAt:
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ?? DateTime.now(),
      sales: SalesSummary.fromJson(
          (json['sales'] as Map<String, dynamic>?) ?? const {}),
      inventory: InventoryStatus.fromJson(
          (json['inventory'] as Map<String, dynamic>?) ?? const {}),
      lowStockMedicines: (json['lowStockMedicines'] as List<dynamic>? ?? [])
          .map((e) => LowStockMedicine.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingPurchaseOrders: json['pendingPurchaseOrders'] as int? ?? 0,
    );
  }

  bool get isEmpty =>
      sales.todayInvoices == 0 &&
      inventory.totalSkus == 0 &&
      lowStockMedicines.isEmpty &&
      pendingPurchaseOrders == 0;
}

class SalesSummary {
  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int todayInvoices;
  final int pendingInvoices;

  const SalesSummary({
    required this.todayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.todayInvoices,
    required this.pendingInvoices,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      weekRevenue: (json['weekRevenue'] as num?)?.toDouble() ?? 0.0,
      monthRevenue: (json['monthRevenue'] as num?)?.toDouble() ?? 0.0,
      todayInvoices: json['todayInvoices'] as int? ?? 0,
      pendingInvoices: json['pendingInvoices'] as int? ?? 0,
    );
  }
}

class InventoryStatus {
  final int totalSkus;
  final int totalBatches;
  final int nearExpiryBatches;
  final int expiredBatches;
  final double totalStockValue;

  const InventoryStatus({
    required this.totalSkus,
    required this.totalBatches,
    required this.nearExpiryBatches,
    required this.expiredBatches,
    required this.totalStockValue,
  });

  factory InventoryStatus.fromJson(Map<String, dynamic> json) {
    return InventoryStatus(
      totalSkus: json['totalSkus'] as int? ?? 0,
      totalBatches: json['totalBatches'] as int? ?? 0,
      nearExpiryBatches: json['nearExpiryBatches'] as int? ?? 0,
      expiredBatches: json['expiredBatches'] as int? ?? 0,
      totalStockValue: (json['totalStockValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LowStockMedicine {
  final int medicineId;
  final String medicineName;
  final String? unit;
  final int currentStock;
  final int reorderLevel;

  const LowStockMedicine({
    required this.medicineId,
    required this.medicineName,
    required this.unit,
    required this.currentStock,
    required this.reorderLevel,
  });

  factory LowStockMedicine.fromJson(Map<String, dynamic> json) {
    return LowStockMedicine(
      medicineId: json['medicineId'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      unit: json['unit'] as String?,
      currentStock: json['currentStock'] as int? ?? 0,
      reorderLevel: json['reorderLevel'] as int? ?? 0,
    );
  }
}
