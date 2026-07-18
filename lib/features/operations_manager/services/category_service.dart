import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class CategoryModel {
  final int categoryID;
  final String categoryName;
  final String? description;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  CategoryModel({
    required this.categoryID,
    required this.categoryName,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryID: json['categoryID'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<PagedResponse<List<CategoryModel>>> getCategories({
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

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}').replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<PagedResponse<List<CategoryModel>>>.fromJson(
        responseBody,
        (dataJson) {
          return PagedResponse<List<CategoryModel>>.fromJson(
            dataJson as Map<String, dynamic>,
            (listJson) {
              final list = listJson as List<dynamic>;
              return list.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
            },
          );
        },
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lấy danh sách danh mục thất bại.');
    } else {
      throw Exception('Lỗi hệ thống: ${response.statusCode}');
    }
  }

  Future<CategoryModel> createCategory({
    required String categoryName,
    String? description,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}');
    final response = await _apiClient.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'categoryName': categoryName,
        'description': description,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<CategoryModel>.fromJson(
        responseBody,
        (dataJson) => CategoryModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Tạo danh mục thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<CategoryModel> updateCategory(
    int id, {
    required String categoryName,
    String? description,
    required bool isActive,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}/$id');
    final response = await _apiClient.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'categoryName': categoryName,
        'description': description,
        'isActive': isActive,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final baseResponse = BaseApiResponse<CategoryModel>.fromJson(
        responseBody,
        (dataJson) => CategoryModel.fromJson(dataJson as Map<String, dynamic>),
      );
      if (baseResponse.success && baseResponse.data != null) {
        return baseResponse.data!;
      }
      throw Exception(baseResponse.message.isNotEmpty ? baseResponse.message : 'Cập nhật danh mục thất bại.');
    } else {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Lỗi hệ thống';
      throw Exception(msg);
    }
  }

  Future<void> deleteCategory(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}/$id');
    final response = await _apiClient.delete(uri);

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = responseBody['message'] as String? ?? 'Xóa danh mục thất bại.';
      throw Exception(msg);
    }
  }
}
