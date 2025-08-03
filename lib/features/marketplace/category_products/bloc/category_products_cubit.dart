import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourisme_app_flutter/domain/product/usecases/get_products_by_category.dart';
import 'category_products_state.dart';

class CategoryProductsCubit extends Cubit<CategoryProductsState> {
  final GetProductsByCategory getProductsByCategory;

  CategoryProductsCubit({required this.getProductsByCategory}) : super(CategoryProductsInitial());

  Future<void> loadProducts(String categoryId) async {
    emit(CategoryProductsLoading());
    try {
      final products = await getProductsByCategory(categoryId);
      emit(CategoryProductsLoaded(products));
    } catch (e) {
      emit(CategoryProductsError(e.toString()));
    }
  }
}