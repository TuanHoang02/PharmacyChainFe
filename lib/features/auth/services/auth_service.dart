import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/shared/models/auth_response_model.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';

class AuthService {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
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

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      }),
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
          : 'Đăng ký thất bại.';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}');
    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
    } catch (_) {
      // Ignore errors for logout since local storage will be cleared anyway
    }
  }
}
