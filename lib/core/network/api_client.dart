import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final LocalStorageService _storageService = LocalStorageService();
  bool _isRefreshing = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _storageService.getToken();
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    var response = await _inner.send(request);

    if (response.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Retry original request
          final newRequest = _copyRequest(request);
          newRequest.headers['Authorization'] = 'Bearer $newToken';
          response = await _inner.send(newRequest);
        } else {
          await _storageService.clearAll();
          // Ideally, trigger navigation to login screen here via a stream or global key
        }
      } finally {
        _isRefreshing = false;
      }
    }

    return response;
  }

  Future<String?> _refreshToken() async {
    final currentToken = await _storageService.getToken();
    final currentRefreshToken = await _storageService.getRefreshToken();

    if (currentToken == null || currentRefreshToken == null) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/Auth/refresh-token');
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'token': currentToken,
          'refreshToken': currentRefreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          final data = responseBody['data'];
          final newToken = data['token'];
          final newRole = data['role'];
          final newRefreshToken = data['refreshToken'];

          await _storageService.saveLoginInfo(newToken, newRole, newRefreshToken);
          return newToken;
        }
      }
    } catch (e) {
      // Ignore errors and return null
    }
    
    return null;
  }

  http.BaseRequest _copyRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;
      return copy;
    }
    return request;
  }
}
