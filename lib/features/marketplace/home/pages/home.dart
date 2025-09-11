import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/category/entities/category.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/features/marketplace/home/widgets/local_artisan_spotlight.dart';
import '../widgets/header.dart';
import '../widgets/search_field.dart';
import '../widgets/categories.dart';
import '../widgets/new_in.dart';
import '../widgets/top_selling.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';

class MarketplacePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categoriesFuture = StaticData.getCategories();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderWidget(),
              const SizedBox(height: 8),
              const SearchFieldWidget(),
              const SizedBox(height: 8),
              LocalArtisanSpotlight(),
              const SizedBox(height: 0),
              FutureBuilder<List<CategoryEntity>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final categories = snapshot.data ?? [];
                  return CategoriesWidget(categories: categories);
                },
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<ProductEntity>>(
                future: StaticData.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final products = snapshot.data ?? [];
                  final newProducts = products.take(4).toList();
                  final topSellingProducts = products.skip(4).take(4).toList();
                  //final newProducts = products
                  //  .where((p) => p.createdDate != null)
                  //  .toList()
                  //  ..sort((a, b) => b.createdDate!.compareTo(a.createdDate!)); // Sort by newest
                  //final topSellingProducts = products
                  //  .where((p) => p.salesCount != null)
                  //  .toList()
                  //  ..sort((a, b) => b.salesCount!.compareTo(a.salesCount!)); // Sort by sales
                    return Column(
                    children: [
                      NewInWidget(products: newProducts),
                      const SizedBox(height: 24),
                      TopSellingWidget(products: topSellingProducts),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}