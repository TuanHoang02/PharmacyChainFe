class PurchaseOrderSummary {
  final int purchaseOrderId;
  final String purchaseOrderCode;
  final int branchId;
  final String branchName;
  final String branchAddress;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final double totalAmount;
  final String orderStatus;
  final String deliveryStatus;

  const PurchaseOrderSummary({
    required this.purchaseOrderId,
    required this.purchaseOrderCode,
    required this.branchId,
    required this.branchName,
    required this.branchAddress,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.totalAmount,
    required this.orderStatus,
    required this.deliveryStatus,
  });

  String get orderStatusLabel {
    switch (orderStatus) {
      case 'PendingSupplierConfirmation':
        return 'Chờ xác nhận';
      case 'Accepted':
        return 'Đã chấp nhận';
      case 'Rejected':
        return 'Bị từ chối';
      case 'Completed':
        return 'Hoàn thành';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return orderStatus;
    }
  }

  String get deliveryStatusLabel {
    switch (deliveryStatus) {
      case 'NotStarted':
        return 'Chưa giao';
      case 'Preparing':
        return 'Đang chuẩn bị';
      case 'Shipping':
        return 'Đang vận chuyển';
      case 'Delivered':
        return 'Đã giao';
      case 'Received':
        return 'Đã nhận';
      default:
        return deliveryStatus;
    }
  }

  factory PurchaseOrderSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderSummary(
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
    );
  }
}
