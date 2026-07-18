import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_dashboard.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';

class BranchDashboardService {
  final http.Client _client;

  BranchDashboardService({http.Client? client}) : _client = client ?? ApiClient();

  Future<BranchDashboard> fetchDashboard() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.branchDashboard}');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);

    if (response.statusCode == 200 &&
        apiResponse.success &&
        apiResponse.data != null) {
      return BranchDashboard.fromJson(apiResponse.data as Map<String, dynamic>);
    }

    final message = apiResponse.message.isNotEmpty
        ? apiResponse.message
        : 'Không thể tải dữ liệu dashboard.';
    throw Exception(message);
  }
}
