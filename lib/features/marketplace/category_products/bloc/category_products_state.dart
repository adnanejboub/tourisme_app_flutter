import 'package:tourisme_app_flutter/domain/product/entities/product.dart';

abstract class CategoryProductsState {}

class CategoryProductsInitial extends CategoryProductsState {}

class CategoryProductsLoading extends CategoryProductsState {}

class CategoryProductsLoaded extends CategoryProductsState {
  final List<ProductEntity> products;

  CategoryProductsLoaded(this.products);
}

class CategoryProductsError extends CategoryProductsState {
  final String message;

  CategoryProductsError(this.message);
}