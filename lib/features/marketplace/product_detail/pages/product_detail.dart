import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/features/marketplace/product_detail/widgets/more-static-info.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';
import '../widgets/product_images.dart';
import '../widgets/product_title.dart';
import '../widgets/product_price.dart';
import '../widgets/product_colors.dart';
import '../widgets/product_sizes.dart';
import '../widgets/product_quantity.dart';
import '../widgets/add_to_bag.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;
  
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? selectedColor;
  String? selectedSize;
  int quantity = 1;
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : null;
    selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : null;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
    appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            // Toggle favorite
          },
          icon: Icon(
            widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.product.isFavorite 
                ? Theme.of(context).colorScheme.error 
                : null,
          ),
        ),
        IconButton(
          onPressed: () {
            // Share product
          },
          icon: const Icon(Icons.share),
        ),
      ],
    ),
    body: Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // space for button
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImagesWidget(images: [widget.product.image]),
              const SizedBox(height: 24),
              ProductTitleWidget(
                title: widget.product.title,
                description: widget.product.description,
              ),
              const SizedBox(height: 16),
              ProductPriceWidget(
                price: widget.product.price,
                discountedPrice: widget.product.discountedPrice,
              ),
              const SizedBox(height: 24),
              if (widget.product.colors.isNotEmpty) ...[
                ProductColorsWidget(
                  colors: widget.product.colors,
                  selectedColor: selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
              if (widget.product.sizes.isNotEmpty) ...[
                ProductSizesWidget(
                  sizes: widget.product.sizes,
                  selectedSize: selectedSize,
                  onSizeSelected: (size) {
                    setState(() {
                      selectedSize = size;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
              ProductQuantityWidget(
                quantity: quantity,
                onQuantityChanged: (newQuantity) {
                  setState(() {
                    quantity = newQuantity;
                  });
                },
              ),
              const SizedBox(height: 24),
              const MoreStaticInfo(), // now inside scroll
              const SizedBox(height: 24),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AddToBagWidget(
            onAddToBag: () async {
              setState(() {
                isAddingToCart = true;
              });

              await Future.delayed(const Duration(milliseconds: 500));

              StaticData.addToCart(
                widget.product.id,
                quantity,
                selectedColor ?? '',
                selectedSize ?? '',
              );

              setState(() {
                isAddingToCart = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            isLoading: isAddingToCart,
          ),
        ),
      ],
    ),
  );
}

}
