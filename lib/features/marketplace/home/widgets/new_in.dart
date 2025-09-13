import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/features/marketplace/home/pages/all_products_page.dart';
import '../../common/widgets/product/product_card.dart';

class NewInWidget extends StatelessWidget {
  const NewInWidget({Key? key, required this.products}) : super(key: key);

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('New In', style: Theme.of(context).textTheme.headlineMedium),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllProductsPage(
                        title: 'New In',
                        products: products,
                      ),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
                const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // prevent GridView from scrolling inside Column
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1, // adjust based on your ProductCard
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
        ],
    );
  }
}








                          // const SizedBox(height: 4),
                          // Text(
                          //   product.appPrice,
                          //   style: TextStyle(
                          //     fontSize: 10,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                          // Text(
                          //   product.touristPrice,
                          //   style: TextStyle(
                          //     fontSize: 10,
                          //     color: Colors.grey[600],
                          //     decoration: TextDecoration.lineThrough,
                          //   ),
                          // ),