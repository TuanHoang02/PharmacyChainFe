import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/features/operations_manager/services/category_service.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryService _categoryService = CategoryService();

  bool _isLoading = false;
  String _searchTerm = '';
  bool? _isActiveFilter;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;
  int _totalPages = 0;
  List<CategoryModel> _categories = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final pagedResponse = await _categoryService.getCategories(
        searchTerm: _searchTerm,
        isActive: _isActiveFilter,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _categories = pagedResponse.data;
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

  void _openCategoryDialog({CategoryModel? category}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.categoryName ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    bool isActive = category?.isActive ?? true;
    bool isSaving = false;
    String dialogError = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(category == null ? 'Thêm danh mục mới' : 'Cập nhật danh mục'),
              content: SingleChildScrollView(
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
                          labelText: 'Tên danh mục *',
                          hintText: 'Nhập tên danh mục thuốc',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên danh mục';
                          }
                          if (value.trim().length > 100) {
                            return 'Tên danh mục không quá 100 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          hintText: 'Mô tả ngắn về danh mục thuốc',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().length > 255) {
                            return 'Mô tả không được quá 255 ký tự';
                          }
                          return null;
                        },
                      ),
                      if (category != null) ...[
                        const SizedBox(height: 16),
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
                            if (category == null) {
                              await _categoryService.createCategory(
                                categoryName: nameController.text.trim(),
                                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                              );
                            } else {
                              await _categoryService.updateCategory(
                                category.categoryID,
                                categoryName: nameController.text.trim(),
                                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                                isActive: isActive,
                              );
                            }
                            if (mounted) {
                              Navigator.pop(context);
                              _fetchCategories();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(category == null
                                      ? 'Thêm danh mục thành công.'
                                      : 'Cập nhật danh mục thành công.'),
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
                      : Text(category == null ? 'Lưu' : 'Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111F38),
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Color(0xFF8FA8C9)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn dừng hoạt động danh mục "${category.categoryName}"?'),
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
        await _categoryService.deleteCategory(category.categoryID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa mềm danh mục thành công.')),
        );
        _fetchCategories();
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
                                'Danh mục thuốc',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quản lý nhóm phân loại thuốc trong hệ thống',
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
                          onPressed: () => _openCategoryDialog(),
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
                                  hintText: 'Tìm kiếm danh mục...',
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
                                  _fetchCategories();
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
                                    _fetchCategories();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error message
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
                            IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: _fetchCategories)
                          ],
                        ),
                      ),

                    // Grid view or list of categories
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _categories.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.category_outlined, size: 64, color: theme.hintColor),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không tìm thấy danh mục nào',
                                        style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    return Card(
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: theme.dividerColor),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: theme.cardColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            // Left indicator icon
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withOpacity(0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.folder, color: theme.colorScheme.primary),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          category.categoryName,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: category.isActive
                                                              ? Colors.teal.withOpacity(0.15)
                                                              : Colors.red.withOpacity(0.15),
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(
                                                            color: category.isActive ? Colors.teal[400]! : Colors.red[400]!,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          category.isActive ? 'Hoạt động' : 'Tạm dừng',
                                                          style: TextStyle(
                                                            color: category.isActive ? Colors.teal[300] : Colors.red[300],
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    category.description ?? 'Không có mô tả.',
                                                    style: TextStyle(
                                                      color: theme.hintColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Action buttons
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () => _openCategoryDialog(category: category),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteCategory(category),
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
                                      _fetchCategories();
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
                                      _fetchCategories();
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