import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';
import '../../data/services/public_api_service.dart';
import 'itinerary_planning_page.dart';

class CityDetailsPage extends StatefulWidget {
final Map<String, dynamic> city;

const CityDetailsPage({
super.key,
required this.city,
});

@override
State<CityDetailsPage> createState() => _CityDetailsPageState();
}

class _CityDetailsPageState extends State<CityDetailsPage>
with TickerProviderStateMixin {
int _selectedTabIndex = 0;
late PageController _pageController;
late TabController _tabController;
bool _isLoading = false;
bool _isFavorite = false;

// API service
late PublicApiService _apiService;

// Dynamic data
Map<String, dynamic>? _cityDetails;
List<Map<String, dynamic>> _activities = [];
List<Map<String, dynamic>> _monuments = [];
List<Map<String, dynamic>> _accommodations = [];
List<Map<String, dynamic>> _events = [];
List<Map<String, dynamic>> _services = [];
List<Map<String, dynamic>> _highlights = [];
Map<String, dynamic>? _statistics;

// Loading states
bool _isLoadingDetails = true;
String? _errorMessage;



@override
void initState() {
super.initState();
_pageController = PageController();
_tabController = TabController(length: 5, vsync: this); // Added specialties tab
_apiService = PublicApiService();
_loadFavoriteStatus();
_loadCityDetails();
}

@override
void dispose() {
_pageController.dispose();
_tabController.dispose();
super.dispose();
}

void _loadFavoriteStatus() {
// TODO: Charger le statut favori depuis SharedPreferences ou API
setState(() {
_isFavorite = false;
});
}

Future<void> _loadCityDetails() async {
try {
setState(() {
_isLoadingDetails = true;
_errorMessage = null;
});

final cityId = widget.city['id'] as int?;
if (cityId == null) {
throw Exception('City ID not found');
}

final details = await _apiService.getCityDetails(cityId);

setState(() {
_cityDetails = details;
_activities = List<Map<String, dynamic>>.from(details['activities'] ?? []);
_monuments = List<Map<String, dynamic>>.from(details['monuments'] ?? []);
_accommodations = List<Map<String, dynamic>>.from(details['accommodations'] ?? []);
_events = List<Map<String, dynamic>>.from(details['events'] ?? []);
_services = List<Map<String, dynamic>>.from(details['services'] ?? []);
_highlights = List<Map<String, dynamic>>.from(details['highlights'] ?? []);
_statistics = details['statistics'] as Map<String, dynamic>?;
_isLoadingDetails = false;
});
} catch (e) {
setState(() {
_errorMessage = e.toString();
_isLoadingDetails = false;
});
}
}

List<Map<String, dynamic>> get _currentActivities {
return _activities;
}

List<Map<String, dynamic>> get _currentHotels {
return _accommodations;
}

List<Map<String, dynamic>> get _currentMonuments {
return _monuments;
}

List<Map<String, dynamic>> get _currentEvents {
return _events;
}

List<Map<String, dynamic>> get _currentServices {
return _services;
}

void _onTabChanged(int index) {
if (_selectedTabIndex != index) {
setState(() {
_selectedTabIndex = index;
});
_pageController.animateToPage(
index,
duration: const Duration(milliseconds: 300),
curve: Curves.easeInOut,
);
_tabController.animateTo(index);
}
}

Future<void> _toggleFavorite() async {
setState(() {
_isFavorite = !_isFavorite;
});

// TODO: Sauvegarder dans SharedPreferences ou envoyer à l'API
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
_isFavorite
? 'Added to favorites'
    : 'Removed from favorites'
),
duration: const Duration(seconds: 2),
),
);
}

Future<void> _shareCity() async {
// TODO: Implémenter le partage avec share_plus package
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Share functionality coming soon!'),
duration: Duration(seconds: 2),
),
);
}

void _planItinerary() {
if (_isLoading) return;

setState(() {
_isLoading = true;
});

final cityData = _cityDetails?['city'] ?? widget.city;
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => ItineraryPlanningPage(
destination: {
'name': cityData['nomVille'] ?? cityData['name'],
'type': 'city',
'isUserLocation': cityData['isUserLocation'] ?? false,
'location': cityData['location'],
'description': cityData['description'] ?? cityData['descriptionVille'],
'popularActivities': cityData['popularActivities'],
'bestTime': cityData['bestTime'] ?? cityData['meilleurePeriode'],
'averageCost': cityData['averageCost'] ?? cityData['coutMoyen'],
'image': cityData['image'] ?? cityData['imageUrl'],
'rating': cityData['noteMoyenne'] ?? cityData['rating'],
'tags': cityData['tags'],
'activities': _currentActivities,
'hotels': _currentHotels,
'monuments': _currentMonuments,
'events': _currentEvents,
'services': _currentServices,
},
),
),
).whenComplete(() {
if (mounted) {
setState(() {
_isLoading = false;
});
}
});
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final localizationService = Provider.of<LocalizationService>(context);
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth > 600;
final isDesktop = screenWidth > 900;

