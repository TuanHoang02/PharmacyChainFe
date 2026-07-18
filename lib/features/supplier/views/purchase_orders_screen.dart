import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_summary.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/purchase_order_service.dart';
import 'package:pharmacy_chain_fe/features/supplier/widgets/order_filter_sheet.dart';
import 'package:pharmacy_chain_fe/features/supplier/widgets/purchase_order_card.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  final PurchaseOrderService _service = PurchaseOrderService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static const int _pageSize = 10;

  final List<PurchaseOrderSummary> _orders = [];
  PurchaseOrderFilter _filter = const PurchaseOrderFilter();
  int _pageNumber = 1;
  int _totalRecords = 0;
  bool _isLoadingFirstPage = false;
  bool _isLoadingMore = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240 &&
        !_isLoadingMore &&
        !_isLoadingFirstPage) {
      final hasMore = _orders.length < _totalRecords;
      if (hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirstPage = true;
      _errorMessage = null;
      _pageNumber = 1;
    });
    try {
      final paged = await _service.getOrders(
        pageNumber: 1,
        pageSize: _pageSize,
        filter: _filter,
      );
      if (!mounted) return;
      setState(() {
        _orders
          ..clear()
          ..addAll(paged.data);
        _totalRecords = paged.totalRecords;
        _hasLoadedOnce = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyError(e);
        _hasLoadedOnce = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFirstPage = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final next = _pageNumber + 1;
      final paged = await _service.getOrders(
        pageNumber: next,
        pageSize: _pageSize,
        filter: _filter,
      );
      if (!mounted) return;
      setState(() {
        _orders.addAll(paged.data);
        _pageNumber = next;
        _totalRecords = paged.totalRecords;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadFirstPage();
  }

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<PurchaseOrderFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderFilterSheet(initial: _filter),
    );
    if (result == null) return;
    setState(() {
      _filter = result.copyWith(search: _searchController.text.trim());
    });
    await _loadFirstPage();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _filter = _filter.copyWith(search: value.trim());
      });
      await _loadFirstPage();
    });
  }

  Future<void> _openDetail(PurchaseOrderSummary order) async {
    await context.push('/supplier/orders/${order.purchaseOrderId}');
    if (!mounted) return;
    await _loadFirstPage();
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }

  bool get _hasAnyFilter => !_filter.isEmpty || _searchController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 4),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn mua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Danh sách các đơn đặt hàng từ chi nhánh',
                  style: TextStyle(
                    color: Color(0xFF8FA8C9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF111F38),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: Color(0xFF8FA8C9), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Tìm theo mã đơn (PO-...)',
                        hintStyle: TextStyle(
                          color: Color(0xFF7E92AD),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: const Icon(Icons.close,
                          color: Color(0xFF7E92AD), size: 18),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: _hasAnyFilter
                ? const Color(0xFF1E88E5)
                : const Color(0xFF111F38),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openFilter,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _hasAnyFilter
                        ? const Color(0xFF1E88E5)
                        : Colors.white.withAlpha(20),
                  ),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingFirstPage && !_hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C48C)));
    }

    if (_errorMessage != null) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: _loadFirstPage,
      );
    }

    if (_orders.isEmpty) {
      if (_hasAnyFilter) {
        return const _NoMatchState();
      }
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF00C48C),
      backgroundColor: const Color(0xFF111F38),
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00C48C),
                  ),
                ),
              ),
            );
          }
          final order = _orders[index];
          return PurchaseOrderCard(
            order: order,
            onTap: () => _openDetail(order),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFF111F38),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFF8FA8C9), size: 38),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hiện không có đơn mua nào',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No purchase orders are currently available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8FA8C9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchState extends StatelessWidget {
  const _NoMatchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFF111F38),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: const Icon(Icons.search_off,
                  color: Color(0xFF8FA8C9), size: 38),
            ),
            const SizedBox(height: 18),
            const Text(
              'Không tìm thấy đơn phù hợp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No purchase orders match the selected criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8FA8C9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: Color(0xFFFF7070), size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFF9090), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
