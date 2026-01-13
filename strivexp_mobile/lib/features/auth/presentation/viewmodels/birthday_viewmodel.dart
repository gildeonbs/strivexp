import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sign_up_provider.dart';

// Estado local da tela (Loading, Sucesso, Erro)
class BirthdayViewModel extends StateNotifier<AsyncValue<void>> {
  final SignUpNotifier _signUpNotifier;

  BirthdayViewModel(this._signUpNotifier) : super(const AsyncValue.data(null));

  Future<void> submitBirthday(int? day, int? month, int? year) async {
    state = const AsyncValue.loading();

    try {
      // 1. Validação local simples
      if (day == null || month == null || year == null) {
        throw Exception("Please fill in all fields.");
      }
      
      // Validação básica de data
      if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900 || year > DateTime.now().year) {
         throw Exception("Invalid date.");
      }

      final date = DateTime(year, month, day);
      if (date.isAfter(DateTime.now())) {
        throw Exception("Are you from the future?");
      }

      // 2. Simula chamada/processamento (Mock)
      await Future.delayed(const Duration(seconds: 1));

      // 3. Salva no estado compartilhado
      _signUpNotifier.setBirthday(date);

      // 4. Sucesso
      state = const AsyncValue.data(null);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final birthdayViewModelProvider = StateNotifierProvider<BirthdayViewModel, AsyncValue<void>>((ref) {
  // Injeta o notifier global para salvar os dados
  return BirthdayViewModel(ref.read(signUpProvider.notifier));
});

