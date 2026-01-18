import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../categories/presentation/viewmodels/categories_viewmodel.dart';
import '../../../categories/domain/usecases/manage_categories_usecase.dart';

// Enum para definir o destino
enum LoginNavigationDestination { dashboard, categoriesPreferences }

// Injeção do UseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

// // ViewModel StateNotifier
// class LoginViewModel extends StateNotifier<AsyncValue<void>> {
//   final LoginUseCase _loginUseCase;
//
//   LoginViewModel(this._loginUseCase) : super(const AsyncValue.data(null));
//
//   Future<void> login(String email, String password) async {
//     // 1. Set Loading
//     state = const AsyncValue.loading();
//
//     try {
//       // 2. Call UseCase
//       await _loginUseCase.call(email, password);
//
//       // 3. Set Success
//       state = const AsyncValue.data(null);
//     } catch (e, stack) {
//       // 4. Set Error
//       state = AsyncValue.error(e, stack);
//     }
//   }
// }

// ViewModel
class LoginViewModel extends StateNotifier<AsyncValue<LoginNavigationDestination?>> {
  final LoginUseCase _loginUseCase;
  final ManageCategoriesUseCase _categoriesUseCase; // Injeção da dependência de categorias

  LoginViewModel(this._loginUseCase, this._categoriesUseCase)
      : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      // 1. Realiza o Login (Autenticação)
      await _loginUseCase.call(email, password);

      // 2. Login Sucesso -> Agora verifica as categorias
      // O Token já está salvo no SecureStorage via AuthRepository/Interceptor

      final categories = await _categoriesUseCase.get();

      // 3. Verifica se existe alguma categoria já selecionada (isSelected == true)
      final hasPreferences = categories.any((category) => category.isSelected);

      if (hasPreferences) {
        // Usuário recorrente ou já configurado
        state = const AsyncValue.data(LoginNavigationDestination.dashboard);
      } else {
        // Primeiro acesso ou nenhuma preferência salva
        state = const AsyncValue.data(LoginNavigationDestination.categoriesPreferences);
      }

    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// // Provider do ViewModel
// final loginViewModelProvider = StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
//   return LoginViewModel(ref.read(loginUseCaseProvider));
// });

// Provider Atualizado
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, AsyncValue<LoginNavigationDestination?>>((ref) {
  return LoginViewModel(
    ref.read(loginUseCaseProvider),
    ref.read(manageCategoriesUseCaseProvider), // Reutilizamos o provider criado na feature categories
  );
});

