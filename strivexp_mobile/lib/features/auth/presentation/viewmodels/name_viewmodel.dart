import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sign_up_provider.dart';

class NameViewModel extends StateNotifier<AsyncValue<void>> {
  final SignUpNotifier _signUpNotifier;

  NameViewModel(this._signUpNotifier) : super(const AsyncValue.data(null));

  Future<void> submitName(String firstName, String lastName) async {
    state = const AsyncValue.loading();

    try {
      // 1. Validação
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        throw Exception("First name and Last name are required.");
      }

      // 2. Simulação de processamento (Mock)
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Atualiza o estado compartilhado
      _signUpNotifier.setName(firstName.trim(), lastName.trim());

      // 4. Sucesso
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final nameViewModelProvider = StateNotifierProvider<NameViewModel, AsyncValue<void>>((ref) {
  return NameViewModel(ref.read(signUpProvider.notifier));
});