if (_isLoadingDetails) {
return Scaffold(
backgroundColor: colorScheme.background,
body: const Center(
child: CircularProgressIndicator(),
),
);
}

if (_errorMessage != null) {
return Scaffold(
backgroundColor: colorScheme.background,
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.error_outline,
size: 64,
color: colorScheme.error,
),
const SizedBox(height: 16),
Text(
'Error loading city details',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
color: colorScheme.onBackground,
),
),
const SizedBox(height: 8),
Text(
_errorMessage!,
style: TextStyle(
fontSize: 14,
color: colorScheme.onBackground.withOpacity(0.7),
),
textAlign: TextAlign.center,
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: _loadCityDetails,
child: const Text('Retry'),
),
],
),
),
);
}

return Scaffold(
backgroundColor: colorScheme.background,
body: CustomScrollView(
slivers: [
_buildSliverAppBar(colorScheme, isTablet, isDesktop),
SliverToBoxAdapter(
child: Column(
children: [
_buildCityOverview(colorScheme, isTablet, isDesktop),
_buildStatisticsSection(colorScheme),
_buildHighlightsSection(colorScheme, isTablet, isDesktop),
_buildTabBar(colorScheme),
const SizedBox(height: 20),
_buildTabContent(colorScheme, isTablet, isDesktop),
],
),
),
],
),
);
}

Widget _buildSliverAppBar(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return SliverAppBar(
expandedHeight: isDesktop ? 400 : (isTablet ? 350 : 300),
floating: false,
pinned: true,
backgroundColor: colorScheme.background,
flexibleSpace: FlexibleSpaceBar(
background: Stack(
fit: StackFit.expand,
children: [
_buildHeroImage(),
_buildGradientOverlay(),
_buildCityInfo(isTablet, isDesktop),
],
),
),
leading: IconButton(
icon: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.3),
shape: BoxShape.circle,
),
child: const Icon(Icons.arrow_back, color: Colors.white),
),
onPressed: () => Navigator.pop(context),
),
actions: [
IconButton(
icon: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.3),
shape: BoxShape.circle,
),
child: Icon(
_isFavorite ? Icons.favorite : Icons.favorite_border,
color: _isFavorite ? Colors.red : Colors.white,
),
),
onPressed: _toggleFavorite,
),
IconButton(
icon: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.3),
shape: BoxShape.circle,
),
child: const Icon(Icons.share, color: Colors.white),
),
onPressed: _shareCity,
),
const SizedBox(width: 8),
],
);
}

Widget _buildHeroImage() {
final cityData = _cityDetails?['city'] ?? widget.city;
return CachedNetworkImage(
imageUrl: cityData['image'] ?? cityData['imageUrl'] ?? '',
fit: BoxFit.cover,
placeholder: (context, url) => Container(
color: Colors.grey[300],
child: const Center(
child: CircularProgressIndicator(),
),
),
errorWidget: (context, url, error) => Container(
color: Colors.grey[300],
child: const Center(
child: Icon(Icons.error, size: 50, color: Colors.grey),
),
),
);
}

Widget _buildGradientOverlay() {
return Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.transparent,
Colors.black.withOpacity(0.7),
],
),
),
);
}

Widget _buildCityInfo(bool isTablet, bool isDesktop) {
final cityData = _cityDetails?['city'] ?? widget.city;
return Positioned(
bottom: 20,
left: 20,
right: 20,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
cityData['nomVille'] ?? cityData['name'] ?? 'Unknown City',
style: TextStyle(
color: Colors.white,
fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
cityData['paysNom'] ?? cityData['pays'] ?? cityData['country'] ?? 'Morocco',
style: TextStyle(
color: Colors.white.withOpacity(0.9),
fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
),
),
const SizedBox(height: 12),
Row(
children: [
const Icon(Icons.star, color: Colors.amber, size: 20),
const SizedBox(width: 8),
Text(
'${cityData['noteMoyenne'] ?? cityData['rating'] ?? 0.0}',
style: const TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
const SizedBox(width: 16),
const Icon(Icons.location_on, color: Colors.white70, size: 20),
const SizedBox(width: 8),
Expanded(
child: Text(
cityData['climatNom'] ?? cityData['region'] ?? cityData['tags']?.join(', ') ?? '',
style: TextStyle(
color: Colors.white.withOpacity(0.9),
fontSize: 16,
),
overflow: TextOverflow.ellipsis,
),
),
],
),
],
),
);
}

