import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import '../../common/widgets/product/product_card.dart';

class AllProductsPage extends StatelessWidget {
  final String title;
  final List<ProductEntity> products;

  const AllProductsPage({Key? key, required this.title, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllProductsPage(
                title: 'New In',
                products: products, // Pass the full sorted list
              ),
            ),
          );
        },
        label: const Text('See All'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}