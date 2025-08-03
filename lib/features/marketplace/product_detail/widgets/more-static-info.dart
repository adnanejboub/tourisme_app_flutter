import 'package:flutter/material.dart';

class MoreStaticInfo extends StatelessWidget {
  const MoreStaticInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipping Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Free shipping on all orders over \$100. Estimated delivery: 5-7 business days',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Similar Items
          const Text(
            'Similar Items',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSimilarItem(
                  'Moroccan Pouf',
                  '\$79.99',
                  Colors.red.shade800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimilarItem(
                  'Ceramic Tagine',
                  '\$45.00',
                  Colors.teal.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Customer Reviews
          const Text(
            'Customer Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(4, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
              Icon(Icons.star, color: Colors.grey.shade300, size: 20),
              const SizedBox(width: 8),
              Text(
                '4.5 out of 5 (128 reviews)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            'Sarah L.',
            'Absolutely stunning rug! The quality is incredible and the colors are even more beautiful in person.',
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            'David M.',
            'Beautiful craftsmanship. It\'s a bit thicker than I expected, but still a very high-quality piece.',
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItem(String title, String price, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          radius: 20,
          child: Text(name[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(review, style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
