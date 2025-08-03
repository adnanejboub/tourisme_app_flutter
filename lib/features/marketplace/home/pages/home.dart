import 'package:flutter/material.dart';
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
    final products = StaticData.getProducts();
    final categories = StaticData.getCategories();
    final newProducts = products.take(4).toList();
    final topSellingProducts = products.skip(4).take(4).toList();

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
              CategoriesWidget(categories: categories),
              const SizedBox(height: 8),
              NewInWidget(products: newProducts),
              const SizedBox(height: 24),
              TopSellingWidget(products: topSellingProducts),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}