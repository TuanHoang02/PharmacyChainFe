class MedicineBatchSummary {
  final int medicineBatchId;
  final String batchNumber;
  final String medicineName;
  final String purchaseOrderCode;
  final String branchName;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final int receivedQuantity;
  final int remainingQuantity;
  final DateTime createdAt;

  MedicineBatchSummary({
    required this.medicineBatchId,
    required this.batchNumber,
    required this.medicineName,
    required this.purchaseOrderCode,
    required this.branchName,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.receivedQuantity,
    required this.remainingQuantity,
    required this.createdAt,
  });

  factory MedicineBatchSummary.fromJson(Map<String, dynamic> json) {
    return MedicineBatchSummary(
      medicineBatchId: json['medicineBatchID'] as int? ?? 0,
      batchNumber: json['batchNumber'] as String? ?? '',
      medicineName: json['medicineName'] as String? ?? '',
      purchaseOrderCode: json['purchaseOrderCode'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      manufacturingDate: DateTime.parse(json['manufacturingDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      receivedQuantity: json['receivedQuantity'] as int? ?? 0,
      remainingQuantity: json['remainingQuantity'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
