import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/usecases/dashboard_usecases.dart';

// Providers dos UseCases
final getDashboardUseCaseProvider = Provider((ref) => GetDashboardUseCase(ref.read(dashboardRepositoryProvider)));
final completeChallengeUseCaseProvider = Provider((ref) => CompleteChallengeUseCase(ref.read(dashboardRepositoryProvider)));
final skipChallengeUseCaseProvider = Provider((ref) => SkipChallengeUseCase(ref.read(dashboardRepositoryProvider)));

// ViewModel
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardModel>> {
  final GetDashboardUseCase _getDashboard;
  final CompleteChallengeUseCase _completeChallenge;
  final SkipChallengeUseCase _skipChallenge;

  DashboardViewModel(
      this._getDashboard,
      this._completeChallenge,
      this._skipChallenge,
      ) : super(const AsyncValue.loading()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      state = const AsyncValue.loading();
      final dashboard = await _getDashboard.call();
      state = AsyncValue.data(dashboard);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeChallenge(String id) async {
    try {
      // Opcional: state = const AsyncValue.loading();
      // Mas para UX melhor, podemos manter os dados antigos enquanto carrega
      // ou apenas mostrar loading no botão específico (requer gestão de estado local na UI).
      // Aqui, recarregaremos tudo para simplicidade e garantir dados atualizados.

      await _completeChallenge.call(id);
      await loadDashboard(); // Atualiza XP e listas
    } catch (e) {
      // Tratar erro (snackbars na UI via listener)
      print("Error completing: $e");
    }
  }

  Future<void> skipChallenge(String id) async {
    try {
      await _skipChallenge.call(id);

      // Sucesso: Recarrega os dados para atualizar a lista
      await loadDashboard();

    } catch (e, stack) {
      // ERRO CRÍTICO AQUI:
      // Se der erro (ex: limite atingido), salvamos o erro no estado
      // MAS usamos copyWithPrevious para NÃO perder os dados atuais do dashboard (tela preta/branca).
      state = AsyncValue<DashboardModel>.error(e, stack).copyWithPrevious(state);
    }
  }
}

final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardModel>>((ref) {
  return DashboardViewModel(
    ref.read(getDashboardUseCaseProvider),
    ref.read(completeChallengeUseCaseProvider),
    ref.read(skipChallengeUseCaseProvider),
  );
});