Widget _buildCityOverview(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
final cityData = _cityDetails?['city'] ?? widget.city;
return Container(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// City name and nickname
Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
cityData['nomVille'] ?? cityData['name'] ?? 'Unknown City',
style: TextStyle(
fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
fontWeight: FontWeight.bold,
color: colorScheme.onBackground,
),
),
const SizedBox(height: 4),
Text(
cityData['surnom'] ?? cityData['nickname'] ?? 'The Red City',
style: TextStyle(
fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
color: colorScheme.primary,
fontWeight: FontWeight.w600,
),
),
],
),
),
// Rating badge
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: colorScheme.primary.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.star, color: colorScheme.primary, size: 16),
const SizedBox(width: 4),
Text(
'${cityData['noteMoyenne'] ?? cityData['rating'] ?? 0.0}',
style: TextStyle(
color: colorScheme.primary,
fontWeight: FontWeight.w600,
fontSize: 14,
),
),
],
),
),
],
),
const SizedBox(height: 16),
// Description
Text(
cityData['description'] ?? cityData['descriptionVille'] ?? 'No description available.',
style: TextStyle(
fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
color: colorScheme.onBackground.withOpacity(0.8),
height: 1.5,
),
),
const SizedBox(height: 20),
// City characteristics
_buildCityCharacteristics(cityData, colorScheme),
const SizedBox(height: 20),
// Info cards
_buildInfoCards(colorScheme),
],
),
);
}

Widget _buildCityCharacteristics(Map<String, dynamic> cityData, ColorScheme colorScheme) {
List<Map<String, dynamic>> characteristics = [];

// Add characteristics based on city data
if (cityData['isPlage'] == true) characteristics.add({'icon': Icons.beach_access, 'label': 'Beach', 'color': Colors.blue});
if (cityData['isMontagne'] == true) characteristics.add({'icon': Icons.landscape, 'label': 'Mountain', 'color': Colors.green});
if (cityData['isDesert'] == true) characteristics.add({'icon': Icons.wb_sunny, 'label': 'Desert', 'color': Colors.orange});
if (cityData['isRiviera'] == true) characteristics.add({'icon': Icons.water, 'label': 'Riviera', 'color': Colors.cyan});
if (cityData['isHistorique'] == true) characteristics.add({'icon': Icons.history_edu, 'label': 'Historical', 'color': Colors.brown});
if (cityData['isCulturelle'] == true) characteristics.add({'icon': Icons.museum, 'label': 'Cultural', 'color': Colors.purple});
if (cityData['isModerne'] == true) characteristics.add({'icon': Icons.business, 'label': 'Modern', 'color': Colors.grey});
if (cityData['hasAeroport'] == true) characteristics.add({'icon': Icons.flight, 'label': 'Airport', 'color': Colors.indigo});
if (cityData['hasGare'] == true) characteristics.add({'icon': Icons.train, 'label': 'Train Station', 'color': Colors.teal});
if (cityData['hasPort'] == true) characteristics.add({'icon': Icons.directions_boat, 'label': 'Port', 'color': Colors.blueGrey});

if (characteristics.isEmpty) return const SizedBox.shrink();

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'City Features',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: colorScheme.onBackground,
),
),
const SizedBox(height: 12),
Wrap(
spacing: 8,
runSpacing: 8,
children: characteristics.map((char) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: (char['color'] as Color).withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
border: Border.all(color: (char['color'] as Color).withOpacity(0.3)),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
char['icon'] as IconData,
size: 16,
color: char['color'] as Color,
),
const SizedBox(width: 6),
Text(
char['label'] as String,
style: TextStyle(
fontSize: 12,
color: char['color'] as Color,
fontWeight: FontWeight.w600,
),
),
],
),
);
}).toList(),
),
],
);
}

Widget _buildInfoCards(ColorScheme colorScheme) {
final cityData = _cityDetails?['city'] ?? widget.city;
return Row(
children: [
_buildInfoCard(
Icons.access_time,
'Best Time',
cityData['bestTime'] ?? cityData['meilleurePeriode'] ?? 'N/A',
colorScheme,
),
const SizedBox(width: 16),
_buildInfoCard(
Icons.attach_money,
'Average Cost',
cityData['averageCost'] ?? cityData['coutMoyen'] ?? 'N/A',
colorScheme,
),
const SizedBox(width: 16),
_buildInfoCard(
Icons.star,
'Rating',
'${cityData['noteMoyenne'] ?? cityData['rating'] ?? 0.0}/5',
colorScheme,
),
],
);
}

Widget _buildInfoCard(IconData icon, String title, String value, ColorScheme colorScheme) {
return Expanded(
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: colorScheme.outline.withOpacity(0.2),
),
),
child: Column(
children: [
Icon(icon, color: colorScheme.primary, size: 24),
const SizedBox(height: 8),
Text(
title,
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.6),
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
value,
style: TextStyle(
fontSize: 14,
color: colorScheme.onSurface,
fontWeight: FontWeight.w600,
),
textAlign: TextAlign.center,
),
],
),
),
);
}

