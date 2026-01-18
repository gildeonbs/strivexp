import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/logout_models.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class SettingsRemoteDataSource {
  Future<LogoutResponseModel> logout(LogoutRequestModel request);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSourceImpl(this._dio);

  @override
  Future<LogoutResponseModel> logout(LogoutRequestModel request) async {
    try {
      // Chamada Real ao Endpoint
      final response = await _dio.post(
        ApiConstants.logoutEndpoint,
        data: request.toJson(),
      );

      return LogoutResponseModel.fromJson(response.data);

    } on DioException catch (e) {
      // Se houver resposta de erro do servidor (ex: token inválido), tentamos extrair a mensagem
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'] ?? data['error'] ?? 'Logout failed on server';
          // Lançamos a exceção para que o Repository a capture
          // e prossiga com a limpeza local
          throw Exception(message);
        }
      }
      throw Exception('Connection error during logout.');
    }
  }
}