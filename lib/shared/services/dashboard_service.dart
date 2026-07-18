import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';

class DailyRevenueModel {
  final String date;
  final double revenue;
  final double expense;

  DailyRevenueModel({
    required this.date,
    required this.revenue,
    required this.expense,
  });

  factory DailyRevenueModel.fromJson(Map<String, dynamic> json) {
    return DailyRevenueModel(
      date: json['date'] as String? ?? '',
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      expense: (json['expense'] as num? ?? 0.0).toDouble(),
    );
  }
}

class LowStockModel {
  final int medicineID;
  final String medicineName;
  final int quantityInStock;
  final int reorderLevel;
  final String? branchName;

  LowStockModel({
    required this.medicineID,
    required this.medicineName,
    required this.quantityInStock,
    required this.reorderLevel,
    this.branchName,
  });

  factory LowStockModel.fromJson(Map<String, dynamic> json) {
    return LowStockModel(
      medicineID: json['medicineID'] as int,
      medicineName: json['medicineName'] as String? ?? '',
      quantityInStock: json['quantityInStock'] as int? ?? 0,
      reorderLevel: json['reorderLevel'] as int? ?? 0,
      branchName: json['branchName'] as String?,
    );
  }
}

class ExpiringBatchModel {
  final int medicineBatchID;
  final String batchNumber;
  final String medicineName;
  final String? branchName;
  final String expiryDate;
  final int remainingQuantity;
  final int daysUntilExpiry;

  ExpiringBatchModel({
    required this.medicineBatchID,
    required this.batchNumber,
    required this.medicineName,
    this.branchName,
    required this.expiryDate,
    required this.remainingQuantity,
    required this.daysUntilExpiry,
  });

  factory ExpiringBatchModel.fromJson(Map<String, dynamic> json) {
    return ExpiringBatchModel(
      medicineBatchID: json['medicineBatchID'] as int,
      batchNumber: json['batchNumber'] as String? ?? '',
      medicineName: json['medicineName'] as String? ?? '',
      branchName: json['branchName'] as String?,
      expiryDate: json['expiryDate'] as String? ?? '',
      remainingQuantity: json['remainingQuantity'] as int? ?? 0,
      daysUntilExpiry: json['daysUntilExpiry'] as int? ?? 0,
    );
  }
}

class TopSellingModel {
  final int medicineID;
  final String medicineName;
  final String? categoryName;
  final int totalQuantitySold;
  final double totalRevenueGenerated;

  TopSellingModel({
    required this.medicineID,
    required this.medicineName,
    this.categoryName,
    required this.totalQuantitySold,
    required this.totalRevenueGenerated,
  });

  factory TopSellingModel.fromJson(Map<String, dynamic> json) {
    return TopSellingModel(
      medicineID: json['medicineID'] as int,
      medicineName: json['medicineName'] as String? ?? '',
      categoryName: json['categoryName'] as String?,
      totalQuantitySold: json['totalQuantitySold'] as int? ?? 0,
      totalRevenueGenerated: (json['totalRevenueGenerated'] as num? ?? 0.0).toDouble(),
    );
  }
}

class BranchPerformanceModel {
  final int branchID;
  final String branchName;
  final double revenue;
  final int salesCount;

  BranchPerformanceModel({
    required this.branchID,
    required this.branchName,
    required this.revenue,
    required this.salesCount,
  });

  factory BranchPerformanceModel.fromJson(Map<String, dynamic> json) {
    return BranchPerformanceModel(
      branchID: json['branchID'] as int,
      branchName: json['branchName'] as String? ?? '',
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      salesCount: json['salesCount'] as int? ?? 0,
    );
  }
}

class DashboardSummaryModel {
  final double totalRevenue;
  final int totalSalesCount;
  final double totalPurchaseExpense;
  final double estimatedProfit;
  final List<DailyRevenueModel> dailyRevenue;
  final List<LowStockModel> lowStockMedicines;
  final List<ExpiringBatchModel> expiringBatches;
  final List<TopSellingModel> topSellingMedicines;
  final List<BranchPerformanceModel>? branchPerformance;

  DashboardSummaryModel({
    required this.totalRevenue,
    required this.totalSalesCount,
    required this.totalPurchaseExpense,
    required this.estimatedProfit,
    required this.dailyRevenue,
    required this.lowStockMedicines,
    required this.expiringBatches,
    required this.topSellingMedicines,
    this.branchPerformance,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalRevenue: (json['totalRevenue'] as num? ?? 0.0).toDouble(),
      totalSalesCount: json['totalSalesCount'] as int? ?? 0,
      totalPurchaseExpense: (json['totalPurchaseExpense'] as num? ?? 0.0).toDouble(),
      estimatedProfit: (json['estimatedProfit'] as num? ?? 0.0).toDouble(),
      dailyRevenue: (json['dailyRevenue'] as List<dynamic>?)
              ?.map((item) => DailyRevenueModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      lowStockMedicines: (json['lowStockMedicines'] as List<dynamic>?)
              ?.map((item) => LowStockModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      expiringBatches: (json['expiringBatches'] as List<dynamic>?)
              ?.map((item) => ExpiringBatchModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      topSellingMedicines: (json['topSellingMedicines'] as List<dynamic>?)
              ?.map((item) => TopSellingModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      branchPerformance: (json['branchPerformance'] as List<dynamic>?)
          ?.map((item) => BranchPerformanceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardSummaryModel> getDashboardSummary({
    int? branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (branchId != null) {
      queryParams['branchId'] = branchId.toString();
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Dashboard/summary').replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<DashboardSummaryModel>.fromJson(
        responseBody,
        (dataJson) => DashboardSummaryModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Tải thông tin Dashboard thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }
}
