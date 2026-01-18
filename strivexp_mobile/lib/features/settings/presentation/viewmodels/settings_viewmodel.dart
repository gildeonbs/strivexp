import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/usecases/logout_usecase.dart';

final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.read(settingsRepositoryProvider)));

class SettingsViewModel extends StateNotifier<AsyncValue<void>> {
  final LogoutUseCase _logoutUseCase;

  SettingsViewModel(this._logoutUseCase) : super(const AsyncValue.data(null));

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _logoutUseCase.call();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, AsyncValue<void>>((ref) {
  return SettingsViewModel(ref.read(logoutUseCaseProvider));
});