import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourisme_app_flutter/features/marketplace/product_detail/pages/product_detail.dart';
import '../../../../core/services/localization_service.dart';
import 'package:tourisme_app_flutter/data/static_data.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import '../../common/widgets/product/product_card.dart';

class SearchFieldWidget extends StatefulWidget {
  const SearchFieldWidget({Key? key}) : super(key: key);

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  final TextEditingController _controller = TextEditingController();
  Future<List<ProductEntity>>? _searchResults;

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    setState(() {
      _searchResults = StaticData.searchProducts(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: localizationService.translate('home_search_hint'),
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.6)),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _searchResults = null);
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (_searchResults != null)
              Container(
                constraints: const BoxConstraints(maxHeight: 350),
                child: FutureBuilder<List<ProductEntity>>(
                  future: _searchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final results = snapshot.data ?? [];
                    if (results.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No products found.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final product = results[index];
                        return ListTile(
                          leading: product.image.isNotEmpty
                              ? Image.network(product.image, width: 40, height: 40, fit: BoxFit.cover)
                              : null,
                          title: Text(product.title),
                          subtitle: Text(product.description ?? ''),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(product: product),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}