import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class BranchModel {
  final int branchID;
  final String branchName;
  final String address;
  final String? phoneNumber;
  final String? email;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  BranchModel({
    required this.branchID,
    required this.branchName,
    required this.address,
    this.phoneNumber,
    this.email,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      branchID: json['branchID'] as int,
      branchName: json['branchName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchID': branchID,
      'branchName': branchName,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class BranchService {
  final ApiClient _apiClient = ApiClient();

  Future<PagedResponse<List<BranchModel>>> getBranches({
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

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Branch').replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<PagedResponse<List<BranchModel>>>.fromJson(
        responseBody,
        (dataJson) {
          return PagedResponse<List<BranchModel>>.fromJson(
            dataJson as Map<String, dynamic>,
            (listJson) {
              final list = listJson as List<dynamic>;
              return list.map((item) => BranchModel.fromJson(item as Map<String, dynamic>)).toList();
            },
          );
        },
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lấy danh sách chi nhánh thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }

  Future<BranchModel> getBranchById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Branch/$id');
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<BranchModel>.fromJson(
        responseBody,
        (dataJson) => BranchModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lấy chi tiết chi nhánh thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }

  Future<BranchModel> createBranch({
    required String branchName,
    required String address,
    String? phoneNumber,
    String? email,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Branch');
    final response = await _apiClient.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'branchName': branchName,
        'address': address,
        'phoneNumber': phoneNumber,
        'email': email,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<BranchModel>.fromJson(
        responseBody,
        (dataJson) => BranchModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Tạo chi nhánh thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<BranchModel> updateBranch(
    int id, {
    required String branchName,
    required String address,
    String? phoneNumber,
    String? email,
    required bool isActive,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Branch/$id');
    final response = await _apiClient.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'branchName': branchName,
        'address': address,
        'phoneNumber': phoneNumber,
        'email': email,
        'isActive': isActive,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<BranchModel>.fromJson(
        responseBody,
        (dataJson) => BranchModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Cập nhật chi nhánh thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<void> deleteBranch(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Branch/$id');
    final response = await _apiClient.delete(uri);

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Xóa chi nhánh thất bại.';
      throw Exception(msg);
    }
  }
}
