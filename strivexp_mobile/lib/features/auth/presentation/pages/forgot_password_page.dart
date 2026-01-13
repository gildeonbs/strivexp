import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);
  static const Color _fieldColor = Color.fromARGB(255, 231, 231, 231);
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    ref.read(forgotPasswordViewModelProvider.notifier).submit(
      _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listener para feedback visual e navegação
    ref.listen(forgotPasswordViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('If the email exists, a reset link was sent.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navega de volta para o Login
          context.go(AppRoutes.login);
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              backgroundColor: Colors.red[300],
            ),
          );
        },
        loading: () {},
      );
    });

    final state = ref.watch(forgotPasswordViewModelProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header (Back Button)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    // Veio do Login, posso usar pop ou go
                    context.canPop() ? context.pop() : context.go(AppRoutes.login);
                  },
                  icon: SvgPicture.asset(
                    'assets/images/back_arrow.svg',
                    width: 24,
                    height: 24,
                    placeholderBuilder: (_) => const Icon(Icons.arrow_back),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Title "Forgot Password?"
              const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 24),

              // 3. Input Field (Cores específicas do prompt)
              TextField(
                controller: _emailController,
                style: const TextStyle(
                  color: _textColor, // RGB(231,231,231)
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldColor, // RGB(112,114,113)
                  //hintText: 'user@example.com',
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontFamily: 'Nunito',
                    color: _textColor.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 16
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4. Info text
              const Text(
                'Enter your email address, and we’ll send you a link to reset your password.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 32),

              // 5. Button "RESET PASSWORD"
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: isLoading ? null : _onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _buttonBlue, // RGB(132, 186, 220)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'RESET PASSWORD',
                          style: TextStyle(
                            fontFamily: 'Nunito',
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

