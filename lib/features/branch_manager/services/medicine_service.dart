import 'dart:convert';
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/api_client.dart';
import 'package:pharmacy_chain_fe/shared/models/base_api_response.dart';
import 'package:pharmacy_chain_fe/shared/models/medicine_model.dart';

class MedicineService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/medicines - Get paginated list of medicines
  Future<PagedMedicineResponse> getMedicines({
    String? search,
    int? categoryId,
    bool? isActive,
    String? sortBy,
    bool isDescending = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final baseUrl = ApiConstants.baseUrl;
    final Map<String, String> queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'isDescending': isDescending.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId.toString();
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParams['sortBy'] = sortBy.trim();
    }

    final uri = Uri.parse('$baseUrl${ApiConstants.medicines}').replace(queryParameters: queryParams);

    final response = await _apiClient.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      return PagedMedicineResponse.fromJson(responseBody);
    } else {
      String errorMessage = 'Không thể tải danh sách thuốc.';
      try {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = BaseApiResponse<dynamic>.fromJson(responseBody, (json) => json);
        if (apiResponse.message.isNotEmpty) {
          errorMessage = apiResponse.message;
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// GET /api/medicines/{id} - Get detailed medicine by ID
  Future<MedicineDetailModel> getMedicineById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.medicines}/$id');

    final response = await _apiClient.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<MedicineDetailModel>.fromJson(
      responseBody,
      (json) => MedicineDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.statusCode == 200 && apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể lấy thông tin chi tiết thuốc.';
      throw Exception(message);
    }
  }

  /// POST /api/medicines - Create medicine
  Future<MedicineDetailModel> createMedicine({
    required String name,
    String? genericName,
    required int categoryId,
    required double price,
    required String unit,
    String? dosageInstructions,
    required bool requiresPrescription,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.medicines}');

    final response = await _apiClient.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'medicineName': name,
        'genericName': genericName,
        'categoryID': categoryId,
        'sellingPrice': price,
        'unit': unit,
        'dosageInstructions': dosageInstructions,
        'requiresPrescription': requiresPrescription,
      }),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<MedicineDetailModel>.fromJson(
      responseBody,
      (json) => MedicineDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if ((response.statusCode == 200 || response.statusCode == 201) && apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể tạo mới thuốc.';
      throw Exception(message);
    }
  }

  /// PUT /api/medicines/{id} - Update medicine
  Future<MedicineDetailModel> updateMedicine(
    int id, {
    required String name,
    String? genericName,
    required int categoryId,
    required double price,
    required String unit,
    String? dosageInstructions,
    required bool requiresPrescription,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.medicines}/$id');

    final response = await _apiClient.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'medicineName': name,
        'genericName': genericName,
        'categoryID': categoryId,
        'sellingPrice': price,
        'unit': unit,
        'dosageInstructions': dosageInstructions,
        'requiresPrescription': requiresPrescription,
      }),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = BaseApiResponse<MedicineDetailModel>.fromJson(
      responseBody,
      (json) => MedicineDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.statusCode == 200 && apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Không thể cập nhật thông tin thuốc.';
      throw Exception(message);
    }
  }

  /// PATCH /api/medicines/{id}/deactivate - Deactivate medicine
  Future<void> deactivateMedicine(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.medicines}/$id/deactivate');

    final response = await _apiClient.patch(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
          : 'Không thể ngưng hoạt động thuốc.';
      throw Exception(message);
    }
  }

  /// Encapsulated Category Retrieval
  Future<List<CategoryModel>> getCategories() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}');
    try {
      final response = await _apiClient.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = BaseApiResponse<List<dynamic>>.fromJson(
          responseBody,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fall through to fallback list
    }

    // Predefined fallback categories
    return [
      CategoryModel(categoryID: 1, categoryName: 'Thuốc kháng sinh', isActive: true),
      CategoryModel(categoryID: 2, categoryName: 'Thuốc giảm đau, hạ sốt', isActive: true),
      CategoryModel(categoryID: 3, categoryName: 'Thuốc kháng viêm', isActive: true),
      CategoryModel(categoryID: 4, categoryName: 'Vitamin & Khoáng chất', isActive: true),
      CategoryModel(categoryID: 5, categoryName: 'Thực phẩm chức năng', isActive: true),
    ];
  }
}
