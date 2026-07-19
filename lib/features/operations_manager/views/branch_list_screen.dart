import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/branch_service.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final BranchService _branchService = BranchService();

  bool _isLoading = false;
  String _searchTerm = '';
  bool? _isActiveFilter;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  int _totalPages = 0;
  List<BranchModel> _branches = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final pagedResponse = await _branchService.getBranches(
        searchTerm: _searchTerm,
        isActive: _isActiveFilter,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _branches = pagedResponse.data;
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

  Future<void> _deleteBranch(BranchModel branch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111F38),
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Color(0xFF8FA8C9)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn dừng hoạt động chi nhánh "${branch.branchName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _branchService.deleteBranch(branch.branchID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa mềm chi nhánh thành công.')),
        );
        _fetchBranches();
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
                          Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Danh sách chi nhánh',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quản lý tất cả chi nhánh trong chuỗi nhà thuốc',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => context.push('/operations/branches/new').then((_) => _fetchBranches()),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm mới', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Row
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
                            // Search field
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm chi nhánh...',
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
                                  _fetchBranches();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Status Dropdown
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
                                    DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
                                    DropdownMenuItem(value: true, child: Text('Đang hoạt động')),
                                    DropdownMenuItem(value: false, child: Text('Dừng hoạt động')),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _isActiveFilter = val;
                                      _currentPage = 1;
                                    });
                                    _fetchBranches();
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
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.red),
                              onPressed: _fetchBranches,
                            )
                          ],
                        ),
                      ),

                    // Content Area
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _branches.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.storefront, size: 64, color: theme.hintColor),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không tìm thấy chi nhánh nào',
                                        style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _branches.length,
                                  itemBuilder: (context, index) {
                                    final branch = _branches[index];
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
                                                          branch.branchName,
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
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: branch.isActive
                                                              ? Colors.teal.withOpacity(0.15)
                                                              : Colors.red.withOpacity(0.15),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(
                                                            color: branch.isActive ? Colors.teal[400]! : Colors.red[400]!,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          branch.isActive ? 'Đang hoạt động' : 'Dừng hoạt động',
                                                          style: TextStyle(
                                                            color: branch.isActive ? Colors.teal[300] : Colors.red[300],
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(children: [
                                                    Icon(Icons.location_on, size: 16, color: theme.hintColor),
                                                    const SizedBox(width: 6),
                                                    Flexible(child: Text(branch.address, style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                  ]),
                                                  if (branch.phoneNumber != null && branch.phoneNumber!.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Row(children: [
                                                      Icon(Icons.phone, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text(branch.phoneNumber!, style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                  ],
                                                  if (branch.email != null && branch.email!.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Row(children: [
                                                      Icon(Icons.email, size: 16, color: theme.hintColor),
                                                      const SizedBox(width: 6),
                                                      Flexible(child: Text(branch.email!, style: TextStyle(color: theme.hintColor), overflow: TextOverflow.ellipsis)),
                                                    ]),
                                                  ],
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
                                                      .push('/operations/branches/edit/${branch.branchID}')
                                                      .then((_) => _fetchBranches()),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _deleteBranch(branch),
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

                    // Pagination controls
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
                                      _fetchBranches();
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
                                      _fetchBranches();
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