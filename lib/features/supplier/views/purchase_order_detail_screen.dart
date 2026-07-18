import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_detail.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/purchase_order_service.dart';
import 'package:pharmacy_chain_fe/features/supplier/widgets/rejection_reason_dialog.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const PurchaseOrderDetailScreen({super.key, required this.orderId});

  @override
  State<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  final PurchaseOrderService _service = PurchaseOrderService();

  PurchaseOrderDetail? _order;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

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
      final detail = await _service.getOrderDetail(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = detail;
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
    return raw.startsWith('Exception: ')
        ? raw.substring('Exception: '.length)
        : raw;
  }

  Future<void> _showAcceptDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1B30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận chấp nhận',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn chấp nhận đơn mua này không?',
          style: TextStyle(color: Color(0xFFB7CDE5), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFFB7CDE5), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C48C),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _runAction(_service.acceptOrder(widget.orderId), success: 'Đơn mua đã được chấp nhận.');
    }
  }

  Future<void> _showRejectDialog() async {
    final reason = await RejectionReasonDialog.show(context);
    if (reason == null || reason.isEmpty) return;
    await _runAction(
      _service.rejectOrder(widget.orderId, reason),
      success: 'Đơn mua đã bị từ chối.',
    );
  }

  Future<void> _runAction(
    Future<dynamic> future, {
    required String success,
  }) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await future;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(success)),
            ],
          ),
          backgroundColor: const Color(0xFF00C48C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadDetail();
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn mua',
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
      return _ErrorView(message: _errorMessage!, onRetry: _loadDetail);
    }
    final order = _order;
    if (order == null) {
      return const SizedBox.shrink();
    }
    return RefreshIndicator(
      color: const Color(0xFF00C48C),
      backgroundColor: const Color(0xFF111F38),
      onRefresh: _loadDetail,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _HeaderCard(order: order),
          const SizedBox(height: 16),
          _BranchCard(order: order),
          const SizedBox(height: 16),
          _ItemsCard(order: order),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _NotesCard(notes: order.notes!),
          ],
          const SizedBox(height: 16),
          if (order.orderStatus == 'PendingSupplierConfirmation')
            _ActionBar(
              isSubmitting: _isSubmitting,
              onAccept: _showAcceptDialog,
              onReject: _showRejectDialog,
            )
          else
            _ResponseStatusCard(order: order),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ActionBar({
    required this.isSubmitting,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : onAccept,
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Chấp nhận',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C48C),
                    disabledBackgroundColor: const Color(0xFF00C48C).withAlpha(120),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : onReject,
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Từ chối',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7070),
                    disabledBackgroundColor: const Color(0xFFFF7070).withAlpha(120),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isSubmitting) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00C48C),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponseStatusCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _ResponseStatusCard({required this.order});

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final isAccepted = order.orderStatus == 'Accepted';
    final accent = isAccepted ? const Color(0xFF00C48C) : const Color(0xFFFF7070);
    final icon = isAccepted ? Icons.check_circle_outline : Icons.cancel_outlined;
    final label = isAccepted ? 'Đơn mua đã được chấp nhận.' : 'Đơn mua đã bị từ chối.';
    return Container(
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
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (order.confirmedAt != null) ...[
            const SizedBox(height: 10),
            Text(
              'Thời điểm phản hồi: ${_dateFormat.format(order.confirmedAt!.toLocal())}',
              style: const TextStyle(color: Color(0xFFB7CDE5), fontSize: 13),
            ),
          ],
          if (!isAccepted && order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Lý do: ${order.notes}',
              style: const TextStyle(color: Color(0xFFFF9090), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _HeaderCard({required this.order});

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.purchaseOrderCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusBadge(
                label: order.orderStatusLabel,
                color: const Color(0xFF60ABFF),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 16, color: Color(0xFF8FA8C9)),
              const SizedBox(width: 6),
              Text(
                'Ngày đặt: ${_dateFormat.format(order.orderDate)}',
                style: const TextStyle(color: Color(0xFFB7CDE5), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 16, color: Color(0xFF8FA8C9)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.expectedDeliveryDate != null
                      ? 'Dự kiến giao: ${_dateFormat.format(order.expectedDeliveryDate!)}'
                      : 'Chưa có ngày giao dự kiến',
                  style: const TextStyle(color: Color(0xFFB7CDE5), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.assignment_outlined,
                  size: 16, color: Color(0xFF8FA8C9)),
              const SizedBox(width: 6),
              Text(
                'Trạng thái giao: ${order.deliveryStatusLabel}',
                style: const TextStyle(color: Color(0xFFB7CDE5), fontSize: 13),
              ),
            ],
          ),
          if (order.createdByFullName != null &&
              order.createdByFullName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: Color(0xFF8FA8C9)),
                const SizedBox(width: 6),
                Text(
                  'Người tạo: ${order.createdByFullName}',
                  style: const TextStyle(
                    color: Color(0xFFB7CDE5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const Divider(color: Color(0x33FFFFFF), height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền',
                style: TextStyle(
                  color: Color(0xFF8FA8C9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _moneyFormat.format(order.totalAmount),
                style: const TextStyle(
                  color: Color(0xFF00C48C),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _BranchCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chi nhánh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.store, size: 16, color: Color(0xFF60ABFF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.branchName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF8FA8C9)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.branchAddress,
                  style: const TextStyle(
                    color: Color(0xFFB7CDE5),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (order.branchPhoneNumber != null &&
              order.branchPhoneNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 16, color: Color(0xFF8FA8C9)),
                const SizedBox(width: 8),
                Text(
                  order.branchPhoneNumber!,
                  style: const TextStyle(
                    color: Color(0xFFB7CDE5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _ItemsCard({required this.order});

  static final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Danh sách thuốc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${order.items.length} mặt hàng',
                style: const TextStyle(
                  color: Color(0xFF8FA8C9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: idx == 0
                    ? null
                    : const Border(
                        top: BorderSide(color: Color(0x22FFFFFF)),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.medicineName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SL: ${item.orderedQuantity}'
                          '${item.unit != null ? ' ${item.unit}' : ''}'
                          ' × ${_moneyFormat.format(item.unitPrice)}',
                          style: const TextStyle(
                            color: Color(0xFF8FA8C9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _moneyFormat.format(item.lineTotal),
                    style: const TextStyle(
                      color: Color(0xFF00C48C),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sticky_note_2_outlined,
                  color: Color(0xFFFFB74D), size: 18),
              SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notes,
            style: const TextStyle(
              color: Color(0xFFB7CDE5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF111F38),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withAlpha(15)),
  );
}
