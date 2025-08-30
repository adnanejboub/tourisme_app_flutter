import '../../../domain/category/entities/category.dart';
import '../../../data/static_data.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryEntity>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final dynamic apiClient; // Would be ApiClient in real implementation

  CategoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return StaticData.getCategories();
  }
}