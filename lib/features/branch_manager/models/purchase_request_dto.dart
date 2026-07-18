class CreatePurchaseRequestDto {
  final String reason;
  final List<PurchaseRequestDetailDto> details;

  CreatePurchaseRequestDto({
    required this.reason,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseRequestDetailDto {
  final int medicineId;
  final int requestedQuantity;

  PurchaseRequestDetailDto({
    required this.medicineId,
    required this.requestedQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'requestedQuantity': requestedQuantity,
    };
  }
}
