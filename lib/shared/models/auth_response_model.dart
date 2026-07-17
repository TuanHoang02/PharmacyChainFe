class AuthResponseModel {
  final String token;
  final String role;
  final String? refreshToken;

  AuthResponseModel({required this.token, required this.role, this.refreshToken});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }
}
