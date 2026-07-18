import 'purchase_request_detail_model.dart';

class PurchaseRequestModel {
  final int purchaseRequestId;
  final String requestCode;
  final int branchId;
  final String? branchName;
  final int createdByUserId;
  final String? createdByUserName;
  final String status;
  final String? reason;
  final String? reviewNote;
  final int? reviewedByUserId;
  final String? reviewedByUserName;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final List<PurchaseRequestDetailModel> details;
  final List<PurchaseRequestOrderModel> purchaseOrders;

  PurchaseRequestModel({
    required this.purchaseRequestId,
    required this.requestCode,
    required this.branchId,
    this.branchName,
    required this.createdByUserId,
    this.createdByUserName,
    required this.status,
    this.reason,
    this.reviewNote,
    this.reviewedByUserId,
    this.reviewedByUserName,
    required this.createdAt,
    this.reviewedAt,
    this.details = const [],
    this.purchaseOrders = const [],
  });

  factory PurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestModel(
      purchaseRequestId: json['purchaseRequestID'] ?? json['purchaseRequestId'] ?? 0,
      requestCode: json['requestCode'] ?? '',
      branchId: json['branchID'] ?? json['branchId'] ?? 0,
      branchName: json['branchName'],
      createdByUserId: json['createdByUserID'] ?? json['createdByUserId'] ?? 0,
      createdByUserName: json['createdByUserName'],
      status: json['status'] ?? '',
      reason: json['reason'],
      reviewNote: json['reviewNote'],
      reviewedByUserId: json['reviewedByUserID'] ?? json['reviewedByUserId'],
      reviewedByUserName: json['reviewedByUserName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => PurchaseRequestDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      purchaseOrders: (json['purchaseOrders'] as List<dynamic>?)
              ?.map((e) => PurchaseRequestOrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseRequestID': purchaseRequestId,
      'requestCode': requestCode,
      'branchID': branchId,
      'branchName': branchName,
      'createdByUserID': createdByUserId,
      'createdByUserName': createdByUserName,
      'status': status,
      'reason': reason,
      'reviewNote': reviewNote,
      'reviewedByUserID': reviewedByUserId,
      'reviewedByUserName': reviewedByUserName,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'details': details.map((e) => e.toJson()).toList(),
      'purchaseOrders': purchaseOrders.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseRequestOrderModel {
  final int purchaseOrderId;
  final String purchaseOrderCode;
  final String supplierName;
  final String orderStatus;
  final String deliveryStatus;
  final double totalAmount;
  final DateTime createdAt;
  final List<PurchaseRequestOrderItemModel> items;

  PurchaseRequestOrderModel({
    required this.purchaseOrderId,
    required this.purchaseOrderCode,
    required this.supplierName,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.createdAt,
    this.items = const [],
  });

  factory PurchaseRequestOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestOrderModel(
      purchaseOrderId: json['purchaseOrderID'] ?? json['purchaseOrderId'] ?? 0,
      purchaseOrderCode: json['purchaseOrderCode'] ?? '',
      supplierName: json['supplierName'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      deliveryStatus: json['deliveryStatus'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PurchaseRequestOrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrderID': purchaseOrderId,
      'purchaseOrderCode': purchaseOrderCode,
      'supplierName': supplierName,
      'orderStatus': orderStatus,
      'deliveryStatus': deliveryStatus,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseRequestOrderItemModel {
  final String medicineName;
  final int orderedQuantity;
  final String unit;

  PurchaseRequestOrderItemModel({
    required this.medicineName,
    required this.orderedQuantity,
    required this.unit,
  });

  factory PurchaseRequestOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestOrderItemModel(
      medicineName: json['medicineName'] ?? '',
      orderedQuantity: json['orderedQuantity'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'orderedQuantity': orderedQuantity,
      'unit': unit,
    };
  }
}
