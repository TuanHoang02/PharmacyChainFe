import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/medicine_batch_summary.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_summary.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/medicine_batch_service.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/purchase_order_service.dart';
import 'package:pharmacy_chain_fe/shared/models/paged_response.dart';

class MedicineBatchListScreen extends StatefulWidget {
  const MedicineBatchListScreen({super.key});

  @override
  State<MedicineBatchListScreen> createState() => _MedicineBatchListScreenState();
}

class _MedicineBatchListScreenState extends State<MedicineBatchListScreen> {
  final MedicineBatchService _batchService = MedicineBatchService();
  final PurchaseOrderService _orderService = PurchaseOrderService();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<MedicineBatchSummary> _batches = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _pageNumber = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Filters
  int? _selectedOrderId;
  String _sortBy = 'CreatedAt';
  bool _isDescending = true;

  List<PurchaseOrderSummary> _orders = [];

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMoreBatches();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load filters data in parallel (Skip MedicineService since it is restricted to Branch Manager/Pharmacist - 403 Forbidden)
      final futures = await Future.wait([
        _orderService.getOrders(pageSize: 100),
        _batchService.getMedicineBatches(
          pageNumber: 1,
          pageSize: _pageSize,
          batchNumber: _searchController.text,
          purchaseOrderId: _selectedOrderId,
          sortBy: _sortBy,
          isDescending: _isDescending,
        ),
      ]);

      final ordersPaged = futures[0] as PagedResponse<List<PurchaseOrderSummary>>;
      final batchesPaged = futures[1] as PagedResponse<List<MedicineBatchSummary>>;

      if (!mounted) return;

      setState(() {
        _orders = ordersPaged.data;
        _batches.clear();
        _batches.addAll(batchesPaged.data);
        _pageNumber = 1;
        _hasMore = batchesPaged.data.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadBatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paged = await _batchService.getMedicineBatches(
        pageNumber: 1,
        pageSize: _pageSize,
        batchNumber: _searchController.text,
        purchaseOrderId: _selectedOrderId,
        sortBy: _sortBy,
        isDescending: _isDescending,
      );

      if (!mounted) return;

      setState(() {
        _batches.clear();
        _batches.addAll(paged.data);
        _pageNumber = 1;
        _hasMore = paged.data.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreBatches() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _pageNumber + 1;
      final paged = await _batchService.getMedicineBatches(
        pageNumber: nextPage,
        pageSize: _pageSize,
        batchNumber: _searchController.text,
        purchaseOrderId: _selectedOrderId,
        sortBy: _sortBy,
        isDescending: _isDescending,
      );

      if (!mounted) return;

      setState(() {
        _batches.addAll(paged.data);
        _pageNumber = nextPage;
        _hasMore = paged.data.length == _pageSize;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thêm lô thuốc: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedOrderId = null;
      _sortBy = 'CreatedAt';
      _isDescending = true;
    });
    _loadBatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text('Quản lý lô thuốc', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A1628),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await context.push('/supplier/batches/create');
          if (res == true) {
            _loadBatches();
          }
        },
        backgroundColor: const Color(0xFF00C48C),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter Panel
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          color: const Color(0xFF0A1628),
          child: Column(
            children: [
              // Search text row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo số lô...',
                        hintStyle: const TextStyle(color: Color(0xFF7E92AD), fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA8C9), size: 18),
                        filled: true,
                        fillColor: const Color(0xFF111F38),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _loadBatches(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loadBatches,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tìm', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 14, color: Color(0xFFFF7070)),
                    label: const Text(
                      'Xóa lọc',
                      style: TextStyle(color: Color(0xFFFF7070), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filters & Sort Row
              Row(
                children: [
                  // Order filter
                  Expanded(
                    flex: 5,
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedOrderId,
                      dropdownColor: const Color(0xFF111F38),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: _getFilterDecoration('Chọn đơn hàng'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Tất cả đơn hàng', style: TextStyle(color: Color(0xFF7E92AD))),
                        ),
                        ..._orders.map((o) {
                          return DropdownMenuItem<int>(
                            value: o.purchaseOrderId,
                            child: Text(
                              o.purchaseOrderCode,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedOrderId = val;
                        });
                        _loadBatches();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sort dropdown
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      initialValue: _sortBy,
                      dropdownColor: const Color(0xFF111F38),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: _getFilterDecoration('Sắp xếp'),
                      items: const [
                        DropdownMenuItem(value: 'CreatedAt', child: Text('Mới tạo')),
                        DropdownMenuItem(value: 'BatchNumber', child: Text('Số lô')),
                        DropdownMenuItem(value: 'ReceivedQuantity', child: Text('Số lượng')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _sortBy = val;
                          });
                          _loadBatches();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Sort direction button
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: Icon(
                      _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                      color: const Color(0xFF00C48C),
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDescending = !_isDescending;
                      });
                      _loadBatches();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Batches List view
        Expanded(child: _buildListSection()),
      ],
    );
  }

  Widget _buildListSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C48C)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: Color(0xFFFF7070), size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFF9090), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_batches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Color(0xFF8FA8C9), size: 48),
            SizedBox(height: 12),
            Text(
              'Không tìm thấy lô thuốc nào.',
              style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBatches,
      color: const Color(0xFF00C48C),
      backgroundColor: const Color(0xFF111F38),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _batches.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _batches.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: Color(0xFF00C48C)),
              ),
            );
          }

          final batch = _batches[index];
          final isExpired = DateTime.now().isAfter(batch.expiryDate);
          final isNearExpiry = !isExpired && batch.expiryDate.difference(DateTime.now()).inDays < 90;

          Color borderAlertColor = Colors.white.withAlpha(10);
          Color textAlertColor = const Color(0xFF8FA8C9);
          String statusText = '';

          if (isExpired) {
            borderAlertColor = const Color(0xFFFF7070).withAlpha(120);
            textAlertColor = const Color(0xFFFF7070);
            statusText = 'HẾT HẠN';
          } else if (isNearExpiry) {
            borderAlertColor = const Color(0xFFFFB03A).withAlpha(120);
            textAlertColor = const Color(0xFFFFB03A);
            statusText = 'SẮP HẾT HẠN';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111F38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderAlertColor),
            ),
            child: InkWell(
              onTap: () => context.push('/supplier/batches/${batch.medicineBatchId}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            batch.medicineName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (statusText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: textAlertColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: textAlertColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số lô: ${batch.batchNumber}',
                          style: const TextStyle(color: Color(0xFFB7CDE5), fontSize: 13),
                        ),
                        Text(
                          'SL: ${batch.remainingQuantity}/${batch.receivedQuantity}',
                          style: const TextStyle(
                            color: Color(0xFF00C48C),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0x1AFFFFFF), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đơn mua: ${batch.purchaseOrderCode}',
                          style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 12),
                        ),
                        Text(
                          'HSD: ${_dateFormat.format(batch.expiryDate)}',
                          style: TextStyle(
                            color: isExpired || isNearExpiry ? textAlertColor : const Color(0xFF8FA8C9),
                            fontSize: 12,
                            fontWeight: isExpired || isNearExpiry ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _getFilterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 11),
      filled: true,
      fillColor: const Color(0xFF111F38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withAlpha(15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
      ),
    );
  }
}
