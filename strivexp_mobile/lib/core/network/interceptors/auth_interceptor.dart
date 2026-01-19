import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../storage/secure_storage.dart';
import '../../constants/api_constants.dart';

// Precisamos de acesso ao Dio para reenviar a requisição (retry)
// Como o Dio depende do Interceptor, e o Interceptor precisa do Dio para retry,
// passaremos o Dio via setter ou usaremos o objeto 'err.requestOptions' com uma nova instancia.

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio; // Referência ao cliente Dio principal

  AuthInterceptor(this._storageService, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    // Se a requisição tiver esse header, não injetamos token (ex: Login, Register, Refresh)
    if (options.headers.containsKey('No-Auth')) {
      options.headers.remove('No-Auth');
      return handler.next(options);
    }

    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Verifica se é erro 401 (Token Expirado)
    if (err.response?.statusCode == 401) {

      // Recupera o refresh token
      final refreshToken = await _storageService.getRefreshToken();

      // Se não temos refresh token, não há o que fazer. Logout.
      if (refreshToken == null) {
        return handler.next(err);
      }

      try {
        // Tenta renovar o token
        // CRIAMOS UMA NOVA INSTÂNCIA DE DIO para evitar loop de interceptors
        // na chamada de refresh.
        final tokenDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

        final response = await tokenDio.post(
          ApiConstants.refreshEndpoint,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          // Extrai novos tokens
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];

          // Salva no storage
          await _storageService.saveToken(newAccessToken);
          await _storageService.saveRefreshToken(newRefreshToken);

          // Atualiza o header da requisição que falhou
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // CLONA e REENVIA a requisição original usando o Dio principal
          final retryResponse = await _dio.fetch(err.requestOptions);

          // Retorna o sucesso para quem chamou originalmente
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        // Se o refresh falhar (ex: refresh token também expirou),
        // limpamos o storage para forçar o usuário a logar novamente.
        await _storageService.deleteAll();
      }
    }

    // Se não foi 401 ou se o refresh falhou, repassa o erro
    handler.next(err);
  }
}

