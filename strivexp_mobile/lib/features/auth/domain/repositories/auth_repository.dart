abstract class AuthRepository {
  // Verifica se existe um token persistido
  Future<bool> isSessionValid();
}
