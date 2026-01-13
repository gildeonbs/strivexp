import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/welcome_viewmodel.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acesso ao ViewModel
    final viewModel = ref.read(welcomeViewModelProvider.notifier);

    // Definição de cores locais (poderiam estar em um ThemeExtension)
    const primaryGreen = Color.fromARGB(255, 128, 188, 77);
    const sloganYellow = Color.fromARGB(255, 244, 191, 59);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espaçamento flexível para empurrar o logo para a posição correta
              const Spacer(flex: 3),
              
              // Logo Centralizado
              Center(
                child: SvgPicture.asset(
                  'assets/images/strivexp_logo_w_text_welcome_screen.svg',
                  width: 160,
                  height: 160,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Slogan
              const Center(
                child: Text(
                  'Level up your life.',
                  style: TextStyle(
                    color: sloganYellow,
                    fontSize: 18,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              // Espaçamento para empurrar os botões para baixo
              const Spacer(flex: 4),
              
              // Botão 1: GET STARTED (Verde, texto branco)
              SizedBox(
                height: 56, // Altura padrão boa para touch targets
                child: FilledButton(
                  onPressed: () => viewModel.navigateToSignUpBirthday(GoRouter.of(context)),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botão 2: I ALREADY HAVE AN ACCOUNT (Branco, texto verde)
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: () => viewModel.navigateToSignIn(GoRouter.of(context)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: primaryGreen, width: 2), // Borda verde opcional para contraste
                    ),
                    elevation: 0, // Flat
                  ),
                  child: const Text(
                    'I ALREADY HAVE AN ACCOUNT',
                    style: TextStyle(
                      fontSize: 14, // Levemente menor pois o texto é longo
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Espaço final
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
