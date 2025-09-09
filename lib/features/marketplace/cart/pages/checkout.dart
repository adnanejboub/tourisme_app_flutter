import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/order/entities/cart_item.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';
import 'order_placed.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/localization_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItemEntity> cartItems;
  
  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  
  String _selectedPaymentMethod = 'Credit Card';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  double get _total {
    return widget.cartItems.fold(0.0, (sum, item) {
      final price = item.product.discountedPrice > 0 
          ? item.product.discountedPrice.toDouble()
          : item.product.price;
      return sum + (price * item.quantity);
    });
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Generate order ID
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Clear cart
    StaticData.clearCart();

    setState(() {
      _isProcessing = false;
    });

    // Navigate to order placed page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPlacedPage(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocalizationService>(
          builder: (context, l10n, _) => Text(l10n.translate('checkout')),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    
                    // Shipping Information
                    _buildShippingInformation(),
                    const SizedBox(height: 24),
                    
                    // Payment Method
                    _buildPaymentMethod(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          // Place Order Button
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
                          final String totalText = currencyService.format(_total);
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
                      onPressed: _isProcessing ? null : _placeOrder,
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Consumer<LocalizationService>(
                              builder: (context, l10n, _) => Text(l10n.translate('place_order')),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LocalizationService>(
              builder: (context, l10n, _) => Text(
                l10n.translate('order_summary'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.cartItems.map((item) {
              final price = item.product.discountedPrice > 0 
                  ? item.product.discountedPrice.toDouble()
                  : item.product.price;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 20,
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
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Consumer<LocalizationService>(
                            builder: (context, l10n, _) => Text(
                              '${l10n.translate('qty')}: ${item.quantity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<CurrencyService>(
                      builder: (context, currencyService, _) {
                        final String linePrice = currencyService.format(price * item.quantity);
                        return Text(
                          linePrice,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<LocalizationService>(
                  builder: (context, l10n, _) => Text(
                    l10n.translate('total'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Consumer<CurrencyService>(
                  builder: (context, currencyService, _) {
                    final String totalText = currencyService.format(_total);
                    return Text(
                      totalText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LocalizationService>(
              builder: (context, l10n, _) => Text(
                l10n.translate('shipping_information'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: LocalizationService().translate('full_name_label'),
                hintText: LocalizationService().translate('full_name_hint'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocalizationService().translate('enter_full_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: LocalizationService().translate('email_label'),
                hintText: LocalizationService().translate('enter_email'),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocalizationService().translate('enter_email');
                }
                if (!value.contains('@')) {
                  return LocalizationService().translate('enter_valid_email');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: LocalizationService().translate('phone_number'),
                hintText: LocalizationService().translate('enter_phone_number'),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocalizationService().translate('enter_phone_number');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: LocalizationService().translate('full_address'),
                hintText: LocalizationService().translate('enter_address'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocalizationService().translate('enter_address');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: LocalizationService().translate('city'),
                      hintText: LocalizationService().translate('enter_city'),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return LocalizationService().translate('enter_city');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: InputDecoration(
                      labelText: LocalizationService().translate('postal_code'),
                      hintText: LocalizationService().translate('enter_postal_code'),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return LocalizationService().translate('enter_postal_code');
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LocalizationService>(
              builder: (context, l10n, _) => Text(
                l10n.translate('payment_method'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile(
              title: Consumer<LocalizationService>(
                builder: (context, l10n, _) => Text(l10n.translate('credit_card')),
              ),
              subtitle: Consumer<LocalizationService>(
                builder: (context, l10n, _) => Text(l10n.translate('pay_with_credit_card')),
              ),
              value: 'Credit Card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('PayPal'),
              subtitle: Consumer<LocalizationService>(
                builder: (context, l10n, _) => Text(l10n.translate('pay_with_paypal')),
              ),
              value: 'PayPal',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile(
              title: Consumer<LocalizationService>(
                builder: (context, l10n, _) => Text(l10n.translate('cash_on_delivery')),
              ),
              subtitle: Consumer<LocalizationService>(
                builder: (context, l10n, _) => Text(l10n.translate('pay_on_delivery')),
              ),
              value: 'Cash on Delivery',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}