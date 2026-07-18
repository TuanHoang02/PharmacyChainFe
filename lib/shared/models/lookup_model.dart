class LookupModel {
  final int id;
  final String name;

  LookupModel({required this.id, required this.name});

  factory LookupModel.fromJson(Map<String, dynamic> json) {
    return LookupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
