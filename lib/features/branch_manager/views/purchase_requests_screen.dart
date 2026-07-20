import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/purchase_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/receive_po_dialog.dart';

class PurchaseRequestsScreen extends StatefulWidget {
  const PurchaseRequestsScreen({super.key});

  @override
  State<PurchaseRequestsScreen> createState() => _PurchaseRequestsScreenState();
}

class _PurchaseRequestsScreenState extends State<PurchaseRequestsScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  List<PurchaseRequestModel> _requests = [];
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
    _fetchRequests();
  }

  Future<void> _fetchRequests({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pagedResponse = await _purchaseService.getPurchaseRequests(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _requests = pagedResponse.data;
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'received':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showReceiveDialog(PurchaseRequestModel request, PurchaseOrderSummaryModel po) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReceivePODialog(po: po),
    );

    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhận hàng thành công! Tồn kho đã được cập nhật.')),
        );
      }
      _fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text('Danh sách Yêu cầu Nhập hàng', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF111F38),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchRequests(resetPage: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (_requests.isNotEmpty) _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C48C)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRequests,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return const Center(child: Text('Không có yêu cầu nhập hàng nào.', style: TextStyle(color: Color(0xFF8FA8C9))));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          color: const Color(0xFF1B2E4B),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Text(
                request.requestCode,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                'Tạo lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt.toLocal())}',
                style: const TextStyle(color: Color(0xFF8FA8C9)),
              ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(request.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor(request.status)),
              ),
              child: Text(
                request.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(request.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            children: [
              const Divider(color: Color(0xFF2A3F5F)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (request.reason != null) ...[
                      Text('Lý do: ${request.reason}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                    ],
                    if (request.reviewNote != null) ...[
                      Text('Ghi chú duyệt: ${request.reviewNote}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                    ],
                    const Text('Chi tiết thuốc:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    ...request.details.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('- ${detail.medicineName}', style: const TextStyle(color: Color(0xFF8FA8C9)))),
                          Text('SL: ${detail.requestedQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    )),
                    if (request.purchaseOrders.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Đơn đặt hàng (Từ NCC):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      ...request.purchaseOrders.map((po) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A3F5F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(po.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('Mã PO: ${po.orderCode}', style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 12)),
                                    Text('Trạng thái: ${po.deliveryStatus}', style: TextStyle(color: po.deliveryStatus == 'Received' ? Colors.green : Colors.orange, fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (po.deliveryStatus == 'Pending' || po.deliveryStatus == 'Confirmed' || po.deliveryStatus == 'Delivered')
                                ElevatedButton(
                                  onPressed: () => _showReceiveDialog(request, po),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Nhận hàng', style: TextStyle(fontSize: 12)),
                                )
                              else if (po.deliveryStatus == 'Received')
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text('Đã nhận', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
          ),
        );
      },
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
                    _fetchRequests();
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
                    _fetchRequests();
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
