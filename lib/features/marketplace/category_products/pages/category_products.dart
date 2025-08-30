import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/category/entities/category.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';
import '../../common/widgets/product/product_card.dart';

class CategoryProductsPage extends StatelessWidget {
  final CategoryEntity category;
  
  const CategoryProductsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = StaticData.getProductsByCategory(category.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show filter options
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no products in this category yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
    );
  }
}