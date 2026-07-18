class BranchPerformanceDto {
  final double totalSales;
  final int totalInvoices;
  final int lowStockMedicines;
  final List<BranchRankingDto> branchRanking;

  BranchPerformanceDto({
    required this.totalSales,
    required this.totalInvoices,
    required this.lowStockMedicines,
    required this.branchRanking,
  });

  factory BranchPerformanceDto.fromJson(Map<String, dynamic> json) {
    return BranchPerformanceDto(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalInvoices: json['totalInvoices'] as int,
      lowStockMedicines: json['lowStockMedicines'] as int,
      branchRanking: (json['branchRanking'] as List)
          .map((e) => BranchRankingDto.fromJson(e))
          .toList(),
    );
  }
}

class BranchRankingDto {
  final int rank;
  final String branchName;
  final double totalSales;
  final int totalInvoices;
  final int lowStockMedicines;

  BranchRankingDto({
    required this.rank,
    required this.branchName,
    required this.totalSales,
    required this.totalInvoices,
    required this.lowStockMedicines,
  });

  factory BranchRankingDto.fromJson(Map<String, dynamic> json) {
    return BranchRankingDto(
      rank: json['rank'] as int,
      branchName: json['branchName'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
      totalInvoices: json['totalInvoices'] as int,
      lowStockMedicines: json['lowStockMedicines'] as int,
    );
  }
}
