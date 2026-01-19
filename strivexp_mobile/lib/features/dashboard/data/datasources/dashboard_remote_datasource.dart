import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_models.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
  Future<void> completeChallenge(String userChallengeId);
  Future<void> skipChallenge(String userChallengeId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<DashboardModel> getDashboard() async {
    try {
      // Chamada GET real
      final response = await _dio.get(ApiConstants.dashboardEndpoint);

      // Converte o JSON recebido para o Modelo
      return DashboardModel.fromJson(response.data);

    } on DioException catch (e) {
      // Tratamento de erro padrão
      throw Exception('Failed to load dashboard: ${e.message}');
    }
  }

  @override
  Future<void> completeChallenge(String userChallengeId) async {
    try {
      // Substitui o placeholder '{id}' pelo ID real do desafio do usuário
      final path = ApiConstants.completeChallengeEndpoint
          .replaceAll('{id}', userChallengeId);

      // Chamada POST para completar
      await _dio.post(path);

    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'] ?? data['error'] ?? 'Failed to complete challenge';
          throw Exception(message);
        }
      }
      throw Exception('Failed to complete challenge');
    }
  }

  @override
  Future<void> skipChallenge(String userChallengeId) async {
    try {
      // Substitui o placeholder '{id}' pelo ID real
      final path = ApiConstants.skipChallengeEndpoint
          .replaceAll('{id}', userChallengeId);

      // Chamada POST para pular
      await _dio.post(path);

    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          // Captura a mensagem "Oops! You've used all your skips..."
          // O Spring pode mandar em 'message' ou 'error' dependendo da config
          final message = data['message'] ?? data['error'] ?? 'Failed to skip challenge';
          throw Exception(message);
        }
      }
      throw Exception('Failed to skip challenge');
    }
  }
}