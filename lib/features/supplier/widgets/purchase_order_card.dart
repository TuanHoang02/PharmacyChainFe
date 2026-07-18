import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_summary.dart';

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrderSummary order;
  final VoidCallback onTap;

  const PurchaseOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  static final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111F38),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(15)),
          ),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(label: order.orderStatusLabel),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.store_outlined,
                      size: 16, color: Color(0xFF8FA8C9)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.branchName,
                      style: const TextStyle(
                        color: Color(0xFFB7CDE5),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.event_outlined,
                      size: 16, color: Color(0xFF8FA8C9)),
                  const SizedBox(width: 6),
                  Text(
                    'Ngày đặt: ${_dateFormat.format(order.orderDate)}',
                    style: const TextStyle(
                      color: Color(0xFFB7CDE5),
                      fontSize: 12,
                    ),
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
                      style: const TextStyle(
                        color: Color(0xFFB7CDE5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0x33FFFFFF), height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _moneyFormat.format(order.totalAmount),
                    style: const TextStyle(
                      color: Color(0xFF00C48C),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    order.deliveryStatusLabel,
                    style: const TextStyle(
                      color: Color(0xFF7E92AD),
                      fontSize: 12,
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
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  (Color, Color) _statusColors(String label) {
    switch (label) {
      case 'Chờ xác nhận':
        return (const Color(0xFFFFB74D).withAlpha(40), const Color(0xFFFFB74D));
      case 'Đã chấp nhận':
        return (const Color(0xFF60ABFF).withAlpha(40), const Color(0xFF60ABFF));
      case 'Bị từ chối':
        return (const Color(0xFFFF7070).withAlpha(40), const Color(0xFFFF7070));
      case 'Hoàn thành':
        return (const Color(0xFF00C48C).withAlpha(40), const Color(0xFF00C48C));
      case 'Đã hủy':
        return (Colors.white.withAlpha(20), const Color(0xFFB7CDE5));
      default:
        return (Colors.white.withAlpha(15), const Color(0xFFB7CDE5));
    }
  }
}
