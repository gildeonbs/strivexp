class LogoutRequestModel {
  final String refreshToken;
  final String pushToken;

  LogoutRequestModel({required this.refreshToken, required this.pushToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
      'pushToken': pushToken,
    };
  }
}

class LogoutResponseModel {
  final String message;

  LogoutResponseModel({required this.message});

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      message: json['message'] ?? 'Logged out successfully',
    );
  }
}