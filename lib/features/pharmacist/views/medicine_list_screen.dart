import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/medicine_service.dart';
import 'package:pharmacy_chain_fe/shared/models/medicine_model.dart';

class PharmacistMedicineListScreen extends StatefulWidget {
  const PharmacistMedicineListScreen({super.key});

  @override
  State<PharmacistMedicineListScreen> createState() => _PharmacistMedicineListScreenState();
}

class _PharmacistMedicineListScreenState extends State<PharmacistMedicineListScreen> {
  final MedicineService _medicineService = MedicineService();
  final TextEditingController _searchController = TextEditingController();

  List<MedicineModel> _medicines = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  bool _hasPrevious = false;
  bool _hasNext = false;

  // Filters & Sorting state
  String _searchQuery = '';
  int? _selectedCategoryId;
  bool? _selectedIsActive;
  String _sortBy = 'medicinename';
  bool _isDescending = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchMedicines(resetPage: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _medicineService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchMedicines({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final pagedResponse = await _medicineService.getMedicines(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        isActive: _selectedIsActive,
        sortBy: _sortBy,
        isDescending: _isDescending,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _medicines = pagedResponse.data;
          _currentPage = pagedResponse.pageNumber;
          _pageSize = pagedResponse.pageSize;
          _totalRecords = pagedResponse.totalRecords;
          _totalPages = pagedResponse.totalPages;
          _hasPrevious = pagedResponse.hasPrevious;
          _hasNext = pagedResponse.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _medicines = [];
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      _fetchMedicines(resetPage: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filters & Search Section ─────────────────────────────
            _buildSearchAndFilters(isTablet),

            // ── Main List Content ────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _fetchCategories();
                  await _fetchMedicines(resetPage: true);
                },
                color: const Color(0xFF1E88E5),
                backgroundColor: const Color(0xFF111F38),
                child: _buildMainBody(isTablet),
              ),
            ),

            // ── Pagination Section ───────────────────────────────────
            if (_medicines.isNotEmpty) _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isTablet) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: const Color(0xFF111F38),
      child: Column(
        children: [
          // Row 1: Search bar
          TextFormField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên thuốc hoặc tên gốc...',
              hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(120), size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white60, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _fetchMedicines(resetPage: true);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withAlpha(12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Row 2: Category Dropdown & Status Filter & Sort Option
          if (isTablet)
            Row(
              children: [
                Expanded(child: _buildCategoryDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildSortDropdown()),
                const SizedBox(width: 8),
                _buildSortDirectionToggle(),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCategoryDropdown()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatusDropdown()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildSortDropdown()),
                    const SizedBox(width: 8),
                    _buildSortDirectionToggle(),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedCategoryId,
          dropdownColor: const Color(0xFF111F38),
          hint: const Text('Chọn danh mục', style: TextStyle(color: Colors.white70, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tất cả danh mục'),
            ),
            ..._categories.map((cat) => DropdownMenuItem<int?>(
                  value: cat.categoryID,
                  child: Text(cat.categoryName),
                )),
          ],
          onChanged: (val) {
            setState(() {
              _selectedCategoryId = val;
            });
            _fetchMedicines(resetPage: true);
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _selectedIsActive,
          dropdownColor: const Color(0xFF111F38),
          hint: const Text('Trạng thái', style: TextStyle(color: Colors.white70, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: const [
            DropdownMenuItem<bool?>(
              value: null,
              child: Text('Tất cả trạng thái'),
            ),
            DropdownMenuItem<bool?>(
              value: true,
              child: Text('Đang hoạt động'),
            ),
            DropdownMenuItem<bool?>(
              value: false,
              child: Text('Ngưng hoạt động'),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _selectedIsActive = val;
            });
            _fetchMedicines(resetPage: true);
          },
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          dropdownColor: const Color(0xFF111F38),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: const [
            DropdownMenuItem(
              value: 'medicinename',
              child: Text('Sắp xếp: Tên thuốc'),
            ),
            DropdownMenuItem(
              value: 'sellingprice',
              child: Text('Sắp xếp: Giá bán'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _sortBy = val;
              });
              _fetchMedicines(resetPage: true);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortDirectionToggle() {
    return Material(
      color: Colors.white.withAlpha(10),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isDescending = !_isDescending;
          });
          _fetchMedicines(resetPage: true);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withAlpha(20)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
            color: const Color(0xFF1E88E5),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMainBody(bool isTablet) {
    if (_isLoading && _medicines.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)));
    }

    if (_errorMessage != null && _medicines.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Color(0xFFFF5252), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Không thể kết nối máy chủ',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _fetchMedicines(resetPage: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_medicines.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white.withAlpha(60), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'No medicines found',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Không tìm thấy thuốc nào khớp với bộ lọc của bạn.',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return isTablet ? _buildGridList() : _buildVerticalList();
  }

  Widget _buildVerticalList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final medicine = _medicines[index];
        return _buildMedicineCard(medicine);
      },
    );
  }

  Widget _buildGridList() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final medicine = _medicines[index];
        return _buildMedicineCard(medicine);
      },
    );
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    return Card(
      color: const Color(0xFF111F38),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withAlpha(18), width: 1.2),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/pharmacist/medicines/${medicine.medicineID}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line: Name & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      medicine.medicineName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(medicine.isActive),
                ],
              ),
              const SizedBox(height: 6),

              // Generic name
              if (medicine.genericName != null && medicine.genericName!.isNotEmpty)
                Text(
                  medicine.genericName!,
                  style: TextStyle(
                    color: Colors.white.withAlpha(120),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),

              // Category, Unit, Requires Prescription info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      medicine.categoryName,
                      style: const TextStyle(color: Color(0xFF60ABFF), fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đơn vị: ${medicine.unit}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (medicine.requiresPrescription) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F43).withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Rx',
                        style: TextStyle(color: Color(0xFFFF9F43), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              const Divider(color: Colors.white10),

              // Footer: Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá bán',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      Text(
                        '${medicine.sellingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        style: const TextStyle(
                          color: Color(0xFF00C48C),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00C48C).withAlpha(30)
            : const Color(0xFFFF5252).withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF00C48C) : const Color(0xFFFF5252),
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? const Color(0xFF00C48C) : const Color(0xFFFF5252),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                    _fetchMedicines();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5).withAlpha(50),
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

          // Page indicator
          Text(
            'Trang $_currentPage / $_totalPages\n(Tổng: $_totalRecords)',
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
                    _fetchMedicines();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5).withAlpha(50),
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
