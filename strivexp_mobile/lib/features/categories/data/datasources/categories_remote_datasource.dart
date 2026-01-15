import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

// Provider
final categoriesRemoteDataSourceProvider = Provider<CategoriesRemoteDataSource>((ref) {
  return CategoriesRemoteDataSourceImpl(ref.read(dioProvider));
});

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> savePreferences(List<String> categoryIds);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final Dio _dio;

  CategoriesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categoriesEndpoint);

      // O Spring Boot retorna uma lista JSON: [ {...}, {...} ]
      final list = response.data as List;
      return list.map((e) => CategoryModel.fromJson(e)).toList();

    } on DioException catch (e) {
      throw Exception('Failed to load categories: ${e.message}');
    }
  }

  @override
  Future<void> savePreferences(List<String> categoryIds) async {
    try {
      // Body: { "categoryIds": ["id1", "id2"] }
      final body = {
        "categoryIds": categoryIds
      };

      await _dio.put(
        ApiConstants.categoriesPreferencesEndpoint,
        data: body,
      );
    } on DioException catch (e) {
      throw Exception('Failed to save preferences: ${e.message}');
    }
  }
}