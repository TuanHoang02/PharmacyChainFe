import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/supplier_service.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final SupplierService _supplierService = SupplierService();

  bool _isLoading = false;
  String _searchTerm = '';
  bool? _isActiveFilter;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  int _totalPages = 0;
  List<SupplierModel> _suppliers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final pagedResponse = await _supplierService.getSuppliers(
        searchTerm: _searchTerm,
        isActive: _isActiveFilter,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _suppliers = pagedResponse.data;
        _currentPage = pagedResponse.pageNumber;
        _pageSize = pagedResponse.pageSize;
        _totalRecords = pagedResponse.totalRecords;
        _totalPages = pagedResponse.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _openSupplierDialog({SupplierModel? supplier}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: supplier?.supplierName ?? '');
    final contactController = TextEditingController(text: supplier?.contactName ?? '');
    final phoneController = TextEditingController(text: supplier?.phoneNumber ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(text: supplier?.address ?? '');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController(text: '123456');

    if (supplier == null) {
      void updateUsername() {
        String unsignedName = _removeDiacritics(nameController.text.trim().toLowerCase());
        unsignedName = unsignedName.replaceAll(RegExp(r'[^a-z0-9]'), '');

        String phoneSuffix = '';
        String cleanPhone = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanPhone.length >= 4) {
          phoneSuffix = cleanPhone.substring(cleanPhone.length - 4);
        }
        usernameController.text = '$unsignedName$phoneSuffix';
      }
      nameController.addListener(updateUsername);
      phoneController.addListener(updateUsername);
    }

    bool isActive = supplier?.isActive ?? true;
    bool isSaving = false;
    String dialogError = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isPasswordObscured = true;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(supplier == null ? 'Thêm nhà cung cấp mới' : 'Cập nhật nhà cung cấp'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width > 500 ? 450 : MediaQuery.of(context).size.width * 0.85,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dialogError.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(dialogError, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ),
                        ],
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Tên nhà cung cấp *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên nhà cung cấp';
                            }
                            if (value.trim().length > 100) {
                              return 'Tên nhà cung cấp không quá 100 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: contactController,
                          decoration: InputDecoration(
                            labelText: 'Tên người liên hệ',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value != null && value.trim().length > 100) {
                              return 'Tên người liên hệ không quá 100 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                                return 'Email không hợp lệ';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Địa chỉ',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value != null && value.trim().length > 255) {
                              return 'Địa chỉ không quá 255 ký tự';
                            }
                            return null;
                          },
                        ),
                        if (supplier == null) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFF1E3A5F)),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Thông tin tài khoản đăng nhập',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Tên đăng nhập *',
                              prefixIcon: Icon(Icons.account_box),
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordController,
                            obscureText: isPasswordObscured,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu *',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    isPasswordObscured = !isPasswordObscured;
                                  });
                                },
                              ),
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
                        ],
                        if (supplier != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Trạng thái hoạt động:'),
                              const SizedBox(width: 8),
                              Switch(
                                value: isActive,
                                onChanged: (val) => setDialogState(() => isActive = val),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSaving = true;
                            dialogError = '';
                          });

                          try {
                            if (supplier == null) {
                              await _supplierService.createSupplierWithAccount(
                                supplierName: nameController.text.trim(),
                                contactName: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                                phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                                username: usernameController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                            } else {
                              await _supplierService.updateSupplier(
                                supplier.supplierID,
                                supplierName: nameController.text.trim(),
                                contactName: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                                phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                                isActive: isActive,
                              );
                            }
                            if (mounted) {
                              Navigator.pop(context);
                              _fetchSuppliers();
                              if (supplier == null) {
                                _showAccountResultDialog(
                                  usernameController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cập nhật nhà cung cấp thành công.'),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setDialogState(() {
                              dialogError = e.toString().replaceAll('Exception:', '').trim();
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(supplier == null ? 'Lưu' : 'Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteSupplier(SupplierModel supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111F38),
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Color(0xFF8FA8C9)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn dừng hoạt động nhà cung cấp "${supplier.supplierName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _supplierService.deleteSupplier(supplier.supplierID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa mềm nhà cung cấp thành công.')),
        );
        _fetchSuppliers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
        );
        setState(() => _isLoading = false);
      }
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
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nhà cung cấp',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quản lý danh sách đối tác cung cấp dược phẩm',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _openSupplierDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm mới', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm theo tên, SĐT, email...',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchTerm = val;
                                    _currentPage = 1;
                                  });
                                  _fetchSuppliers();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor),
                                color: const Color(0xFF0A1628),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<bool?>(
                                  dropdownColor: const Color(0xFF0A1628),
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8FA8C9)),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  value: _isActiveFilter,
                                  hint: const Text('Trạng thái', style: TextStyle(color: Color(0xFF8FA8C9))),
                                  items: const [
                                    DropdownMenuItem(value: null, child: Text('Tất cả')),
                                    DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
                                    DropdownMenuItem(value: false, child: Text('Dừng hoạt động')),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _isActiveFilter = val;
                                      _currentPage = 1;
                                    });
                                    _fetchSuppliers();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error banner
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
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
                            IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: _fetchSuppliers)
                          ],
                        ),
                      ),

                    // Content Area
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _suppliers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_shipping_outlined, size: 64, color: theme.hintColor),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không tìm thấy nhà cung cấp nào',
                                        style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _suppliers.length,
                                  itemBuilder: (context, index) {
                                    final supplier = _suppliers[index];
                                    return Card(
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: theme.dividerColor),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: theme.cardColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Name + Status badge
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          supplier.supplierName,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: supplier.isActive
                                                              ? Colors.teal.withOpacity(0.15)
                                                              : Colors.red.withOpacity(0.15),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(
                                                            color: supplier.isActive ? Colors.teal[400]! : Colors.red[400]!,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          supplier.isActive ? 'Hoạt động' : 'Tạm dừng',
                                                          style: TextStyle(
                                                            color: supplier.isActive ? Colors.teal[300] : Colors.red[300],
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  if (supplier.username != null && supplier.username!.isNotEmpty) ...[
                                                    Row(children: [
                                                      Icon(Icons.account_box, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text('Tài khoản: ${supplier.username!}', style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                    const SizedBox(height: 4),
                                                  ],
                                                  if (supplier.contactName != null && supplier.contactName!.isNotEmpty) ...[
                                                    Row(children: [
                                                      Icon(Icons.person, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text('Người liên hệ: ${supplier.contactName!}', style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                    const SizedBox(height: 4),
                                                  ],
                                                  if (supplier.phoneNumber != null && supplier.phoneNumber!.isNotEmpty) ...[
                                                    Row(children: [
                                                      Icon(Icons.phone, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text(supplier.phoneNumber!, style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                    const SizedBox(height: 4),
                                                  ],
                                                  if (supplier.email != null && supplier.email!.isNotEmpty) ...[
                                                    Row(children: [
                                                      Icon(Icons.email, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text(supplier.email!, style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                    const SizedBox(height: 4),
                                                  ],
                                                  if (supplier.address != null && supplier.address!.isNotEmpty)
                                                    Row(children: [
                                                      Icon(Icons.location_on, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text(supplier.address!, style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                ],
                                              ),
                                            ),
                                            // Action buttons
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                                  onPressed: () => _openSupplierDialog(supplier: supplier),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _deleteSupplier(supplier),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),

                    // Pagination
                    if (_totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.white),
                              onPressed: _currentPage > 1
                                  ? () {
                                      setState(() => _currentPage--);
                                      _fetchSuppliers();
                                    }
                                  : null,
                            ),
                            Text(
                              'Trang $_currentPage / $_totalPages',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Colors.white),
                              onPressed: _currentPage < _totalPages
                                  ? () {
                                      setState(() => _currentPage++);
                                      _fetchSuppliers();
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _removeDiacritics(String str) {
    const vietnamese = 'aAeEoOuUiIdDyYoO';
    final vietnameseRegex = [
      RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'),
      RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'),
      RegExp(r'[èéẹẻẽêềếệểễ]'),
      RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'),
      RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'),
      RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'),
      RegExp(r'[ùúụủũưừứựửữ]'),
      RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'),
      RegExp(r'[ìíịỉĩ]'),
      RegExp(r'[ÌÍỊỈĨ]'),
      RegExp(r'[đ]'),
      RegExp(r'[Đ]'),
      RegExp(r'[ỳýỵỷỹ]'),
      RegExp(r'[ỲÝỴỶỸ]'),
      RegExp(r'[õòóọỏôồốộổỗơờớợởỡ]'),
      RegExp(r'[ÕÒÓỌỎÔỒỐỘỔỖƠỜỚỢỞỠ]')
    ];

    for (int i = 0; i < vietnameseRegex.length; i++) {
      str = str.replaceAll(vietnameseRegex[i], vietnamese[i]);
    }
    return str;
  }

  void _showAccountResultDialog(String username, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111F38),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.teal),
            SizedBox(width: 10),
            Text(
              'Tạo nhà cung cấp thành công!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tài khoản đăng nhập đã được tự động tạo cho nhà cung cấp:',
              style: TextStyle(color: Color(0xFF8FA8C9)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_box, size: 18, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text('Tên đăng nhập: ', style: TextStyle(color: Color(0xFF8FA8C9))),
                      Text(
                        username,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 18, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text('Mật khẩu: ', style: TextStyle(color: Color(0xFF8FA8C9))),
                      Text(
                        password,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Sao chép thông tin'),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text: 'Tài khoản nhà cung cấp:\n- Tên đăng nhập: $username\n- Mật khẩu: $password',
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép thông tin tài khoản đăng nhập!')),
                );
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}