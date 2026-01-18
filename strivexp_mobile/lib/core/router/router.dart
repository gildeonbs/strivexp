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
import '../../features/auth/presentation/pages/password_page.dart';
import '../../features/categories/presentation/pages/categories_preferences_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';



// Rotas como constantes para evitar erros de digitação
class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  //static const home = '/home';
  static const dashboard = '/dashboard';
  static const forgotPassword = '/forgot-password';
  static const signUpBirthday = '/signup/birthday';
  static const signUpName = '/signup/name';
  static const signUpEmail = '/signup/email';
  static const signUpPassword = '/signup/password';
  static const categoriesPreferences = '/categories/preferences';
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
      // GoRoute(
      //   path: AppRoutes.home,
      //   builder: (context, state) => const Scaffold(
      //     body: Center(child: Text('Home Page Placeholder')),
      //   ),
      // ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      // Fluxo de Cadastro
      GoRoute(
        path: AppRoutes.signUpBirthday,
        builder: (context, state) => const BirthdayPage(),
      ),
      GoRoute(
        path: AppRoutes.signUpName,
        builder: (context, state) => const NamePage(),
      ),
      GoRoute(
        path: AppRoutes.signUpEmail,
        builder: (context, state) => const EmailPage(),
      ),
      GoRoute(
        path: AppRoutes.signUpPassword,
        builder: (context, state) => const PasswordPage(),
      ),
      // Categories Preferences Screen
      GoRoute(
        path: AppRoutes.categoriesPreferences,
        builder: (context, state) => const CategoriesPreferencesPage(),
      ),
    ],
  );
});
