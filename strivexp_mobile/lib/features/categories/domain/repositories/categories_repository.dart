import '../../data/models/category_model.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> getCategories();
  Future<void> savePreferences(List<String> categoryIds);
}

