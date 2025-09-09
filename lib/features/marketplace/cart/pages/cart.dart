import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';
import 'package:tourisme_app_flutter/domain/order/entities/cart_item.dart';
import '../widgets/cart_item_widget.dart';
import 'checkout.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/localization_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocalizationService>(
          builder: (context, l10n, _) => Text(l10n.translate('shopping_cart')),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: FutureBuilder<List<CartItemEntity>>(
        future: StaticData.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Consumer<LocalizationService>(
                builder: (context, l10n, _) => Text(l10n.translate('failed_load_cart_items')),
              ),
            );
          }
          final cartItems = snapshot.data ?? [];
          final total = cartItems.fold(0.0, (sum, item) {
            final price = item.product.discountedPrice > 0
                ? item.product.discountedPrice.toDouble()
                : item.product.price;
            return sum + (price * item.quantity);
          });

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Consumer<LocalizationService>(
                    builder: (context, l10n, _) => Text(
                      l10n.translate('cart_empty_title'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<LocalizationService>(
                    builder: (context, l10n, _) => Text(
                      l10n.translate('cart_empty_subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Consumer<LocalizationService>(
                      builder: (context, l10n, _) => Text(l10n.translate('continue_shopping')),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return CartItemWidget(
                      item: item,
                      onQuantityChanged: (quantity) async {
                        await StaticData.updateCartItemQuantity(item.id, quantity);
                        setState(() {});
                      },
                      onRemove: () async {
                        await StaticData.removeFromCart(item.id);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<LocalizationService>(
                            builder: (context, l10n, _) => Text(
                              l10n.translate('total'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Consumer<CurrencyService>(
                            builder: (context, currencyService, _) {
                              final String totalText = currencyService.format(total);
                              return Text(
                                totalText,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(cartItems: cartItems),
                              ),
                            );
                          },
                          child: Consumer<LocalizationService>(
                            builder: (context, l10n, _) => Text(
                              l10n.translate('proceed_to_checkout'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}