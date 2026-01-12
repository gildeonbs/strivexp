import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Estado local para visibilidade da senha
  bool _isPasswordVisible = false;

  // Definição das Cores
  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);
  static const Color _fieldColor = Color.fromARGB(255, 231, 231, 231);
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    // Fecha teclado
    FocusScope.of(context).unfocus();
    
    ref.read(loginViewModelProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuta mudanças de estado para Ações (Navegação/Snackbar)
    ref.listen(loginViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Sucesso: Vai para Home
          context.go(AppRoutes.home);
        },
        error: (err, stack) {
          // Erro: Mostra Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${err.toString()}'),
              backgroundColor: Colors.red[300],
            ),
          );
        },
        loading: () {}, // Loading é tratado visualmente no botão
      );
    });

    // Observa estado para UI (Loading spinner)
    final loginState = ref.watch(loginViewModelProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Botão Back (Topo Esquerda)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: SvgPicture.asset(
                    'assets/images/back_arrow.svg',
                    width: 24,
                    height: 24,
                    // Fallback visual
                    placeholderBuilder: (_) => const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Campos de Texto
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Log in with your StriveXP account',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              //_buildLabel('Log in with your StriveXP account'),
              const SizedBox(height: 24),

              //_buildLabel('Email'),
              //const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                //hint: 'user@example.com',
                hint: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 4),

              //_buildLabel('Password'),
              //const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                //hint: '••••••',
                hint: 'Password',
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: SvgPicture.asset(
                    _isPasswordVisible ? 'assets/images/eye_open.svg' : 'assets/images/eye_closed.svg',
                    width: 24,
                    height: 24,
                    // Ícones padrão do material como fallback
                    placeholderBuilder: (_) => Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: _textColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 3. Botão SIGN IN
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: isLoading ? null : _onSignIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: _buttonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Forgot Password
              TextButton(
                onPressed: () {
                  // TODO: Implementar Forgot Password
                },
                child: const Text(
                  'FORGOT PASSWORD',
                  style: TextStyle(
                    color: _buttonBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Espaçador para empurrar o footer para baixo
              SizedBox(height: MediaQuery.of(context).size.height * 0.4),

              // 5. Footer Text
              const Text(
                'By signing in to StriveXP, you agree to our Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget para Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87, 
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Helper Widget para Inputs
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: _textColor, // RGB(231,231,231) - Texto Claro
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldColor, // RGB(112,114,113) - Fundo Escuro
        hintText: hint,
        hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

