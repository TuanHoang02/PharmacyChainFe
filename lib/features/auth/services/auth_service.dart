import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/shared/models/auth_response_model.dart';

class AuthService {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && responseBody['success'] == true) {
      final data = responseBody['data'] as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } else {
      final message = responseBody['message'] ?? 'Đăng nhập thất bại.';
      throw Exception(message);
    }
  }
}
