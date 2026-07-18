import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_item.dart';
import 'package:pharmacy_chain_fe/features/supplier/models/purchase_order_summary.dart';

class PurchaseOrderDetail extends PurchaseOrderSummary {
  final String? branchPhoneNumber;
  final String? notes;
  final String? createdByFullName;
  final DateTime? confirmedAt;
  final List<PurchaseOrderItem> items;
  final String? supplierResponseNote;
  final DateTime? deliveredAt;

  const PurchaseOrderDetail({
    required super.purchaseOrderId,
    required super.purchaseOrderCode,
    required super.branchId,
    required super.branchName,
    required super.branchAddress,
    required super.orderDate,
    required super.expectedDeliveryDate,
    required super.totalAmount,
    required super.orderStatus,
    required super.deliveryStatus,
    required this.branchPhoneNumber,
    required this.notes,
    required this.createdByFullName,
    required this.confirmedAt,
    required this.items,
    this.supplierResponseNote,
    this.deliveredAt,
  });

  factory PurchaseOrderDetail.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return PurchaseOrderDetail(
      purchaseOrderId: json['purchaseOrderID'] as int? ?? 0,
      purchaseOrderCode: json['purchaseOrderCode'] as String? ?? '',
      branchId: json['branchID'] as int? ?? 0,
      branchName: json['branchName'] as String? ?? '',
      branchAddress: json['branchAddress'] as String? ?? '',
      orderDate: DateTime.tryParse(json['orderDate'] as String? ?? '') ?? DateTime.now(),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.tryParse(json['expectedDeliveryDate'] as String)
          : null,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderStatus: json['orderStatus'] as String? ?? '',
      deliveryStatus: json['deliveryStatus'] as String? ?? '',
      branchPhoneNumber: json['branchPhoneNumber'] as String?,
      notes: json['notes'] as String?,
      createdByFullName: json['createdByFullName'] as String?,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'] as String)
          : null,
      items: items,
      supplierResponseNote: json['supplierResponseNote'] as String?,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
    );
  }
}
