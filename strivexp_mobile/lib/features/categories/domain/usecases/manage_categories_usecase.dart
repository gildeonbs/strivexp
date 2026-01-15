import '../repositories/categories_repository.dart';
import '../../data/models/category_model.dart';

class ManageCategoriesUseCase {
  final CategoriesRepository _repository;

  ManageCategoriesUseCase(this._repository);

  Future<List<CategoryModel>> get() async {
    return await _repository.getCategories();
  }

  Future<void> save(List<String> ids) async {
    await _repository.savePreferences(ids);
  }
}