Widget _buildStatisticsSection(ColorScheme colorScheme) {
if (_statistics == null) return const SizedBox.shrink();

return Container(
margin: const EdgeInsets.symmetric(horizontal: 20),
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'City Statistics',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
),
const SizedBox(height: 16),
Row(
children: [
_buildStatCard(
Icons.explore,
'Activities',
'${_statistics!['totalActivities'] ?? 0}',
colorScheme.primary,
colorScheme,
),
const SizedBox(width: 12),
_buildStatCard(
Icons.location_city,
'Monuments',
'${_statistics!['totalMonuments'] ?? 0}',
Colors.orange,
colorScheme,
),
const SizedBox(width: 12),
_buildStatCard(
Icons.hotel,
'Hotels',
'${_statistics!['totalAccommodations'] ?? 0}',
Colors.green,
colorScheme,
),
const SizedBox(width: 12),
_buildStatCard(
Icons.build,
'Services',
'${_statistics!['totalServices'] ?? 0}',
Colors.purple,
colorScheme,
),
],
),
],
),
);
}

Widget _buildStatCard(IconData icon, String label, String value, Color iconColor, ColorScheme colorScheme) {
return Expanded(
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: iconColor.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
),
child: Column(
children: [
Icon(icon, color: iconColor, size: 24),
const SizedBox(height: 8),
Text(
value,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
),
Text(
label,
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.7),
),
),
],
),
),
);
}

Widget _buildHighlightsSection(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
if (_highlights.isEmpty) return const SizedBox.shrink();

return Container(
margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Key Attractions',
style: TextStyle(
fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
fontWeight: FontWeight.bold,
color: colorScheme.onBackground,
),
),
const SizedBox(height: 12),
SizedBox(
height: 120,
child: ListView.builder(
scrollDirection: Axis.horizontal,
itemCount: _highlights.length,
itemBuilder: (context, index) {
final highlight = _highlights[index];
return _buildHighlightCard(highlight, colorScheme);
},
),
),
],
),
);
}

Widget _buildHighlightCard(Map<String, dynamic> highlight, ColorScheme colorScheme) {
return Container(
width: 200,
margin: const EdgeInsets.only(right: 12),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 8,
offset: const Offset(0, 2),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Container(
decoration: BoxDecoration(
borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
color: Colors.grey[200],
),
child: ClipRRect(
borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
child: CachedNetworkImage(
imageUrl: highlight['imageUrl'] ?? '',
fit: BoxFit.cover,
width: double.infinity,
placeholder: (context, url) => Container(
color: Colors.grey[300],
child: const Center(child: CircularProgressIndicator()),
),
errorWidget: (context, url, error) => Container(
color: Colors.grey[300],
child: const Icon(Icons.image_not_supported, color: Colors.grey),
),
),
),
),
),
Padding(
padding: const EdgeInsets.all(8),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
highlight['name'] ?? 'Unknown',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: colorScheme.onSurface,
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
Row(
children: [
Icon(Icons.star, color: Colors.amber, size: 12),
const SizedBox(width: 4),
Text(
'${highlight['rating'] ?? 0.0}',
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.7),
),
),
],
),
],
),
),
],
),
);
}

Widget _buildTabBar(ColorScheme colorScheme) {
return Container(
margin: const EdgeInsets.symmetric(horizontal: 20),
decoration: BoxDecoration(
color: colorScheme.surfaceVariant.withOpacity(0.3),
borderRadius: BorderRadius.circular(12),
),
child: Row(
children: [
Expanded(
child: _buildTabButton('Activities', 0, Icons.explore, colorScheme),
),
Expanded(
child: _buildTabButton('Monuments', 1, Icons.location_city, colorScheme),
),
Expanded(
child: _buildTabButton('Hotels', 2, Icons.hotel, colorScheme),
),
Expanded(
child: _buildTabButton('Services', 3, Icons.build, colorScheme),
),
Expanded(
child: _buildTabButton('Plan Trip', 4, Icons.map, colorScheme),
),
],
),
);
}

Widget _buildTabButton(String title, int index, IconData icon, ColorScheme colorScheme) {
final isSelected = _selectedTabIndex == index;

return GestureDetector(
onTap: () => _onTabChanged(index),
child: AnimatedContainer(
duration: const Duration(milliseconds: 200),
padding: const EdgeInsets.symmetric(vertical: 16),
decoration: BoxDecoration(
color: isSelected ? colorScheme.primary : Colors.transparent,
borderRadius: BorderRadius.circular(12),
),
child: Column(
children: [
Icon(
icon,
color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
size: 20,
),
const SizedBox(height: 4),
Text(
title,
style: TextStyle(
color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.6),
fontSize: 12,
fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
),
),
],
),
),
);
}

Widget _buildTabContent(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return SizedBox(
height: isDesktop ? 600 : (isTablet ? 550 : 500),
child: PageView(
controller: _pageController,
onPageChanged: _onTabChanged,
children: [
_buildActivitiesTab(colorScheme, isTablet, isDesktop),
_buildMonumentsTab(colorScheme, isTablet, isDesktop),
_buildHotelsTab(colorScheme, isTablet, isDesktop),
_buildServicesTab(colorScheme, isTablet, isDesktop),
_buildPlanTripTab(colorScheme, isTablet, isDesktop),
],
),
);
}

