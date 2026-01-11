// lib/core/router/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Vamos definir as rotas como constantes para evitar erros de digitação
class AppRoutes {
  static const login = '/login';
  static const home = '/home';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login, // Começamos pelo login por enquanto
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela de Login (Placeholder)')),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home (Placeholder)')),
        ),
      ),
    ],
  );
});

