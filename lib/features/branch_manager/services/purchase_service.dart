import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_dto.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

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

  Future<PagedResponse<List<PurchaseRequestModel>>> getPurchaseRequests({int pageNumber = 1, int pageSize = 10}) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/purchase/requests?pageNumber=$pageNumber&pageSize=$pageSize');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return PagedResponse<List<PurchaseRequestModel>>.fromJson(
        body['data'] as Map<String, dynamic>,
        (listJson) {
          final list = listJson as List<dynamic>;
          return list.map((item) => PurchaseRequestModel.fromJson(item as Map<String, dynamic>)).toList();
        },
      );
    } else {
      throw Exception('Không thể tải danh sách phiếu nhập hàng');
    }
  }

  Future<void> receivePurchaseOrder(int purchaseOrderId, Map<String, dynamic> data) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/purchase/order/$purchaseOrderId/receive');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
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
