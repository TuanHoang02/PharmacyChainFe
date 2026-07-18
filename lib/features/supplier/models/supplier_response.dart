class SupplierResponse {
  final int purchaseOrderId;
  final String orderStatus;
  final DateTime confirmedAt;
  final String? rejectionReason;

  const SupplierResponse({
    required this.purchaseOrderId,
    required this.orderStatus,
    required this.confirmedAt,
    this.rejectionReason,
  });

  factory SupplierResponse.fromJson(Map<String, dynamic> json) {
    return SupplierResponse(
      purchaseOrderId: json['purchaseOrderID'] as int? ?? 0,
      orderStatus: json['orderStatus'] as String? ?? '',
      confirmedAt:
          DateTime.tryParse(json['confirmedAt'] as String? ?? '') ??
              DateTime.now(),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}
