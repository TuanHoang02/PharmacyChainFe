import 'package:flutter/material.dart';

class BranchReportFilters extends StatelessWidget {
  final String selectedType;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final VoidCallback onGenerate;
  final bool isLoading;

  const BranchReportFilters({
    super.key,
    required this.selectedType,
    required this.startDate,
    required this.endDate,
    required this.onTypeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onGenerate,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(context),
          const SizedBox(height: 12),
          _buildDateRow(context),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Tạo báo cáo',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A1628),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8FA8C9)),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: const [
            DropdownMenuItem(value: 'Sales', child: Text('Sales Report')),
            DropdownMenuItem(value: 'Inventory', child: Text('Inventory Report')),
          ],
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    if (selectedType == 'Inventory') return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(child: _buildDatePicker(context, startDate, onStartDateChanged, 'Từ ngày')),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, color: Color(0xFF8FA8C9), size: 18),
        const SizedBox(width: 8),
        Expanded(child: _buildDatePicker(context, endDate, onEndDateChanged, 'Đến ngày')),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    DateTime date,
    ValueChanged<DateTime> onChanged,
    String label,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF1E88E5),
                  surface: Color(0xFF111F38),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E3A5F)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF8FA8C9), size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _formatDate(date),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
