import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/branch_report.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/branch_report_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/branch_report_empty_state.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/branch_report_error_state.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/branch_report_filters.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/branch_report_summary.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/widgets/branch_report_table.dart';

class BranchReportScreen extends StatefulWidget {
  const BranchReportScreen({super.key});

  @override
  State<BranchReportScreen> createState() => _BranchReportScreenState();
}

class _BranchReportScreenState extends State<BranchReportScreen> {
  final BranchReportService _service = BranchReportService();

  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedType = 'Sales';
  BranchReport? _report;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = _selectedType == 'Sales'
          ? await _service.fetchSalesReport(_startDate, _endDate)
          : await _service.fetchInventoryReport();

      setState(() {
        _report = report;
        _hasGenerated = true;
        _isLoading = false;
      });
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = message;
        _isLoading = false;
        _hasGenerated = true;
      });
    }
  }

  Future<void> _retry() async {
    await _generateReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BranchReportFilters(
                      selectedType: _selectedType,
                      startDate: _startDate,
                      endDate: _endDate,
                      isLoading: _isLoading,
                      onTypeChanged: (type) => setState(() => _selectedType = type),
                      onStartDateChanged: (date) => setState(() => _startDate = date),
                      onEndDateChanged: (date) => setState(() => _endDate = date),
                      onGenerate: _generateReport,
                    ),
                    if (_hasGenerated) ...[
                      const SizedBox(height: 20),
                      _buildReportContent(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Báo cáo chi nhánh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Xem báo cáo doanh thu và tồn kho',
            style: TextStyle(
              color: Color(0xFF8FA8C9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_errorMessage != null) {
      return BranchReportErrorState(
        message: _errorMessage!,
        onRetry: _retry,
      );
    }

    if (_report == null) return const SizedBox.shrink();

    if (_report!.isEmpty) {
      return BranchReportEmptyState(onRetry: _retry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReportHeader(),
        const SizedBox(height: 16),
        BranchReportSummary(report: _report!),
        const SizedBox(height: 20),
        _buildTableSection(),
      ],
    );
  }

  Widget _buildReportHeader() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Color(0xFF1E88E5), size: 18),
              const SizedBox(width: 8),
              Text(
                _report!.branchName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetaChip(Icons.bar_chart, _report!.reportType == 'Sales' ? 'Doanh thu' : 'Tồn kho'),
              const SizedBox(width: 8),
              _buildMetaChip(
                Icons.date_range,
                _getDateRangeLabel(dateFormat),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF8FA8C9), size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeLabel(DateFormat dateFormat) {
    if (_report!.reportType == 'Inventory') {
      return 'Toàn bộ tồn kho';
    }
    return '${dateFormat.format(_report!.startDate)} - ${dateFormat.format(_report!.endDate)}';
  }

  Widget _buildTableSection() {
    final isSales = _report!.reportType == 'Sales';
    final count = isSales ? _report!.salesDetails.length : _report!.inventoryDetails.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSales ? Icons.receipt_long : Icons.inventory_2,
              color: const Color(0xFF8FA8C9),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Chi tiết ($count bản ghi)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111F38),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: BranchReportTable(report: _report!),
        ),
      ],
    );
  }
}
