import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/inventory_item.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class InventoryService {
  final LocalStorageService _storageService = LocalStorageService();

  Future<PagedResponse<List<InventoryItem>>> getInventories({String searchKeyword = '', int pageNumber = 1, int pageSize = 10}) async {
    final token = await _storageService.getToken();
    
    var urlString = '${ApiConstants.baseUrl}/api/inventory?pageNumber=$pageNumber&pageSize=$pageSize';
    if (searchKeyword.isNotEmpty) {
      urlString += '&searchKeyword=$searchKeyword';
    }
    
    final url = Uri.parse(urlString);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      
      return PagedResponse<List<InventoryItem>>.fromJson(
        body['data'] as Map<String, dynamic>,
        (listJson) {
          final list = listJson as List<dynamic>;
          return list.map((item) => InventoryItem.fromJson(item as Map<String, dynamic>)).toList();
        },
      );
    } else {
      throw Exception('Không thể tải danh sách thuốc (${response.statusCode})');
    }
  }
}
