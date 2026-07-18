import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/models/sales_history_model.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/models/create_sales_invoice_dto.dart';

class SalesService {
  final ApiClient _apiClient = ApiClient();
  final LocalStorageService _storageService = LocalStorageService();

  /// GET /api/sales - Get paginated sales history
  Future<PagedSalesHistoryResponse> getSalesHistory({
    String? customerPhoneNumber,
    int? invoiceStatus,
    String? sortBy,
    bool isDescending = true,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final baseUrl = ApiConstants.baseUrl;
    final Map<String, String> queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'isDescending': isDescending.toString(),
    };

    if (customerPhoneNumber != null && customerPhoneNumber.trim().isNotEmpty) {
      queryParams['customerPhoneNumber'] = customerPhoneNumber.trim();
    }
    if (invoiceStatus != null) {
      queryParams['invoiceStatus'] = invoiceStatus.toString();
    }
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParams['sortBy'] = sortBy.trim();
    }

    final uri = Uri.parse('$baseUrl${ApiConstants.sales}').replace(queryParameters: queryParams);

    final response = await _apiClient.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<PagedSalesHistoryResponse>.fromJson(
      responseBody,
      (json) => PagedSalesHistoryResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.statusCode == 200 && apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tải lịch sử bán lẻ.';
      throw Exception(message);
    }
  }

  /// GET /api/sales/{id} - Get sales invoice details by ID
  Future<SalesInvoiceDetailModel> getSalesInvoiceById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sales}/$id');

    final response = await _apiClient.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<SalesInvoiceDetailModel>.fromJson(
      responseBody,
      (json) => SalesInvoiceDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.statusCode == 200 && apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể lấy thông tin chi tiết hóa đơn.';
      throw Exception(message);
    }
  }

  Future<void> createSalesInvoice(CreateSalesInvoiceDto request) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/sales/invoice');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      String errorMessage = 'Tạo hóa đơn thất bại (${response.statusCode})';
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
