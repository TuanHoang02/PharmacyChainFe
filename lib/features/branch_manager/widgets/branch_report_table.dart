import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_report.dart';

class BranchReportTable extends StatelessWidget {
  final BranchReport report;

  const BranchReportTable({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final isSales = report.reportType == 'Sales';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final moneyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);

    if (isSales) {
      return _buildSalesTable(report.salesDetails, dateFormat, moneyFormat);
    }
    return _buildInventoryTable(report.inventoryDetails, moneyFormat);
  }

  Widget _buildSalesTable(List<SalesReportDetail> details, DateFormat dateFormat, NumberFormat moneyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableHeader([
          'Mã HD',
          'Ngày',
          'Khách hàng',
          'SL',
          'Tổng tiền',
        ]),
        ...details.map((d) => _buildSalesRow(d, dateFormat, moneyFormat)),
      ],
    );
  }

  Widget _buildSalesRow(SalesReportDetail d, DateFormat dateFormat, NumberFormat moneyFormat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E3A5F), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              d.invoiceCode,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dateFormat.format(d.invoiceDate.toLocal()),
              style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              d.customerName ?? 'Khách lẻ',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              d.totalItems.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              moneyFormat.format(d.totalAmount),
              style: const TextStyle(color: Color(0xFF43A047), fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable(List<InventoryReportDetail> details, NumberFormat moneyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableHeader([
          'Thuốc',
          'Tồn kho',
          'Giá bán',
          'Giá trị',
          'Trạng thái',
        ]),
        ...details.map((d) => _buildInventoryRow(d, moneyFormat)),
      ],
    );
  }

  Widget _buildInventoryRow(InventoryReportDetail d, NumberFormat moneyFormat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E3A5F), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              d.medicineName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              '${d.quantityInStock}${d.unit ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              moneyFormat.format(d.sellingPrice),
              style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              moneyFormat.format(d.stockValue),
              style: const TextStyle(color: Color(0xFF43A047), fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(d.stockStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Out of Stock':
        color = const Color(0xFFEF5350);
        break;
      case 'Low Stock':
        color = const Color(0xFFFF7043);
        break;
      case 'Medium Stock':
        color = const Color(0xFFFFA726);
        break;
      default:
        color = const Color(0xFF43A047);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableHeader(List<String> columns) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: columns
            .map((col) => Expanded(
                  flex: columns.indexOf(col) == 1 ? 1 : 2,
                  child: Text(
                    col,
                    style: const TextStyle(
                      color: Color(0xFF8FA8C9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
