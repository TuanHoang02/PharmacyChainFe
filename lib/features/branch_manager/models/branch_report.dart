class BranchReport {
  final String branchName;
  final DateTime generatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final String reportType;
  final ReportSummary summary;
  final List<SalesReportDetail> salesDetails;
  final List<InventoryReportDetail> inventoryDetails;

  const BranchReport({
    required this.branchName,
    required this.generatedAt,
    required this.startDate,
    required this.endDate,
    required this.reportType,
    required this.summary,
    required this.salesDetails,
    required this.inventoryDetails,
  });

  factory BranchReport.fromJson(Map<String, dynamic> json) {
    return BranchReport(
      branchName: json['branchName'] as String? ?? '',
      generatedAt:
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ?? DateTime.now(),
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      reportType: json['reportType'] as String? ?? '',
      summary: ReportSummary.fromJson(
          (json['summary'] as Map<String, dynamic>?) ?? const {}),
      salesDetails: (json['salesDetails'] as List<dynamic>? ?? [])
          .map((e) => SalesReportDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      inventoryDetails: (json['inventoryDetails'] as List<dynamic>? ?? [])
          .map((e) => InventoryReportDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isEmpty =>
      reportType == 'Sales'
          ? salesDetails.isEmpty
          : inventoryDetails.isEmpty;
}

class ReportSummary {
  final int totalOrders;
  final double totalRevenue;
  final int totalItemsSold;
  final double averageOrderValue;
  final double totalStockValue;
  final int totalSkus;
  final int lowStockCount;
  final int nearExpiryCount;
  final int expiredCount;

  const ReportSummary({
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.totalItemsSold = 0,
    this.averageOrderValue = 0.0,
    this.totalStockValue = 0.0,
    this.totalSkus = 0,
    this.lowStockCount = 0,
    this.nearExpiryCount = 0,
    this.expiredCount = 0,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalItemsSold: json['totalItemsSold'] as int? ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      totalStockValue: (json['totalStockValue'] as num?)?.toDouble() ?? 0.0,
      totalSkus: json['totalSkus'] as int? ?? 0,
      lowStockCount: json['lowStockCount'] as int? ?? 0,
      nearExpiryCount: json['nearExpiryCount'] as int? ?? 0,
      expiredCount: json['expiredCount'] as int? ?? 0,
    );
  }
}

class SalesReportDetail {
  final String invoiceCode;
  final DateTime invoiceDate;
  final String? customerName;
  final String paymentMethod;
  final String paymentStatus;
  final int totalItems;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;

  const SalesReportDetail({
    required this.invoiceCode,
    required this.invoiceDate,
    this.customerName,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalItems,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
  });

  factory SalesReportDetail.fromJson(Map<String, dynamic> json) {
    return SalesReportDetail(
      invoiceCode: json['invoiceCode'] as String? ?? '',
      invoiceDate:
          DateTime.tryParse(json['invoiceDate'] as String? ?? '') ?? DateTime.now(),
      customerName: json['customerName'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      totalItems: json['totalItems'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InventoryReportDetail {
  final int medicineId;
  final String medicineName;
  final String? unit;
  final int quantityInStock;
  final int reorderLevel;
  final double sellingPrice;
  final double stockValue;
  final int totalBatches;
  final DateTime? nearestExpiryDate;
  final String stockStatus;

  const InventoryReportDetail({
    required this.medicineId,
    required this.medicineName,
    this.unit,
    required this.quantityInStock,
    required this.reorderLevel,
    required this.sellingPrice,
    required this.stockValue,
    required this.totalBatches,
    this.nearestExpiryDate,
    required this.stockStatus,
  });

  factory InventoryReportDetail.fromJson(Map<String, dynamic> json) {
    return InventoryReportDetail(
      medicineId: json['medicineId'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      unit: json['unit'] as String?,
      quantityInStock: json['quantityInStock'] as int? ?? 0,
      reorderLevel: json['reorderLevel'] as int? ?? 0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      stockValue: (json['stockValue'] as num?)?.toDouble() ?? 0.0,
      totalBatches: json['totalBatches'] as int? ?? 0,
      nearestExpiryDate: json['nearestExpiryDate'] != null
          ? DateTime.tryParse(json['nearestExpiryDate'] as String)
          : null,
      stockStatus: json['stockStatus'] as String? ?? '',
    );
  }
}
