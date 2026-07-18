import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/models/branch_performance_model.dart';

class BranchPerformanceService {
  final ApiClient _apiClient = ApiClient();

  Future<BranchPerformanceDto> getPerformanceData({int? branchId, String period = 'This Month', DateTime? startDate, DateTime? endDate}) async {
    String query = '?period=$period';
    if (branchId != null) {
      query += '&branchId=$branchId';
    }
    if (startDate != null) {
      query += '&startDate=${startDate.toIso8601String()}';
    }
    if (endDate != null) {
      query += '&endDate=${endDate.toIso8601String()}';
    }

    final response = await _apiClient.get(Uri.parse('${ApiConstants.branchPerformance}$query'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return BranchPerformanceDto.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to parse performance data');
      }
    } else {
      throw Exception('Failed to load performance data');
    }
  }
}
