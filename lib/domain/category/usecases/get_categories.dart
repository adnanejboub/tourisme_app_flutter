import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repository/category_repository.dart';

class GetCategories extends UseCase<List<CategoryEntity>, NoParams> {
  final CategoryRepository repository;

  GetCategories(this.repository);

  @override
  Future<List<CategoryEntity>> call(NoParams params) async {
    return await repository.getCategories();
  }
}