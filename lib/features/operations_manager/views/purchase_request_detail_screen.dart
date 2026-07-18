import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/shared/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/shared/models/review_purchase_request_model.dart';
import 'package:pharmacy_chain_fe/shared/models/lookup_model.dart';
import '../services/purchase_request_service.dart';

class PurchaseRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const PurchaseRequestDetailScreen({super.key, required this.requestId});

  @override
  State<PurchaseRequestDetailScreen> createState() => _PurchaseRequestDetailScreenState();
}

class _PurchaseRequestDetailScreenState extends State<PurchaseRequestDetailScreen> {
  final PurchaseRequestService _service = PurchaseRequestService();
  PurchaseRequestModel? _request;
  List<LookupModel> _suppliers = [];
  bool _isLoading = true;
  bool _isReviewing = false;
  String? _errorMessage;
  final Map<int, int?> _selectedSuppliers = {}; // detailId -> supplierId

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = await _service.getPurchaseRequestById(widget.requestId);
      final suppliers = await _service.getSuppliers();
      setState(() {
        _request = request;
        _suppliers = suppliers;
        _isLoading = false;
        
        for (var detail in request.details) {
          _selectedSuppliers[detail.purchaseRequestDetailId] = null;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _reviewRequest(bool isApproved, String? rejectionReason, {List<Map<String, dynamic>>? detailSuppliers}) async {
    setState(() {
      _isReviewing = true;
      _errorMessage = null;
    });

    try {
      final reviewData = ReviewPurchaseRequestModel(
        isApproved: isApproved,
        rejectionReason: rejectionReason,
        detailSuppliers: detailSuppliers,
      );
      await _service.reviewPurchaseRequest(widget.requestId, reviewData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isApproved ? 'Đã duyệt yêu cầu nhập hàng và tạo các Đơn đặt hàng' : 'Đã từ chối yêu cầu nhập hàng')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviewing = false;
        });
      }
    }
  }

  void _showRejectionDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Từ chối yêu cầu'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Lý do từ chối (*)',
              hintText: 'Nhập lý do từ chối',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lý do từ chối là bắt buộc.')),
                  );
                  return;
                }
                
                Navigator.pop(dialogContext); // close dialog
                await _reviewRequest(false, reason);
              },
              child: const Text('Xác nhận từ chối', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu nhập hàng'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _request == null) {
      return Center(
        child: Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)),
      );
    }

    final request = _request;
    if (request == null) {
      return const Center(child: Text('Không tìm thấy dữ liệu.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã yêu cầu: ${request.requestCode}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Chi nhánh: ${request.branchName ?? 'N/A'}'),
                  Text('Trạng thái: ${request.status}'),
                  Text('Ngày tạo: ${request.createdAt.toLocal().toString().split('.')[0]}'),
                  Text('Người tạo: ${request.createdByUserName ?? 'N/A'}'),
                  if (request.reason != null && request.reason!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Ghi chú của chi nhánh: ${request.reason}', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Danh sách thuốc yêu cầu:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: request.details.length,
            itemBuilder: (context, index) {
              final detail = request.details[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(detail.medicineName ?? 'N/A'),
                        subtitle: Text('Tồn kho: ${detail.currentStock} ${detail.unit ?? ''}'),
                        trailing: Text(
                          'YC: ${detail.requestedQuantity} ${detail.unit ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      if (request.status == 'Pending')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Nhà cung cấp (*)',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedSuppliers[detail.purchaseRequestDetailId],
                            items: _suppliers.map((s) => DropdownMenuItem<int>(
                              value: s.id,
                              child: Text(s.name, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedSuppliers[detail.purchaseRequestDetailId] = v;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (request.status == 'Approved' && request.purchaseOrders.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Các Đơn đặt hàng đã tạo:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: request.purchaseOrders.length,
              itemBuilder: (context, index) {
                final po = request.purchaseOrders[index];
                return Card(
                  color: const Color(0xFFE3F2FD),
                  child: ExpansionTile(
                    title: Text(po.purchaseOrderCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nhà cung cấp: ${po.supplierName}'),
                        Text('Trạng thái Đơn hàng: ${po.orderStatus}'),
                        Text('Trạng thái Giao hàng: ${po.deliveryStatus}'),
                      ],
                    ),
                    children: po.items.map((item) {
                      return ListTile(
                        title: Text(item.medicineName),
                        trailing: Text('${item.orderedQuantity} ${item.unit}'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    if (_isLoading || _request == null) return null;
    if (_request!.status != 'Pending') return null; // Only show actions if Pending

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isReviewing
                    ? null
                    : () => _showRejectionDialog(context),
                child: const Text('TỪ CHỐI'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isReviewing
                    ? null
                    : () async {
                        // Validate suppliers
                        final missingSuppliers = _selectedSuppliers.values.any((s) => s == null);
                        if (missingSuppliers) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng chọn nhà cung cấp cho tất cả các loại thuốc để duyệt.')),
                          );
                          return;
                        }

                        final detailSuppliers = _selectedSuppliers.entries
                            .map((e) => {
                                  'purchaseRequestDetailID': e.key,
                                  'supplierID': e.value,
                                })
                            .toList();

                        await _reviewRequest(true, null, detailSuppliers: detailSuppliers);
                      },
                child: _isReviewing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('DUYỆT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
