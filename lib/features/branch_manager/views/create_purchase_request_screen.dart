import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/inventory_item.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_dto.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/inventory_service.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/purchase_service.dart';

class CreatePurchaseRequestScreen extends StatefulWidget {
  const CreatePurchaseRequestScreen({super.key});

  @override
  State<CreatePurchaseRequestScreen> createState() => _CreatePurchaseRequestScreenState();
}

class _CreatePurchaseRequestScreenState extends State<CreatePurchaseRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  final InventoryService _inventoryService = InventoryService();
  final PurchaseService _purchaseService = PurchaseService();

  List<InventoryItem> _medicines = [];
  bool _isLoadingMedicines = true;
  bool _isSubmitting = false;

  final List<_RequestRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
    _addRow(); // Start with one empty row
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (var row in _rows) {
      row.quantityController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMedicines() async {
    try {
      final items = await _inventoryService.getInventories();
      setState(() {
        _medicines = items;
        _isLoadingMedicines = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicines = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách thuốc: $e')),
        );
      }
    }
  }

  void _addRow() {
    setState(() {
      _rows.add(_RequestRow(quantityController: TextEditingController(text: '1')));
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows[index].quantityController.dispose();
        _rows.removeAt(index);
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rows.any((row) => row.selectedMedicineId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thuốc cho tất cả các dòng')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final details = _rows.map((row) {
        return PurchaseRequestDetailDto(
          medicineId: row.selectedMedicineId!,
          requestedQuantity: int.parse(row.quantityController.text),
        );
      }).toList();

      final request = CreatePurchaseRequestDto(
        reason: _reasonController.text.trim(),
        details: details,
      );

      await _purchaseService.createPurchaseRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo yêu cầu nhập hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: const Text('Tạo Yêu Cầu Nhập Hàng'),
        backgroundColor: const Color(0xFF111F38),
        elevation: 0,
      ),
      body: _isLoadingMedicines
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C48C)))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason TextField
                    TextFormField(
                      controller: _reasonController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Lý do nhập hàng',
                        labelStyle: const TextStyle(color: Color(0xFF8FA8C9)),
                        filled: true,
                        fillColor: const Color(0xFF111F38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập lý do';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Danh sách thuốc cần nhập',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dynamic Rows
                    ..._rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return _buildRow(index, row);
                    }),
                    const SizedBox(height: 16),
                    // Add Row Button
                    OutlinedButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add, color: Color(0xFF00C48C)),
                      label: const Text(
                        'Thêm Thuốc Khác',
                        style: TextStyle(color: Color(0xFF00C48C)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00C48C)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C48C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Gửi Yêu Cầu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRow(int index, _RequestRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111F38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: row.selectedMedicineId,
              dropdownColor: const Color(0xFF111F38),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Chọn thuốc',
                labelStyle: const TextStyle(color: Color(0xFF8FA8C9)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8FA8C9)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _medicines.map((m) {
                return DropdownMenuItem<int>(
                  value: m.medicineId,
                  child: Text(
                    '${m.medicineName} (Tồn: ${m.quantityInStock} ${m.unit})',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  row.selectedMedicineId = val;
                });
              },
              validator: (val) => val == null ? 'Bắt buộc' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: row.quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'SL',
                labelStyle: const TextStyle(color: Color(0xFF8FA8C9)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8FA8C9)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Lỗi';
                if (int.tryParse(val) == null || int.parse(val) <= 0) return '>0';
                return null;
              },
            ),
          ),
          if (_rows.length > 1) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF7070)),
              onPressed: () => _removeRow(index),
            ),
          ]
        ],
      ),
    );
  }
}

class _RequestRow {
  int? selectedMedicineId;
  TextEditingController quantityController;

  _RequestRow({
    this.selectedMedicineId,
    required this.quantityController,
  });
}
