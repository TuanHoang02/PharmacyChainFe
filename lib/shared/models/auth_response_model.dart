class AuthResponseModel {
  final String token;
  final String role;

  AuthResponseModel({required this.token, required this.role});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
