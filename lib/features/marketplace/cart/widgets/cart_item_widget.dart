import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/order/entities/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemEntity item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  
  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final price = item.product.discountedPrice > 0 
        ? item.product.discountedPrice.toDouble()
        : item.product.price;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.selectedColor.isNotEmpty || item.selectedSize.isNotEmpty)
                    Text(
                      '${item.selectedColor.isNotEmpty ? "Color: ${item.selectedColor}" : ""}'
                      '${item.selectedColor.isNotEmpty && item.selectedSize.isNotEmpty ? " • " : ""}'
                      '${item.selectedSize.isNotEmpty ? "Size: ${item.selectedSize}" : ""}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: item.quantity > 1 
                                ? () => onQuantityChanged(item.quantity - 1) 
                                : null,
                            icon: const Icon(Icons.remove),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              item.quantity.toString(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => onQuantityChanged(item.quantity + 1),
                            icon: const Icon(Icons.add),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}