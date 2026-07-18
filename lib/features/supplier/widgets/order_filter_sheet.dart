import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pharmacy_chain_fe/features/supplier/services/purchase_order_service.dart';

class OrderFilterSheet extends StatefulWidget {
  final PurchaseOrderFilter initial;

  const OrderFilterSheet({super.key, required this.initial});

  @override
  State<OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<OrderFilterSheet> {
  static const List<({int value, String label})> _statusOptions = [
    (value: 0, label: 'Chờ xác nhận'),
    (value: 1, label: 'Đã chấp nhận'),
    (value: 2, label: 'Bị từ chối'),
    (value: 3, label: 'Hoàn thành'),
    (value: 4, label: 'Đã hủy'),
  ];

  late DateTime? _startDate;
  late DateTime? _endDate;
  late int? _status;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initial.startDate;
    _endDate = widget.initial.endDate;
    _status = widget.initial.status;
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _validateDates();
      });
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _validateDates();
      });
    }
  }

  void _validateDates() {
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      setState(() {
        _dateError = 'Ngày bắt đầu không được sau ngày kết thúc.';
      });
    } else {
      setState(() {
        _dateError = null;
      });
    }
  }

  void _apply() {
    if (_dateError != null) return;
    Navigator.of(context).pop(
      widget.initial.copyWith(
        startDate: _startDate,
        clearStartDate: _startDate == null,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        status: _status,
        clearStatus: _status == null,
      ),
    );
  }

  void _clear() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _status = null;
      _dateError = null;
    });
    Navigator.of(context).pop(const PurchaseOrderFilter());
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1B30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bộ lọc đơn mua',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _DateField(
                label: 'Từ ngày',
                value: _startDate,
                onTap: _pickStart,
                error: _dateError,
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'Đến ngày',
                value: _endDate,
                onTap: _pickEnd,
                error: _dateError,
              ),
              if (_dateError != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7070).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF7070).withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFFF7070), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateError!,
                          style: const TextStyle(
                            color: Color(0xFFFF9090),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trạng thái đơn',
                  style: TextStyle(
                    color: Color(0xFFB7CDE5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statusOptions.map((opt) {
                  final selected = _status == opt.value;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(opt.label),
                    onSelected: (_) {
                      setState(() {
                        _status = selected ? null : opt.value;
                      });
                    },
                    selectedColor: const Color(0xFF1E88E5),
                    backgroundColor: Colors.white.withAlpha(10),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFB7CDE5),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF1E88E5)
                            : Colors.white.withAlpha(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withAlpha(40)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xóa lọc',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _dateError == null ? _apply : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1E88E5),
                        disabledBackgroundColor: const Color(0xFF1E88E5).withAlpha(120),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? error;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB7CDE5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFFF7070)
                    : Colors.white.withAlpha(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFFB7CDE5), size: 18),
                const SizedBox(width: 10),
                Text(
                  value != null ? dateFormat.format(value!) : 'Chọn ngày',
                  style: TextStyle(
                    color: value != null
                        ? Colors.white
                        : Colors.white.withAlpha(80),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
