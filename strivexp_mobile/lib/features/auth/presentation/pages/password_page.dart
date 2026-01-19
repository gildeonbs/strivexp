import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/password_viewmodel.dart';

class PasswordPage extends ConsumerStatefulWidget {
  const PasswordPage({super.key});

  @override
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);
  static const Color _fieldColor = Color.fromARGB(255, 231, 231, 231);
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    ref.read(passwordViewModelProvider.notifier).submitRegister(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Listener: Sucesso ou Erro
    ref.listen(passwordViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Sucesso: Snackbar Especial e Navegação para Login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "You’re almost in! We sent a link to your email. Tap it to start your journey.",
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          // Redireciona para o Login (ou poderia ser Home, dependendo do fluxo de verificação de email)
          context.go(AppRoutes.login);
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

    final state = ref.watch(passwordViewModelProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
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
                  "Create your password",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
            
                const SizedBox(height: 32),
            
                // 3. Password Field with Eye Icon
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
                    filled: true,
                    fillColor: _fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: SvgPicture.asset(
                        _isPasswordVisible ? 'assets/images/eye_open.svg' : 'assets/images/eye_closed.svg',
                        width: 24,
                        height: 24,
                         placeholderBuilder: (_) => Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      color: _textColor
                  ),
                ),
            
                const SizedBox(height: 18),

                // 4. Validation Rules Text
                const Text(
                  "Your password must contain:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Nunito', color: _textColor),
                ),
                const SizedBox(height: 8),
                _buildRuleText("At least 8 characters"),
                _buildRuleText("One number (0-9)"),
                _buildRuleText("One uppercase letter (A-Z)"),
            
                const SizedBox(height: 40),
            
                // 5. NEXT Button (Submit Registration)
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
      ),
    );
  }

  Widget _buildRuleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: _textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: _textColor, fontSize: 13, fontFamily: 'Nunito'),
          ),
        ],
      ),
    );
  }
}
