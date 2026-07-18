class BranchPerformanceDto {
  final double totalSales;
  final double inventoryTurnover;
  final int expiredMedicines;
  final double staffPerformanceScore;
  final List<SalesTrendDto> salesTrend;
  final List<ExpiredMedicineByBranchDto> expiredMedicinesByBranch;
  final List<InventoryTurnoverByBranchDto> inventoryTurnoverByBranch;
  final List<BranchRankingDto> branchRanking;

  BranchPerformanceDto({
    required this.totalSales,
    required this.inventoryTurnover,
    required this.expiredMedicines,
    required this.staffPerformanceScore,
    required this.salesTrend,
    required this.expiredMedicinesByBranch,
    required this.inventoryTurnoverByBranch,
    required this.branchRanking,
  });

  factory BranchPerformanceDto.fromJson(Map<String, dynamic> json) {
    return BranchPerformanceDto(
      totalSales: (json['totalSales'] as num).toDouble(),
      inventoryTurnover: (json['inventoryTurnover'] as num).toDouble(),
      expiredMedicines: json['expiredMedicines'] as int,
      staffPerformanceScore: (json['staffPerformanceScore'] as num).toDouble(),
      salesTrend: (json['salesTrend'] as List)
          .map((e) => SalesTrendDto.fromJson(e))
          .toList(),
      expiredMedicinesByBranch: (json['expiredMedicinesByBranch'] as List)
          .map((e) => ExpiredMedicineByBranchDto.fromJson(e))
          .toList(),
      inventoryTurnoverByBranch: (json['inventoryTurnoverByBranch'] as List)
          .map((e) => InventoryTurnoverByBranchDto.fromJson(e))
          .toList(),
      branchRanking: (json['branchRanking'] as List)
          .map((e) => BranchRankingDto.fromJson(e))
          .toList(),
    );
  }
}

class SalesTrendDto {
  final String dateLabel;
  final double totalSales;

  SalesTrendDto({required this.dateLabel, required this.totalSales});

  factory SalesTrendDto.fromJson(Map<String, dynamic> json) {
    return SalesTrendDto(
      dateLabel: json['dateLabel'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
    );
  }
}

class ExpiredMedicineByBranchDto {
  final String branchName;
  final int expiredCount;

  ExpiredMedicineByBranchDto({required this.branchName, required this.expiredCount});

  factory ExpiredMedicineByBranchDto.fromJson(Map<String, dynamic> json) {
    return ExpiredMedicineByBranchDto(
      branchName: json['branchName'] as String,
      expiredCount: json['expiredCount'] as int,
    );
  }
}

class InventoryTurnoverByBranchDto {
  final String branchName;
  final double turnoverRate;

  InventoryTurnoverByBranchDto({required this.branchName, required this.turnoverRate});

  factory InventoryTurnoverByBranchDto.fromJson(Map<String, dynamic> json) {
    return InventoryTurnoverByBranchDto(
      branchName: json['branchName'] as String,
      turnoverRate: (json['turnoverRate'] as num).toDouble(),
    );
  }
}

class BranchRankingDto {
  final int rank;
  final String branchName;
  final double totalSales;
  final double inventoryTurnover;
  final int expiredMedicines;
  final double staffScore;

  BranchRankingDto({
    required this.rank,
    required this.branchName,
    required this.totalSales,
    required this.inventoryTurnover,
    required this.expiredMedicines,
    required this.staffScore,
  });

  factory BranchRankingDto.fromJson(Map<String, dynamic> json) {
    return BranchRankingDto(
      rank: json['rank'] as int,
      branchName: json['branchName'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
      inventoryTurnover: (json['inventoryTurnover'] as num).toDouble(),
      expiredMedicines: json['expiredMedicines'] as int,
      staffScore: (json['staffScore'] as num).toDouble(),
    );
  }
}
