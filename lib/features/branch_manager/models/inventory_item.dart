class InventoryItem {
  final int medicineId;
  final String medicineName;
  final String categoryName;
  final String unit;
  final int quantityInStock;
  final int reorderLevel;
  final bool isLowStock;
  final double sellingPrice;
  final bool requiresPrescription;

  InventoryItem({
    required this.medicineId,
    required this.medicineName,
    required this.categoryName,
    required this.unit,
    required this.quantityInStock,
    required this.reorderLevel,
    required this.isLowStock,
    this.sellingPrice = 0.0,
    this.requiresPrescription = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      medicineId: json['medicineId'] as int,
      medicineName: json['medicineName'] as String? ?? 'Unknown',
      categoryName: json['categoryName'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantityInStock: json['quantityInStock'] as int? ?? 0,
      reorderLevel: json['reorderLevel'] as int? ?? 0,
      isLowStock: json['isLowStock'] as bool? ?? false,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      requiresPrescription: json['requiresPrescription'] as bool? ?? false,
    );
  }
}
