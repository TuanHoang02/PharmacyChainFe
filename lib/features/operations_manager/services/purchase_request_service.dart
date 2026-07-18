import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/shared/models/review_purchase_request_model.dart';
import 'package:pharmacy_chain_fe/shared/models/lookup_model.dart';

import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class PurchaseRequestService {
  final ApiClient _apiClient = ApiClient();

  Future<PagedResponse<List<PurchaseRequestModel>>> getPurchaseRequests({
    int page = 1,
    int size = 10,
    String? status,
    int? branchId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (branchId != null) queryParams['branchId'] = branchId.toString();

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.purchaseRequests}').replace(queryParameters: queryParams);
      final response = await _apiClient.get(uri);
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final baseResponse = BaseApiResponse<PagedResponse<List<PurchaseRequestModel>>>.fromJson(
          decoded,
          (json) {
            return PagedResponse<List<PurchaseRequestModel>>.fromJson(
              json as Map<String, dynamic>,
              (dataJson) {
                final List<dynamic> list = dataJson as List<dynamic>;
                return list.map((e) => PurchaseRequestModel.fromJson(e as Map<String, dynamic>)).toList();
              },
            );
          },
        );
        
        if (baseResponse.success && baseResponse.data != null) {
          return baseResponse.data!;
        } else {
          throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Failed to load purchase requests');
        }
      } else {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Failed to load purchase requests');
      }
    } catch (e) {
      throw Exception('Failed to load purchase requests: $e');
    }
  }

  Future<PurchaseRequestModel> getPurchaseRequestById(int id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.purchaseRequests}/$id');
      final response = await _apiClient.get(uri);
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return PurchaseRequestModel.fromJson(decoded['data']);
      }
      throw Exception('Failed to load purchase request details');
    } catch (e) {
      throw Exception('Failed to load purchase request details: $e');
    }
  }

  Future<void> reviewPurchaseRequest(int id, ReviewPurchaseRequestModel reviewData) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.purchaseRequests}/$id/review');
      final response = await _apiClient.put(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(reviewData.toJson()),
      );
      
      if (response.statusCode != 200) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Failed to review purchase request');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<LookupModel>> getBranches() async {
    try {
      final response = await _apiClient.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.purchaseRequests}/branches'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return (decoded['data'] as List).map((i) => LookupModel.fromJson(i)).toList();
        } else {
          throw Exception(decoded['message'] ?? 'Failed to load branches');
        }
      } else {
        throw Exception('Failed to load branches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  Future<List<LookupModel>> getSuppliers() async {
    try {
      final response = await _apiClient.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.purchaseRequests}/suppliers'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return (decoded['data'] as List).map((i) => LookupModel.fromJson(i)).toList();
        } else {
          throw Exception(decoded['message'] ?? 'Failed to load suppliers');
        }
      } else {
        throw Exception('Failed to load suppliers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load suppliers: $e');
    }
  }
}
