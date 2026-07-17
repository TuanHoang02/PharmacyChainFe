import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/shared/models/auth_response_model.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';

class AuthService {
  final LocalStorageService _storageService = LocalStorageService();
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<AuthResponseModel>.fromJson(
      responseBody,
      (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.statusCode == 200 && apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Đăng nhập thất bại.';
      throw Exception(message);
    }
  }


  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.changePassword}');

    final response = await _apiClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<dynamic>.fromJson(
      responseBody,
      (json) => json,
    );

    if (response.statusCode == 200 && apiResponse.success) {
      return;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Đổi mật khẩu thất bại.';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}');
    try {
      await _apiClient.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
    } catch (_) {
      // Ignore errors for logout since local storage will be cleared anyway
    }
  }
}
