import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _branchIdKey = 'user_branch_id';

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return {};
    }
    
    String output = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        return {};
    }
    
    try {
      final payloadString = utf8.decode(base64Url.decode(output));
      return jsonDecode(payloadString) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveLoginInfo(String token, String role, [String? refreshToken]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }

    final payload = _decodeJwt(token);
    final branchId = payload['BranchID']?.toString();
    if (branchId != null) {
      await prefs.setString(_branchIdKey, branchId);
    } else {
      await prefs.remove(_branchIdKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<String?> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_branchIdKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_branchIdKey);
  }
}
