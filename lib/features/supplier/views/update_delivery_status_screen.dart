import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_detail.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/purchase_order_service.dart';

class UpdateDeliveryStatusScreen extends StatefulWidget {
  final int orderId;

  const UpdateDeliveryStatusScreen({super.key, required this.orderId});

  @override
  State<UpdateDeliveryStatusScreen> createState() => _UpdateDeliveryStatusScreenState();
}

class _UpdateDeliveryStatusScreenState extends State<UpdateDeliveryStatusScreen> {
  final PurchaseOrderService _service = PurchaseOrderService();
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PurchaseOrderDetail? _order;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _selectedStatus;

  List<Map<String, String>> _getFilteredStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case 'NotStarted':
        return [
          {'value': 'Preparing', 'label': 'Đang chuẩn bị'},
          {'value': 'Shipping', 'label': 'Đang vận chuyển'},
          {'value': 'Delivered', 'label': 'Đã giao'},
        ];
      case 'Preparing':
        return [
          {'value': 'Shipping', 'label': 'Đang vận chuyển'},
          {'value': 'Delivered', 'label': 'Đã giao'},
        ];
      case 'Shipping':
        return [
          {'value': 'Delivered', 'label': 'Đã giao'},
        ];
      default:
        return [];
    }
  }

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
    _noteController.addListener(_onNoteChanged);
  }

  @override
  void dispose() {
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    setState(() {});
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _service.getPurchaseOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = detail;
        _noteController.text = detail.supplierResponseNote ?? '';
        // Pre-select the next logical delivery status
        final options = _getFilteredStatusOptions(detail.deliveryStatus);
        if (options.isNotEmpty) {
          _selectedStatus = options.first['value'];
        } else {
          _selectedStatus = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    return raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
  }

  Future<void> _submitUpdate() async {
    if (_selectedStatus == null || _isSubmitting) return;
    if (_noteController.text.length > 255) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _service.updateDeliveryStatus(
        widget.orderId,
        _selectedStatus!,
        _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Cập nhật trạng thái giao hàng thành công.')),
            ],
          ),
          backgroundColor: const Color(0xFF00C48C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_friendlyError(e))),
            ],
          ),
          backgroundColor: const Color(0xFFFF7070),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
          'Cập nhật giao hàng',
          style: TextStyle(fontWeight: FontWeight.w700),
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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C48C)),
      );
    }

    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadOrderDetail);
    }

    final order = _order;
    if (order == null) {
      return const Center(
        child: Text(
          'Không tìm thấy thông tin đơn mua.',
          style: TextStyle(color: Color(0xFFB7CDE5), fontSize: 14),
        ),
      );
    }

    final isNoteTooLong = _noteController.text.length > 255;
    final isAllowedToUpdate = order.orderStatus == 'Accepted' && order.deliveryStatus != 'Delivered' && order.deliveryStatus != 'Received';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order details summary card
            Container(
              padding: const EdgeInsets.all(18),
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
                      Text(
                        order.purchaseOrderCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF60ABFF).withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.orderStatusLabel,
                          style: const TextStyle(
                            color: Color(0xFF60ABFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0x33FFFFFF), height: 24),
                  _buildDetailRow(Icons.store, 'Chi nhánh', order.branchName),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.location_on_outlined, 'Địa chỉ', order.branchAddress),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    Icons.monetization_on_outlined,
                    'Tổng tiền',
                    _moneyFormat.format(order.totalAmount),
                    valueColor: const Color(0xFF00C48C),
                    valueWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.local_shipping_outlined, 'Trạng thái hiện tại', order.deliveryStatusLabel),
                  if (order.deliveredAt != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.event_available_outlined,
                      'Thời điểm giao hàng',
                      _dateFormat.format(order.deliveredAt!.toLocal()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dropdown selector for status
            const Text(
              'Trạng thái giao hàng mới',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              dropdownColor: const Color(0xFF111F38),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF111F38),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF7070)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF7070)),
                ),
              ),
              hint: const Text(
                'Chọn trạng thái giao hàng',
                style: TextStyle(color: Color(0xFF7E92AD), fontSize: 14),
              ),
              items: _getFilteredStatusOptions(order.deliveryStatus).map((opt) {
                return DropdownMenuItem<String>(
                  value: opt['value'],
                  child: Text(opt['label']!),
                );
              }).toList(),
              onChanged: _isSubmitting || !isAllowedToUpdate
                  ? null
                  : (val) {
                      setState(() {
                        _selectedStatus = val;
                      });
                    },
              validator: (val) => val == null ? 'Vui lòng chọn trạng thái giao hàng' : null,
            ),
            const SizedBox(height: 20),

            // Note TextField
            const Text(
              'Ghi chú phản hồi',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 255,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              enabled: !_isSubmitting && isAllowedToUpdate,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength / $maxLength ký tự',
                  style: TextStyle(
                    color: isNoteTooLong ? const Color(0xFFFF7070) : const Color(0xFF7E92AD),
                    fontSize: 12,
                  ),
                );
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF111F38),
                hintText: 'Nhập ghi chú phản hồi của nhà cung cấp...',
                hintStyle: const TextStyle(color: Color(0xFF7E92AD), fontSize: 14),
                contentPadding: const EdgeInsets.all(16),
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha(10)),
                ),
              ),
            ),
            if (isNoteTooLong) ...[
              const SizedBox(height: 6),
              const Text(
                'Ghi chú không được vượt quá 255 ký tự.',
                style: TextStyle(color: Color(0xFFFF7070), fontSize: 12),
              ),
            ],
            const SizedBox(height: 32),

            // Submit button
            if (isAllowedToUpdate)
              ElevatedButton(
                onPressed: _selectedStatus == null || _isSubmitting || isNoteTooLong ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C48C),
                  disabledBackgroundColor: const Color(0xFF00C48C).withAlpha(120),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Cập nhật',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7070).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF7070).withAlpha(60)),
                ),
                child: const Text(
                  'Đơn mua này không ở trạng thái cho phép cập nhật giao hàng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFFF7070), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
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
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 13, fontWeight: FontWeight.w500),
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Color(0xFFFF7070), size: 48),
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
