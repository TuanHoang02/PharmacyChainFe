import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/core/network/local_storage_service.dart';
import 'package:pharmacy_chain_fe/shared/services/staff_service.dart';

class BranchStaffScreen extends StatefulWidget {
  const BranchStaffScreen({super.key});

  @override
  State<BranchStaffScreen> createState() => _BranchStaffScreenState();
}

class _BranchStaffScreenState extends State<BranchStaffScreen> {
  final StaffService _staffService = StaffService();
  final LocalStorageService _storageService = LocalStorageService();

  bool _isLoading = false;
  String _searchTerm = '';
  int? _currentUserBranchId;
  bool? _selectedIsActive;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  int _totalPages = 0;
  List<StaffModel> _staffList = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserBranchAndFetch();
  }

  Future<void> _loadUserBranchAndFetch() async {
    final bIdStr = await _storageService.getBranchId();
    final bId = bIdStr != null ? int.tryParse(bIdStr) : null;
    if (mounted) {
      setState(() {
        _currentUserBranchId = bId;
      });
      _fetchStaff();
    }
  }

  Future<void> _fetchStaff() async {
    if (_currentUserBranchId == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy ID chi nhánh của bạn. Vui lòng đăng nhập lại.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _staffService.getStaffs(
        searchTerm: _searchTerm,
        branchId: _currentUserBranchId,
        isActive: _selectedIsActive,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _staffList = response.data;
        _totalRecords = response.totalRecords;
        _totalPages = response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _staffList = [];
      });
    }
  }

  Future<void> _deleteStaff(StaffModel staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111F38),
        title: const Text('Xác nhận khóa tài khoản', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn ngừng hoạt động nhân viên "${staff.fullName}" không?',
          style: const TextStyle(color: Color(0xFF8FA8C9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF8FA8C9))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Khóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _staffService.deleteStaff(staff.userID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật trạng thái ngừng hoạt động nhân viên.')),
        );
        _fetchStaff();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
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
                        const Text(
                          'Nhân sự chi nhánh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Quản lý danh sách dược sĩ thuộc chi nhánh của bạn',
                          style: TextStyle(
                            color: Color(0xFF8FA8C9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C48C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.push('/manager/staff/new').then((_) => _fetchStaff()),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm Dược sĩ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Row
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF111F38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm dược sĩ theo tên, SĐT...',
                          hintStyle: const TextStyle(color: Color(0xFF8FA8C9), fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA8C9)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          filled: true,
                          fillColor: const Color(0xFF0A1628),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF00C48C)),
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
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E3A5F)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<bool?>(
                          value: _selectedIsActive,
                          dropdownColor: const Color(0xFF0A1628),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8FA8C9)),
                          hint: const Text('Trạng thái', style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 14)),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tất cả')),
                            DropdownMenuItem(value: true, child: Text('Hoạt động')),
                            DropdownMenuItem(value: false, child: Text('Bị khóa')),
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
                  ],
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
                    border: Border.all(color: Colors.red[800]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.redAccent),
                        onPressed: _fetchStaff,
                      )
                    ],
                  ),
                ),

              // Content Area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C48C)))
                    : _staffList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.badge_outlined, size: 64, color: Color(0xFF8FA8C9)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Không tìm thấy nhân viên nào trong chi nhánh này',
                                  style: TextStyle(color: Color(0xFF8FA8C9), fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              final staff = _staffList[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111F38),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF1E3A5F)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF0A1628),
                                    child: const Icon(Icons.medical_services, color: Color(0xFF00C48C)),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          staff.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: staff.isActive
                                              ? const Color(0xFF00C48C).withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: staff.isActive
                                                ? const Color(0xFF00C48C).withOpacity(0.3)
                                                : Colors.red.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          staff.isActive ? 'Active' : 'Locked',
                                          style: TextStyle(
                                            color: staff.isActive ? const Color(0xFF00C48C) : Colors.redAccent,
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
                                            const Icon(Icons.security, size: 14, color: Color(0xFF8FA8C9)),
                                            const SizedBox(width: 6),
                                            Text(staff.roleName, style: const TextStyle(color: Color(0xFF8FA8C9))),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.phone, size: 14, color: Color(0xFF8FA8C9)),
                                            const SizedBox(width: 6),
                                            Text(staff.phoneNumber ?? 'Chưa có SĐT', style: const TextStyle(color: Color(0xFF8FA8C9))),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email, size: 14, color: Color(0xFF8FA8C9)),
                                            const SizedBox(width: 6),
                                            Text(staff.email ?? 'Chưa có email', style: const TextStyle(color: Color(0xFF8FA8C9))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFF1E88E5)),
                                        onPressed: () => context
                                            .push('/manager/staff/edit/${staff.userID}')
                                            .then((_) => _fetchStaff()),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.lock_outline, color: Colors.redAccent),
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
  }
}
