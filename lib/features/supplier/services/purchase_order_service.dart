import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_detail.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_summary.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/supplier_response.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class PurchaseOrderFilter {
  final String? search;
  final int? branchId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? status;

  const PurchaseOrderFilter({
    this.search,
    this.branchId,
    this.startDate,
    this.endDate,
    this.status,
  });

  bool get isEmpty =>
      (search == null || search!.isEmpty) &&
      branchId == null &&
      startDate == null &&
      endDate == null &&
      status == null;

  PurchaseOrderFilter copyWith({
    String? search,
    int? branchId,
    bool clearBranchId = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    int? status,
    bool clearStatus = false,
  }) {
    return PurchaseOrderFilter(
      search: search ?? this.search,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class PurchaseOrderService {
  final http.Client _client;

  PurchaseOrderService({http.Client? client}) : _client = client ?? ApiClient();

  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  Future<PagedResponse<List<PurchaseOrderSummary>>> getOrders({
    int pageNumber = 1,
    int pageSize = 10,
    PurchaseOrderFilter filter = const PurchaseOrderFilter(),
  }) async {
    final queryParameters = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };
    if (filter.search != null && filter.search!.isNotEmpty) {
      queryParameters['search'] = filter.search!;
    }
    if (filter.branchId != null) {
      queryParameters['branchId'] = filter.branchId.toString();
    }
    if (filter.startDate != null) {
      queryParameters['startDate'] = _apiDateFormat.format(filter.startDate!);
    }
    if (filter.endDate != null) {
      queryParameters['endDate'] = _apiDateFormat.format(filter.endDate!);
    }
    if (filter.status != null) {
      queryParameters['status'] = filter.status.toString();
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.purchaseOrders}',
    ).replace(queryParameters: queryParameters);

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);

    if (response.statusCode == 200 && apiResponse.success) {
      final paged = PagedResponse<List<PurchaseOrderSummary>>.fromJson(
        apiResponse.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => PurchaseOrderSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return paged;
    }

    final message = apiResponse.message.isNotEmpty
        ? apiResponse.message
        : 'Không thể tải danh sách đơn mua.';
    throw Exception(message);
  }

  Future<PurchaseOrderDetail> getOrderDetail(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.purchaseOrders}/$id',
    );

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<dynamic>.fromJson(body, (json) => json);

    if (response.statusCode == 200 &&
        apiResponse.success &&
        apiResponse.data != null) {
      return PurchaseOrderDetail.fromJson(apiResponse.data as Map<String, dynamic>);
    }

    final message = apiResponse.message.isNotEmpty
        ? apiResponse.message
        : 'Không thể tải chi tiết đơn mua.';
    throw Exception(message);
  }

  Future<SupplierResponse> acceptOrder(int id) {
    return _postSupplierResponse('${ApiConstants.purchaseOrders}/$id/accept', const {});
  }

  Future<SupplierResponse> rejectOrder(int id, String rejectionReason) {
    return _postSupplierResponse(
      '${ApiConstants.purchaseOrders}/$id/reject',
      {'rejectionReason': rejectionReason},
    );
  }

  // ponytail: helper extracted to dedupe the POST + parse + throw pattern across
  // accept/reject; safe to keep private until a third POST call needs it.
  Future<SupplierResponse> _postSupplierResponse(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<dynamic>.fromJson(decoded, (json) => json);

    if (response.statusCode == 200 &&
        apiResponse.success &&
        apiResponse.data != null) {
      return SupplierResponse.fromJson(apiResponse.data as Map<String, dynamic>);
    }

    final message = apiResponse.message.isNotEmpty
        ? apiResponse.message
        : 'Yêu cầu thất bại.';
    throw Exception(message);
  }

  Future<PurchaseOrderDetail> getPurchaseOrderById(int id) {
    return getOrderDetail(id);
  }

  Future<PurchaseOrderDetail> updateDeliveryStatus(
    int id,
    String deliveryStatus,
    String? supplierResponseNote,
  ) async {
    int statusValue = 0;
    switch (deliveryStatus) {
      case 'NotStarted':
        statusValue = 0;
        break;
      case 'Preparing':
        statusValue = 1;
        break;
      case 'Shipping':
        statusValue = 2;
        break;
      case 'Delivered':
        statusValue = 3;
        break;
      case 'Received':
        statusValue = 4;
        break;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.purchaseOrders}/$id/delivery-status',
    );
    final response = await _client.patch(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'deliveryStatus': statusValue,
        'supplierResponseNote': supplierResponseNote,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = BaseApiResponse<dynamic>.fromJson(decoded, (json) => json);
      if (apiResponse.success && apiResponse.data != null) {
        return PurchaseOrderDetail.fromJson(apiResponse.data as Map<String, dynamic>);
      }
    }

    String errorMessage = 'Cập nhật trạng thái giao hàng thất bại (Mã lỗi: ${response.statusCode}).';
    try {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = BaseApiResponse<dynamic>.fromJson(decoded, (json) => json);
        if (apiResponse.message.isNotEmpty) {
          errorMessage = '${apiResponse.message} (Mã lỗi: ${response.statusCode})';
        }
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }
}
