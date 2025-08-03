import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/domain/category/entities/category.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ProductEntity> newProducts;
  final List<ProductEntity> topSellingProducts;
  final List<CategoryEntity> categories;

  HomeLoaded({
    required this.newProducts,
    required this.topSellingProducts,
    required this.categories,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}