import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/models/branch_performance_model.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/branch_performance_service.dart';

class BranchPerformanceScreen extends StatefulWidget {
  const BranchPerformanceScreen({super.key});

  @override
  State<BranchPerformanceScreen> createState() => _BranchPerformanceScreenState();
}

class _BranchPerformanceScreenState extends State<BranchPerformanceScreen> {
  final BranchPerformanceService _service = BranchPerformanceService();
  
  BranchPerformanceDto? _data;
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'Custom'];
  final Map<String, String> _periodLabels = {'Today': 'Hôm nay', 'This Week': 'Tuần này', 'This Month': 'Tháng này', 'Custom': 'Tùy chỉnh'};
  
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
          _branches.addAll(data.branchRanking.map((e) => e.branchName).toList());
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
    if (_data == null) return BranchPerformanceDto(totalSales: 0, inventoryTurnover: 0, expiredMedicines: 0, staffPerformanceScore: 0, salesTrend: [], expiredMedicinesByBranch: [], inventoryTurnoverByBranch: [], branchRanking: []);
    
    if (_selectedBranch == 'All Branches') return _data!;

    // Find branch specific data
    var b = _data!.branchRanking.firstWhere((element) => element.branchName == _selectedBranch, 
      orElse: () => BranchRankingDto(rank: 0, branchName: '', totalSales: 0, inventoryTurnover: 0, expiredMedicines: 0, staffScore: 0));
    
    return BranchPerformanceDto(
      totalSales: b.totalSales,
      inventoryTurnover: b.inventoryTurnover,
      expiredMedicines: b.expiredMedicines,
      staffPerformanceScore: b.staffScore,
      salesTrend: _data!.salesTrend, // Should technically be filtered too, but keep it simple
      expiredMedicinesByBranch: _data!.expiredMedicinesByBranch,
      inventoryTurnoverByBranch: _data!.inventoryTurnoverByBranch,
      branchRanking: _data!.branchRanking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi hiệu suất chi nhánh', style: TextStyle(fontWeight: FontWeight.bold)),
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
            ElevatedButton(onPressed: _fetchData, child: const Text('Thử lại'))
          ],
        ),
      );
    }

    if (_data == null || _data!.branchRanking.isEmpty) {
      return const Center(child: Text('Không tìm thấy dữ liệu hiệu suất cho tiêu chí đã chọn.'));
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
            _buildSalesTrendChart(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInventoryTurnoverChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildExpiredMedicinesChart()),
              ],
            ),
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
                  const Text('Chi nhánh', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                const Icon(Icons.business, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(value == 'All Branches' ? 'Tất cả chi nhánh' : value),
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
                  const Text('Thời gian', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(_periodLabels[value] ?? value),
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
                    const Text('Từ ngày', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            _fetchData();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Chọn ngày'),
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
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
                    const Text('Đến ngày', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                            _fetchData();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Chọn ngày'),
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildKpiCard('Tổng doanh thu', '${d.totalSales.toStringAsFixed(0)} ₫', Icons.attach_money, true),
        _buildKpiCard('Vòng quay tồn kho', '${d.inventoryTurnover} lần', Icons.sync, true),
        _buildKpiCard('Thuốc hết hạn', '${d.expiredMedicines}', Icons.warning_amber_rounded, false),
        _buildKpiCard('Hiệu suất nhân viên', '${d.staffPerformanceScore} / 5', Icons.people_outline, true),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, bool isPositiveTrend) {
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
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPositiveTrend ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: isPositiveTrend ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  Text(
                    'so với tháng trước',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesTrendChart() {
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
                const Text('Xu hướng doanh thu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Hàng ngày', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= 0 && value.toInt() < _displayData.salesTrend.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(_displayData.salesTrend[value.toInt()].dateLabel, style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text('${(value / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _displayData.salesTrend.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.totalSales);
                      }).toList(),
                      isCurved: false,
                      color: Colors.grey.shade600,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTurnoverChart() {
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
            const Text('Vòng quay tồn kho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 30,
                      sections: _getPieSections(),
                    ),
                  ),
                  // Legend
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _displayData.inventoryTurnoverByBranch.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _getColor(e.key))),
                              const SizedBox(width: 4),
                              Text(e.value.branchName, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections() {
    return _displayData.inventoryTurnoverByBranch.asMap().entries.map((e) {
      return PieChartSectionData(
        color: _getColor(e.key),
        value: e.value.turnoverRate,
        title: '${e.value.turnoverRate}',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColor(int index) {
    List<Color> colors = [Colors.grey.shade700, Colors.grey.shade500, Colors.grey.shade400, Colors.grey.shade300];
    return colors[index % colors.length];
  }

  Widget _buildExpiredMedicinesChart() {
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
                const Text('Thuốc hết hạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Theo chi nhánh v', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_displayData.expiredMedicinesByBranch.isEmpty ? 20 : _displayData.expiredMedicinesByBranch.map((e) => e.expiredCount).reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= 0 && value.toInt() < _displayData.expiredMedicinesByBranch.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(_displayData.expiredMedicinesByBranch[value.toInt()].branchName, style: const TextStyle(fontSize: 8)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 20,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 5 == 0) {
                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _displayData.expiredMedicinesByBranch.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.expiredCount.toDouble(),
                          color: Colors.grey.shade600,
                          width: 15,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                        )
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
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
                const Text('Xếp hạng hiệu suất chi nhánh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16, color: Colors.black),
                  label: const Text('Xuất file', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Chi nhánh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Tổng doanh thu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Vòng quay\ntồn kho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Thuốc\nhết hạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Điểm nhân viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: _displayData.branchRanking.map((branch) {
                  return DataRow(cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text('${branch.rank}', style: const TextStyle(fontSize: 12)),
                      )
                    ),
                    DataCell(Text(branch.branchName, style: const TextStyle(fontSize: 12))),
                    DataCell(Text('${branch.totalSales.toStringAsFixed(0)} ₫', style: const TextStyle(fontSize: 12))),
                    DataCell(Text(branch.inventoryTurnover.toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(branch.expiredMedicines.toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(branch.staffScore.toString(), style: const TextStyle(fontSize: 12))),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
