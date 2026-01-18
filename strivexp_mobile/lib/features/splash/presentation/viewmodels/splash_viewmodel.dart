import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/check_auth_status_usecase.dart';

// Provider do UseCase (Injeção de dependência)
final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
});

// Enum para representar o destino da navegação
enum SplashDestination { dashboard, login }

// Controller da Splash
class SplashViewModel extends StateNotifier<AsyncValue<SplashDestination?>> {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  SplashViewModel(this._checkAuthStatusUseCase) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Executa as duas tarefas em paralelo: 
      // 1. Espera 2 segundos (Regra de UI)
      // 2. Verifica autenticação (Regra de Negócio)
      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _checkAuthStatusUseCase.call(),
      ]);

      final isLoggedIn = results[1] as bool;

      // Define o próximo estado
      state = AsyncValue.data(
        isLoggedIn ? SplashDestination.dashboard : SplashDestination.login
      );
    } catch (e, stack) {
      // Em caso de erro crítico, mandamos para o login por segurança
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider do ViewModel
final splashViewModelProvider = StateNotifierProvider<SplashViewModel, AsyncValue<SplashDestination?>>((ref) {
  final useCase = ref.read(checkAuthStatusUseCaseProvider);
  return SplashViewModel(useCase);
});
