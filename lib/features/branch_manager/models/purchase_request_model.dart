class PurchaseRequestModel {
  final int purchaseRequestId;
  final String requestCode;
  final int branchId;
  final int createdByUserId;
  final String status;
  final String? reason;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final List<PurchaseRequestDetailModel> details;

  PurchaseRequestModel({
    required this.purchaseRequestId,
    required this.requestCode,
    required this.branchId,
    required this.createdByUserId,
    required this.status,
    this.reason,
    this.reviewNote,
    required this.createdAt,
    this.reviewedAt,
    required this.details,
  });

  factory PurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestModel(
      purchaseRequestId: json['purchaseRequestId'],
      requestCode: json['requestCode'],
      branchId: json['branchId'],
      createdByUserId: json['createdByUserId'],
      status: json['status'],
      reason: json['reason'],
      reviewNote: json['reviewNote'],
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      details: (json['details'] as List)
          .map((item) => PurchaseRequestDetailModel.fromJson(item))
          .toList(),
    );
  }
}

class PurchaseRequestDetailModel {
  final int purchaseRequestDetailId;
  final int medicineId;
  final String medicineName;
  final int requestedQuantity;
  final int currentStock;

  PurchaseRequestDetailModel({
    required this.purchaseRequestDetailId,
    required this.medicineId,
    required this.medicineName,
    required this.requestedQuantity,
    required this.currentStock,
  });

  factory PurchaseRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDetailModel(
      purchaseRequestDetailId: json['purchaseRequestDetailId'],
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      requestedQuantity: json['requestedQuantity'],
      currentStock: json['currentStock'],
    );
  }
}
