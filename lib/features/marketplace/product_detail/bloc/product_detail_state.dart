class ProductDetailState {
  final String? selectedColor;
  final String? selectedSize;
  final int quantity;
  final bool isAddingToCart;
  final String? errorMessage;

  ProductDetailState({
    this.selectedColor,
    this.selectedSize,
    this.quantity = 1,
    this.isAddingToCart = false,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    String? selectedColor,
    String? selectedSize,
    int? quantity,
    bool? isAddingToCart,
    String? errorMessage,
  }) {
    return ProductDetailState(
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

