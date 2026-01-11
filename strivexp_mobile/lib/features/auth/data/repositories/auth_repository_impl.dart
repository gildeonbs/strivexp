import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';

// Provider do Repositório
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(storageServiceProvider));
});

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;

  AuthRepositoryImpl(this._storageService);

  @override
  Future<bool> isSessionValid() async {
    final token = await _storageService.getToken();
    // Lógica simples: se tem token e não é vazio, é válido.
    // Em apps reais, poderíamos verificar a expiração do JWT aqui.
    return token != null && token.isNotEmpty;
  }
}

