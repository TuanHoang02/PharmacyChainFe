import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/branch_service.dart';

class BranchFormScreen extends StatefulWidget {
  final int? branchId;
  const BranchFormScreen({super.key, this.branchId});

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final BranchService _branchService = BranchService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isActive = true;

  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';

  bool get _isEditMode => widget.branchId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadBranchDetails();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadBranchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final branch = await _branchService.getBranchById(widget.branchId!);
      setState(() {
        _nameController.text = branch.branchName;
        _addressController.text = branch.address;
        _phoneController.text = branch.phoneNumber ?? '';
        _emailController.text = branch.email ?? '';
        _isActive = branch.isActive;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      if (_isEditMode) {
        await _branchService.updateBranch(
          widget.branchId!,
          branchName: _nameController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          isActive: _isActive,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật chi nhánh thành công.')),
          );
          context.pop(true);
        }
      } else {
        await _branchService.createBranch(
          branchName: _nameController.text.trim(),
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm mới chi nhánh thành công.')),
          );
          context.pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

        final darkTheme = theme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A1628),
      cardColor: const Color(0xFF111F38),
      dialogBackgroundColor: const Color(0xFF111F38),
      dividerColor: const Color(0xFF1E3A5F),
      primaryColor: const Color(0xFF00C48C),
      hintColor: const Color(0xFF8FA8C9),
      colorScheme: theme.colorScheme.copyWith(
        primary: const Color(0xFF00C48C),
        surface: const Color(0xFF111F38),
        onSurface: Colors.white,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF0A1628),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF0A1628),
        labelStyle: const TextStyle(color: Color(0xFF8FA8C9)),
        hintStyle: const TextStyle(color: Color(0xFF8FA8C9)),
        prefixIconColor: const Color(0xFF8FA8C9),
        suffixIconColor: const Color(0xFF8FA8C9),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF1E3A5F)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF00C48C)),
        ),
      ),
    );

    return Theme(
      data: darkTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Cập nhật chi nhánh' : 'Thêm chi nhánh'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Text(
                        _isEditMode ? 'Chỉnh sửa chi nhánh' : 'Khai báo chi nhánh mới',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Điền đầy đủ các thông tin bắt buộc dưới đây để lưu vào hệ thống.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                      const SizedBox(height: 24),

                      // Error message banner
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên chi nhánh *',
                          hintText: 'Nhập tên chi nhánh (ví dụ: Chi nhánh Quận 1)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên chi nhánh';
                          }
                          if (value.trim().length > 100) {
                            return 'Tên chi nhánh không được quá 100 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Address field
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ *',
                          hintText: 'Số nhà, tên đường, phường, quận, thành phố...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập địa chỉ';
                          }
                          if (value.trim().length > 255) {
                            return 'Địa chỉ không được quá 255 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          hintText: 'Nhập số điện thoại liên hệ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length > 20) {
                              return 'Số điện thoại không quá 20 ký tự';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Nhập email liên hệ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length > 100) {
                              return 'Email không quá 100 ký tự';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Định dạng email không hợp lệ';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Is Active (Switch) - Only in Edit Mode
                      if (_isEditMode) ...[
                        Row(
                          children: [
                            const Text(
                              'Trạng thái hoạt động:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                              activeColor: theme.colorScheme.primary,
                            ),
                            Text(
                              _isActive ? 'Đang hoạt động' : 'Dừng hoạt động',
                              style: TextStyle(
                                color: _isActive ? Colors.teal : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveForm,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'LƯU THAY ĐỔI' : 'TẠO CHI NHÁNH',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
        },
      ),
    );
  }
}