import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/features/marketplace/product_detail/pages/product_detail.dart';
import 'package:tourisme_app_flutter/features/saved/data/services/wishlist_service.dart';

class ProductCard extends StatefulWidget {
  final ProductEntity product;
  
  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavoriteLocal = false;

  @override
  void initState() {
    super.initState();
    _isFavoriteLocal = widget.product.isFavorite;
    WishlistService.changes.addListener(_onFavoritesChanged);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: widget.product),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.product.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            final id = int.tryParse(widget.product.id) ?? 0;
                            if (id == 0) return;
                            final prev = _isFavoriteLocal;
                            setState(() { _isFavoriteLocal = !prev; });
                            try {
                              // Save snapshot for wishlist rendering identical card data
                              await WishlistService.saveSnapshot(
                                type: 'product',
                                itemId: id,
                                data: {
                                  'id': id,
                                  'nom': widget.product.title,
                                  'description': widget.product.description,
                                  'prix': widget.product.price,
                                  'image': widget.product.image,
                                },
                              );
                              final res = await WishlistService().toggleFavorite(type: 'product', itemId: id);
                              final action = res['action'] as String?;
                              final added = action == 'added';
                              if (mounted) {
                                setState(() { _isFavoriteLocal = added; });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(added ? 'Added to wishlist' : 'Removed from wishlist')),
                                );
                              }
                            } catch (e) {
                              setState(() { _isFavoriteLocal = prev; });
                              if (e is UnauthorizedException && mounted) {
                                Navigator.pushNamed(context, '/login');
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isFavoriteLocal ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: _isFavoriteLocal 
                                  ? Theme.of(context).colorScheme.error 
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.product.discountedPrice > 0) ...[
                          Text(
                            '\$${widget.product.discountedPrice}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${widget.product.price}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ] else
                          Text(
                            '\$${widget.product.price}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WishlistService.changes.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    // no-op here; could be used to sync status if product detail pushes updates
  }
}
