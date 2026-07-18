import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/branch_service.dart';
import 'package:pharmacy_chain_fe/shared/services/staff_service.dart';

class StaffFormScreen extends StatefulWidget {
  final int? staffId;
  const StaffFormScreen({super.key, this.staffId});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final StaffService _staffService = StaffService();
  final BranchService _branchService = BranchService();
  final LocalStorageService _storageService = LocalStorageService();
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  int? _selectedRoleId;
  int? _selectedBranchId;
  bool _isActive = true;

  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';

  String _currentUserRole = '';
  int? _currentUserBranchId;
  List<BranchModel> _activeBranches = [];

  bool get _isEditMode => widget.staffId != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Get current user info from token/storage
      final role = await _storageService.getRole();
      final branchIdStr = await _storageService.getBranchId();
      _currentUserRole = role?.toLowerCase() ?? '';
      if (branchIdStr != null) {
        _currentUserBranchId = int.tryParse(branchIdStr);
      }

      // 2. If Operations Manager, fetch active branches
      if (_currentUserRole.contains('operations')) {
        final branchesResponse = await _branchService.getBranches(isActive: true, pageSize: 100);
        _activeBranches = branchesResponse.data;
      } else {
        // For Branch Manager, branch is fixed
        _selectedBranchId = _currentUserBranchId;
        _selectedRoleId = 4; // Fixed to Pharmacist
      }

      // 3. If Edit Mode, fetch staff details
      if (_isEditMode) {
        final staff = await _staffService.getStaffById(widget.staffId!);
        _fullNameController.text = staff.fullName;
        _emailController.text = staff.email ?? '';
        _phoneController.text = staff.phoneNumber ?? '';
        _selectedRoleId = staff.roleID;
        _selectedBranchId = staff.branchID;
        _isActive = staff.isActive;
      } else {
        // Set defaults for create mode
        if (_currentUserRole.contains('operations')) {
          _selectedRoleId = 4; // Default to Pharmacist
        }
      }

      setState(() {
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
        await _staffService.updateStaff(
          widget.staffId!,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          roleID: _selectedRoleId!,
          branchID: _selectedBranchId,
          isActive: _isActive,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật nhân sự thành công.')),
          );
          context.pop(true);
        }
      } else {
        await _staffService.createStaff(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          roleID: _selectedRoleId!,
          branchID: _selectedBranchId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo tài khoản nhân sự thành công.')),
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
    final isOpsManager = _currentUserRole.contains('operations');

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
        title: Text(_isEditMode ? 'Cập nhật nhân sự' : 'Thêm nhân sự mới'),
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
                      Text(
                        _isEditMode ? 'Chỉnh sửa nhân viên' : 'Đăng ký tài khoản nhân viên mới',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOpsManager
                            ? 'Quyền Quản lý chuỗi: Có thể chỉ định vai trò và chi nhánh cho nhân viên.'
                            : 'Quyền Quản lý chi nhánh: Chỉ được tạo vai trò Dược sĩ tại chi nhánh của bạn.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                      const SizedBox(height: 24),

                      // Error Banner
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      ],

                      // Username field (Only for create mode)
                      if (!_isEditMode) ...[
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Tên đăng nhập *',
                            hintText: 'Nhập tên tài khoản của nhân viên',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên đăng nhập';
                            }
                            if (value.trim().length > 50) {
                              return 'Tên đăng nhập không quá 50 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password field (Only for create mode)
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu *',
                            hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.trim().length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Full Name field
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên *',
                          hintText: 'Nhập họ và tên nhân viên',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          if (value.trim().length > 100) {
                            return 'Họ tên không quá 100 ký tự';
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
                          hintText: 'Nhập email nhân viên',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length > 100) {
                              return 'Email không quá 100 ký tự';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Email không đúng định dạng';
                            }
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
                          hintText: 'Nhập số điện thoại nhân viên',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
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

                      // Role dropdown (OpsManager can choose, BranchManager is fixed to Pharmacist)
                      if (isOpsManager) ...[
                        DropdownButtonFormField<int>(
                          value: _selectedRoleId,
                          decoration: InputDecoration(
                            labelText: 'Vai trò (Role) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.security),
                          ),
                          items: const [
                            DropdownMenuItem(value: 4, child: Text('Pharmacist (Dược sĩ)')),
                            DropdownMenuItem(value: 3, child: Text('BranchManager (Quản lý chi nhánh)')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedRoleId = val;
                            });
                          },
                          validator: (value) => value == null ? 'Vui lòng chọn vai trò' : null,
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        // Hidden/disabled view showing Pharmacist
                        InputDecorationTheme(
                          child: TextFormField(
                            initialValue: 'Dược sĩ (Pharmacist)',
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Vai trò (Role)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.security),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Branch dropdown (OpsManager can choose, BranchManager is fixed to their branch)
                      if (isOpsManager) ...[
                        DropdownButtonFormField<int>(
                          value: _selectedBranchId,
                          decoration: InputDecoration(
                            labelText: 'Chi nhánh làm việc *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.storefront),
                          ),
                          items: _activeBranches.map((branch) {
                            return DropdownMenuItem<int>(
                              value: branch.branchID,
                              child: Text(branch.branchName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedBranchId = val;
                            });
                          },
                          validator: (value) => value == null ? 'Vui lòng chọn chi nhánh làm việc' : null,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Is Active Switch (Only for Edit mode)
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
                              _isActive ? 'Đang hoạt động' : 'Tạm khóa',
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
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isEditMode ? 'LƯU THAY ĐỔI' : 'TẠO TÀI KHOẢN',
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