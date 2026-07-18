import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/medicine_batch_detail.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/medicine_batch_service.dart';

class MedicineBatchDetailScreen extends StatefulWidget {
  final int batchId;

  const MedicineBatchDetailScreen({super.key, required this.batchId});

  @override
  State<MedicineBatchDetailScreen> createState() => _MedicineBatchDetailScreenState();
}

class _MedicineBatchDetailScreenState extends State<MedicineBatchDetailScreen> {
  final MedicineBatchService _batchService = MedicineBatchService();
  MedicineBatchDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateOnlyFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _batchService.getMedicineBatchById(widget.batchId);
      if (!mounted) return;
      setState(() {
        _detail = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text(
          'Chi tiết lô thuốc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A1628),
        foregroundColor: Colors.white,
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
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
                onPressed: _loadDetail,
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

    final detail = _detail;
    if (detail == null) {
      return const Center(
        child: Text(
          'Không tìm thấy thông tin lô thuốc.',
          style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 14),
        ),
      );
    }

    final isExpired = DateTime.now().isAfter(detail.expiryDate);
    final isNearExpiry = !isExpired && detail.expiryDate.difference(DateTime.now()).inDays < 90;

    Color warningColor = Colors.transparent;
    String warningText = '';
    if (isExpired) {
      warningColor = const Color(0xFFFF7070);
      warningText = 'Lô thuốc này đã HẾT HẠN sử dụng!';
    } else if (isNearExpiry) {
      warningColor = const Color(0xFFFFB03A);
      warningText = 'Lô thuốc này sắp hết hạn sử dụng (dưới 90 ngày)!';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Warning Banner
          if (warningText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: warningColor.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: warningColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      warningText,
                      style: TextStyle(
                        color: warningColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Batch Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111F38),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Số lô: ${detail.batchNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0x33FFFFFF), height: 32),

                _buildDetailRow(Icons.medication_outlined, 'Thuốc', detail.medicineName),
                const SizedBox(height: 14),
                _buildDetailRow(Icons.local_shipping_outlined, 'Nhà cung cấp', detail.supplierName),
                const SizedBox(height: 14),
                _buildDetailRow(Icons.store, 'Chi nhánh nhận', detail.branchName),
                const SizedBox(height: 14),
                _buildDetailRow(Icons.receipt_long_outlined, 'Mã đơn mua', detail.purchaseOrderCode),
                const SizedBox(height: 14),
                _buildDetailRow(
                  Icons.production_quantity_limits,
                  'Số lượng nhận',
                  '${detail.receivedQuantity}',
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  Icons.inventory_2_outlined,
                  'Số lượng còn lại',
                  '${detail.remainingQuantity}',
                  valueColor: detail.remainingQuantity == 0
                      ? const Color(0xFFFF7070)
                      : const Color(0xFF00C48C),
                  valueWeight: FontWeight.bold,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  Icons.date_range,
                  'Ngày sản xuất (NSX)',
                  _dateOnlyFormat.format(detail.manufacturingDate),
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  Icons.event,
                  'Ngày hết hạn (HSD)',
                  _dateOnlyFormat.format(detail.expiryDate),
                  valueColor: warningColor == Colors.transparent ? Colors.white : warningColor,
                  valueWeight: warningColor == Colors.transparent ? FontWeight.normal : FontWeight.bold,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  Icons.access_time,
                  'Ngày tạo trên hệ thống',
                  _dateFormat.format(detail.createdAt.toLocal()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8FA8C9)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF8FA8C9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: valueWeight ?? FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
