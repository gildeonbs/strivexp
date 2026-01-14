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
    // 1. Cria o modelo de request
    final request = LoginRequestModel(email: email, password: password);

    // 2. Chama a API (DataSource)
    final response = await _remoteDataSource.login(request);

    // 3. Salva o Access Token seguro para chamadas futuras (Dio Interceptor)
    await _storageService.saveToken(response.accessToken);

    // TODO: Salvar Refresh Token para implementar renovação automática
    //await _storageService.saveRefreshToken(response.refreshToken);

  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final request = ForgotPasswordRequestModel(email: email);
    // Chama o datasource
    await _remoteDataSource.requestPasswordReset(request);
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    final response = await _remoteDataSource.register(request);
    // Ao registar, geralmente já logamos o utilizador
    await _storageService.saveToken(response.accessToken);
  }

}
