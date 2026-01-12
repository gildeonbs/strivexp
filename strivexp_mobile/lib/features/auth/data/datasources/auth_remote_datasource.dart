import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
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
}