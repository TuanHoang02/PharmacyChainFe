import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/models/branch_performance_model.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/branch_performance_service.dart';

class BranchPerformanceScreen extends StatefulWidget {
  const BranchPerformanceScreen({super.key});

  @override
  State<BranchPerformanceScreen> createState() =>
      _BranchPerformanceScreenState();
}

class _BranchPerformanceScreenState extends State<BranchPerformanceScreen> {
  final BranchPerformanceService _service = BranchPerformanceService();

  BranchPerformanceDto? _data;
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'Custom'];
  final Map<String, String> _periodLabels = {
    'Today': 'Hôm nay',
    'This Week': 'Tuần này',
    'This Month': 'Tháng này',
    'Custom': 'Tùy chỉnh',
  };

  // Using branch name for simplicity, in a real app this would be a Branch object with ID
  String _selectedBranch = 'All Branches';
  final List<String> _branches = ['All Branches'];

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Default 7 days ago to today for Custom
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // In a real app we'd map branch name to ID, but backend service uses null for All Branches
      // For this MVP, if it's "All Branches", we send null.
      // If we had a list of branch objects, we'd find the ID.
      // Since backend BranchPerformanceService handles branchId, and we don't have an easy way
      // to map name to ID without another API call, we'll just fetch all and aggregate locally
      // or rely on backend. I'll just fetch 'All' from backend.

      final data = await _service.getPerformanceData(
        period: _selectedPeriod,
        startDate: _selectedPeriod == 'Custom' ? _startDate : null,
        endDate: _selectedPeriod == 'Custom' ? _endDate : null,
      );

      setState(() {
        _data = data;
        _isLoading = false;

        // Update branches list from ranking data
        if (_branches.length == 1) {
          _branches.addAll(
            data.branchRanking.map((e) => e.branchName).toList(),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // A local filter just to update UI based on selected branch if we fetched 'All'
  BranchPerformanceDto get _displayData {
    if (_data == null)
      return BranchPerformanceDto(
        totalSales: 0,
        totalInvoices: 0,
        lowStockMedicines: 0,
        branchRanking: [],
      );

    if (_selectedBranch == 'All Branches') return _data!;

    // Find branch specific data
    var b = _data!.branchRanking.firstWhere(
      (element) => element.branchName == _selectedBranch,
      orElse: () => BranchRankingDto(
        rank: 0,
        branchName: '',
        totalSales: 0,
        totalInvoices: 0,
        lowStockMedicines: 0,
      ),
    );

    return BranchPerformanceDto(
      totalSales: b.totalSales,
      totalInvoices: b.totalInvoices,
      lowStockMedicines: b.lowStockMedicines,
      branchRanking: _data!.branchRanking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Theo dõi hiệu suất chi nhánh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $_errorMessage'),
            ElevatedButton(onPressed: _fetchData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_data == null || _data!.branchRanking.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy dữ liệu hiệu suất cho tiêu chí đã chọn.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            _buildKpiCards(),
            const SizedBox(height: 16),
            _buildRankingTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi nhánh',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedBranch,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: _branches.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.business,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    value == 'All Branches'
                                        ? 'Tất cả chi nhánh'
                                        : value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedBranch = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPeriod,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: _periods.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _periodLabels[value] ?? value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPeriod = newValue!;
                            _fetchData(); // Fetch new data from backend when period changes
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_selectedPeriod == 'Custom') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Từ ngày',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _startDate ??
                              DateTime.now().subtract(const Duration(days: 7)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            // Automatically adjust end date if start date is after end date
                            if (_endDate != null &&
                                _startDate!.isAfter(_endDate!)) {
                              _endDate = _startDate;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ngày kết thúc đã được tự động điều chỉnh',
                                  ),
                                ),
                              );
                            }
                            _fetchData();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Chọn ngày',
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đến ngày',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                            // Automatically adjust start date if end date is before start date
                            if (_startDate != null &&
                                _endDate!.isBefore(_startDate!)) {
                              _startDate = _endDate;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ngày bắt đầu đã được tự động điều chỉnh',
                                  ),
                                ),
                              );
                            }
                            _fetchData();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Chọn ngày',
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildKpiCards() {
    final d = _displayData;
    return Column(
      children: [
        Row(
          children: [
            _buildKpiCard(
              'Tổng doanh thu',
              NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(d.totalSales),
              Icons.attach_money,
              true,
            ),
            const SizedBox(width: 16),
            _buildKpiCard(
              'Số lượng hóa đơn',
              '${d.totalInvoices}',
              Icons.receipt_long,
              true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildKpiCard(
              'Thuốc sắp hết hàng',
              '${d.lowStockMedicines}',
              Icons.inventory_2_outlined,
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    bool isPositiveTrend,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.grey.shade700),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Xếp hạng hiệu suất chi nhánh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.download,
                    size: 16,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Xuất file',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.grey.shade50,
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Chi nhánh',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tổng doanh thu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Số lượng\nhóa đơn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sắp\nhết hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                rows: _displayData.branchRanking.map((branch) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            '${branch.rank}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          branch.branchName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(branch.totalSales),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          branch.totalInvoices.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          branch.lowStockMedicines.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
