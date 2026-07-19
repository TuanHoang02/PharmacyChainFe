import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/purchase_service.dart';

class ReceivePODialog extends StatefulWidget {
  final PurchaseOrderSummaryModel po;

  const ReceivePODialog({super.key, required this.po});

  @override
  State<ReceivePODialog> createState() => _ReceivePODialogState();
}

class _ReceivePODialogState extends State<ReceivePODialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _batchControllers = {};
  final Map<int, DateTime?> _mfgDates = {};
  final Map<int, DateTime?> _expDates = {};

  @override
  void initState() {
    super.initState();
    for (var detail in widget.po.details) {
      if (detail.receivedQuantity < detail.orderedQuantity) {
        _qtyControllers[detail.medicineId] = TextEditingController(text: (detail.orderedQuantity - detail.receivedQuantity).toString());
        _batchControllers[detail.medicineId] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var controller in _batchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, int medicineId, bool isMfg) async {
    final initialDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isMfg) {
          _mfgDates[medicineId] = picked;
        } else {
          _expDates[medicineId] = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check dates
    for (var detail in widget.po.details) {
      if (detail.receivedQuantity < detail.orderedQuantity) {
        if (_mfgDates[detail.medicineId] == null || _expDates[detail.medicineId] == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn đầy đủ NSX và HSD cho tất cả thuốc.')));
          return;
        }
        if (_mfgDates[detail.medicineId]!.isAfter(_expDates[detail.medicineId]!)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NSX không được sau HSD đối với thuốc ${detail.medicineName}.')));
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> detailsData = [];
      for (var detail in widget.po.details) {
        if (detail.receivedQuantity < detail.orderedQuantity) {
          detailsData.add({
            'medicineId': detail.medicineId,
            'receivedQuantity': int.parse(_qtyControllers[detail.medicineId]!.text),
            'batchNumber': _batchControllers[detail.medicineId]!.text,
            'manufacturingDate': _mfgDates[detail.medicineId]!.toIso8601String(),
            'expirationDate': _expDates[detail.medicineId]!.toIso8601String(),
          });
        }
      }

      await PurchaseService().receivePurchaseOrder(widget.po.purchaseOrderId, {'details': detailsData});
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nhận hàng - ${widget.po.orderCode} (${widget.po.supplierName})'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: widget.po.details.map((detail) {
              if (detail.receivedQuantity >= detail.orderedQuantity) {
                return ListTile(
                  title: Text(detail.medicineName),
                  subtitle: const Text('Đã nhận đủ', style: TextStyle(color: Colors.green)),
                );
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('SL chưa nhận: ${detail.orderedQuantity - detail.receivedQuantity}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _qtyControllers[detail.medicineId],
                              decoration: const InputDecoration(labelText: 'SL nhận', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Bắt buộc';
                                final val = int.tryParse(value);
                                if (val == null || val <= 0) return 'Không hợp lệ';
                                if (val > (detail.orderedQuantity - detail.receivedQuantity)) return 'Quá SL';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _batchControllers[detail.medicineId],
                              decoration: const InputDecoration(labelText: 'Mã lô', border: OutlineInputBorder()),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Bắt buộc';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, detail.medicineId, true),
                              child: Text(_mfgDates[detail.medicineId] == null 
                                  ? 'Chọn NSX' 
                                  : DateFormat('dd/MM/yyyy').format(_mfgDates[detail.medicineId]!)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context, detail.medicineId, false),
                              child: Text(_expDates[detail.medicineId] == null 
                                  ? 'Chọn HSD' 
                                  : DateFormat('dd/MM/yyyy').format(_expDates[detail.medicineId]!)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Xác nhận Nhận'),
        ),
      ],
    );
  }
}
