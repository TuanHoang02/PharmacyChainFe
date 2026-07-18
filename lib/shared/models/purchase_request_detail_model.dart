class PurchaseRequestDetailModel {
  final int purchaseRequestDetailId;
  final int purchaseRequestId;
  final int medicineId;
  final String? medicineName;
  final String? unit;
  final int currentStock;
  final int requestedQuantity;

  PurchaseRequestDetailModel({
    required this.purchaseRequestDetailId,
    required this.purchaseRequestId,
    required this.medicineId,
    this.medicineName,
    this.unit,
    required this.currentStock,
    required this.requestedQuantity,
  });

  factory PurchaseRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDetailModel(
      purchaseRequestDetailId: json['purchaseRequestDetailID'] ?? json['purchaseRequestDetailId'] ?? 0,
      purchaseRequestId: json['purchaseRequestID'] ?? json['purchaseRequestId'] ?? 0,
      medicineId: json['medicineID'] ?? json['medicineId'] ?? 0,
      medicineName: json['medicineName'],
      unit: json['unit'],
      currentStock: json['currentStock'] ?? 0,
      requestedQuantity: json['requestedQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseRequestDetailID': purchaseRequestDetailId,
      'purchaseRequestID': purchaseRequestId,
      'medicineID': medicineId,
      'medicineName': medicineName,
      'unit': unit,
      'currentStock': currentStock,
      'requestedQuantity': requestedQuantity,
    };
  }
}
