import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/inventory_item.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/inventory_service.dart';

class BranchInventoryScreen extends StatefulWidget {
  const BranchInventoryScreen({super.key});

  @override
  State<BranchInventoryScreen> createState() => _BranchInventoryScreenState();
}

class _BranchInventoryScreenState extends State<BranchInventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<InventoryItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  bool _hasPrevious = false;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchInventory(searchKeyword: query, resetPage: true);
    });
  }

  Future<void> _fetchInventory({String searchKeyword = '', bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pagedResponse = await _inventoryService.getInventories(
        searchKeyword: searchKeyword.isEmpty ? _searchController.text : searchKeyword,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _items = pagedResponse.data;
        _currentPage = pagedResponse.pageNumber;
        _pageSize = pagedResponse.pageSize;
        _totalRecords = pagedResponse.totalRecords;
        _totalPages = pagedResponse.totalPages;
        _hasPrevious = pagedResponse.hasPrevious;
        _hasNext = pagedResponse.hasNext;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text('Kho Thuốc Chi Nhánh'),
        backgroundColor: const Color(0xFF111F38),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildBody(),
          ),
          if (_items.isNotEmpty) _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/manager/purchase-request/create');
        },
        backgroundColor: const Color(0xFF00C48C),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Tạo Yêu Cầu Nhập Hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: _items.isNotEmpty
          ? const _OffsetFloatingActionButtonLocation(
              FloatingActionButtonLocation.endFloat,
              offsetY: -60,
            )
          : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF111F38),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tên thuốc...',
          hintStyle: const TextStyle(color: Color(0xFF8FA8C9)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA8C9)),
          filled: true,
          fillColor: const Color(0xFF0A1628),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C48C)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF7070), size: 48),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra:\n$_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchInventory(searchKeyword: _searchController.text),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C48C)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Color(0xFF8FA8C9), size: 64),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy loại thuốc nào.',
              style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildInventoryCard(item);
      },
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isLowStock ? const Color(0xFFFF7070) : Colors.white.withAlpha(15),
          width: item.isLowStock ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.medicineName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item.isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7070).withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sắp hết',
                    style: TextStyle(color: Color(0xFFFF7070), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.categoryName.isNotEmpty ? 'Danh mục: ${item.categoryName}' : 'Thuốc',
            style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStat(Icons.inventory_2_outlined, 'Tồn kho', '${item.quantityInStock} ${item.unit}'),
              const SizedBox(width: 24),
              _buildStat(Icons.warning_amber_rounded, 'Mức cảnh báo', '${item.reorderLevel} ${item.unit}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8FA8C9)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF111F38),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton(
            onPressed: _hasPrevious && !_isLoading
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _fetchInventory();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C48C).withAlpha(50),
              disabledBackgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Row(
              children: [
                Icon(Icons.chevron_left, size: 18),
                Text('Trước', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          
          // Page Indicator
          Text(
            'Trang $_currentPage / ${math.max(1, _totalPages)}\n(Tổng: $_totalRecords)',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
          ),
          
          // Next button
          ElevatedButton(
            onPressed: _hasNext && !_isLoading
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _fetchInventory();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C48C).withAlpha(50),
              disabledBackgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Row(
              children: [
                Text('Sau', style: TextStyle(fontSize: 12)),
                Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OffsetFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation location;
  final double offsetX;
  final double offsetY;

  const _OffsetFloatingActionButtonLocation(
    this.location, {
    this.offsetX = 0,
    this.offsetY = 0,
  });

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}
