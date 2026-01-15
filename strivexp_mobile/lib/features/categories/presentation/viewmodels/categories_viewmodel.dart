import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/categories_repository_impl.dart';
import '../../domain/usecases/manage_categories_usecase.dart';

// UseCase Provider
final manageCategoriesUseCaseProvider = Provider<ManageCategoriesUseCase>((ref) {
  return ManageCategoriesUseCase(ref.read(categoriesRepositoryProvider));
});

// ViewModel State: Usamos AsyncValue para gerenciar Loading/Error/Data
class CategoriesViewModel extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final ManageCategoriesUseCase _useCase;

  CategoriesViewModel(this._useCase) : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _useCase.get();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Alterna a seleção de um item localmente
  void toggleSelection(String id) {
    state.whenData((categories) {
      final updatedList = categories.map((cat) {
        if (cat.id == id) {
          return cat.copyWith(isSelected: !cat.isSelected);
        }
        return cat;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }

  // Salva as preferências
  // Se isSelectAll for true, ignora a seleção manual e envia todos os IDs
  Future<void> submitPreferences({bool isSelectAll = false}) async {
    // Mantemos o estado atual enquanto carregamos, ou mudamos para loading
    // Para UX, vamos apenas pegar os dados atuais
    final currentList = state.value;
    if (currentList == null) return;

    try {
      // Define o estado como loading para mostrar spinner no botão
      // Nota: Idealmente teríamos um estado separado para "Submitting", 
      // mas usaremos o AsyncValue.loading() por simplicidade.
      state = const AsyncValue.loading();

      List<String> idsToSend;
      
      if (isSelectAll) {
        idsToSend = currentList.map((e) => e.id).toList();
      } else {
        idsToSend = currentList
            .where((e) => e.isSelected)
            .map((e) => e.id)
            .toList();
      }

      await _useCase.save(idsToSend);
      
      // Ao sucesso, podemos recarregar ou navegar. 
      // Como a navegação é feita na UI via listener, aqui apenas retornamos o data original
      state = AsyncValue.data(currentList);
      
    } catch (e, stack) {
      // Restaura a lista em caso de erro
      state = AsyncValue.error(e, stack);
      // Recarrega os dados para garantir consistência se necessário
      // _loadCategories(); 
    }
  }
}

final categoriesViewModelProvider = 
    StateNotifierProvider<CategoriesViewModel, AsyncValue<List<CategoryModel>>>((ref) {
  return CategoriesViewModel(ref.read(manageCategoriesUseCaseProvider));
});

