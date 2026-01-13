import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';

// Provider do UseCase
final requestPasswordResetUseCaseProvider = Provider<RequestPasswordResetUseCase>((ref) {
  return RequestPasswordResetUseCase(ref.read(authRepositoryProvider));
});

// ViewModel
class ForgotPasswordViewModel extends StateNotifier<AsyncValue<void>> {
  final RequestPasswordResetUseCase _useCase;

  ForgotPasswordViewModel(this._useCase) : super(const AsyncValue.data(null));

  Future<void> submit(String email) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.call(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider do ViewModel
final forgotPasswordViewModelProvider = 
    StateNotifierProvider<ForgotPasswordViewModel, AsyncValue<void>>((ref) {
  return ForgotPasswordViewModel(ref.read(requestPasswordResetUseCaseProvider));
});

