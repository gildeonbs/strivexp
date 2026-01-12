import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';

// Injeção do UseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

// ViewModel StateNotifier
class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final LoginUseCase _loginUseCase;

  LoginViewModel(this._loginUseCase) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    // 1. Set Loading
    state = const AsyncValue.loading();

    try {
      // 2. Call UseCase
      await _loginUseCase.call(email, password);
      
      // 3. Set Success
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // 4. Set Error
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider do ViewModel
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  return LoginViewModel(ref.read(loginUseCaseProvider));
});

