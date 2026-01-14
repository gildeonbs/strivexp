import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/birthday_viewmodel.dart';

class BirthdayPage extends ConsumerStatefulWidget {
  const BirthdayPage({super.key});

  @override
  ConsumerState<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends ConsumerState<BirthdayPage> {
  // Controladores para os 3 campos
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  final _yearController = TextEditingController();

  // Cor do botão azul [RGB 132, 186, 220]
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus(); // Fecha teclado
    
    // Converte textos para int
    final m = int.tryParse(_monthController.text);
    final d = int.tryParse(_dayController.text);
    final y = int.tryParse(_yearController.text);

    ref.read(birthdayViewModelProvider.notifier).submitBirthday(d, m, y);
  }

  @override
  Widget build(BuildContext context) {
    // Escuta estado para navegação/feedback
    ref.listen(birthdayViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Sucesso: Vai para a tela de Nome
          context.push(AppRoutes.signUpName);
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    final state = ref.watch(birthdayViewModelProvider);
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
                "What's your birthday?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 32),

              // 3. Date Fields (Row of 3 inputs)
              Row(
                children: [
                  // Month
                  Expanded(
                    flex: 1,
                    child: _buildDateInput(
                      controller: _monthController,
                      hint: 'Month',
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Day
                  Expanded(
                    flex: 1,
                    child: _buildDateInput(
                      controller: _dayController,
                      hint: 'Day',
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Year
                  Expanded(
                    flex: 2, // Ano um pouco maior
                    child: _buildDateInput(
                      controller: _yearController,
                      hint: 'Year',
                      maxLength: 4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Descriptive Text
              const Text(
                "This is just to confirm your age. Your information is kept private.",
                style: TextStyle(
                  color: Colors.grey, // Cinza escuro/médio
                  fontSize: 13,
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

  Widget _buildDateInput({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: maxLength,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: "", // Esconde o contador de caracteres (ex: 0/2)
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.grey[100], // Fundo leve
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

