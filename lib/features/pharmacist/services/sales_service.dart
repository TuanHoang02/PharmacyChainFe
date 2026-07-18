import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/models/create_sales_invoice_dto.dart';

class SalesService {
  final LocalStorageService _storageService = LocalStorageService();

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
