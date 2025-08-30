import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourisme_app_flutter/domain/product/usecases/get_products.dart';
import 'package:tourisme_app_flutter/domain/category/usecases/get_categories.dart';
import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetProducts getProducts;
  final GetCategories getCategories;

  HomeCubit({
    required this.getProducts,
    required this.getCategories,
  }) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final products = await getProducts(NoParams());
      final categories = await getCategories(NoParams());
      
      // Assuming you have logic to separate new and top selling products
      final newProducts = products.take(5).toList();
      final topSellingProducts = products.skip(5).take(5).toList();
      
      emit(HomeLoaded(
        newProducts: newProducts,
        topSellingProducts: topSellingProducts,
        categories: categories,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}