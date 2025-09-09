import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/currency_service.dart';

class ProductPriceWidget extends StatelessWidget {
  final double price;
  final int discountedPrice;
  
  const ProductPriceWidget({
    Key? key,
    required this.price,
    required this.discountedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, _) {
        final String mainPrice = currencyService.format(
          discountedPrice > 0 ? discountedPrice.toDouble() : price,
        );
        final String? oldPrice = discountedPrice > 0
            ? currencyService.format(price)
            : null;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                mainPrice,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  oldPrice,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${((price - discountedPrice) / price * 100).round()}% OFF',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}