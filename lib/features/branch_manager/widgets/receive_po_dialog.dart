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

  // Key: medicineBatchId, Value: TextEditingController
  final Map<int, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    for (var detail in widget.po.details) {
      if (detail.receivedQuantity < detail.orderedQuantity) {
        for (var batch in detail.batches) {
          // Default to the full declared quantity
          _qtyControllers[batch.medicineBatchId] = TextEditingController(text: batch.declaredQuantity.toString());
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> detailsData = [];
      
      for (var detail in widget.po.details) {
        if (detail.receivedQuantity < detail.orderedQuantity) {
          final List<Map<String, dynamic>> batchesData = [];
          for (var batch in detail.batches) {
            final qtyText = _qtyControllers[batch.medicineBatchId]?.text;
            if (qtyText != null && qtyText.isNotEmpty) {
              final qty = int.tryParse(qtyText) ?? 0;
              if (qty > 0) {
                batchesData.add({
                  'medicineBatchId': batch.medicineBatchId,
                  'receivedQuantity': qty,
                });
              }
            }
          }
          if (batchesData.isNotEmpty) {
            detailsData.add({
              'medicineId': detail.medicineId,
              'receivedBatches': batchesData,
            });
          }
        }
      }

      if (detailsData.isEmpty) {
        throw Exception("Vui lòng nhập số lượng cho ít nhất một lô hàng.");
      }

      await PurchaseService().receivePurchaseOrder(widget.po.purchaseOrderId, {
        'details': detailsData
      });
      
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
                      Text('SL đặt: ${detail.orderedQuantity} - Đã nhận: ${detail.receivedQuantity}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      if (detail.batches.isEmpty)
                        const Text('Nhà cung cấp chưa khai báo lô thuốc nào.', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic))
                      else
                        ...detail.batches.map((batch) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Lô: ${batch.batchNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('SL khai báo: ${batch.declaredQuantity}'),
                                      Text('NSX: ${DateFormat('dd/MM/yyyy').format(batch.manufacturingDate)} - HSD: ${DateFormat('dd/MM/yyyy').format(batch.expirationDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _qtyControllers[batch.medicineBatchId],
                                    decoration: const InputDecoration(labelText: 'SL nhận', border: OutlineInputBorder(), isDense: true),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Bắt buộc';
                                      final val = int.tryParse(value);
                                      if (val == null || val < 0) return 'Lỗi';
                                      if (val > batch.declaredQuantity) return 'Vượt SL khai báo';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
