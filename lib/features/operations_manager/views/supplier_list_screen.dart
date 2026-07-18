import 'package:flutter/material.dart';
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
    bool isActive = supplier?.isActive ?? true;
    bool isSaving = false;
    String dialogError = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(supplier == null ? 'Thêm nhà cung cấp mới' : 'Cập nhật nhà cung cấp'),
              content: SizedBox(
                width: 450,
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
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Text(dialogError, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ),
                        ],
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
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
                              await _supplierService.createSupplier(
                                supplierName: nameController.text.trim(),
                                contactName: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                                phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(supplier == null
                                      ? 'Thêm nhà cung cấp thành công.'
                                      : 'Cập nhật nhà cung cấp thành công.'),
                                ),
                              );
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhà cung cấp',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Quản lý danh sách đối tác cung cấp dược phẩm',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
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
                  side: BorderSide(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
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
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[200]!),
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
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<bool?>(
                            value: _isActiveFilter,
                            hint: const Text('Trạng thái'),
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
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
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
                                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Không tìm thấy nhà cung cấp nào',
                                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
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
                                  side: BorderSide(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          supplier.supplierName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: supplier.isActive ? Colors.teal[50] : Colors.red[50],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: supplier.isActive ? Colors.teal[200]! : Colors.red[200]!,
                                          ),
                                        ),
                                        child: Text(
                                          supplier.isActive ? 'Hoạt động' : 'Tạm dừng',
                                          style: TextStyle(
                                            color: supplier.isActive ? Colors.teal[700] : Colors.red[700],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (supplier.contactName != null && supplier.contactName!.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              const Icon(Icons.person, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text('Người liên hệ: ${supplier.contactName!}',
                                                  style: const TextStyle(color: Colors.black87)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        if (supplier.phoneNumber != null && supplier.phoneNumber!.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(supplier.phoneNumber!, style: const TextStyle(color: Colors.black87)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        if (supplier.email != null && supplier.email!.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              const Icon(Icons.email, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(supplier.email!, style: const TextStyle(color: Colors.black87)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        if (supplier.address != null && supplier.address!.isNotEmpty) ...[
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(supplier.address!, style: const TextStyle(color: Colors.black87)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
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
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _fetchSuppliers();
                              }
                            : null,
                      ),
                      Text(
                        'Trang $_currentPage / $_totalPages',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
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
  }
}
