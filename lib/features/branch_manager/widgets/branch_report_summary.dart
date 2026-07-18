import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_report.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/dashboard_kpi_card.dart';

class BranchReportSummary extends StatelessWidget {
  final BranchReport report;

  const BranchReportSummary({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final isSales = report.reportType == 'Sales';
    final moneyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);

    if (isSales) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardKpiCard(
                  icon: Icons.receipt_long,
                  label: 'Tổng đơn hàng',
                  value: NumberFormat.compact().format(report.summary.totalOrders),
                  accent: const Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardKpiCard(
                  icon: Icons.payments,
                  label: 'Tổng doanh thu',
                  value: moneyFormat.format(report.summary.totalRevenue),
                  subtitle: 'VND',
                  accent: const Color(0xFF43A047),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DashboardKpiCard(
                  icon: Icons.shopping_bag,
                  label: 'Sản phẩm bán ra',
                  value: NumberFormat.compact().format(report.summary.totalItemsSold),
                  accent: const Color(0xFFFF7043),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardKpiCard(
                  icon: Icons.trending_up,
                  label: 'TB / đơn',
                  value: moneyFormat.format(report.summary.averageOrderValue),
                  subtitle: 'VND',
                  accent: const Color(0xFFAB47BC),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.inventory_2,
                label: 'Tổng SKU',
                value: NumberFormat.compact().format(report.summary.totalSkus),
                accent: const Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.account_balance_wallet,
                label: 'Giá trị tồn kho',
                value: moneyFormat.format(report.summary.totalStockValue),
                subtitle: 'VND',
                accent: const Color(0xFF43A047),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.warning_amber,
                label: 'Sắp hết hàng',
                value: report.summary.lowStockCount.toString(),
                accent: const Color(0xFFFF7043),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.timer,
                label: 'Sắp hết hạn',
                value: report.summary.nearExpiryCount.toString(),
                accent: const Color(0xFFFFA726),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.event_busy,
                label: 'Đã hết hạn',
                value: report.summary.expiredCount.toString(),
                accent: const Color(0xFFEF5350),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}
