import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<void> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    await _repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    final emailRegex =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
