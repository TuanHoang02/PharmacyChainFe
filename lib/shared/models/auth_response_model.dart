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

class BaseApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String timestamp;

  BaseApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });
}
