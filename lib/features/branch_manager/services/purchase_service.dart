import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_dto.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_model.dart';

class PurchaseService {
  final LocalStorageService _storageService = LocalStorageService();

  Future<void> createPurchaseRequest(CreatePurchaseRequestDto request) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/purchase/request');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      return;
    } else {
      String errorMessage = 'Tạo yêu cầu nhập hàng thất bại (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          errorMessage = body['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<List<PurchaseRequestModel>> getPurchaseRequests() async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/purchase/requests');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => PurchaseRequestModel.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tải danh sách phiếu nhập hàng');
    }
  }

  Future<void> receiveMedicines(int purchaseRequestId) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/purchase/$purchaseRequestId/receive');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      String errorMessage = 'Nhận hàng thất bại (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          errorMessage = body['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
