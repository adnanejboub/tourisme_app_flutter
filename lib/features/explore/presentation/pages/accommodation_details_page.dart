import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/services/public_api_service.dart';
import '../../../../config/routes/app_routes.dart';
import 'city_details_page.dart';

class AccommodationDetailsPage extends StatefulWidget {
  final int hebergementId;
  const AccommodationDetailsPage({super.key, required this.hebergementId});

  @override
  State<AccommodationDetailsPage> createState() => _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  final PublicApiService _api = PublicApiService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _details;
  List<Map<String, dynamic>> _related = [];
  Map<String, dynamic>? _cityInfo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { _loading = true; _error = null; });
      final d = await _api.getAccommodationDetails(widget.hebergementId);
      setState(() {
        _details = d;
        _related = List<Map<String, dynamic>>.from(d['relatedAccommodations'] ?? []);
        _cityInfo = d['city'] as Map<String, dynamic>?;
        _loading = false;
      });

      // If backend didn't provide related items, fetch by city name as fallback
      if ((_related.isEmpty) && _cityInfo != null) {
        final cityName = _cityInfo!['nomVille'] as String?;
        if (cityName != null && cityName.isNotEmpty) {
          final fromCity = await _api.getProductsByCity(cityName);
          if (mounted) {
            setState(() {
              _related = fromCity
                  .whereType<Map<String, dynamic>>()
                  .where((e) => (e['idHebergement'] != _details?['idHebergement']))
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return Scaffold(backgroundColor: cs.background, body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: cs.background,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, color: cs.error, size: 64),
            const SizedBox(height: 12),
            Text('Failed to load accommodation', style: TextStyle(color: cs.onBackground)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.onBackground.withOpacity(0.7))),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ]),
        ),
      );
    }

    final title = (_details?['nomHebergement'] ?? 'Accommodation').toString();
    final address = (_details?['adresse'] ?? '').toString();
    final price = _details?['prixParNuit'];
    final stars = _details?['etoiles'];
    final available = _details?['isDisponible'] == true;
    final type = (_details?['hebergementType'] ?? '').toString();

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onBackground), onPressed: () => Navigator.pop(context)),
        title: Text(title, style: TextStyle(color: cs.onBackground)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroImage(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: cs.onBackground,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (stars != null)
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('$stars', style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w600)),
                ]),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.location_on, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(address, style: TextStyle(color: cs.onBackground.withOpacity(0.8))))
          ]),
          const SizedBox(height: 12),
          _buildInfoChips(cs, price, available, type),
          const SizedBox(height: 16),
          if ((_details?['description'] ?? '').toString().isNotEmpty)
            Text(_details!['description'], style: TextStyle(color: cs.onBackground.withOpacity(0.9), height: 1.5)),
          const SizedBox(height: 16),
          if (_cityInfo != null) _buildCityCard(cs),
          const SizedBox(height: 24),
          if (_related.isNotEmpty) ...[
            Text(
              'Related accommodations' + (_cityInfo != null && (_cityInfo!['nomVille'] ?? '').toString().isNotEmpty ? ' in ${_cityInfo!['nomVille']}' : ''),
              style: TextStyle(fontWeight: FontWeight.bold, color: cs.onBackground),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final r = _related[i];
                  return _buildRelatedCard(cs, r);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _related.length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    final imageUrl = (_details?['imageUrl'] ?? '').toString();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
          errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.hotel, color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildInfoChips(ColorScheme cs, dynamic price, bool available, String type) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary.withOpacity(0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.attach_money, size: 16),
            const SizedBox(width: 6),
            Text(price != null ? '${price.toString()} MAD / night' : 'Contact for price', style: TextStyle(color: cs.onBackground)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (available ? Colors.green : cs.error).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (available ? Colors.green : cs.error).withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(available ? Icons.check_circle : Icons.cancel, size: 16, color: available ? Colors.green : cs.error),
            const SizedBox(width: 6),
            Text(available ? 'Available' : 'Not available', style: TextStyle(color: cs.onBackground)),
          ]),
        ),
        if (type.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outline.withOpacity(0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.category, size: 16),
              const SizedBox(width: 6),
              Text(type),
            ]),
          ),
      ],
    );
  }

  Widget _buildCityCard(ColorScheme cs) {
    final city = _cityInfo!;
    return InkWell(
      onTap: () {
        final cityMap = {
          'id': city['idVille'],
          'nomVille': city['nomVille'],
          'name': city['nomVille'],
          'description': city['description'] ?? '',
          'imageUrl': city['imageUrl'] ?? '',
          'image': city['imageUrl'] ?? '',
          'latitude': city['latitude'],
          'longitude': city['longitude'],
          'paysNom': city['paysNom'],
          'climatNom': city['climatNom'],
          'isPlage': city['isPlage'],
          'isMontagne': city['isMontagne'],
          'isDesert': city['isDesert'],
          'isRiviera': city['isRiviera'],
          'isHistorique': city['isHistorique'],
          'isCulturelle': city['isCulturelle'],
          'isModerne': city['isModerne'],
          'noteMoyenne': city['noteMoyenne'],
          'rating': city['noteMoyenne'],
        };
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CityDetailsPage(city: cityMap)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(Icons.location_city, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Located in ${city['nomVille']}', style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary)),
              const SizedBox(height: 4),
              Text('Tap to explore the city', style: TextStyle(color: cs.primary.withOpacity(0.7), fontSize: 12)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: cs.primary),
        ]),
      ),
    );
  }

  Widget _buildRelatedCard(ColorScheme cs, Map<String, dynamic> r) {
    return InkWell(
      onTap: () {
        final id = r['idHebergement'] as int?;
        if (id != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.accommodationDetails, arguments: {'hebergementId': id});
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.hotel)))),
            const SizedBox(height: 8),
            Text((r['nomHebergement'] ?? 'Accommodation').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (r['prixParNuit'] != null) Text('${r['prixParNuit']} MAD', style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}


