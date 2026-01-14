//import '../entities/user_entity.dart';
import '../../data/models/auth_models.dart';

abstract class AuthRepository {
  // Verifica se existe um token persistido
  Future<bool> isSessionValid();

  Future<void> login(String email, String password);

  Future<void> requestPasswordReset(String email);

  Future<void> register(RegisterRequestModel request);

}
