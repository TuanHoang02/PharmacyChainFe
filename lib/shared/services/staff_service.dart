import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class StaffModel {
  final int userID;
  final String username;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final int roleID;
  final String roleName;
  final int? branchID;
  final String? branchName;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  StaffModel({
    required this.userID,
    required this.username,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.roleID,
    required this.roleName,
    this.branchID,
    this.branchName,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      userID: json['userID'] as int,
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      roleID: json['roleID'] as int? ?? 0,
      roleName: json['roleName'] as String? ?? '',
      branchID: json['branchID'] as int?,
      branchName: json['branchName'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class StaffService {
  final ApiClient _apiClient = ApiClient();

  Future<PagedResponse<List<StaffModel>>> getStaffs({
    String? searchTerm,
    int? branchId,
    int? roleId,
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
    if (branchId != null) {
      queryParams['branchId'] = branchId.toString();
    }
    if (roleId != null) {
      queryParams['roleId'] = roleId.toString();
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Staff').replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<PagedResponse<List<StaffModel>>>.fromJson(
        responseBody,
        (dataJson) {
          return PagedResponse<List<StaffModel>>.fromJson(
            dataJson as Map<String, dynamic>,
            (listJson) {
              final list = listJson as List<dynamic>;
              return list.map((item) => StaffModel.fromJson(item as Map<String, dynamic>)).toList();
            },
          );
        },
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lấy danh sách nhân sự thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }

  Future<StaffModel> getStaffById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Staff/$id');
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<StaffModel>.fromJson(
        responseBody,
        (dataJson) => StaffModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lấy chi tiết nhân viên thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }

  Future<StaffModel> createStaff({
    required String username,
    required String password,
    required String fullName,
    String? email,
    String? phoneNumber,
    required int roleID,
    int? branchID,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Staff');
    final response = await _apiClient.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'roleID': roleID,
        'branchID': branchID,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<StaffModel>.fromJson(
        responseBody,
        (dataJson) => StaffModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Tạo nhân viên thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<StaffModel> updateStaff(
    int id, {
    required String fullName,
    String? email,
    String? phoneNumber,
    required int roleID,
    int? branchID,
    required bool isActive,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Staff/$id');
    final response = await _apiClient.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'roleID': roleID,
        'branchID': branchID,
        'isActive': isActive,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<StaffModel>.fromJson(
        responseBody,
        (dataJson) => StaffModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Cập nhật nhân viên thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<void> deleteStaff(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Staff/$id');
    final response = await _apiClient.delete(uri);

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Xóa nhân viên thất bại.';
      throw Exception(msg);
    }
  }
}
