import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/purchase_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _purchaseService.getPurchaseRequests();
      setState(() {
        _requests = requests;
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

  void _showReceiveDialog(PurchaseRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhận hàng - ${request.requestCode}'),
        content: const Text('Bạn có chắc chắn muốn xác nhận nhận đủ số lượng lô hàng này không?\n\n(Hệ thống sẽ lấy dữ liệu lô thuốc đã được khai báo từ trước để cập nhật vào kho).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              setState(() => _isLoading = true);
              try {
                await _purchaseService.receiveMedicines(request.purchaseRequestId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nhận hàng thành công! Tồn kho đã được cập nhật.')),
                  );
                }
                _fetchRequests(); // Tải lại danh sách
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                  );
                }
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Đồng ý Nhận'),
          ),
        ],
      ),
    );
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
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: _buildBody(),
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
                    if (request.status.toLowerCase() == 'approved') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showReceiveDialog(request),
                          icon: const Icon(Icons.download),
                          label: const Text('NHẬN HÀNG'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
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
}
