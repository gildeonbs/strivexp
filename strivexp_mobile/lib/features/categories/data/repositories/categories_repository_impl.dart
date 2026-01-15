import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/categories_repository.dart';
import '../../data/datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(ref.read(categoriesRemoteDataSourceProvider));
});

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _dataSource;

  CategoriesRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryModel>> getCategories() => _dataSource.getCategories();

  @override
  Future<void> savePreferences(List<String> categoryIds) => _dataSource.savePreferences(categoryIds);
}

