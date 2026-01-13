import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  RequestPasswordResetUseCase(this._repository);

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw Exception("Email cannot be empty.");
    }

    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    await _repository.requestPasswordReset(email);
  }

  bool _isValidEmail(String email) {
    final emailRegex =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

}

