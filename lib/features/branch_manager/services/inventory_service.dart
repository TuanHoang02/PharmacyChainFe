import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacy_chain_fe/core/constants/api_constants.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/inventory_item.dart';

class InventoryService {
  final LocalStorageService _storageService = LocalStorageService();

  Future<List<InventoryItem>> getInventories({String searchKeyword = ''}) async {
    final token = await _storageService.getToken();
    
    var urlString = '${ApiConstants.baseUrl}/api/inventory';
    if (searchKeyword.isNotEmpty) {
      urlString += '?searchKeyword=$searchKeyword';
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
      final body = jsonDecode(response.body);
      final List<dynamic> itemsData = body['data']?['data'] ?? [];
      return itemsData.map((e) => InventoryItem.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải danh sách thuốc (${response.statusCode})');
    }
  }
}