Widget _buildActivitiesTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
if (_currentActivities.isEmpty) {
return _buildEmptyState(
'No activities available',
'Activities will be added soon for this destination.',
Icons.explore_off,
colorScheme,
);
}

return ListView.builder(
padding: const EdgeInsets.symmetric(horizontal: 20),
itemCount: _currentActivities.length,
itemBuilder: (context, index) {
final activity = _currentActivities[index];
return _buildActivityCard(activity, colorScheme, isTablet, isDesktop);
},
);
}

Widget _buildActivityCard(Map<String, dynamic> activity, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return Container(
margin: const EdgeInsets.only(bottom: 16),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: InkWell(
onTap: () {
// TODO: Navigate to activity details
},
borderRadius: BorderRadius.circular(16),
child: Row(
children: [
_buildActivityImage(activity, isTablet, isDesktop),
Expanded(
child: _buildActivityInfo(activity, colorScheme, isTablet, isDesktop),
),
],
),
),
);
}

Widget _buildActivityImage(Map<String, dynamic> activity, bool isTablet, bool isDesktop) {
final size = isDesktop ? 120.0 : (isTablet ? 100.0 : 80.0);

return Container(
width: size,
height: size,
decoration: const BoxDecoration(
borderRadius: BorderRadius.only(
topLeft: Radius.circular(16),
bottomLeft: Radius.circular(16),
),
),
child: ClipRRect(
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(16),
bottomLeft: Radius.circular(16),
),
child: CachedNetworkImage(
imageUrl: activity['image'] ?? '',
fit: BoxFit.cover,
placeholder: (context, url) => Container(
color: Colors.grey[300],
child: const Center(
child: CircularProgressIndicator(),
),
),
errorWidget: (context, url, error) => Container(
color: Colors.grey[300],
child: const Center(
child: Icon(Icons.image_not_supported, color: Colors.grey),
),
),
),
),
);
}

Widget _buildActivityInfo(Map<String, dynamic> activity, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
// Calculate duration range
String durationText = 'N/A';
if (activity['dureeMinimun'] != null && activity['dureeMaximun'] != null) {
durationText = '${activity['dureeMinimun']}-${activity['dureeMaximun']}h';
} else if (activity['dureeMinimun'] != null) {
durationText = '${activity['dureeMinimun']}h+';
} else if (activity['dureeMaximun'] != null) {
durationText = 'Up to ${activity['dureeMaximun']}h';
}

return Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
activity['nom'] ?? activity['nomActivite'] ?? activity['name'] ?? 'Unknown Activity',
style: TextStyle(
fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
),
const SizedBox(height: 4),
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
decoration: BoxDecoration(
color: colorScheme.primary.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
),
child: Text(
activity['categorie'] ?? activity['typeActivite'] ?? activity['type'] ?? 'Activity',
style: TextStyle(
fontSize: 12,
color: colorScheme.primary,
fontWeight: FontWeight.w600,
),
),
),
const SizedBox(height: 8),
// Season information
if (activity['saison'] != null)
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
decoration: BoxDecoration(
color: Colors.blue.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Text(
'Season: ${activity['saison']}',
style: TextStyle(
fontSize: 10,
color: Colors.blue,
fontWeight: FontWeight.w500,
),
),
),
const SizedBox(height: 8),
// Difficulty level
if (activity['niveauDificulta'] != null)
Row(
children: [
Icon(Icons.trending_up, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
'Difficulty: ${activity['niveauDificulta']}',
style: TextStyle(
fontSize: 11,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
],
),
const SizedBox(height: 4),
// Special conditions
if (activity['conditionsSpeciales'] != null)
Row(
children: [
Icon(Icons.info_outline, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Expanded(
child: Text(
activity['conditionsSpeciales'],
style: TextStyle(
fontSize: 11,
color: colorScheme.onSurface.withOpacity(0.6),
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
),
],
),
const SizedBox(height: 8),
Row(
children: [
Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
durationText,
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
const SizedBox(width: 16),
Icon(Icons.attach_money, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
activity['prix'] != null ? '${activity['prix']} MAD' : activity['price'] ?? 'Contact for price',
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
const Spacer(),
Row(
children: [
Icon(Icons.star, size: 14, color: Colors.amber),
const SizedBox(width: 2),
Text(
'${activity['noteMoyenne'] ?? activity['rating'] ?? 0.0}',
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.8),
fontWeight: FontWeight.w600,
),
),
],
),
],
),
],
),
);
}

Widget _buildMonumentsTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
if (_currentMonuments.isEmpty) {
return _buildEmptyState(
'No monuments available',
'Monuments will be added soon for this destination.',
Icons.location_city_outlined,
colorScheme,
);
}

