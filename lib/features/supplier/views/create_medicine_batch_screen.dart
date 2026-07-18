import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_item.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_summary.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/medicine_batch_service.dart';
import 'package:pharmacy_chain_fe/features/supplier/services/purchase_order_service.dart';

class CreateMedicineBatchScreen extends StatefulWidget {
  final int? preSelectedOrderId;
  final int? preSelectedDetailId;

  const CreateMedicineBatchScreen({
    super.key,
    this.preSelectedOrderId,
    this.preSelectedDetailId,
  });

  @override
  State<CreateMedicineBatchScreen> createState() => _CreateMedicineBatchScreenState();
}

class _CreateMedicineBatchScreenState extends State<CreateMedicineBatchScreen> {
  final MedicineBatchService _batchService = MedicineBatchService();
  final PurchaseOrderService _orderService = PurchaseOrderService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _isLoadingOrders = true;
  bool _isLoadingOrderDetails = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<PurchaseOrderSummary> _deliveredOrders = [];
  PurchaseOrderSummary? _selectedOrder;
  List<PurchaseOrderItem> _availableItems = [];

  PurchaseOrderItem? _selectedItem;

  DateTime? _manufacturingDate;
  DateTime? _expiryDate;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadDeliveredOrders();
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveredOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _errorMessage = null;
    });

    try {
      // Get all accepted orders (status = 1)
      final response = await _orderService.getOrders(
        pageNumber: 1,
        pageSize: 100,
        filter: const PurchaseOrderFilter(status: 1),
      );

      // Filter in-memory for delivered orders
      final list = response.data.where((po) => po.deliveryStatus == 'Delivered').toList();

      if (!mounted) return;

      setState(() {
        _deliveredOrders = list;
        if (widget.preSelectedOrderId != null) {
          final match = list.where((o) => o.purchaseOrderId == widget.preSelectedOrderId);
          if (match.isNotEmpty) {
            _selectedOrder = match.first;
            _loadOrderDetails(widget.preSelectedOrderId!);
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  Future<void> _loadOrderDetails(int orderId) async {
    setState(() {
      _isLoadingOrderDetails = true;
      _selectedItem = null;
      _availableItems.clear();
    });

    try {
      final detail = await _orderService.getPurchaseOrderById(orderId);
      final batchesResponse = await _batchService.getMedicineBatches(
        purchaseOrderId: orderId,
        pageSize: 100,
      );
      if (!mounted) return;

      final declaredNames = batchesResponse.data.map((b) => b.medicineName).toSet();
      final undeclaredItems = detail.items
          .where((item) => !declaredNames.contains(item.medicineName) || item.purchaseOrderDetailId == widget.preSelectedDetailId)
          .toList();

      setState(() {
        _availableItems = undeclaredItems;
        if (widget.preSelectedDetailId != null) {
          final match = detail.items.where((item) => item.purchaseOrderDetailId == widget.preSelectedDetailId);
          if (match.isNotEmpty) {
            _selectedItem = match.first;
            _quantityController.text = match.first.orderedQuantity.toString();
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải chi tiết đơn hàng: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrderDetails = false;
        });
      }
    }
  }

  Future<void> _selectManufacturingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _manufacturingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // cannot select future dates
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C48C),
              onPrimary: Colors.white,
              surface: Color(0xFF111F38),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0A1628),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _manufacturingDate) {
      setState(() {
        _manufacturingDate = picked;
        // Reset expiry date if it is before manufacturing date
        if (_expiryDate != null && _expiryDate!.isBefore(_manufacturingDate!)) {
          _expiryDate = null;
        }
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime startLimit = _manufacturingDate != null
        ? _manufacturingDate!.add(const Duration(days: 1))
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? startLimit,
      firstDate: startLimit, // must be after manufacturing date
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C48C),
              onPrimary: Colors.white,
              surface: Color(0xFF111F38),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0A1628),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null || _manufacturingDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ các trường thông tin.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _batchService.createMedicineBatch(
        purchaseOrderDetailId: _selectedItem!.purchaseOrderDetailId,
        batchNumber: _batchNumberController.text.trim(),
        manufacturingDate: _manufacturingDate!,
        expiryDate: _expiryDate!,
        receivedQuantity: int.parse(_quantityController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Tạo lô thuốc mới thành công.')),
            ],
          ),
          backgroundColor: const Color(0xFF00C48C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
            ],
          ),
          backgroundColor: const Color(0xFFFF7070),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
        title: const Text(
          'Khai báo lô thuốc mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A1628),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C48C)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: Color(0xFFFF7070), size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFF9090), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDeliveredOrders,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_deliveredOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF8FA8C9), size: 64),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy đơn mua hàng nào ở trạng thái "Đã giao" để khai báo lô.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Select Purchase Order
            const Text(
              'Chọn Đơn mua hàng (Đã giao)',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PurchaseOrderSummary>(
              initialValue: _selectedOrder,
              dropdownColor: const Color(0xFF111F38),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _getInputDecoration('Chọn đơn hàng đã giao tới chi nhánh'),
              hint: const Text(
                'Chọn đơn hàng',
                style: TextStyle(color: Color(0xFF7E92AD), fontSize: 14),
              ),
              items: _deliveredOrders.map((po) {
                return DropdownMenuItem<PurchaseOrderSummary>(
                  value: po,
                  child: Text('${po.purchaseOrderCode} (${po.branchName})'),
                );
              }).toList(),
              onChanged: _isSubmitting || widget.preSelectedOrderId != null
                  ? null
                  : (val) {
                      setState(() {
                        _selectedOrder = val;
                      });
                      if (val != null) {
                        _loadOrderDetails(val.purchaseOrderId);
                      }
                    },
              validator: (val) => val == null ? 'Vui lòng chọn đơn hàng' : null,
            ),
            const SizedBox(height: 20),

            // Select Medicine item from order details
            if (_selectedOrder != null) ...[
              const Text(
                'Chọn mặt hàng thuốc cần khai báo',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_isLoadingOrderDetails)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: Color(0xFF00C48C)),
                  ),
                )
              else
                DropdownButtonFormField<PurchaseOrderItem>(
                  initialValue: _selectedItem,
                  dropdownColor: const Color(0xFF111F38),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _getInputDecoration('Chọn loại thuốc bàn giao'),
                  hint: const Text(
                    'Chọn loại thuốc',
                    style: TextStyle(color: Color(0xFF7E92AD), fontSize: 14),
                  ),
                  items: _availableItems.map((item) {
                    return DropdownMenuItem<PurchaseOrderItem>(
                      value: item,
                      child: Text('${item.medicineName} (Đặt mua: ${item.orderedQuantity})'),
                    );
                  }).toList(),
                  onChanged: _isSubmitting || widget.preSelectedDetailId != null
                      ? null
                      : (val) {
                          setState(() {
                            _selectedItem = val;
                            if (val != null) {
                              _quantityController.text = val.orderedQuantity.toString();
                            }
                          });
                        },
                  validator: (val) => val == null ? 'Vui lòng chọn mặt hàng thuốc' : null,
                ),
              const SizedBox(height: 20),
            ],

            // Batch Number Field
            const Text(
              'Số lô sản xuất',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _batchNumberController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              enabled: !_isSubmitting,
              maxLength: 50,
              decoration: _getInputDecoration('Nhập số lô sản xuất (tối đa 50 ký tự)'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập số lô sản xuất';
                }
                if (val.trim().length > 50) {
                  return 'Số lô sản xuất không được vượt quá 50 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Date Pickers Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày sản xuất (NSX)',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isSubmitting ? null : () => _selectManufacturingDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111F38),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withAlpha(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _manufacturingDate == null
                                    ? 'Chọn NSX'
                                    : _dateFormat.format(_manufacturingDate!),
                                style: TextStyle(
                                  color: _manufacturingDate == null
                                      ? const Color(0xFF7E92AD)
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF8FA8C9)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày hết hạn (HSD)',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isSubmitting ? null : () => _selectExpiryDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111F38),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withAlpha(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _expiryDate == null ? 'Chọn HSD' : _dateFormat.format(_expiryDate!),
                                style: TextStyle(
                                  color: _expiryDate == null
                                      ? const Color(0xFF7E92AD)
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF8FA8C9)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quantity Field
            const Text(
              'Số lượng bàn giao thực tế',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              enabled: !_isSubmitting,
              decoration: _getInputDecoration('Nhập số lượng bàn giao thực tế'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập số lượng nhận';
                }
                final numVal = int.tryParse(val.trim());
                if (numVal == null || numVal <= 0) {
                  return 'Số lượng phải là số nguyên dương lớn hơn 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C48C),
                disabledBackgroundColor: const Color(0xFF00C48C).withAlpha(120),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Lưu thông tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF111F38),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7E92AD), fontSize: 13),
      contentPadding: const EdgeInsets.all(16),
      counterText: '',
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(10)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF7070)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF7070)),
      ),
    );
  }
}
