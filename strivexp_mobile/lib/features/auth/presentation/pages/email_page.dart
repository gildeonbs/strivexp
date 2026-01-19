import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/email_viewmodel.dart';

class EmailPage extends ConsumerStatefulWidget {
  const EmailPage({super.key});

  @override
  ConsumerState<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  final _emailController = TextEditingController();

  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);
  static const Color _fieldColor = Color.fromARGB(255, 231, 231, 231);
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus(); // Fecha teclado
    ref.read(emailViewModelProvider.notifier).submitEmail(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Listener para navegação
    ref.listen(emailViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Sucesso: Vai para a tela de Senha
          context.push(AppRoutes.signUpPassword);
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red[300],
            ),
          );
        },
        loading: () {},
      );
    });

    final state = ref.watch(emailViewModelProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: SvgPicture.asset(
                    'assets/images/back_arrow.svg',
                    width: 24,
                    height: 24,
                    placeholderBuilder: (_) => const Icon(Icons.arrow_back),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Title
              const Text(
                "What's your email?",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 32),

              // 3. Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Teclado otimizado para e-mail
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: _fieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    color: _textColor
                ),
              ),

              const SizedBox(height: 16),

              // 4. Helper Text
              const Text(
                "Enter your best email address! We’ll send a quick link to verify it’s you.",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: _textColor,
                  fontSize: 13,
                  height: 1.4, // Melhor legibilidade
                ),
              ),

              const SizedBox(height: 40),

              // 5. NEXT Button
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: isLoading ? null : _onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: _buttonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


