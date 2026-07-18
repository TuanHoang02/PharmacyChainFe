import 'package:flutter/material.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/models/sales_history_model.dart';
import 'package:pharmacy_chain_fe/features/pharmacist/services/sales_service.dart';

class SalesInvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  const SalesInvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<SalesInvoiceDetailScreen> createState() => _SalesInvoiceDetailScreenState();
}

class _SalesInvoiceDetailScreenState extends State<SalesInvoiceDetailScreen> {
  final SalesService _salesService = SalesService();

  SalesInvoiceDetailModel? _invoice;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _salesService.getSalesInvoiceById(widget.invoiceId);
      setState(() {
        _invoice = details;
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

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
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
          'Chi tiết hóa đơn',
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
                'Lỗi tải chi tiết hóa đơn',
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
                onPressed: _fetchInvoiceDetails,
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

    if (_invoice == null) {
      return const Center(
        child: Text('Không có dữ liệu hóa đơn.', style: TextStyle(color: Colors.white54)),
      );
    }

    final invoice = _invoice!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Invoice Code & Status Header ───────────────────────────
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
                  children: [
                    Text(
                      invoice.invoiceCode,
                      style: const TextStyle(
                        color: Color(0xFF60ABFF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildInvoiceStatusBadge(invoice.invoiceStatus),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng tiền thanh toán',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        Text(
                          _formatCurrency(invoice.totalAmount),
                          style: const TextStyle(
                            color: Color(0xFF00C48C),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildPaymentStatusBadge(invoice.paymentStatus),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Basic Information Row ──────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Thông tin khách hàng & Giao dịch',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                _buildInfoRow(Icons.person_outline, 'Khách hàng', invoice.customerName ?? 'Khách vãng lai'),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', invoice.customerPhoneNumber ?? 'Không có'),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(Icons.payment_outlined, 'Phương thức thanh toán', displayPaymentMethod(invoice.paymentMethod)),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(Icons.storefront_outlined, 'Chi nhánh', invoice.branchName),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(Icons.badge_outlined, 'Dược sĩ bán hàng', invoice.pharmacistName),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(Icons.calendar_today_outlined, 'Ngày lập', _formatDateTime(invoice.createdAt)),
                if (invoice.completedAt != null) ...[
                  const Divider(color: Colors.white10, height: 24),
                  _buildInfoRow(Icons.check_circle_outline, 'Ngày hoàn thành', _formatDateTime(invoice.completedAt!)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Medicines Items ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Danh sách thuốc đã mua',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111F38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
            ),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoice.items.length,
                  itemBuilder: (context, index) {
                    final item = invoice.items[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.medicineName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatCurrency(item.unitPrice)} x ${item.quantity}',
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatCurrency(item.lineTotal),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < invoice.items.length - 1)
                          const Divider(color: Colors.white10, height: 16),
                      ],
                    );
                  },
                ),
                const Divider(color: Colors.white24, height: 24),
                _buildSummaryLine('Tạm tính:', _formatCurrency(invoice.subtotal)),
                const SizedBox(height: 8),
                _buildSummaryLine('Giảm giá:', '- ${_formatCurrency(invoice.discountAmount)}', valueColor: const Color(0xFFFF5252)),
                const SizedBox(height: 8),
                _buildSummaryLine('Tổng cộng:', _formatCurrency(invoice.totalAmount), valueColor: const Color(0xFF00C48C), isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Prescription Section ───────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Đơn thuốc đi kèm (Rx)',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Yêu cầu xác minh đơn thuốc:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    _buildVerificationBadge(invoice.isPrescriptionVerified),
                  ],
                ),
                const SizedBox(height: 16),
                if (invoice.prescriptionImageUrl != null && invoice.prescriptionImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black26,
                      constraints: const BoxConstraints(maxHeight: 300),
                      width: double.infinity,
                      child: Image.network(
                        invoice.prescriptionImageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(Icons.broken_image_outlined, color: Colors.white30, size: 48),
                                  SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh đơn thuốc',
                                    style: TextStyle(color: Colors.white30, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No prescription image.',
                        style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInvoiceStatusBadge(InvoiceStatus status) {
    Color color;
    switch (status) {
      case InvoiceStatus.draft:
        color = const Color(0xFFFF9F43);
        break;
      case InvoiceStatus.finalized:
        color = const Color(0xFF00C48C);
        break;
      case InvoiceStatus.cancelled:
        color = const Color(0xFFFF5252);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        displayInvoiceStatus(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.pending:
        color = const Color(0xFFFF9F43);
        break;
      case PaymentStatus.completed:
        color = const Color(0xFF00C48C);
        break;
      case PaymentStatus.failed:
        color = const Color(0xFFFF5252);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            displayPaymentStatus(status),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(bool? isVerified) {
    final verified = isVerified ?? false;
    final color = verified ? const Color(0xFF00C48C) : const Color(0xFFFF9F43);
    final text = verified ? 'Đã xác minh' : 'Chưa xác minh / Không yêu cầu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String value, {Color valueColor = Colors.white, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : Colors.white70,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