return ListView.builder(
padding: const EdgeInsets.symmetric(horizontal: 20),
itemCount: _currentMonuments.length,
itemBuilder: (context, index) {
final monument = _currentMonuments[index];
return _buildMonumentCard(monument, colorScheme, isTablet, isDesktop);
},
);
}

Widget _buildMonumentCard(Map<String, dynamic> monument, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return Container(
margin: const EdgeInsets.only(bottom: 16),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: InkWell(
onTap: () {
// TODO: Navigate to monument details
},
borderRadius: BorderRadius.circular(16),
child: Column(
children: [
// Image section
if (monument['imageUrl'] != null)
Container(
height: 120,
decoration: BoxDecoration(
borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
color: Colors.grey[200],
),
child: ClipRRect(
borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
child: CachedNetworkImage(
imageUrl: monument['imageUrl'],
fit: BoxFit.cover,
width: double.infinity,
placeholder: (context, url) => Container(
color: Colors.grey[300],
child: const Center(child: CircularProgressIndicator()),
),
errorWidget: (context, url, error) => Container(
color: Colors.grey[300],
child: const Icon(Icons.location_city, color: Colors.grey, size: 40),
),
),
),
),
// Content section
Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
Icons.location_city,
color: colorScheme.primary,
size: 20,
),
const SizedBox(width: 8),
Expanded(
child: Text(
monument['nomMonument'] ?? 'Unknown Monument',
style: TextStyle(
fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
),
),
if (monument['gratuit'] == true)
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: Colors.green.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Text(
'Free',
style: TextStyle(
fontSize: 10,
color: Colors.green,
fontWeight: FontWeight.w600,
),
),
),
],
),
const SizedBox(height: 8),
// Monument type and characteristics
if (monument['typeMonument'] != null)
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
decoration: BoxDecoration(
color: colorScheme.primary.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Text(
monument['typeMonument'],
style: TextStyle(
fontSize: 10,
color: colorScheme.primary,
fontWeight: FontWeight.w500,
),
),
),
const SizedBox(height: 8),
// Historical and cultural significance
if (monument['hasHistorique'] != null || monument['hasCulturelle'] != null)
Wrap(
spacing: 8,
runSpacing: 4,
children: [
if (monument['hasHistorique'] != null)
Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(
color: Colors.orange.withOpacity(0.1),
borderRadius: BorderRadius.circular(6),
),
child: Text(
'Historical: ${monument['hasHistorique']}',
style: TextStyle(
fontSize: 9,
color: Colors.orange,
fontWeight: FontWeight.w500,
),
),
),
if (monument['hasCulturelle'] != null)
Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(
color: Colors.purple.withOpacity(0.1),
borderRadius: BorderRadius.circular(6),
),
child: Text(
'Cultural: ${monument['hasCulturelle']}',
style: TextStyle(
fontSize: 9,
color: Colors.purple,
fontWeight: FontWeight.w500,
),
),
),
],
),
const SizedBox(height: 8),
if (monument['description'] != null)
Text(
monument['description'],
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.7),
),
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 8),
if (monument['adresseMonument'] != null)
Row(
children: [
Icon(Icons.location_on, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Expanded(
child: Text(
monument['adresseMonument'],
style: TextStyle(
fontSize: 11,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
),
],
),
const SizedBox(height: 4),
// Opening hours
if (monument['horairesOuverture'] != null)
Row(
children: [
Icon(Icons.access_time, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Expanded(
child: Text(
'Hours: ${monument['horairesOuverture']}',
style: TextStyle(
fontSize: 11,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
),
],
),
const SizedBox(height: 8),
Row(
children: [
if (monument['prix'] != null && monument['gratuit'] != true)
Row(
children: [
Icon(Icons.attach_money, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
'${monument['prix']} MAD',
style: TextStyle(
fontSize: 11,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
],
),
const Spacer(),
if (monument['notesMoyennes'] != null)
Row(
children: [
Icon(Icons.star, size: 12, color: Colors.amber),
const SizedBox(width: 2),
Text(
'${monument['notesMoyennes']}',
style: TextStyle(
fontSize: 11,
color: colorScheme.onSurface.withOpacity(0.8),
fontWeight: FontWeight.w600,
),
),
],
),
],
),
],
),
),
],
),
),
);
}

Widget _buildHotelsTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
if (_currentHotels.isEmpty) {
return _buildEmptyState(
'No hotels available',
'Hotel recommendations will be added soon for this destination.',
Icons.hotel_outlined,
colorScheme,
);
}

return ListView.builder(
padding: const EdgeInsets.symmetric(horizontal: 20),
itemCount: _currentHotels.length,
itemBuilder: (context, index) {
final hotel = _currentHotels[index];
return _buildHotelCard(hotel, colorScheme, isTablet, isDesktop);
},
);
}

