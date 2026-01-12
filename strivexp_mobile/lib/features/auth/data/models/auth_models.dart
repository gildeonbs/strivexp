// Request
class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Response
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;

  AuthResponseModel({required this.accessToken, required this.refreshToken});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}

