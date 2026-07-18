import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/medicine_batch_summary.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/medicine_batch_detail.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class MedicineBatchService {
  final http.Client _client;

  MedicineBatchService({http.Client? client}) : _client = client ?? ApiClient();

  Future<PagedResponse<List<MedicineBatchSummary>>> getMedicineBatches({
    int pageNumber = 1,
    int pageSize = 10,
    String? batchNumber,
    int? medicineId,
    int? purchaseOrderId,
    String? sortBy,
    bool isDescending = true,
  }) async {
    final queryParameters = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'isDescending': isDescending.toString(),
    };
    if (batchNumber != null && batchNumber.trim().isNotEmpty) {
      queryParameters['batchNumber'] = batchNumber.trim();
    }
    if (medicineId != null) {
      queryParameters['medicineId'] = medicineId.toString();
    }
    if (purchaseOrderId != null) {
      queryParameters['purchaseOrderId'] = purchaseOrderId.toString();
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sortBy'] = sortBy;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.medicineBatches}',
    ).replace(queryParameters: queryParameters);

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);
      if (apiResponse.success && apiResponse.data != null) {
        final paged = PagedResponse<List<MedicineBatchSummary>>.fromJson(
          apiResponse.data as Map<String, dynamic>,
          (json) => (json as List<dynamic>)
              .map((e) => MedicineBatchSummary.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        return paged;
      }
    }

    String errorMessage = 'Không thể tải danh sách lô thuốc (Mã lỗi: ${response.statusCode}).';
    try {
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);
        if (apiResponse.message.isNotEmpty) {
          errorMessage = '${apiResponse.message} (Mã lỗi: ${response.statusCode})';
        }
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }

  Future<MedicineBatchDetail> getMedicineBatchById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.medicineBatches}/$id',
    );

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);
      if (apiResponse.success && apiResponse.data != null) {
        return MedicineBatchDetail.fromJson(apiResponse.data as Map<String, dynamic>);
      }
    }

    String errorMessage = 'Không thể tải chi tiết lô thuốc (Mã lỗi: ${response.statusCode}).';
    try {
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);
        if (apiResponse.message.isNotEmpty) {
          errorMessage = '${apiResponse.message} (Mã lỗi: ${response.statusCode})';
        }
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }

  Future<MedicineBatchDetail> createMedicineBatch({
    required int purchaseOrderDetailId,
    required String batchNumber,
    required DateTime manufacturingDate,
    required DateTime expiryDate,
    required int receivedQuantity,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.medicineBatches}',
    );

    final response = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'purchaseOrderDetailID': purchaseOrderDetailId,
        'batchNumber': batchNumber,
        'manufacturingDate': manufacturingDate.toUtc().toIso8601String(),
        'expiryDate': expiryDate.toUtc().toIso8601String(),
        'receivedQuantity': receivedQuantity,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);
      if (apiResponse.success && apiResponse.data != null) {
        return MedicineBatchDetail.fromJson(apiResponse.data as Map<String, dynamic>);
      }
    }

    String errorMessage = 'Tạo lô thuốc thất bại (Mã lỗi: ${response.statusCode}).';
    try {
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);
        if (apiResponse.message.isNotEmpty) {
          errorMessage = '${apiResponse.message} (Mã lỗi: ${response.statusCode})';
        }
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }
}
