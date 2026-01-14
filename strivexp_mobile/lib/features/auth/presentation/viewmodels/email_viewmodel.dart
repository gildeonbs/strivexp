import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sign_up_provider.dart';

class EmailViewModel extends StateNotifier<AsyncValue<void>> {
  final SignUpNotifier _signUpNotifier;

  EmailViewModel(this._signUpNotifier) : super(const AsyncValue.data(null));

  Future<void> submitEmail(String email) async {
    state = const AsyncValue.loading();

    try {
      // 1. Validação
      final trimmedEmail = email.trim();
      if (trimmedEmail.isEmpty) {
        throw Exception("Email is required.");
      }

      // Regex simples para validação de e-mail
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmedEmail)) {
        throw Exception("Please enter a valid email address.");
      }

      // 2. Simulação de processamento (Mock)
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Atualiza o estado compartilhado
      _signUpNotifier.setEmail(trimmedEmail);

      // 4. Sucesso
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final emailViewModelProvider = StateNotifierProvider<EmailViewModel, AsyncValue<void>>((ref) {
  return EmailViewModel(ref.read(signUpProvider.notifier));
});

