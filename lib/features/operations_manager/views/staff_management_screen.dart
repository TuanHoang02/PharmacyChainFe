import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/branch_service.dart';
import 'package:pharmacy_chain_fe/shared/services/staff_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final StaffService _staffService = StaffService();
  final BranchService _branchService = BranchService();

  bool _isLoading = false;
  String _searchTerm = '';
  int? _selectedBranchId;
  int? _selectedRoleId;
  bool? _selectedIsActive;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  int _totalPages = 0;
  List<StaffModel> _staffList = [];
  List<BranchModel> _branches = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final branchesResponse = await _branchService.getBranches(isActive: true, pageSize: 100);
      _branches = branchesResponse.data;
      await _fetchStaff();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final pagedResponse = await _staffService.getStaffs(
        searchTerm: _searchTerm,
        branchId: _selectedBranchId,
        roleId: _selectedRoleId,
        isActive: _selectedIsActive,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _staffList = pagedResponse.data;
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

  Future<void> _deleteStaff(StaffModel staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn tạm khóa tài khoản nhân sự "${staff.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạm khóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _staffService.deleteStaff(staff.userID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạm khóa tài khoản nhân viên thành công.')),
        );
        _fetchStaff();
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
                        'Quản lý nhân sự chuỗi',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Quản lý tài khoản quản trị chi nhánh và dược sĩ toàn hệ thống',
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
                    onPressed: () => context.push('/operations/staff/new').then((_) => _fetchStaff()),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mới', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter row
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Search & Status row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Tìm theo họ tên, tên đăng nhập, số điện thoại...',
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
                                _fetchStaff();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Dropdowns filter row
                      Row(
                        children: [
                          // Branch filter
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedBranchId,
                                  hint: const Text('Tất cả chi nhánh'),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Tất cả chi nhánh')),
                                    ..._branches.map((b) => DropdownMenuItem(value: b.branchID, child: Text(b.branchName))),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedBranchId = val;
                                      _currentPage = 1;
                                    });
                                    _fetchStaff();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Role filter
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedRoleId,
                                  hint: const Text('Tất cả vai trò'),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: null, child: Text('Tất cả vai trò')),
                                    DropdownMenuItem(value: 3, child: Text('Pharmacist (Dược sĩ)')),
                                    DropdownMenuItem(value: 4, child: Text('BranchManager (Quản lý)')),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedRoleId = val;
                                      _currentPage = 1;
                                    });
                                    _fetchStaff();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Status Filter
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<bool?>(
                                  value: _selectedIsActive,
                                  hint: const Text('Tất cả trạng thái'),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
                                    DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
                                    DropdownMenuItem(value: false, child: Text('Bị tạm khóa')),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedIsActive = val;
                                      _currentPage = 1;
                                    });
                                    _fetchStaff();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: _fetchStaff)
                    ],
                  ),
                ),

              // Staff List Card
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _staffList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Không tìm thấy nhân viên nào',
                                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              final staff = _staffList[index];
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
                                  leading: CircleAvatar(
                                    backgroundColor: staff.roleID == 4
                                        ? Colors.orange[50]
                                        : Colors.teal[50],
                                    child: Icon(
                                      staff.roleID == 4 ? Icons.manage_accounts : Icons.health_and_safety,
                                      color: staff.roleID == 4 ? Colors.orange[700] : Colors.teal[700],
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          staff.fullName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: staff.isActive ? Colors.teal[50] : Colors.red[50],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: staff.isActive ? Colors.teal[200]! : Colors.red[200]!,
                                          ),
                                        ),
                                        child: Text(
                                          staff.isActive ? 'Hoạt động' : 'Tạm khóa',
                                          style: TextStyle(
                                            color: staff.isActive ? Colors.teal[700] : Colors.red[700],
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
                                        Row(
                                          children: [
                                            const Icon(Icons.security, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Quyền: ${staff.roleName}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.storefront, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text('Chi nhánh: ${staff.branchName ?? "Toàn chuỗi"}'),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(staff.phoneNumber ?? 'Chưa có SĐT'),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.email, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(staff.email ?? 'Chưa có email'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => context
                                            .push('/operations/staff/edit/${staff.userID}')
                                            .then((_) => _fetchStaff()),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.lock_outline, color: Colors.red),
                                        onPressed: () => _deleteStaff(staff),
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
                                _fetchStaff();
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
                                _fetchStaff();
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
