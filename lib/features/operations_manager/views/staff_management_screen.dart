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

  Widget _buildRoleBadge(String roleName) {
    Color badgeColor;
    Color textColor;
    String displayRole = roleName;
    
    final roleLower = roleName.toLowerCase();
    if (roleLower.contains('pharmacist') || roleLower.contains('dược sĩ')) {
      badgeColor = Colors.teal.withOpacity(0.15);
      textColor = Colors.teal[300]!;
      displayRole = 'Dược sĩ';
    } else if (roleLower.contains('branchmanager') || roleLower.contains('quản lý')) {
      badgeColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange[300]!;
      displayRole = 'Quản lý';
    } else if (roleLower.contains('operationsmanager') || roleLower.contains('vận hành')) {
      badgeColor = Colors.purple.withOpacity(0.15);
      textColor = Colors.purple[300]!;
      displayRole = 'Vận hành';
    } else {
      badgeColor = Colors.blue.withOpacity(0.15);
      textColor = Colors.blue[300]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayRole,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


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
        backgroundColor: const Color(0xFF111F38),
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Color(0xFF8FA8C9)),
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
                                'Quản lý nhân sự chuỗi',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quản lý tài khoản quản trị chi nhánh và dược sĩ toàn hệ thống',
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
                        side: BorderSide(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: theme.cardColor,
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
                                      border: Border.all(color: theme.dividerColor),
                                      color: const Color(0xFF0A1628),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int?>(
                                        dropdownColor: const Color(0xFF0A1628),
                                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8FA8C9)),
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        value: _selectedBranchId,
                                        hint: const Text('Tất cả chi nhánh', style: TextStyle(color: Color(0xFF8FA8C9))),
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
                                      border: Border.all(color: theme.dividerColor),
                                      color: const Color(0xFF0A1628),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int?>(
                                        dropdownColor: const Color(0xFF0A1628),
                                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8FA8C9)),
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        value: _selectedRoleId,
                                        hint: const Text('Tất cả vai trò', style: TextStyle(color: Color(0xFF8FA8C9))),
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(value: null, child: Text('Tất cả vai trò')),
                                          DropdownMenuItem(value: 4, child: Text('Pharmacist (Dược sĩ)')),
                                          DropdownMenuItem(value: 3, child: Text('BranchManager (Quản lý)')),
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
                                      border: Border.all(color: theme.dividerColor),
                                      color: const Color(0xFF0A1628),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<bool?>(
                                        dropdownColor: const Color(0xFF0A1628),
                                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8FA8C9)),
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        value: _selectedIsActive,
                                        hint: const Text('Tất cả trạng thái', style: TextStyle(color: Color(0xFF8FA8C9))),
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
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                                      Icon(Icons.people_outline, size: 64, color: theme.hintColor),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không tìm thấy nhân viên nào',
                                        style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
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
                                        side: BorderSide(color: theme.dividerColor),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: theme.cardColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Leading avatar
                                            CircleAvatar(
                                              backgroundColor: staff.roleID == 4
                                                  ? Colors.orange.withOpacity(0.2)
                                                  : Colors.teal.withOpacity(0.2),
                                              child: Icon(
                                                staff.roleID == 4 ? Icons.manage_accounts : Icons.health_and_safety,
                                                color: staff.roleID == 4 ? Colors.orange[300] : Colors.teal[300],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                                          staff.fullName,
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
                                                          color: staff.isActive
                                                              ? Colors.teal.withOpacity(0.15)
                                                              : Colors.red.withOpacity(0.15),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(
                                                            color: staff.isActive ? Colors.teal[400]! : Colors.red[400]!,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          staff.isActive ? 'Hoạt động' : 'Tạm khóa',
                                                          style: TextStyle(
                                                            color: staff.isActive ? Colors.teal[300] : Colors.red[300],
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // Role badge & Branch name
                                                  Row(
                                                    children: [
                                                      _buildRoleBadge(staff.roleName),
                                                      const SizedBox(width: 8),
                                                      const Icon(Icons.storefront, size: 14, color: Color(0xFF8FA8C9)),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          staff.branchName ?? 'Toàn chuỗi',
                                                          style: TextStyle(color: theme.hintColor, fontSize: 13),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // Phone & Email
                                                  Row(
                                                    children: [
                                                      if (staff.phoneNumber != null && staff.phoneNumber!.isNotEmpty) ...[
                                                        const Icon(Icons.phone, size: 14, color: Color(0xFF8FA8C9)),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          staff.phoneNumber!,
                                                          style: TextStyle(color: theme.hintColor, fontSize: 13),
                                                        ),
                                                        const SizedBox(width: 12),
                                                      ],
                                                      if (staff.email != null && staff.email!.isNotEmpty) ...[
                                                        const Icon(Icons.email, size: 14, color: Color(0xFF8FA8C9)),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            staff.email!,
                                                            style: TextStyle(color: theme.hintColor, fontSize: 13),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Action buttons
                                            Column(
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
                                      _fetchStaff();
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
        },
      ),
    );
  }
}