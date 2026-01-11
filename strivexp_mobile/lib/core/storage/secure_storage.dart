// lib/core/storage/secure_storage.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider global para acessar o serviço de storage
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Opções para Android (EncryptedSharedPreferences) e iOS (Keychain)
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey, 
      value: token, 
      aOptions: _getAndroidOptions()
    );
  }

  Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey, 
      aOptions: _getAndroidOptions()
    );
  }

  Future<void> deleteToken() async {
    await _storage.delete(
      key: _tokenKey, 
      aOptions: _getAndroidOptions()
    );
  }
}

