import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_chain_fe/shared/models/purchase_request_model.dart';
import 'package:pharmacy_chain_fe/shared/models/lookup_model.dart';
import '../services/purchase_request_service.dart';

class PurchaseRequestsScreen extends StatefulWidget {
  const PurchaseRequestsScreen({super.key});

  @override
  State<PurchaseRequestsScreen> createState() => _PurchaseRequestsScreenState();
}

class _PurchaseRequestsScreenState extends State<PurchaseRequestsScreen> {
  final PurchaseRequestService _service = PurchaseRequestService();
  
  List<PurchaseRequestModel> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  final int _pageSize = 10;
  
  List<LookupModel> _branches = [];
  int? _selectedBranchId;
  String? _selectedStatus;

  final List<String> _statuses = ['Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final branches = await _service.getBranches();
      setState(() {
        _branches = branches;
      });
      await _fetchRequests();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pagedResponse = await _service.getPurchaseRequests(
        page: _currentPage,
        size: _pageSize,
        status: _selectedStatus,
        branchId: _selectedBranchId,
      );
      setState(() {
        _requests = pagedResponse.data;
        _totalRecords = pagedResponse.totalRecords;
        _totalPages = pagedResponse.totalPages > 0 ? pagedResponse.totalPages : 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged() {
    _currentPage = 1;
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Danh sách Yêu cầu Nhập hàng',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter Toolbar
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    isExpanded: true,
                    value: _selectedBranchId,
                    decoration: InputDecoration(
                      labelText: 'Lọc theo Chi nhánh',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Tất cả chi nhánh', overflow: TextOverflow.ellipsis)),
                      ..._branches.map((b) => DropdownMenuItem<int?>(
                        value: b.id,
                        child: Text(b.name, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedBranchId = v);
                      _onFilterChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Tất cả trạng thái', overflow: TextOverflow.ellipsis)),
                      ..._statuses.map((s) => DropdownMenuItem<String?>(
                        value: s,
                        child: Text(s, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedStatus = v);
                      _onFilterChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Tổng số yêu cầu: $_totalRecords',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // Data List
            Expanded(
              child: _buildList(),
            ),
            
            // Pagination Controls
            if (!_isLoading && _requests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: _buildPaginationRow(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRequests,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return const Center(child: Text('Không tìm thấy yêu cầu nhập hàng nào.'));
    }

    return ListView.builder(
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1E3A5F)),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Mã yêu cầu: ${request.requestCode}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(request.status),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: Color(0xFF60ABFF)),
                      const SizedBox(width: 4),
                      Text('Chi nhánh: ${request.branchName ?? 'N/A'}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF60ABFF)),
                      const SizedBox(width: 4),
                      Text('Ngày tạo: ${request.createdAt.toLocal().toString().split('.')[0]}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF60ABFF)),
                      const SizedBox(width: 4),
                      Text('Người tạo: ${request.createdByUserName ?? 'N/A'}'),
                    ],
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/operations/purchase-requests/${request.purchaseRequestId}').then((_) {
                // Refresh list when coming back
                _fetchRequests();
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'Pending':
        bgColor = const Color(0xFFFFA726).withAlpha(40);
        textColor = const Color(0xFFFFCC80);
        text = 'Chờ duyệt';
        break;
      case 'Approved':
        bgColor = const Color(0xFF00C48C).withAlpha(40);
        textColor = const Color(0xFF80FFD0);
        text = 'Đã duyệt';
        break;
      case 'Rejected':
        bgColor = const Color(0xFFEF5350).withAlpha(40);
        textColor = const Color(0xFFFF8A80);
        text = 'Đã từ chối';
        break;
      default:
        bgColor = const Color(0xFF607D9E).withAlpha(40);
        textColor = const Color(0xFFB0BEC5);
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildPaginationRow() {
    List<Widget> pageButtons = [];
    
    pageButtons.add(
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: _currentPage > 1 ? () {
          setState(() => _currentPage--);
          _fetchRequests();
        } : null,
      ),
    );

    List<int> pages = [];
    if (_totalPages <= 5) {
      for (int i = 1; i <= _totalPages; i++) {
        pages.add(i);
      }
    } else {
      if (_currentPage <= 3) {
        pages.addAll([1, 2, 3, -1, _totalPages]); 
      } else if (_currentPage >= _totalPages - 2) {
        pages.addAll([1, -1, _totalPages - 2, _totalPages - 1, _totalPages]);
      } else {
        pages.addAll([1, -1, _currentPage - 1, _currentPage, _currentPage + 1, -1, _totalPages]);
      }
    }

    for (var page in pages) {
      if (page == -1) {
        pageButtons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
        ));
      } else {
        bool isActive = page == _currentPage;
        pageButtons.add(
          InkWell(
            onTap: isActive ? null : () {
              setState(() => _currentPage = page);
              _fetchRequests();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1E88E5) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive ? null : Border.all(color: Colors.grey.withAlpha(50)),
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
        );
      }
    }

    pageButtons.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: _currentPage < _totalPages ? () {
          setState(() => _currentPage++);
          _fetchRequests();
        } : null,
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: pageButtons,
    );
  }
}