Widget _buildHotelCard(Map<String, dynamic> hotel, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return Container(
margin: const EdgeInsets.only(bottom: 16),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: InkWell(
onTap: () {
// TODO: Navigate to hotel details
},
borderRadius: BorderRadius.circular(16),
child: Column(
children: [
_buildHotelImage(hotel, isTablet, isDesktop),
_buildHotelInfo(hotel, colorScheme, isTablet, isDesktop),
],
),
),
);
}

Widget _buildHotelImage(Map<String, dynamic> hotel, bool isTablet, bool isDesktop) {
return Container(
height: isDesktop ? 200 : (isTablet ? 180 : 160),
decoration: const BoxDecoration(
borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
),
child: ClipRRect(
borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
child: CachedNetworkImage(
imageUrl: hotel['imageUrl'] ?? hotel['image'] ?? '',
width: double.infinity,
fit: BoxFit.cover,
placeholder: (context, url) => Container(
color: Colors.grey[300],
child: const Center(
child: CircularProgressIndicator(),
),
),
errorWidget: (context, url, error) => Container(
color: Colors.grey[300],
child: const Center(
child: Icon(Icons.hotel_outlined, size: 50, color: Colors.grey),
),
),
),
),
);
}

Widget _buildHotelInfo(Map<String, dynamic> hotel, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Expanded(
child: Text(
hotel['nomHebergement'] ?? 'Unknown Hotel',
style: TextStyle(
fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: colorScheme.primary.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Text(
hotel['hebergementType'] ?? 'Hotel',
style: TextStyle(
fontSize: 12,
color: colorScheme.primary,
fontWeight: FontWeight.w600,
),
),
),
],
),
const SizedBox(height: 8),
Text(
hotel['description'] ?? 'No description available.',
style: TextStyle(
fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
color: colorScheme.onSurface.withOpacity(0.7),
),
),
const SizedBox(height: 12),
Row(
children: [
Icon(Icons.location_on, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
hotel['adresse'] ?? 'Unknown Location',
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
const Spacer(),
if (hotel['etoiles'] != null)
Row(
children: [
Icon(Icons.star, size: 14, color: Colors.amber),
const SizedBox(width: 2),
Text(
'${hotel['etoiles']}',
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.8),
fontWeight: FontWeight.w600,
),
),
],
),
],
),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
hotel['prixParNuit'] != null ? 'From ${hotel['prixParNuit']} MAD/night' : 'Price not available',
style: TextStyle(
fontSize: 16,
color: colorScheme.primary,
fontWeight: FontWeight.w600,
),
),
],
),
const SizedBox(height: 12),
// Availability status
if (hotel['isDisponible'] != null)
Row(
children: [
Icon(
hotel['isDisponible'] == true ? Icons.check_circle : Icons.cancel,
size: 14,
color: hotel['isDisponible'] == true ? Colors.green : Colors.red,
),
const SizedBox(width: 4),
Text(
hotel['isDisponible'] == true ? 'Available' : 'Not Available',
style: TextStyle(
fontSize: 12,
color: hotel['isDisponible'] == true ? Colors.green : Colors.red,
fontWeight: FontWeight.w500,
),
),
],
),
const SizedBox(height: 8),
if (hotel['amenities'] != null)
Wrap(
spacing: 8,
runSpacing: 4,
children: (hotel['amenities'] as List<dynamic>).map((amenity) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: colorScheme.surfaceVariant.withOpacity(0.3),
borderRadius: BorderRadius.circular(8),
),
child: Text(
amenity.toString(),
style: TextStyle(
fontSize: 10,
color: colorScheme.onSurface.withOpacity(0.7),
),
),
);
}).toList(),
),
],
),
);
}

Widget _buildServicesTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
if (_currentServices.isEmpty) {
return _buildEmptyState(
'No services available',
'Local services will be added soon for this destination.',
Icons.build_outlined,
colorScheme,
);
}

return ListView.builder(
padding: const EdgeInsets.symmetric(horizontal: 20),
itemCount: _currentServices.length,
itemBuilder: (context, index) {
final service = _currentServices[index];
return _buildServiceCard(service, colorScheme, isTablet, isDesktop);
},
);
}

