import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/name_viewmodel.dart';

class NamePage extends ConsumerStatefulWidget {
  const NamePage({super.key});

  @override
  ConsumerState<NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<NamePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);
  static const Color _fieldColor = Color.fromARGB(255, 231, 231, 231);
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus(); // Fecha teclado
    ref.read(nameViewModelProvider.notifier).submitName(
      _firstNameController.text,
      _lastNameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listener para navegação
    ref.listen(nameViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Sucesso: Vai para a tela de Email
          context.push(AppRoutes.signUpEmail);
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

    final state = ref.watch(nameViewModelProvider);
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
                "What's your name?",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),

              const SizedBox(height: 32),

              // 3. First Name Field
              _buildTextInput(
                controller: _firstNameController,
                hint: 'First name',
              ),

              const SizedBox(height: 4),

              // 4. Last Name Field
              _buildTextInput(
                controller: _lastNameController,
                hint: 'Last name',
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

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words, // Capitaliza nomes
      style: TextStyle(
        fontFamily: 'Nunito',
        color: _textColor
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
        filled: true,
        fillColor: _fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

