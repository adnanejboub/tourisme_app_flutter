import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';
import '../../common/widgets/product/product_card.dart';

class SimilarProductsWidget extends StatelessWidget {
  final String categoryId;
  final String excludeProductId;

  const SimilarProductsWidget({
    Key? key,
    required this.categoryId,
    required this.excludeProductId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductEntity>>(
      future: StaticData.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading similar products'));
        }
        final products = (snapshot.data ?? [])
            .where((p) => p.categoryId == categoryId && p.id != excludeProductId)
            .take(4)
            .toList();

        if (products.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Similar Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 160,
                    child: ProductCard(product: products[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}