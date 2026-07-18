import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/features/branch_manager/services/medicine_service.dart';
import 'package:pharmacy_chain_fe/shared/models/medicine_model.dart';

class PharmacistMedicineDetailScreen extends StatefulWidget {
  final int medicineId;
  const PharmacistMedicineDetailScreen({super.key, required this.medicineId});

  @override
  State<PharmacistMedicineDetailScreen> createState() => _PharmacistMedicineDetailScreenState();
}

class _PharmacistMedicineDetailScreenState extends State<PharmacistMedicineDetailScreen> {
  final MedicineService _medicineService = MedicineService();

  MedicineDetailModel? _medicine;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _medicineService.getMedicineById(widget.medicineId);
      setState(() {
        _medicine = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final localDt = dt.toLocal();
    final day = localDt.day.toString().padLeft(2, '0');
    final month = localDt.month.toString().padLeft(2, '0');
    final year = localDt.year;
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111F38),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết thuốc (Dược sĩ)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5252), size: 60),
              const SizedBox(height: 16),
              const Text(
                'Lỗi tải chi tiết thuốc',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_medicine == null) {
      return const Center(
        child: Text('Không có dữ liệu thuốc.', style: TextStyle(color: Colors.white54)),
      );
    }

    final medicine = _medicine!;
    final formattedPrice = medicine.sellingPrice
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Medicine Identity Header ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111F38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        medicine.medicineName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(medicine.isActive),
                  ],
                ),
                const SizedBox(height: 8),
                if (medicine.genericName != null && medicine.genericName!.isNotEmpty) ...[
                  Text(
                    'Tên gốc (Generic Name):',
                    style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medicine.genericName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá bán lẻ',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        Text(
                          '$formattedPrice đ',
                          style: const TextStyle(
                            color: Color(0xFF00C48C),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: medicine.requiresPrescription
                            ? const Color(0xFFFF5252).withAlpha(20)
                            : const Color(0xFF00C48C).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: medicine.requiresPrescription
                              ? const Color(0xFFFF5252)
                              : const Color(0xFF00C48C),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        medicine.requiresPrescription ? 'Cần kê đơn (Rx)' : 'Không kê đơn (OTC)',
                        style: TextStyle(
                          color: medicine.requiresPrescription
                              ? const Color(0xFFFF5252)
                              : const Color(0xFF00C48C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Detailed Attributes ────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Thông tin chi tiết',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111F38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.category_outlined, 'Danh mục', medicine.categoryName),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(Icons.line_weight_outlined, 'Đơn vị tính', medicine.unit),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(
                  Icons.description_outlined,
                  'Hướng dẫn liều dùng',
                  medicine.dosageInstructions ?? 'Không có hướng dẫn chi tiết.',
                  isMultiLine: true,
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Ngày tạo',
                  _formatDateTime(medicine.createdAt),
                ),
                if (medicine.updatedAt != null) ...[
                  const Divider(color: Colors.white10, height: 24),
                  _buildInfoRow(
                    Icons.edit_calendar_outlined,
                    'Cập nhật lần cuối',
                    _formatDateTime(medicine.updatedAt!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00C48C).withAlpha(30)
            : const Color(0xFFFF5252).withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF00C48C) : const Color(0xFFFF5252),
          width: 1.2,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? const Color(0xFF00C48C) : const Color(0xFFFF5252),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
