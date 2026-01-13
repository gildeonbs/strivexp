import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';
import '../models/forgot_password_models.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<ForgotPasswordResponseModel> requestPasswordReset(ForgotPasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      // Sucesso (200 OK)
      return AuthResponseModel.fromJson(response.data);

    } on DioException catch (e) {
      // Tratamento de erros HTTP (Spring Boot)
      if (e.response != null) {
        // O Spring Boot costuma retornar erros assim:
        // { "status": 401, "error": "Unauthorized", "message": "Bad credentials" }
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          final message = data['message'] ?? data['error'] ?? 'Authentication failed';
          throw Exception(message);
        }
      }

      // Erros de conexão (sem internet, servidor offline)
      throw Exception('Connection error. Please check your internet.');
    }
  }


  @override
  Future<ForgotPasswordResponseModel> requestPasswordReset(ForgotPasswordRequestModel request) async {
    try {
      // 1. Chamada Real HTTP POST
      final response = await _dio.post(
        ApiConstants.passwordResetRequestEndpoint,
        data: request.toJson(),
      );

      // 2. Converte o JSON de resposta (ex: { "message": "If the email..." })
      return ForgotPasswordResponseModel.fromJson(response.data);

    } on DioException catch (e) {
      // 3. Tratamento de Erros do Backend
      if (e.response != null) {
        final data = e.response?.data;
        // Tenta extrair a mensagem de erro do JSON do Spring Boot
        if (data is Map<String, dynamic>) {
          // O Spring pode retornar 'message' ou 'error' dependendo da config
          final message = data['message'] ?? data['error'] ?? 'Failed to process request';
          throw Exception(message);
        }
      }

      // Erro genérico de conexão
      throw Exception('Connection error. Please check your internet.');
    }
  }

}
