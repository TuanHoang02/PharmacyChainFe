class ReviewPurchaseRequestModel {
  final bool isApproved;
  final String? rejectionReason;
  final List<Map<String, dynamic>>? detailSuppliers;

  ReviewPurchaseRequestModel({
    required this.isApproved,
    this.rejectionReason,
    this.detailSuppliers,
  });

  Map<String, dynamic> toJson() {
    return {
      'isApproved': isApproved,
      'rejectionReason': rejectionReason,
      'detailSuppliers': detailSuppliers,
    };
  }
}
