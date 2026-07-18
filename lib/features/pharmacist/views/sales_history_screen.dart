import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/models/sales_history_model.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/services/sales_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final SalesService _salesService = SalesService();
  final TextEditingController _searchController = TextEditingController();

  List<SalesHistoryModel> _invoices = [];
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
  int? _selectedStatusIndex; // mapped to InvoiceStatus integer values
  String _sortBy = 'createdat';
  bool _isDescending = true;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchSalesHistory(resetPage: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSalesHistory({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pagedResponse = await _salesService.getSalesHistory(
        customerPhoneNumber: _searchQuery,
        invoiceStatus: _selectedStatusIndex,
        sortBy: _sortBy,
        isDescending: _isDescending,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _invoices = pagedResponse.data;
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
          _invoices = [];
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
      _fetchSalesHistory(resetPage: true);
    });
  }

  String _formatDateTime(DateTime dt) {
    final localDt = dt.toLocal();
    final day = localDt.day.toString().padLeft(2, '0');
    final month = localDt.month.toString().padLeft(2, '0');
    final year = localDt.year;
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111F38),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lịch sử bán lẻ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Filters ─────────────────────────────────────
            _buildSearchAndFilters(isTablet),

            // ── Invoices List ────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchSalesHistory(resetPage: true),
                color: const Color(0xFF1E88E5),
                backgroundColor: const Color(0xFF111F38),
                child: _buildMainContent(isTablet),
              ),
            ),

            // ── Pagination Section ───────────────────────────────────
            if (_invoices.isNotEmpty) _buildPaginationControls(),
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
          // Row 1: Search text field (Phone number search)
          TextFormField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo số điện thoại khách hàng...',
              hintStyle: TextStyle(color: Colors.white.withAlpha(80), fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(120), size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white60, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _fetchSalesHistory(resetPage: true);
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

          // Row 2: Status & Sort dropdowns
          if (isTablet)
            Row(
              children: [
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
                    Expanded(child: _buildStatusDropdown()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSortDropdown()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Hướng sắp xếp: ', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(width: 8),
                    _buildSortDirectionToggle(),
                  ],
                ),
              ],
            ),
        ],
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
        child: DropdownButton<int?>(
          value: _selectedStatusIndex,
          dropdownColor: const Color(0xFF111F38),
          hint: const Text('Trạng thái hóa đơn', style: TextStyle(color: Colors.white70, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tất cả trạng thái'),
            ),
            ...InvoiceStatus.values.map((status) => DropdownMenuItem<int?>(
                  value: status.index,
                  child: Text(displayInvoiceStatus(status)),
                )),
          ],
          onChanged: (val) {
            setState(() {
              _selectedStatusIndex = val;
            });
            _fetchSalesHistory(resetPage: true);
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
              value: 'createdat',
              child: Text('Sắp xếp: Ngày tạo'),
            ),
            DropdownMenuItem(
              value: 'totalamount',
              child: Text('Sắp xếp: Tổng tiền'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _sortBy = val;
              });
              _fetchSalesHistory(resetPage: true);
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
          _fetchSalesHistory(resetPage: true);
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

  Widget _buildMainContent(bool isTablet) {
    if (_isLoading && _invoices.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)));
    }

    if (_errorMessage != null && _invoices.isEmpty) {
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
                  onPressed: () => _fetchSalesHistory(resetPage: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_invoices.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, color: Colors.white.withAlpha(60), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'No sales invoices found.',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Không tìm thấy hóa đơn nào khớp với bộ lọc của bạn.',
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
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return _buildInvoiceCard(invoice);
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
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final invoice = _invoices[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(SalesHistoryModel invoice) {
    final formattedPrice = invoice.totalAmount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    final isTablet = MediaQuery.of(context).size.width > 600;

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
          context.push('/pharmacist/sales/${invoice.salesInvoiceID}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Code and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceCode,
                    style: const TextStyle(
                      color: Color(0xFF60ABFF),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildInvoiceStatusBadge(invoice.invoiceStatus),
                ],
              ),
              const SizedBox(height: 10),

              // Customer details
              Text(
                'Khách hàng: ${invoice.customerName ?? "Vãng lai"}',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (invoice.customerPhoneNumber != null && invoice.customerPhoneNumber!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'SĐT: ${invoice.customerPhoneNumber}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
              const SizedBox(height: 10),

              // Payment Status and Payment Method
              Row(
                children: [
                  _buildPaymentStatusBadge(invoice.paymentStatus),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayPaymentMethod(invoice.paymentMethod),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
              if (isTablet) const Spacer() else const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 16),

              // Footer: Total Amount & Timestamps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(invoice.createdAt),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      if (invoice.completedAt != null)
                        Text(
                          'Xong: ${_formatDateTime(invoice.completedAt!)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                    ],
                  ),
                  Text(
                    '$formattedPrice đ',
                    style: const TextStyle(
                      color: Color(0xFF00C48C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceStatusBadge(InvoiceStatus status) {
    Color color;
    switch (status) {
      case InvoiceStatus.draft:
        color = const Color(0xFFFF9F43);
        break;
      case InvoiceStatus.finalized:
        color = const Color(0xFF00C48C);
        break;
      case InvoiceStatus.cancelled:
        color = const Color(0xFFFF5252);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        displayInvoiceStatus(status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.pending:
        color = const Color(0xFFFF9F43);
        break;
      case PaymentStatus.completed:
        color = const Color(0xFF00C48C);
        break;
      case PaymentStatus.failed:
        color = const Color(0xFFFF5252);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            displayPaymentStatus(status),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
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
                    _fetchSalesHistory();
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
                    _fetchSalesHistory();
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
