import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/shared/services/dashboard_service.dart';
import 'package:intl/intl.dart';

class BranchManagerHomeScreen extends StatefulWidget {
  const BranchManagerHomeScreen({super.key});

  @override
  State<BranchManagerHomeScreen> createState() => _BranchManagerHomeScreenState();
}

class _BranchManagerHomeScreenState extends State<BranchManagerHomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final LocalStorageService _storageService = LocalStorageService();

  bool _isLoading = false;
  String _errorMessage = '';
  DashboardSummaryModel? _summary;
  int? _currentUserBranchId;
  String _selectedDateText = '30 ngày qua';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Default: last 30 days
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _loadBranchAndFetchDashboard();
  }

  Future<void> _loadBranchAndFetchDashboard() async {
    setState(() => _isLoading = true);
    try {
      final branchIdStr = await _storageService.getBranchId();
      if (branchIdStr != null) {
        _currentUserBranchId = int.tryParse(branchIdStr);
      }
      await _fetchDashboard();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final summary = await _dashboardService.getDashboardSummary(
        branchId: _currentUserBranchId,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _setDateRange(String preset) {
    final now = DateTime.now();
    setState(() {
      _selectedDateText = preset;
      if (preset == 'Hôm nay') {
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
      } else if (preset == '7 ngày qua') {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      } else if (preset == '30 ngày qua') {
        _startDate = now.subtract(const Duration(days: 30));
        _endDate = now;
      }
    });
    _fetchDashboard();
  }

  String _formatCurrency(double val) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(val);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng quan chi nhánh',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Báo cáo hoạt động chi nhánh hiện tại của bạn',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _fetchDashboard,
                      tooltip: 'Tải lại',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date Presets filter
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Khoảng thời gian báo cáo:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDateText,
                              items: const [
                                DropdownMenuItem(value: 'Hôm nay', child: Text('Hôm nay')),
                                DropdownMenuItem(value: '7 ngày qua', child: Text('7 ngày qua')),
                                DropdownMenuItem(value: '30 ngày qua', child: Text('30 ngày qua')),
                              ],
                              onChanged: (val) {
                                if (val != null) _setDateRange(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
                        IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: _fetchDashboard)
                      ],
                    ),
                  ),

                if (_isLoading)
                  const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_summary != null) ...[
                  // Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricCard(
                        title: 'Doanh thu chi nhánh',
                        value: _formatCurrency(_summary!.totalRevenue),
                        icon: Icons.monetization_on,
                        color: Colors.green,
                      ),
                      _buildMetricCard(
                        title: 'Lợi nhuận chi nhánh',
                        value: _formatCurrency(_summary!.estimatedProfit),
                        icon: Icons.trending_up,
                        color: Colors.teal,
                      ),
                      _buildMetricCard(
                        title: 'Chi phí nhập hàng',
                        value: _formatCurrency(_summary!.totalPurchaseExpense),
                        icon: Icons.shopping_cart,
                        color: Colors.red,
                      ),
                      _buildMetricCard(
                        title: 'Đơn hàng bán ra',
                        value: _summary!.totalSalesCount.toString(),
                        icon: Icons.assignment,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Low stock warnings
                  _buildSectionTitle(theme, 'Cảnh báo tồn kho thấp (${_summary!.lowStockMedicines.length})'),
                  const SizedBox(height: 10),
                  _summary!.lowStockMedicines.isEmpty
                      ? _buildEmptyState('Không có thuốc nào cảnh báo.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _summary!.lowStockMedicines.length,
                          itemBuilder: (context, idx) {
                            final item = _summary!.lowStockMedicines[idx];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.amber[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: Colors.amber[50],
                              child: ListTile(
                                leading: Icon(Icons.warning, color: Colors.amber[700]),
                                title: Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Kho chi nhánh của bạn'),
                                trailing: Text(
                                  'Còn lại: ${item.quantityInStock} (Min: ${item.reorderLevel})',
                                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),

                  // Expiring batches warnings
                  _buildSectionTitle(theme, 'Lô hàng sắp hết hạn (${_summary!.expiringBatches.length})'),
                  const SizedBox(height: 10),
                  _summary!.expiringBatches.isEmpty
                      ? _buildEmptyState('Không có lô hàng nào sắp hết hạn.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _summary!.expiringBatches.length,
                          itemBuilder: (context, idx) {
                            final batch = _summary!.expiringBatches[idx];
                            final expiryDateStr = DateFormat('dd/MM/yyyy').format(DateTime.parse(batch.expiryDate));
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.red[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: Colors.red[50],
                              child: ListTile(
                                leading: Icon(Icons.hourglass_bottom, color: Colors.red[700]),
                                title: Text('${batch.medicineName} (${batch.batchNumber})',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Hạn dùng: $expiryDateStr'),
                                trailing: Text(
                                  'Còn ${batch.daysUntilExpiry} ngày',
                                  style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),

                  // Top selling medicines
                  _buildSectionTitle(theme, 'Thuốc bán chạy tại chi nhánh'),
                  const SizedBox(height: 10),
                  _summary!.topSellingMedicines.isEmpty
                      ? _buildEmptyState('Chưa có số liệu thuốc bán chạy.')
                      : Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _summary!.topSellingMedicines.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final ts = _summary!.topSellingMedicines[idx];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  child: Text((idx + 1).toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                ),
                                title: Text(ts.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Phân loại: ${ts.categoryName ?? "Chưa rõ"}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Đã bán: ${ts.totalQuantitySold}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_formatCurrency(ts.totalRevenueGenerated),
                                        style: TextStyle(color: Colors.green[700], fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[100]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}
