class CreateSalesInvoiceDto {
  final String? customerName;
  final String? customerPhoneNumber;
  final double discountAmount;
  final int paymentMethod; // 0: Cash, 1: CreditCard, 2: BankTransfer
  final String? prescriptionImageUrl;
  final List<SalesInvoiceDetailDto> details;

  CreateSalesInvoiceDto({
    this.customerName,
    this.customerPhoneNumber,
    required this.discountAmount,
    required this.paymentMethod,
    this.prescriptionImageUrl,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'discountAmount': discountAmount,
      'paymentMethod': paymentMethod,
      'prescriptionImageUrl': prescriptionImageUrl,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}

class SalesInvoiceDetailDto {
  final int medicineId;
  final int quantity;

  SalesInvoiceDetailDto({
    required this.medicineId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'quantity': quantity,
    };
  }
}
