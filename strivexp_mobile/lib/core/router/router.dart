import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/birthday_page.dart';
import '../../features/auth/presentation/pages/name_page.dart';
import '../../features/auth/presentation/pages/email_page.dart';

// Rotas como constantes para evitar erros de digitação
class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const forgotPassword = '/forgot-password';
  static const signUpBirthday = '/signup/birthday';
  static const signUpName = '/signup/name';
  static const signUpEmail = '/signup/email';
  static const signUpPassword = '/signup/password';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home Page Placeholder')),
        ),
      ),
      // Fluxo de Cadastro - Passo 1
      GoRoute(
        path: AppRoutes.signUpBirthday,
        builder: (context, state) => const BirthdayPage(),
      ),
      GoRoute(
        path: AppRoutes.signUpName,
        builder: (context, state) => const NamePage(),
      ),
      // Passo 3: Email (Placeholder)
      // Passo 3: Email (Implementação atual)
      GoRoute(
        path: AppRoutes.signUpEmail,
        builder: (context, state) => const EmailPage(),
      ),
      // Passo 4: Password (Placeholder para o futuro)
      GoRoute(
        path: AppRoutes.signUpPassword,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("GET STARTED 4 - Create Password (Next Step)")),
        ),
      ),
    ],
  );
});