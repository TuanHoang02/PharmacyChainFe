class UserModel {
  final int userId;
  final String fullName;
  final String username;
  final String? email;
  final String? phoneNumber;
  final String roleName;
  final String? branchName;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.username,
    this.email,
    this.phoneNumber,
    required this.roleName,
    this.branchName,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userID'] ?? 0,
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      roleName: json['roleName'] ?? '',
      branchName: json['branchName'],
      isActive: json['isActive'] ?? false,
    );
  }
}

class PagedUserResponse {
  final List<UserModel> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;

  PagedUserResponse({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
  });

  factory PagedUserResponse.fromJson(Map<String, dynamic> json) {
    return PagedUserResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => UserModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

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
