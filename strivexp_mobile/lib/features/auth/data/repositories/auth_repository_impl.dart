import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';
import '../models/forgot_password_models.dart';

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(storageServiceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<bool> isSessionValid() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> login(String email, String password) async {
    // Cria o modelo de request
    final request = LoginRequestModel(email: email, password: password);

    // Chama a API (DataSource)
    final response = await _remoteDataSource.login(request);

    // Salva o Access Token seguro para chamadas futuras (Dio Interceptor)
    await _storageService.saveToken(response.accessToken);

    // Salva o Refresh Token para renovação automática
    await _storageService.saveRefreshToken(response.refreshToken);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final request = ForgotPasswordRequestModel(email: email);
    // Chama o datasource
    await _remoteDataSource.requestPasswordReset(request);
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    // 1. Chama a API
    final response = await _remoteDataSource.register(request);

    // DECISÃO DE ARQUITETURA:
    // Ao registar, geralmente já logamos o usuário, mas nesse caso não.
    // await _storageService.saveToken(response.accessToken); // <--- REMOVIDO
  }

  //@override
  Future<String?> refreshToken() async {
    try {
      final currentRefreshToken = await _storageService.getRefreshToken();
      if (currentRefreshToken == null) return null;

      // Chama o DataSource para renovar
      final response = await _remoteDataSource.refreshToken(currentRefreshToken);

      // Salva os novos tokens
      await _storageService.saveToken(response.accessToken);
      await _storageService.saveRefreshToken(response.refreshToken);

      return response.accessToken;
    } catch (e) {
      // Se falhar (refresh expirado), limpa tudo para forçar logout
      await _storageService.deleteAll();
      return null;
    }
  }

}
