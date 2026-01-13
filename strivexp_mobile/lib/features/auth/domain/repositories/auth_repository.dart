//import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Verifica se existe um token persistido
  Future<bool> isSessionValid();

  Future<void> login(String email, String password);

  Future<void> requestPasswordReset(String email);
}
