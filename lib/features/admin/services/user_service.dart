import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/user_model.dart';
import 'package:pharmacy_chain_fe/shared/models/lookup_model.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';

class UserService {
  final ApiClient _client = ApiClient();

  Future<PagedResponse<List<UserModel>>> getUsers({
    int page = 1,
    int size = 10,
    String? keyword,
    int? roleId,
    int? branchId,
    bool? isActive,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (roleId != null) queryParams['roleId'] = roleId.toString();
    if (branchId != null) queryParams['branchId'] = branchId.toString();
    if (isActive != null) queryParams['isActive'] = isActive.toString();

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/administrator/users').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final baseResponse = BaseApiResponse<PagedResponse<List<UserModel>>>.fromJson(
          decoded,
          (json) {
            return PagedResponse<List<UserModel>>.fromJson(
              json as Map<String, dynamic>,
              (dataJson) {
                final List<dynamic> list = dataJson as List<dynamic>;
                return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
              },
            );
          },
        );
        
        if (baseResponse.success && baseResponse.data != null) {
          return baseResponse.data!;
        } else {
          throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Failed to load users');
        }
      } else {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Error fetching users: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/administrator/users');

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return UserModel.fromJson(decoded['data']);
        } else {
          throw Exception(decoded['message'] ?? 'Failed to create user');
        }
      } else {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Error creating user: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> userData) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/administrator/users/$id');

    try {
      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return UserModel.fromJson(decoded['data']);
        } else {
          throw Exception(decoded['message'] ?? 'Failed to update user');
        }
      } else {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Error updating user: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deactivateUser(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/administrator/users/$id/deactivate');

    try {
      final response = await _client.patch(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return true;
        } else {
          throw Exception(decoded['message'] ?? 'Failed to deactivate user');
        }
      } else {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Error deactivating user: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LookupModel>> getRoles() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/administrator/users/roles');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return (decoded['data'] as List).map((i) => LookupModel.fromJson(i)).toList();
        }
        throw Exception(decoded['message'] ?? 'Failed to load roles');
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LookupModel>> getBranches() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/administrator/users/branches');
    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return (decoded['data'] as List).map((i) => LookupModel.fromJson(i)).toList();
        }
        throw Exception(decoded['message'] ?? 'Failed to load branches');
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