Widget _buildServiceCard(Map<String, dynamic> service, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return Container(
margin: const EdgeInsets.only(bottom: 16),
decoration: BoxDecoration(
color: colorScheme.surface,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: InkWell(
onTap: () {
// TODO: Navigate to service details
},
borderRadius: BorderRadius.circular(16),
child: Row(
children: [
// Image section
Container(
width: 100,
height: 100,
decoration: BoxDecoration(
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(16),
bottomLeft: Radius.circular(16),
),
color: Colors.grey[200],
),
child: ClipRRect(
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(16),
bottomLeft: Radius.circular(16),
),
child: CachedNetworkImage(
imageUrl: service['imageUrl'] ?? '',
fit: BoxFit.cover,
placeholder: (context, url) => Container(
color: Colors.grey[300],
child: const Center(child: CircularProgressIndicator()),
),
errorWidget: (context, url, error) => Container(
color: Colors.grey[300],
child: const Icon(Icons.build, color: Colors.grey, size: 30),
),
),
),
),
// Content section
Expanded(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
Icons.build,
color: colorScheme.primary,
size: 20,
),
const SizedBox(width: 8),
Expanded(
child: Text(
service['nomService'] ?? service['name'] ?? 'Unknown Service',
style: TextStyle(
fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
),
),
if (service['categorie'] != null)
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: colorScheme.primary.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Text(
service['categorie'],
style: TextStyle(
fontSize: 10,
color: colorScheme.primary,
fontWeight: FontWeight.w600,
),
),
),
],
),
const SizedBox(height: 8),
if (service['description'] != null)
Text(
service['description'],
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.7),
),
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 8),
Row(
children: [
if (service['prix'] != null)
Row(
children: [
Icon(Icons.attach_money, size: 12, color: colorScheme.onSurface.withOpacity(0.6)),
const SizedBox(width: 4),
Text(
'${service['prix']} MAD',
style: TextStyle(
fontSize: 12,
color: colorScheme.onSurface.withOpacity(0.6),
),
),
],
),
const Spacer(),
if (service['disponible'] == true)
Container(
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
decoration: BoxDecoration(
color: Colors.green.withOpacity(0.1),
borderRadius: BorderRadius.circular(6),
),
child: Text(
'Available',
style: TextStyle(
fontSize: 10,
color: Colors.green,
fontWeight: FontWeight.w600,
),
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

Widget _buildPlanTripTab(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
return Container(
padding: const EdgeInsets.all(20),
child: Column(
children: [
Icon(
Icons.map,
size: isDesktop ? 80 : (isTablet ? 70 : 60),
color: colorScheme.primary.withOpacity(0.6),
),
const SizedBox(height: 24),
Text(
'Plan Your Perfect Trip to ${(_cityDetails?['city'] ?? widget.city)['nomVille'] ?? (_cityDetails?['city'] ?? widget.city)['name'] ?? 'this destination'}',
style: TextStyle(
fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
fontWeight: FontWeight.bold,
color: colorScheme.onSurface,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 16),
Text(
'Create a personalized itinerary with activities, hotels, and travel tips based on your preferences.',
style: TextStyle(
fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
color: colorScheme.onSurface.withOpacity(0.7),
height: 1.5,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 32),
Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: colorScheme.primary.withOpacity(0.1),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: colorScheme.primary.withOpacity(0.3),
),
),
child: Column(
children: [
Text(
'What you\'ll get:',
style: TextStyle(
fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
fontWeight: FontWeight.w600,
color: colorScheme.primary,
),
),
const SizedBox(height: 16),
_buildFeatureItem(Icons.check_circle, 'Customized daily itinerary', colorScheme),
_buildFeatureItem(Icons.check_circle, 'Activity recommendations', colorScheme),
_buildFeatureItem(Icons.check_circle, 'Hotel suggestions', colorScheme),
_buildFeatureItem(Icons.check_circle, 'Travel tips and timing', colorScheme),
],
),
),
const SizedBox(height: 32),
ElevatedButton(
onPressed: _isLoading ? null : _planItinerary,
style: ElevatedButton.styleFrom(
backgroundColor: colorScheme.primary,
foregroundColor: Colors.white,
padding: EdgeInsets.symmetric(
horizontal: isDesktop ? 48 : (isTablet ? 40 : 32),
vertical: isDesktop ? 20 : (isTablet ? 18 : 16),
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
elevation: 2,
),
child: _isLoading
? const SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(
color: Colors.white,
strokeWidth: 2,
),
)
    : Row(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.map, size: 20),
const SizedBox(width: 12),
Text(
'Start Planning',
style: TextStyle(
fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
fontWeight: FontWeight.w600,
),
),
],
),
),
],
),
);
}

Widget _buildFeatureItem(IconData icon, String text, ColorScheme colorScheme) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 4),
child: Row(
children: [
Icon(
icon,
color: colorScheme.primary,
size: 20,
),
const SizedBox(width: 12),
Text(
text,
style: TextStyle(
fontSize: 14,
color: colorScheme.onSurface,
),
),
],
),
);
}

Widget _buildEmptyState(String title, String message, IconData icon, ColorScheme colorScheme) {
return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
icon,
size: 64,
color: colorScheme.onSurface.withOpacity(0.3),
),
const SizedBox(height: 16),
Text(
title,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
color: colorScheme.onSurface.withOpacity(0.7),
),
textAlign: TextAlign.center,
),
const SizedBox(height: 8),
Text(
message,
style: TextStyle(
fontSize: 14,
color: colorScheme.onSurface.withOpacity(0.5),
),
textAlign: TextAlign.center,
),
],
),
),
);
}
}