class PurchaseOrderItem {
  final int purchaseOrderDetailId;
  final int medicineId;
  final String medicineName;
  final String? unit;
  final int orderedQuantity;
  final double unitPrice;
  final double lineTotal;

  const PurchaseOrderItem({
    required this.purchaseOrderDetailId,
    required this.medicineId,
    required this.medicineName,
    required this.unit,
    required this.orderedQuantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      purchaseOrderDetailId: json['purchaseOrderDetailID'] as int? ?? 0,
      medicineId: json['medicineID'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      unit: json['unit'] as String?,
      orderedQuantity: json['orderedQuantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
