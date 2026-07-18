import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_dashboard.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/dashboard_kpi_card.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/dashboard_section.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/dashboard_low_stock_row.dart';

class DashboardBody extends StatelessWidget {
  final BranchDashboard dashboard;
  final NumberFormat moneyFormat;
  final DateFormat dateFormat;

  const DashboardBody({
    super.key,
    required this.dashboard,
    required this.moneyFormat,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSalesSection(),
        const SizedBox(height: 16),
        _buildInventorySection(),
        const SizedBox(height: 16),
        _buildLowStockSection(),
        const SizedBox(height: 16),
        _buildPendingOrdersTile(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dashboard.branchName.isEmpty ? 'Chi nhánh' : dashboard.branchName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cập nhật lúc ${dateFormat.format(dashboard.generatedAt.toLocal())}',
          style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSalesSection() {
    final s = dashboard.sales;
    return DashboardSection(
      title: 'Doanh thu',
      icon: Icons.payments_outlined,
      iconColor: const Color(0xFF00C48C),
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.today_outlined,
                label: 'Hôm nay',
                value: moneyFormat.format(s.todayRevenue),
                subtitle: '${s.todayInvoices} hóa đơn',
                accent: const Color(0xFF00C48C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.calendar_view_week_outlined,
                label: 'Tuần này',
                value: moneyFormat.format(s.weekRevenue),
                accent: const Color(0xFF60ABFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.calendar_month_outlined,
                label: 'Tháng này',
                value: moneyFormat.format(s.monthRevenue),
                accent: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.hourglass_top_outlined,
                label: 'Chờ xử lý',
                value: '${s.pendingInvoices}',
                subtitle: 'hóa đơn chưa hoàn tất',
                accent: const Color(0xFFFFB74D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventorySection() {
    final i = dashboard.inventory;
    return DashboardSection(
      title: 'Tồn kho',
      icon: Icons.inventory_2_outlined,
      iconColor: const Color(0xFF60ABFF),
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardKpiCard(
                icon: Icons.category_outlined,
                label: 'Số SKU',
                value: '${i.totalSkus}',
                accent: const Color(0xFF60ABFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BatchInfoCard(
                totalBatches: i.totalBatches,
                nearExpiryBatches: i.nearExpiryBatches,
                expiredBatches: i.expiredBatches,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DashboardKpiCard(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Giá trị tồn kho',
          value: moneyFormat.format(i.totalStockValue),
          accent: const Color(0xFF00C48C),
        ),
      ],
    );
  }

  Widget _buildLowStockSection() {
    final items = dashboard.lowStockMedicines;
    return DashboardSection(
      title: 'Thuốc sắp hết',
      icon: Icons.warning_amber_outlined,
      iconColor: const Color(0xFFFF7070),
      trailing: Text(
        '${items.length}',
        style: const TextStyle(
          color: Color(0xFFFF7070),
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111F38),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Color(0xFF00C48C), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kho đang ổn, không có thuốc sắp hết.',
                    style: TextStyle(color: Color(0xFFB7CDE5), fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DashboardLowStockRow(item: m),
              )),
      ],
    );
  }

  Widget _buildPendingOrdersTile(BuildContext context) {
    final n = dashboard.pendingPurchaseOrders;
    return Material(
      color: const Color(0xFF111F38),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: n == 0
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Có $n yêu cầu mua hàng đang chờ.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(15)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D).withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: Color(0xFFFFB74D), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Yêu cầu mua hàng đang chờ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$n',
                style: const TextStyle(
                  color: Color(0xFFFFB74D),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchInfoCard extends StatelessWidget {
  final int totalBatches;
  final int nearExpiryBatches;
  final int expiredBatches;

  const _BatchInfoCard({
    required this.totalBatches,
    required this.nearExpiryBatches,
    required this.expiredBatches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D).withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.layers_outlined,
                    color: Color(0xFFFFB74D), size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lô hàng',
                  style: TextStyle(
                    color: Color(0xFF8FA8C9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$totalBatches',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$nearExpiryBatches sắp hết hạn',
            style: const TextStyle(color: Color(0xFFFFB74D), fontSize: 11),
          ),
          Text(
            '$expiredBatches đã hết hạn',
            style: const TextStyle(color: Color(0xFFFF7070), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
