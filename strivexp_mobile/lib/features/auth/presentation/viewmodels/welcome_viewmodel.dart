import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';

// Estado vazio, pois a tela não carrega dados, apenas reage a eventos.
class WelcomeViewModel extends StateNotifier<void> {
  WelcomeViewModel() : super(null);

  void navigateToSignUp(GoRouter router) {
    // "Get Started" leva para criar conta
    router.push(AppRoutes.signup);
  }

  void navigateToSignIn(GoRouter router) {
    // "Already have account" leva para login
    router.push(AppRoutes.login);
  }
}

final welcomeViewModelProvider = StateNotifierProvider<WelcomeViewModel, void>((ref) {
  return WelcomeViewModel();
});

