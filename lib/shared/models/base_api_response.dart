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

  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    final isSuccess = json['success'] as bool? ?? false;
    return BaseApiResponse<T>(
      success: isSuccess,
      message: json['message'] as String? ?? '',
      data: (isSuccess && json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
