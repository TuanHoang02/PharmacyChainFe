import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/models/inventory_item.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/inventory_service.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/models/create_sales_invoice_dto.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/services/sales_service.dart';

class CreateSalesInvoiceScreen extends StatefulWidget {
  const CreateSalesInvoiceScreen({super.key});

  @override
  State<CreateSalesInvoiceScreen> createState() => _CreateSalesInvoiceScreenState();
}

class _CartItem {
  final InventoryItem inventory;
  int quantity;

  _CartItem({required this.inventory, this.quantity = 1});

  double get totalPrice => inventory.sellingPrice * quantity;
}

class _CreateSalesInvoiceScreenState extends State<CreateSalesInvoiceScreen> {
  final InventoryService _inventoryService = InventoryService();
  final SalesService _salesService = SalesService();

  List<_CartItem> _cart = [];
  List<InventoryItem> _availableMedicines = [];
  bool _isSubmitting = false;
  int _selectedPaymentMethod = 0; // 0: Cash, 2: BankTransfer
  String? _prescriptionFileName;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');

  // Dark Theme Colors
  final Color _bgColor = const Color(0xFF0A1628);
  final Color _panelColor = const Color(0xFF111F38);
  final Color _cardColor = const Color(0xFF1B2E4B);
  final Color _textColor = Colors.white;
  final Color _subtextColor = const Color(0xFF8FA8C9);
  final Color _primaryColor = const Color(0xFF00C48C);
  final Color _borderColor = const Color(0xFF2A3F5F);

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final items = await _inventoryService.getInventories(pageSize: 1000);
      if (mounted) {
        setState(() {
          _availableMedicines = items.data;
        });
      }
    } catch (e) {
      debugPrint('Error loading medicines: $e');
    }
  }

  // Removed _showAddMedicineBottomSheet as we use Dropdown now

  void _addToCart(InventoryItem item) {
    if (item.quantityInStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thuốc này đã hết hàng!')));
      return;
    }
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.inventory.medicineId == item.medicineId);
      if (existingIndex >= 0) {
        if (_cart[existingIndex].quantity < item.quantityInStock) {
          _cart[existingIndex].quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vượt quá tồn kho!')));
        }
      } else {
        _cart.add(_CartItem(inventory: item));
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQuantity = _cart[index].quantity + delta;
      if (newQuantity <= 0) return;
      if (newQuantity <= _cart[index].inventory.quantityInStock) {
        _cart[index].quantity = newQuantity;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vượt quá tồn kho!')));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get _tax => _subtotal * 0.05; // 5% VAT
  double get _total => _subtotal + _tax;

  bool get _requiresPrescription => _cart.any((item) => item.inventory.requiresPrescription);

  Future<void> _submitInvoice() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!')));
      return;
    }

    final phone = _customerPhoneController.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số điện thoại không hợp lệ! Vui lòng nhập đúng 10 số.'), backgroundColor: Colors.orange));
      return;
    }

    if (_requiresPrescription && _prescriptionFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đính kèm ảnh đơn thuốc cho các thuốc kê đơn (Rx)!'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dto = CreateSalesInvoiceDto(
        customerName: _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
        customerPhoneNumber: phone.isEmpty ? null : phone,
        prescriptionImageUrl: _prescriptionFileName != null ? 'https://example.com/$_prescriptionFileName' : null,
        discountAmount: 0,
        paymentMethod: _selectedPaymentMethod,
        details: _cart.map((c) => SalesInvoiceDetailDto(
          medicineId: c.inventory.medicineId,
          quantity: c.quantity,
        )).toList(),
      );

      await _salesService.createSalesInvoice(dto);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công!'), backgroundColor: Colors.green),
      );
      
      setState(() {
        _cart.clear();
        _prescriptionFileName = null;
        _customerNameController.clear();
        _customerPhoneController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _panelColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('TẠO HÓA ĐƠN BÁN HÀNG', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildCustomerInfoSection(),
              const SizedBox(height: 24),
              _buildInvoiceItemsHeader(),
              const SizedBox(height: 16),
              _buildCartItems(),
              const SizedBox(height: 24),
              if (_requiresPrescription) ...[
                _buildPrescriptionSection(),
                const SizedBox(height: 24),
              ],
              _buildPaymentMethodSelection(),
              const SizedBox(height: 24),
              _buildInvoiceSummary(),
              const SizedBox(height: 24),
              _buildProcessPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: _borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_outline, size: 28, color: _textColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào,', style: TextStyle(color: _subtextColor, fontSize: 12)),
                Text('Pharmacist', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Vai trò: Dược sĩ', style: TextStyle(color: _subtextColor, fontSize: 12)),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(Icons.sync, size: 14, color: _subtextColor),
                const SizedBox(width: 4),
                Text('Cập nhật lúc', style: TextStyle(color: _subtextColor, fontSize: 12)),
              ],
            ),
            Text(DateFormat('HH:mm a').format(DateTime.now()), style: TextStyle(color: _textColor, fontWeight: FontWeight.w500, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildInvoiceItemsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('DANH SÁCH THUỐC', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(8),
            color: _panelColor,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<InventoryItem>(
              hint: Text('Thêm thuốc', style: TextStyle(color: _textColor, fontSize: 13)),
              dropdownColor: _panelColor,
              icon: Icon(Icons.keyboard_arrow_down, color: _textColor, size: 16),
              items: _availableMedicines.map((item) {
                return DropdownMenuItem<InventoryItem>(
                  value: item,
                  child: SizedBox(
                    width: 200,
                    child: Text('${item.medicineName} (${item.quantityInStock})', 
                      style: TextStyle(color: _textColor, fontSize: 13), 
                      overflow: TextOverflow.ellipsis),
                  ),
                );
              }).toList(),
              onChanged: (item) {
                if (item != null) {
                  _addToCart(item);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItems() {
    if (_cart.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _panelColor,
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: _subtextColor),
            const SizedBox(height: 16),
            Text('Chưa có thuốc nào', style: TextStyle(color: _subtextColor)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _panelColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text('Tên thuốc', style: TextStyle(color: _subtextColor, fontSize: 12, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Center(child: Text('SL', style: TextStyle(color: _subtextColor, fontSize: 12, fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Center(child: Text('Đơn giá', style: TextStyle(color: _subtextColor, fontSize: 12, fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Center(child: Text('Giảm giá', style: TextStyle(color: _subtextColor, fontSize: 12, fontWeight: FontWeight.bold)))),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Tổng', style: TextStyle(color: _subtextColor, fontSize: 12, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: _borderColor),
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cart.length,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, color: _borderColor),
            itemBuilder: (context, index) {
              final item = _cart[index];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Medicine Info
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Icon(Icons.image_outlined, color: _subtextColor, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(item.inventory.medicineName, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    if (item.inventory.requiresPrescription)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: _subtextColor),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('Thuốc kê đơn', style: TextStyle(color: _subtextColor, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                Text('Viên', style: TextStyle(color: _subtextColor, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Qty
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          border: Border.all(color: _borderColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _updateQuantity(index, -1),
                              child: Icon(Icons.remove, size: 16, color: _textColor),
                            ),
                            Text('${item.quantity}', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                            GestureDetector(
                              onTap: () => _updateQuantity(index, 1),
                              child: Icon(Icons.add, size: 16, color: _textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Unit Price
                    Expanded(
                      flex: 2,
                      child: Center(child: Text(_currencyFormat.format(item.inventory.sellingPrice), style: TextStyle(color: _textColor, fontSize: 12))),
                    ),
                    // Discount
                    Expanded(
                      flex: 2,
                      child: Center(child: Text('0%', style: TextStyle(color: _textColor, fontSize: 12))),
                    ),
                    // Total
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => _removeFromCart(index),
                            child: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 8),
                          Text(_currencyFormat.format(item.totalPrice), style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('THÔNG TIN KHÁCH HÀNG', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customerNameController,
                style: TextStyle(color: _textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tên khách hàng',
                  hintStyle: TextStyle(color: _subtextColor, fontSize: 13),
                  prefixIcon: Icon(Icons.person_outline, color: _subtextColor, size: 20),
                  filled: true,
                  fillColor: _panelColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _customerPhoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: _textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Số điện thoại',
                  hintStyle: TextStyle(color: _subtextColor, fontSize: 13),
                  prefixIcon: Icon(Icons.phone_outlined, color: _subtextColor, size: 20),
                  filled: true,
                  fillColor: _panelColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ĐÍNH KÈM ĐƠN THUỐC (Bắt buộc)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _panelColor,
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUploadButton(Icons.camera_alt_outlined, 'Chụp ảnh'),
              Text('hoặc', style: TextStyle(color: _subtextColor)),
              _buildUploadButton(Icons.upload_file, 'Chọn từ thư viện'),
            ],
          ),
        ),
        if (_prescriptionFileName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file_outlined, color: _subtextColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_prescriptionFileName!, style: TextStyle(color: _textColor, fontWeight: FontWeight.w500, fontSize: 13)),
                      Text('Thêm lúc ${DateFormat('HH:mm a').format(DateTime.now())}', style: TextStyle(color: _subtextColor, fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _prescriptionFileName = null),
                  child: Icon(Icons.close, size: 18, color: _subtextColor),
                ),
              ],
            ),
          )
        ]
      ],
    );
  }

  Widget _buildUploadButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _prescriptionFileName = 'Prescription_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.jpg';
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardColor,
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _textColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: _subtextColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PHƯƠNG THỨC THANH TOÁN', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == 0 ? _primaryColor.withOpacity(0.1) : _panelColor,
                    border: Border.all(color: _selectedPaymentMethod == 0 ? _primaryColor : _borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money, color: _selectedPaymentMethod == 0 ? _primaryColor : _subtextColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Tiền mặt', style: TextStyle(color: _selectedPaymentMethod == 0 ? _primaryColor : _subtextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPaymentMethod = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == 2 ? _primaryColor.withOpacity(0.1) : _panelColor,
                    border: Border.all(color: _selectedPaymentMethod == 2 ? _primaryColor : _borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, color: _selectedPaymentMethod == 2 ? _primaryColor : _subtextColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Chuyển khoản', style: TextStyle(color: _selectedPaymentMethod == 2 ? _primaryColor : _subtextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TỔNG KẾT ĐƠN HÀNG', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _panelColor,
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Tạm tính (${_cart.length} thuốc)', _currencyFormat.format(_subtotal)),
              const SizedBox(height: 8),
              _buildSummaryRow('Giảm giá', '0'),
              const SizedBox(height: 8),
              _buildSummaryRow('Thuế (VAT 5%)', _currencyFormat.format(_tax)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1, color: _borderColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TỔNG TIỀN', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${_currencyFormat.format(_total)}đ', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: _subtextColor, fontSize: 13)),
        Text(value, style: TextStyle(color: _textColor, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProcessPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitInvoice,
        icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.credit_card, color: Colors.white),
        label: _isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('THANH TOÁN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// Helper Bottom Sheet for searching and adding medicines
class _AddMedicineSheet extends StatefulWidget {
  const _AddMedicineSheet();

  @override
  State<_AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<_AddMedicineSheet> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _searchController = TextEditingController();
  List<InventoryItem> _searchResults = [];
  bool _isSearching = false;

  final Color _bgColor = const Color(0xFF111F38);
  final Color _cardColor = const Color(0xFF1B2E4B);
  final Color _textColor = Colors.white;
  final Color _subtextColor = const Color(0xFF8FA8C9);
  final Color _primaryColor = const Color(0xFF00C48C);

  void _searchMedicine(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final pagedResponse = await _inventoryService.getInventories(searchKeyword: query);
      setState(() => _searchResults = pagedResponse.data);
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _subtextColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Search Medicine', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _searchMedicine,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              hintText: 'Enter medicine name...',
              hintStyle: TextStyle(color: _subtextColor),
              prefixIcon: Icon(Icons.search, color: _subtextColor),
              filled: true,
              fillColor: _cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              suffixIcon: _isSearching ? Padding(padding: const EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor)) : null,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: _searchResults.isEmpty && !_isSearching
                ? Center(child: Text('No results', style: TextStyle(color: _subtextColor)))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        title: Text(item.medicineName, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
                        subtitle: Text('In stock: ${item.quantityInStock} | Price: ${NumberFormat('#,##0', 'en_US').format(item.sellingPrice)}', style: TextStyle(color: _subtextColor)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                          onPressed: () => Navigator.pop(context, item),
                          child: const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
