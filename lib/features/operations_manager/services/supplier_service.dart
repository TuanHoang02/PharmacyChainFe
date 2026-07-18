import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class SupplierModel {
  final int supplierID;
  final String supplierName;
  final String? contactName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;
  final String? username;

  SupplierModel({
    required this.supplierID,
    required this.supplierName,
    this.contactName,
    this.phoneNumber,
    this.email,
    this.address,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.username,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierID: json['supplierID'] as int,
      supplierName: json['supplierName'] as String? ?? '',
      contactName: json['contactName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      username: json['username'] as String?,
    );
  }
}

class SupplierService {
  final ApiClient _apiClient = ApiClient();

  Future<PagedResponse<List<SupplierModel>>> getSuppliers({
    String? searchTerm,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['searchTerm'] = searchTerm;
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Supplier').replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<PagedResponse<List<SupplierModel>>>.fromJson(
        responseBody,
        (dataJson) {
          return PagedResponse<List<SupplierModel>>.fromJson(
            dataJson as Map<String, dynamic>,
            (listJson) {
              final list = listJson as List<dynamic>;
              return list.map((item) => SupplierModel.fromJson(item as Map<String, dynamic>)).toList();
            },
          );
        },
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lấy danh sách nhà cung cấp thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }

  Future<SupplierModel> createSupplier({
    required String supplierName,
    String? contactName,
    String? phoneNumber,
    String? email,
    String? address,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Supplier');
    final response = await _apiClient.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'supplierName': supplierName,
        'contactName': contactName,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<SupplierModel>.fromJson(
        responseBody,
        (dataJson) => SupplierModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Tạo nhà cung cấp thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<SupplierModel> createSupplierWithAccount({
    required String supplierName,
    String? contactName,
    String? phoneNumber,
    String? email,
    String? address,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Supplier/register');
    final response = await _apiClient.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'supplierName': supplierName,
        'contactName': contactName,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<SupplierModel>.fromJson(
        responseBody,
        (dataJson) => SupplierModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Tạo nhà cung cấp và tài khoản thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<SupplierModel> updateSupplier(
    int id, {
    required String supplierName,
    String? contactName,
    String? phoneNumber,
    String? email,
    String? address,
    required bool isActive,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Supplier/$id');
    final response = await _apiClient.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'supplierName': supplierName,
        'contactName': contactName,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'isActive': isActive,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<SupplierModel>.fromJson(
        responseBody,
        (dataJson) => SupplierModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Cập nhật nhà cung cấp thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<void> deleteSupplier(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Supplier/$id');
    final response = await _apiClient.delete(uri);

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Xóa nhà cung cấp thất bại.';
      throw Exception(msg);
    }
  }
}
