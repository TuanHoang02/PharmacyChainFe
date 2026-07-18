import 'package:flutter/material.dart';

import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_dashboard.dart';

class DashboardLowStockRow extends StatelessWidget {
  final LowStockMedicine item;

  const DashboardLowStockRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medication_outlined,
            color: Color(0xFFFF9090),
            size: 20,
          ),
          const SizedBox(width: 10),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Ngưỡng đặt lại: ${item.reorderLevel}${item.unit == null ? '' : ' ${item.unit}'}',
                  style: const TextStyle(
                    color: Color(0xFF8FA8C9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7070).withAlpha(35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${item.currentStock}${item.unit == null ? '' : ' ${item.unit}'}',
              style: const TextStyle(
                color: Color(0xFFFF7070),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
