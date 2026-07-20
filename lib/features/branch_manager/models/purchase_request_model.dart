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
  final List<PurchaseOrderSummaryModel> purchaseOrders;

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
    required this.purchaseOrders,
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
      purchaseOrders: json['purchaseOrders'] != null
          ? (json['purchaseOrders'] as List)
              .map((item) => PurchaseOrderSummaryModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

class PurchaseOrderSummaryModel {
  final int purchaseOrderId;
  final String orderCode;
  final int supplierId;
  final String supplierName;
  final String deliveryStatus;
  final List<PurchaseOrderSummaryDetailModel> details;

  PurchaseOrderSummaryModel({
    required this.purchaseOrderId,
    required this.orderCode,
    required this.supplierId,
    required this.supplierName,
    required this.deliveryStatus,
    required this.details,
  });

  factory PurchaseOrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSummaryModel(
      purchaseOrderId: json['purchaseOrderId'],
      orderCode: json['orderCode'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      deliveryStatus: json['deliveryStatus'],
      details: json['details'] != null
          ? (json['details'] as List)
              .map((item) => PurchaseOrderSummaryDetailModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

class PurchaseOrderSummaryDetailModel {
  final int medicineId;
  final String medicineName;
  final int orderedQuantity;
  final int receivedQuantity;
  final List<PreDeclaredBatchModel> batches;

  PurchaseOrderSummaryDetailModel({
    required this.medicineId,
    required this.medicineName,
    required this.orderedQuantity,
    required this.receivedQuantity,
    required this.batches,
  });

  factory PurchaseOrderSummaryDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSummaryDetailModel(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      orderedQuantity: json['orderedQuantity'],
      receivedQuantity: json['receivedQuantity'],
      batches: json['batches'] != null
          ? (json['batches'] as List)
              .map((item) => PreDeclaredBatchModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

class PreDeclaredBatchModel {
  final int medicineBatchId;
  final String batchNumber;
  final int declaredQuantity;
  final DateTime manufacturingDate;
  final DateTime expirationDate;

  PreDeclaredBatchModel({
    required this.medicineBatchId,
    required this.batchNumber,
    required this.declaredQuantity,
    required this.manufacturingDate,
    required this.expirationDate,
  });

  factory PreDeclaredBatchModel.fromJson(Map<String, dynamic> json) {
    return PreDeclaredBatchModel(
      medicineBatchId: json['medicineBatchId'],
      batchNumber: json['batchNumber'],
      declaredQuantity: json['declaredQuantity'],
      manufacturingDate: DateTime.parse(json['manufacturingDate']),
      expirationDate: DateTime.parse(json['expirationDate']),
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
