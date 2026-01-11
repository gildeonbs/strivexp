import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta as mudanças de estado do ViewModel
    ref.listen(splashViewModelProvider, (previous, next) {
      next.when(
        data: (destination) {
          if (destination == SplashDestination.home) {
            context.go(AppRoutes.home);
          } else if (destination == SplashDestination.login) {
            context.go(AppRoutes.login);
          }
        },
        error: (_, __) => context.go(AppRoutes.login), // Falback seguro
        loading: () {}, // Continua na tela de splash
      );
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 191, 59),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo SVG
            SvgPicture.asset(
              'assets/images/strivexp_logo_w_text_splash_screen.svg',
              width: 600,
              height: 600,
              placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
