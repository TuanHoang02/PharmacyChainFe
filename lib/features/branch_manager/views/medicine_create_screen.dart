import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/medicine_service.dart';
import 'package:pharmacy_chain_fe/shared/models/medicine_model.dart';

class MedicineCreateScreen extends StatefulWidget {
  const MedicineCreateScreen({super.key});

  @override
  State<MedicineCreateScreen> createState() => _MedicineCreateScreenState();
}

class _MedicineCreateScreenState extends State<MedicineCreateScreen> {
  final MedicineService _medicineService = MedicineService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genericNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  int? _selectedCategoryId;
  bool _requiresPrescription = false;

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _errorMessage = null;
    });
    try {
      final list = await _medicineService.getCategories();
      setState(() {
        _categories = list;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh mục thuốc. Vui lòng quay lại sau.';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn danh mục thuốc.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final price = double.tryParse(_priceController.text) ?? 0.0;

    try {
      await _medicineService.createMedicine(
        name: _nameController.text.trim(),
        genericName: _genericNameController.text.trim().isNotEmpty
            ? _genericNameController.text.trim()
            : null,
        categoryId: _selectedCategoryId!,
        price: price,
        unit: _unitController.text.trim(),
        dosageInstructions: _dosageController.text.trim().isNotEmpty
            ? _dosageController.text.trim()
            : null,
        requiresPrescription: _requiresPrescription,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Tạo thuốc thành công!'),
              ],
            ),
            backgroundColor: const Color(0xFF00C48C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate successful creation
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
        backgroundColor: const Color(0xFF111F38),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thêm thuốc mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Banner
                      if (_errorMessage != null) ...[
                        _buildErrorBanner(_errorMessage!),
                        const SizedBox(height: 16),
                      ],

                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111F38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Name field ─────────────────────────────
                            _buildLabel('Tên thuốc *'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _nameController,
                              hint: 'Nhập tên thương mại (ví dụ: Panadol Extra)',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tên thuốc không được để trống.';
                                }
                                if (value.trim().length > 200) {
                                  return 'Tên thuốc không vượt quá 200 ký tự.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Generic Name field ─────────────────────
                            _buildLabel('Tên gốc / Hoạt chất'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _genericNameController,
                              hint: 'Nhập tên hoạt chất (ví dụ: Paracetamol)',
                              validator: (value) {
                                if (value != null && value.trim().length > 200) {
                                  return 'Tên gốc không vượt quá 200 ký tự.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Category Dropdown ──────────────────────
                            _buildLabel('Danh mục thuốc *'),
                            const SizedBox(height: 8),
                            _buildCategoryDropdown(),
                            const SizedBox(height: 16),

                            // ── Price & Unit Row ───────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Giá bán * (đ)'),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        controller: _priceController,
                                        hint: 'Ví dụ: 15000',
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Giá không được trống.';
                                          }
                                          final val = double.tryParse(value);
                                          if (val == null || val <= 0) {
                                            return 'Giá bán phải lớn hơn 0.';
                                          }
                                          if (val > 10000000) {
                                            return 'Tối đa 10.000.000đ.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Đơn vị tính *'),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        controller: _unitController,
                                        hint: 'ví dụ: Viên, Vỉ, Hộp',
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Không được để trống.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Dosage Instructions field ──────────────
                            _buildLabel('Hướng dẫn sử dụng / Liều dùng'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _dosageController,
                              hint: 'Nhập liều dùng chi tiết (ví dụ: Uống 1 viên sau ăn...)',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // ── Requires Prescription Switch ───────────
                            SwitchListTile(
                              title: const Text(
                                'Requires Prescription (Rx)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: const Text(
                                'Thuốc yêu cầu phải có đơn thuốc của bác sĩ',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              value: _requiresPrescription,
                              activeColor: const Color(0xFF1E88E5),
                              activeTrackColor: const Color(0xFF1E88E5).withAlpha(50),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.white12,
                              contentPadding: EdgeInsets.zero,
                              onChanged: _isSubmitting
                                  ? null
                                  : (bool value) {
                                      setState(() {
                                        _requiresPrescription = value;
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withAlpha(180),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSubmitting,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withAlpha(60), fontSize: 13),
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF7070), fontSize: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          dropdownColor: const Color(0xFF111F38),
          hint: const Text('Chọn danh mục', style: TextStyle(color: Colors.white54, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _categories.map((cat) {
            return DropdownMenuItem<int>(
              value: cat.categoryID,
              child: Text(cat.categoryName),
            );
          }).toList(),
          onChanged: _isSubmitting
              ? null
              : (val) {
                  setState(() {
                    _selectedCategoryId = val;
                  });
                },
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF5252).withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF7070), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF9090), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isSubmitting
                ? LinearGradient(
                    colors: [
                      const Color(0xFF1E88E5).withAlpha(120),
                      const Color(0xFF00C48C).withAlpha(120),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF00C48C)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isSubmitting
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lưu lại',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
