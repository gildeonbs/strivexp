import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/logout_models.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    ref.read(settingsRemoteDataSourceProvider),
    ref.read(storageServiceProvider),
  );
});

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _dataSource;
  final StorageService _storageService;

  SettingsRepositoryImpl(this._dataSource, this._storageService);

  @override
  Future<void> logout() async {
    // Recuperar o Refresh Token armazenado
    final refreshToken = await _storageService.getRefreshToken();

    // Definir um Push Token (Mockado por enquanto, pois a feature não existe)
    const pushToken = "mock_push_token_123";

    if (refreshToken != null) {
      final request = LogoutRequestModel(
        refreshToken: refreshToken,
        pushToken: pushToken,
      );

      // Tenta chamar a API para invalidar no backend
      try {
        await _dataSource.logout(request);
      } catch (e) {
        // Mesmo se a API falhar (ex: sem internet),
        // devemos forçar o logout localmente abaixo.
        print("API Logout failed, clearing local storage anyway: $e");
      }
    }

    // Limpar dados locais (Sessão, Tokens, IDs)
    await _storageService.deleteAll();
  }
}