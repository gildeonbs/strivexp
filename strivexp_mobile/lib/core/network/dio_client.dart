// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(storageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Adiciona o interceptor criado acima
  dio.interceptors.add(AuthInterceptor(storageService));

  // Log para debug (opcional, ajuda a ver o que está trafegando)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});

