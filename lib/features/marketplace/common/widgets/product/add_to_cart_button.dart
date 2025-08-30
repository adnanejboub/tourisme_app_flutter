import 'package:flutter/material.dart';
import '../../../../../shared/widgets/guest_mode_mixin.dart';
import '../../../../../domain/product/entities/product.dart';

class AddToCartButton extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onAddedToCart;

  const AddToCartButton({
    Key? key,
    required this.product,
    this.onAddedToCart,
  }) : super(key: key);

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> with GuestModeMixin {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isGuestMode ? Icons.lock : Icons.shopping_cart,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isGuestMode ? 'Se connecter pour acheter' : 'Ajouter au panier',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    if (isGuestMode) {
      // En mode invité, rediriger vers la page de login
      executeWithGuestCheck('add_to_cart', () {
        // Cette fonction ne sera appelée que si l'utilisateur n'est pas en mode invité
        _performAddToCart();
      });
    } else {
      // Utilisateur connecté, procéder normalement
      _performAddToCart();
    }
  }

  Future<void> _performAddToCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.title} ajouté au panier'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Appeler le callback
      widget.onAddedToCart?.call();

    } catch (e) {
      if (!mounted) return;

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de l\'ajout au panier'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
