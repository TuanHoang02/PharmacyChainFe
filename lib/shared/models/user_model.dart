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
