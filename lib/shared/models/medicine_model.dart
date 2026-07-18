class CategoryModel {
  final int categoryID;
  final String categoryName;
  final String? description;
  final bool isActive;

  CategoryModel({
    required this.categoryID,
    required this.categoryName,
    this.description,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryID: json['categoryID'] as int? ?? json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryID,
      'categoryName': categoryName,
      'description': description,
      'isActive': isActive,
    };
  }
}

class MedicineModel {
  final int medicineID;
  final String medicineName;
  final String? genericName;
  final int categoryID;
  final String categoryName;
  final double sellingPrice;
  final String unit;
  final bool requiresPrescription;
  final bool isActive;

  MedicineModel({
    required this.medicineID,
    required this.medicineName,
    this.genericName,
    required this.categoryID,
    required this.categoryName,
    required this.sellingPrice,
    required this.unit,
    required this.requiresPrescription,
    required this.isActive,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      medicineID: json['medicineID'] as int? ?? json['medicineId'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      genericName: json['genericName'] as String?,
      categoryID: json['categoryID'] as int? ?? json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num? ?? 0).toDouble(),
      unit: json['unit'] as String? ?? '',
      requiresPrescription: json['requiresPrescription'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineID': medicineID,
      'medicineName': medicineName,
      'genericName': genericName,
      'categoryID': categoryID,
      'categoryName': categoryName,
      'sellingPrice': sellingPrice,
      'unit': unit,
      'requiresPrescription': requiresPrescription,
      'isActive': isActive,
    };
  }
}

class MedicineDetailModel {
  final int medicineID;
  final String medicineName;
  final String? genericName;
  final int categoryID;
  final String categoryName;
  final double sellingPrice;
  final String unit;
  final String? dosageInstructions;
  final bool requiresPrescription;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MedicineDetailModel({
    required this.medicineID,
    required this.medicineName,
    this.genericName,
    required this.categoryID,
    required this.categoryName,
    required this.sellingPrice,
    required this.unit,
    this.dosageInstructions,
    required this.requiresPrescription,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory MedicineDetailModel.fromJson(Map<String, dynamic> json) {
    return MedicineDetailModel(
      medicineID: json['medicineID'] as int? ?? json['medicineId'] as int? ?? 0,
      medicineName: json['medicineName'] as String? ?? '',
      genericName: json['genericName'] as String?,
      categoryID: json['categoryID'] as int? ?? json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num? ?? 0).toDouble(),
      unit: json['unit'] as String? ?? '',
      dosageInstructions: json['dosageInstructions'] as String?,
      requiresPrescription: json['requiresPrescription'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineID': medicineID,
      'medicineName': medicineName,
      'genericName': genericName,
      'categoryID': categoryID,
      'categoryName': categoryName,
      'sellingPrice': sellingPrice,
      'unit': unit,
      'dosageInstructions': dosageInstructions,
      'requiresPrescription': requiresPrescription,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PagedMedicineResponse {
  final List<MedicineModel> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;

  PagedMedicineResponse({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory PagedMedicineResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] as List? ?? [];
    List<MedicineModel> medicines =
        rawList.map((item) => MedicineModel.fromJson(item as Map<String, dynamic>)).toList();

    return PagedMedicineResponse(
      data: medicines,
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalRecords: json['totalRecords'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}
