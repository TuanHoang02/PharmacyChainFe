import 'package:pharmacy_chain_fe/features/supplier/models/medicine_batch_summary.dart';

class MedicineBatchDetail extends MedicineBatchSummary {
  final int medicineId;
  final String supplierName;

  MedicineBatchDetail({
    required super.medicineBatchId,
    required super.batchNumber,
    required this.medicineId,
    required super.medicineName,
    required this.supplierName,
    required super.branchName,
    required super.purchaseOrderCode,
    required super.manufacturingDate,
    required super.expiryDate,
    required super.receivedQuantity,
    required super.remainingQuantity,
    required super.createdAt,
  });

  factory MedicineBatchDetail.fromJson(Map<String, dynamic> json) {
    return MedicineBatchDetail(
      medicineBatchId: json['medicineBatchID'] as int? ?? 0,
      batchNumber: json['batchNumber'] as String? ?? '',
      medicineId: json['medicineID'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      purchaseOrderCode: json['purchaseOrderCode'] as String? ?? '',
      manufacturingDate: DateTime.parse(json['manufacturingDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      receivedQuantity: json['receivedQuantity'] as int? ?? 0,
      remainingQuantity: json['remainingQuantity'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
