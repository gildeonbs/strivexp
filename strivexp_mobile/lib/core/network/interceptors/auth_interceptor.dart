// lib/core/network/interceptors/auth_interceptor.dart

import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    
    // Busca o token do storage
    final token = await _storageService.getToken();

    // Se houver token, adiciona ao Header Authorization
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Segue com a requisição
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Aqui poderíamos tratar erro 401 (Token expirado) para deslogar o usuário
    // Por enquanto, apenas repassamos o erro
    handler.next(err);
  }
}

