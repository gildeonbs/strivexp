import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/register_usecase.dart';
import '../providers/sign_up_provider.dart';

// Provider do UseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

class PasswordViewModel extends StateNotifier<AsyncValue<void>> {
  final RegisterUseCase _registerUseCase;
  final SignUpNotifier _signUpNotifier; // Acesso ao estado acumulado
  final Ref _ref; // Para ler o estado atual do provider

  PasswordViewModel(this._registerUseCase, this._signUpNotifier, this._ref) 
      : super(const AsyncValue.data(null));

  Future<void> submitRegister(String password) async {
    state = const AsyncValue.loading();

    try {
      // 1. Validação da Password (Regras de UI)
      if (password.length < 8) {
        throw Exception("Password must be at least 8 characters.");
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        throw Exception("Password must contain a number.");
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        throw Exception("Password must contain an uppercase letter.");
      }

      // 2. Recuperar dados acumulados
      final signUpState = _ref.read(signUpProvider);
      
      // Validação de segurança dos dados anteriores
      if (signUpState.firstName == null || 
          signUpState.email == null || 
          signUpState.birthday == null) {
        throw Exception("Missing registration data. Please restart.");
      }

      // 3. Formatação da Data para YYYY-MM-DD
      final dob = signUpState.birthday!;
      final formattedDate = "${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";

      // 4. Montar Objeto de Request
      final request = RegisterRequestModel(
        firstName: signUpState.firstName!,
        lastName: signUpState.lastName ?? "",
        email: signUpState.email!,
        password: password,
        birthday: formattedDate,
      );

      // 5. Chamar UseCase (Mock API)
      await _registerUseCase.call(request);

      // 6. Sucesso
      state = const AsyncValue.data(null);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final passwordViewModelProvider = StateNotifierProvider<PasswordViewModel, AsyncValue<void>>((ref) {
  return PasswordViewModel(
    ref.read(registerUseCaseProvider),
    ref.read(signUpProvider.notifier),
    ref,
  );
});

