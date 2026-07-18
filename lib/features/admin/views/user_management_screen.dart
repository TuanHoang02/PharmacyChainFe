import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/features/admin/models/user_model.dart';
import 'package:pharmacy_chain_fe/features/admin/services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  
  // Pagination & Filtering
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  final TextEditingController _searchController = TextEditingController();

  // Roles & Branches
  List<LookupModel> _availableRoles = [];
  List<LookupModel> _availableBranches = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _userService.getRoles();
      final branches = await _userService.getBranches();
      setState(() {
        _availableRoles = roles;
        _availableBranches = branches;
      });
      await _fetchUsers(); // fetch users after getting lookups
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _userService.getUsers(
        page: _currentPage,
        size: 10,
        keyword: _searchController.text,
      );
      setState(() {
        _users = response.data;
        _totalRecords = response.totalRecords;
        _totalPages = (response.totalRecords / response.pageSize).ceil();
        if (_totalPages == 0) _totalPages = 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deactivateUser(int userId) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận vô hiệu hoá'),
        content: const Text('Bạn có chắc chắn muốn vô hiệu hoá người dùng này không? Họ sẽ không thể đăng nhập được nữa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Vô hiệu hoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    ) ?? false;

    if (!confirm) return;

    try {
      await _userService.deactivateUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vô hiệu hoá người dùng thành công')),
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showUserDialog([UserModel? user]) {
    showDialog(
      context: context,
      builder: (dialogContext) => _UserFormDialog(
        user: user,
        roles: _availableRoles,
        branches: _availableBranches,
        onSaved: (userData) async {
          Navigator.pop(dialogContext); // Close dialog
          try {
            if (user == null) {
              await _userService.createUser(userData);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo người dùng thành công')));
              }
            } else {
              await _userService.updateUser(user.userId, userData);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật người dùng thành công')));
              }
            }
            _fetchUsers();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
            }
          }
        },
      ),
    );
  }

  void _showUserDetailDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${user.userId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Họ và tên: ${user.fullName}'),
            const SizedBox(height: 4),
            Text('Tên đăng nhập: ${user.username}'),
            const SizedBox(height: 4),
            Text('Email: ${user.email ?? 'Không có'}'),
            const SizedBox(height: 4),
            Text('Số điện thoại: ${user.phoneNumber ?? 'Không có'}'),
            const SizedBox(height: 4),
            Text('Vai trò: ${user.roleName}'),
            const SizedBox(height: 4),
            Text('Chi nhánh: ${user.branchName ?? 'Không có'}'),
            const SizedBox(height: 4),
            Text('Trạng thái: ${user.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý người dùng',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 32),
                onPressed: () => _showUserDialog(),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email hoặc số điện thoại',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onSubmitted: (_) {
                    _currentPage = 1;
                    _fetchUsers();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () {
                    // Filter popup placeholder
                    _currentPage = 1;
                    _fetchUsers();
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Tổng số người dùng: $_totalRecords',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Data List
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                ? const Center(child: Text('Không tìm thấy người dùng nào.'))
                : ListView.separated(
                    itemCount: _users.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[200],
                                child: const Icon(Icons.person_outline, size: 30, color: Colors.black54),
                              ),
                              const SizedBox(width: 12),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, size: 14, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            user.email ?? 'Chưa có email',
                                            style: const TextStyle(color: Colors.black87, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 14, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.phoneNumber ?? 'Chưa có SĐT',
                                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                                          child: Text('•', style: TextStyle(color: Colors.black54)),
                                        ),
                                        Expanded(
                                          child: Text(
                                            user.roleName,
                                            style: const TextStyle(color: Colors.black87, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Actions & Badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: user.isActive ? Colors.grey[200] : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade400)
                                        ),
                                        child: Text(
                                          user.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
                                          style: const TextStyle(color: Colors.black87, fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          if (value == 'detail') {
                                            _showUserDetailDialog(user);
                                          } else if (value == 'edit') {
                                            _showUserDialog(user);
                                          } else if (value == 'deactivate') {
                                            _deactivateUser(user.userId);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'detail',
                                            child: Text('Chi tiết'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Chỉnh sửa'),
                                          ),
                                          if (user.isActive)
                                            const PopupMenuItem(
                                              value: 'deactivate',
                                              child: Text('Vô hiệu hoá'),
                                            ),
                                        ],
                                      ),
                                    ],
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
          
          // Pagination Controls
          if (!_isLoading && _users.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1 ? () {
                      setState(() => _currentPage--);
                      _fetchUsers();
                    } : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_currentPage',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('... $_totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages ? () {
                      setState(() => _currentPage++);
                      _fetchUsers();
                    } : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final List<LookupModel> roles;
  final List<LookupModel> branches;
  final Function(Map<String, dynamic>) onSaved;

  const _UserFormDialog({this.user, required this.roles, required this.branches, required this.onSaved});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late String _fullName;
  late String _username;
  String? _email;
  String? _phoneNumber;
  String? _password;
  late int _roleId;
  int? _branchId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullName = user?.fullName ?? '';
    _username = user?.username ?? '';
    _email = user?.email;
    _phoneNumber = user?.phoneNumber;
    // Attempt to match existing role. Default to 1 (Admin) if new
    _roleId = 1; 
    if (user != null && widget.roles.isNotEmpty) {
      final match = widget.roles.firstWhere((r) => r.name == user.roleName, orElse: () => widget.roles.first);
      _roleId = match.id;
    } else if (widget.roles.isNotEmpty) {
      _roleId = widget.roles.first.id;
    }
    
    // Attempt to match branchId
    if (user != null && user.branchName != null && widget.branches.isNotEmpty) {
      final bMatch = widget.branches.firstWhere((b) => b.name == user.branchName, orElse: () => widget.branches.first);
      _branchId = bMatch.id;
    }
    
    _isActive = user?.isActive ?? true;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSaved({
        'fullName': _fullName,
        'username': _username,
        'email': _email,
        'phoneNumber': _phoneNumber,
        'password': _password,
        'roleId': _roleId,
        'branchID': _branchId,
        'isActive': _isActive,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _fullName,
                  decoration: const InputDecoration(labelText: 'Họ và tên *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                  onSaved: (v) => _fullName = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _username,
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                  onSaved: (v) => _username = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(v)) return 'Định dạng email không hợp lệ';
                    }
                    return null;
                  },
                  onSaved: (v) => _email = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _phoneNumber,
                  decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      final phoneRegex = RegExp(r'^\d{10,11}$');
                      if (!phoneRegex.hasMatch(v)) return 'SĐT phải có 10-11 chữ số';
                    }
                    return null;
                  },
                  onSaved: (v) => _phoneNumber = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Mật khẩu (để trống nếu không đổi)' : 'Mật khẩu *', 
                    border: const OutlineInputBorder()
                  ),
                  validator: (v) {
                    if (!isEditing && (v == null || v.isEmpty)) return 'Bắt buộc đối với người dùng mới';
                    return null;
                  },
                  onSaved: (v) => _password = v,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _roleId,
                  decoration: const InputDecoration(labelText: 'Vai trò *', border: OutlineInputBorder()),
                  items: widget.roles.map((r) => DropdownMenuItem<int>(
                    value: r.id,
                    child: Text(r.name),
                  )).toList(),
                  onChanged: (v) => setState(() => _roleId = v!),
                  onSaved: (v) => _roleId = v!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _branchId,
                  decoration: const InputDecoration(labelText: 'Chi nhánh (Tùy chọn)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Không / Trụ sở chính')),
                    ...widget.branches.map((b) => DropdownMenuItem<int?>(
                      value: b.id,
                      child: Text(b.name),
                    )),
                  ],
                  onChanged: (v) => setState(() => _branchId = v),
                  onSaved: (v) => _branchId = v,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Đang hoạt động'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                )
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}
