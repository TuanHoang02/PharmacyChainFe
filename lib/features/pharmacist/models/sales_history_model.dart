enum PaymentMethod { cash, creditCard, bankTransfer }
enum PaymentStatus { pending, completed, failed }
enum InvoiceStatus { draft, finalized, cancelled }

PaymentMethod parsePaymentMethod(dynamic val) {
  if (val is int) {
    if (val >= 0 && val < PaymentMethod.values.length) {
      return PaymentMethod.values[val];
    }
  } else if (val is String) {
    final s = val.toLowerCase();
    if (s == 'cash') return PaymentMethod.cash;
    if (s == 'creditcard' || s == 'credit card') return PaymentMethod.creditCard;
    if (s == 'banktransfer' || s == 'bank transfer') return PaymentMethod.bankTransfer;
  }
  return PaymentMethod.cash;
}

String displayPaymentMethod(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Tiền mặt';
    case PaymentMethod.creditCard:
      return 'Thẻ tín dụng';
    case PaymentMethod.bankTransfer:
      return 'Chuyển khoản';
  }
}

PaymentStatus parsePaymentStatus(dynamic val) {
  if (val is int) {
    if (val >= 0 && val < PaymentStatus.values.length) {
      return PaymentStatus.values[val];
    }
  } else if (val is String) {
    final s = val.toLowerCase();
    if (s == 'pending') return PaymentStatus.pending;
    if (s == 'completed') return PaymentStatus.completed;
    if (s == 'failed') return PaymentStatus.failed;
  }
  return PaymentStatus.pending;
}

String displayPaymentStatus(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return 'Chờ thanh toán';
    case PaymentStatus.completed:
      return 'Đã thanh toán';
    case PaymentStatus.failed:
      return 'Thanh toán thất bại';
  }
}

InvoiceStatus parseInvoiceStatus(dynamic val) {
  if (val is int) {
    if (val >= 0 && val < InvoiceStatus.values.length) {
      return InvoiceStatus.values[val];
    }
  } else if (val is String) {
    final s = val.toLowerCase();
    if (s == 'draft') return InvoiceStatus.draft;
    if (s == 'finalized') return InvoiceStatus.finalized;
    if (s == 'cancelled') return InvoiceStatus.cancelled;
  }
  return InvoiceStatus.draft;
}

String displayInvoiceStatus(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return 'Bản nháp';
    case InvoiceStatus.finalized:
      return 'Đã hoàn thành';
    case InvoiceStatus.cancelled:
      return 'Đã hủy';
  }
}

class SalesHistoryModel {
  final int salesInvoiceID;
  final String invoiceCode;
  final String? customerName;
  final String? customerPhoneNumber;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final InvoiceStatus invoiceStatus;
  final DateTime createdAt;
  final DateTime? completedAt;

  SalesHistoryModel({
    required this.salesInvoiceID,
    required this.invoiceCode,
    this.customerName,
    this.customerPhoneNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.invoiceStatus,
    required this.createdAt,
    this.completedAt,
  });

  factory SalesHistoryModel.fromJson(Map<String, dynamic> json) {
    return SalesHistoryModel(
      salesInvoiceID: json['salesInvoiceID'] as int? ?? json['salesInvoiceId'] as int? ?? 0,
      invoiceCode: json['invoiceCode'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhoneNumber: json['customerPhoneNumber'] as String?,
      totalAmount: (json['totalAmount'] as num? ?? 0.0).toDouble(),
      paymentMethod: parsePaymentMethod(json['paymentMethod']),
      paymentStatus: parsePaymentStatus(json['paymentStatus']),
      invoiceStatus: parseInvoiceStatus(json['invoiceStatus']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesInvoiceID': salesInvoiceID,
      'invoiceCode': invoiceCode,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.index,
      'paymentStatus': paymentStatus.index,
      'invoiceStatus': invoiceStatus.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class SalesInvoiceItemModel {
  final int medicineID;
  final String medicineName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  SalesInvoiceItemModel({
    required this.medicineID,
    required this.medicineName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory SalesInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItemModel(
      medicineID: json['medicineID'] as int? ?? json['medicineId'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num? ?? 0.0).toDouble(),
      lineTotal: (json['lineTotal'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineID': medicineID,
      'medicineName': medicineName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }
}

class SalesInvoiceDetailModel {
  final int salesInvoiceID;
  final String invoiceCode;
  final String? customerName;
  final String? customerPhoneNumber;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final InvoiceStatus invoiceStatus;
  final String? prescriptionImageUrl;
  final bool? isPrescriptionVerified;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String branchName;
  final String pharmacistName;
  final List<SalesInvoiceItemModel> items;

  SalesInvoiceDetailModel({
    required this.salesInvoiceID,
    required this.invoiceCode,
    this.customerName,
    this.customerPhoneNumber,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.invoiceStatus,
    this.prescriptionImageUrl,
    this.isPrescriptionVerified,
    required this.createdAt,
    this.completedAt,
    required this.branchName,
    required this.pharmacistName,
    required this.items,
  });

  factory SalesInvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    var itemsList = rawItems.map((item) => SalesInvoiceItemModel.fromJson(item as Map<String, dynamic>)).toList();

    return SalesInvoiceDetailModel(
      salesInvoiceID: json['salesInvoiceID'] as int? ?? json['salesInvoiceId'] as int? ?? 0,
      invoiceCode: json['invoiceCode'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhoneNumber: json['customerPhoneNumber'] as String?,
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0.0).toDouble(),
      paymentMethod: parsePaymentMethod(json['paymentMethod']),
      paymentStatus: parsePaymentStatus(json['paymentStatus']),
      invoiceStatus: parseInvoiceStatus(json['invoiceStatus']),
      prescriptionImageUrl: json['prescriptionImageUrl'] as String?,
      isPrescriptionVerified: json['isPrescriptionVerified'] as bool? ?? json['prescriptionVerified'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      branchName: json['branchName'] as String? ?? '',
      pharmacistName: json['pharmacistName'] as String? ?? '',
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesInvoiceID': salesInvoiceID,
      'invoiceCode': invoiceCode,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.index,
      'paymentStatus': paymentStatus.index,
      'invoiceStatus': invoiceStatus.index,
      'prescriptionImageUrl': prescriptionImageUrl,
      'isPrescriptionVerified': isPrescriptionVerified,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'branchName': branchName,
      'pharmacistName': pharmacistName,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PagedSalesHistoryResponse {
  final List<SalesHistoryModel> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;

  PagedSalesHistoryResponse({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory PagedSalesHistoryResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'] as List? ?? [];
    var dataList = rawData.map((item) => SalesHistoryModel.fromJson(item as Map<String, dynamic>)).toList();

    return PagedSalesHistoryResponse(
      data: dataList,
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalRecords: json['totalRecords'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}
