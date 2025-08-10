import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class ItineraryResultPage extends StatefulWidget {
  final Map<String, dynamic>? destination;
  final Map<String, dynamic> tripData;

  const ItineraryResultPage({
    super.key,
    this.destination,
    required this.tripData,
  });

  @override
  State<ItineraryResultPage> createState() => _ItineraryResultPageState();
}

class _ItineraryResultPageState extends State<ItineraryResultPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentDay = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizationService = Provider.of<LocalizationService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your ${widget.tripData['days']}-Day Trip to ${widget.destination?['name'] ?? 'Morocco'}',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: colorScheme.primary),
            onPressed: _shareItinerary,
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: colorScheme.primary),
            onPressed: _saveItinerary,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTripSummary(colorScheme, localizationService, isTablet, isDesktop),
          _buildTabBar(colorScheme, isTablet, isDesktop),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItineraryTab(colorScheme, localizationService, isTablet, isDesktop),
                _buildMapTab(colorScheme, localizationService, isTablet, isDesktop),
                _buildBudgetTab(colorScheme, localizationService, isTablet, isDesktop),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(colorScheme, localizationService, isTablet, isDesktop),
    );
  }

  Widget _buildTripSummary(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    final destination = widget.destination;
    final tripData = widget.tripData;
    
    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  destination?['image'] as String? ?? 'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5',
                  width: isDesktop ? 100 : (isTablet ? 80 : 60),
                  height: isDesktop ? 100 : (isTablet ? 80 : 60),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: isDesktop ? 100 : (isTablet ? 80 : 60),
                      height: isDesktop ? 100 : (isTablet ? 80 : 60),
                      color: colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.image,
                        color: colorScheme.onSurfaceVariant,
                        size: isDesktop ? 40 : (isTablet ? 32 : 24),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: isDesktop ? 24 : (isTablet ? 20 : 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination?['name'] as String? ?? 'Morocco',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${tripData['days']} Days • ${tripData['budgetInfo']['name']} • ${DateFormat('MMM dd').format(tripData['startDate'])}',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          Row(
            children: [
              _buildSummaryCard(
                Icons.calendar_today,
                'Start Date',
                DateFormat('MMM dd, yyyy').format(tripData['startDate']),
                colorScheme,
                isTablet,
                isDesktop,
              ),
              SizedBox(width: 12),
              _buildSummaryCard(
                Icons.account_balance_wallet,
                'Budget',
                tripData['budgetInfo']['range'],
                colorScheme,
                isTablet,
                isDesktop,
              ),
              SizedBox(width: 12),
              _buildSummaryCard(
                Icons.auto_awesome,
                'Activities',
                '${tripData['activities'].length} Selected',
                colorScheme,
                isTablet,
                isDesktop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String label, String value, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: isDesktop ? 24 : 20,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        indicator: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            icon: Icon(Icons.map, size: isDesktop ? 24 : 20),
            text: 'Itinerary',
          ),
          Tab(
            icon: Icon(Icons.location_on, size: isDesktop ? 24 : 20),
            text: 'Map',
          ),
          Tab(
            icon: Icon(Icons.account_balance_wallet, size: isDesktop ? 24 : 20),
            text: 'Budget',
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    final days = widget.tripData['days'] as int;
    final activities = widget.tripData['activities'] as List<String>;
    
    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      itemCount: days,
      itemBuilder: (context, dayIndex) {
        final day = dayIndex + 1;
        final dayActivities = _generateDayActivities(day, activities, dayIndex);
        
        return Container(
          margin: EdgeInsets.only(bottom: isDesktop ? 32 : 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: colorScheme.onPrimary,
                        size: isDesktop ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day $day',
                            style: TextStyle(
                              fontSize: isDesktop ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _getDayTitle(day, activities),
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.expand_more,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      size: isDesktop ? 28 : 24,
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayActivities.length,
                itemBuilder: (context, activityIndex) {
                  final activity = dayActivities[activityIndex];
                  return _buildActivityItem(activity, activityIndex, dayActivities.length, colorScheme, isTablet, isDesktop);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, int index, int total, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    final isLast = index == total - 1;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: isDesktop ? 16 : 12,
                height: isDesktop ? 16 : 12,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: isDesktop ? 60 : 50,
                  color: colorScheme.outline.withOpacity(0.3),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: colorScheme.primary,
                        size: isDesktop ? 20 : 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['name'] as String,
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            activity['time'] as String,
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 12,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activity['duration'] as String,
                        style: TextStyle(
                          fontSize: isDesktop ? 12 : 10,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  activity['description'] as String,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                if (activity['location'] != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: isDesktop ? 16 : 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        activity['location'] as String,
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 40 : 32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Icon(
              Icons.map,
              size: isDesktop ? 80 : 64,
              color: colorScheme.primary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Interactive Map Coming Soon',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'View your itinerary on an interactive map with real-time navigation',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    final days = widget.tripData['days'] as int;
    final budgetInfo = widget.tripData['budgetInfo'] as Map<String, dynamic>;
    final budgetRange = budgetInfo['range'] as String;
    
    // Parse budget range
    final budgetValues = _parseBudgetRange(budgetRange);
    final dailyBudget = budgetValues['daily'];
    final totalBudget = dailyBudget! * days;
    
    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      children: [
        _buildBudgetOverview(dailyBudget!, totalBudget, budgetInfo, colorScheme, isTablet, isDesktop),
        SizedBox(height: 32),
        _buildBudgetBreakdown(days, dailyBudget, colorScheme, isTablet, isDesktop),
        SizedBox(height: 32),
        _buildBudgetTips(budgetInfo, colorScheme, isTablet, isDesktop),
      ],
    );
  }

  Widget _buildBudgetOverview(double dailyBudget, double totalBudget, Map<String, dynamic> budgetInfo, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBudgetCard(
                  'Daily Budget',
                  '${dailyBudget.toStringAsFixed(0)} MAD',
                  Icons.today,
                  colorScheme,
                  isTablet,
                  isDesktop,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildBudgetCard(
                  'Total Budget',
                  '${totalBudget.toStringAsFixed(0)} MAD',
                  Icons.account_balance_wallet,
                  colorScheme,
                  isTablet,
                  isDesktop,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  budgetInfo['icon'] as IconData,
                  color: colorScheme.primary,
                  size: isDesktop ? 24 : 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    budgetInfo['description'] as String,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(String label, String value, IconData icon, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: isDesktop ? 32 : 28,
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBreakdown(int days, double dailyBudget, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    final categories = [
      {'name': 'Accommodation', 'percentage': 0.4, 'icon': Icons.hotel},
      {'name': 'Food & Dining', 'percentage': 0.3, 'icon': Icons.restaurant},
      {'name': 'Activities', 'percentage': 0.2, 'icon': Icons.explore},
      {'name': 'Transportation', 'percentage': 0.1, 'icon': Icons.directions_car},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Budget Breakdown',
          style: TextStyle(
            fontSize: isDesktop ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 20),
        ...categories.map((category) {
          final amount = dailyBudget * (category['percentage'] as double);
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: colorScheme.primary,
                    size: isDesktop ? 24 : 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${((category['percentage'] as double) * 100).toInt()}% of daily budget',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0)} MAD',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBudgetTips(Map<String, dynamic> budgetInfo, ColorScheme colorScheme, bool isTablet, bool isDesktop) {
    final tips = [
      'Book accommodations in advance for better rates',
      'Try local restaurants for authentic and affordable meals',
      'Use public transportation when possible',
      'Look for free activities and attractions',
      'Consider group tours for cost savings',
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: isDesktop ? 28 : 24,
              ),
              SizedBox(width: 12),
              Text(
                'Budget Tips',
                style: TextStyle(
                  fontSize: isDesktop ? 22 : 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...tips.map((tip) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ColorScheme colorScheme, LocalizationService localizationService, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _editItinerary,
              icon: Icon(Icons.edit, size: isDesktop ? 24 : 20),
              label: Text(
                'Edit',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _bookNow,
              icon: Icon(Icons.book_online, size: isDesktop ? 24 : 20),
              label: Text(
                'Book Now',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateDayActivities(int day, List<String> activities, int dayIndex) {
    final List<Map<String, dynamic>> dayActivities = [];
    final activityTypes = activities.toSet();
    
    // Morning activities
    if (activityTypes.contains('sightseeing')) {
      dayActivities.add({
        'name': 'Morning Sightseeing',
        'time': '9:00 AM - 12:00 PM',
        'duration': '3 hours',
        'description': 'Explore the main attractions and landmarks of the city. Visit historical sites and take memorable photos.',
        'icon': Icons.visibility,
        'location': 'City Center',
      });
    }
    
    // Lunch
    if (activityTypes.contains('food_tour')) {
      dayActivities.add({
        'name': 'Local Cuisine Experience',
        'time': '12:00 PM - 2:00 PM',
        'duration': '2 hours',
        'description': 'Enjoy traditional local dishes at a recommended restaurant. Taste authentic flavors and learn about local food culture.',
        'icon': Icons.restaurant,
        'location': 'Local Restaurant',
      });
    }
    
    // Afternoon activities
    if (activityTypes.contains('cultural_visit')) {
      dayActivities.add({
        'name': 'Cultural Exploration',
        'time': '2:30 PM - 4:30 PM',
        'duration': '2 hours',
        'description': 'Visit museums, art galleries, or cultural centers to learn about the local heritage and traditions.',
        'icon': Icons.museum,
        'location': 'Cultural District',
      });
    }
    
    // Evening activities
    if (activityTypes.contains('shopping')) {
      dayActivities.add({
        'name': 'Evening Shopping',
        'time': '5:00 PM - 7:00 PM',
        'duration': '2 hours',
        'description': 'Explore local markets, souks, or shopping districts. Find unique souvenirs and local crafts.',
        'icon': Icons.shopping_bag,
        'location': 'Market Area',
      });
    }
    
    // If no specific activities, add generic ones
    if (dayActivities.isEmpty) {
      dayActivities.addAll([
        {
          'name': 'City Exploration',
          'time': '9:00 AM - 12:00 PM',
          'duration': '3 hours',
          'description': 'Discover the city on your own pace, visit local attractions and immerse yourself in the local culture.',
          'icon': Icons.explore,
          'location': 'Various Locations',
        },
        {
          'name': 'Local Dining',
          'time': '12:00 PM - 2:00 PM',
          'duration': '2 hours',
          'description': 'Experience local cuisine at a traditional restaurant recommended by locals.',
          'icon': Icons.restaurant,
          'location': 'Local Restaurant',
        },
        {
          'name': 'Evening Walk',
          'time': '6:00 PM - 8:00 PM',
          'duration': '2 hours',
          'description': 'Take a relaxing evening stroll through the city, enjoy the atmosphere and local life.',
          'icon': Icons.directions_walk,
          'location': 'City Streets',
        },
      ]);
    }
    
    return dayActivities;
  }

  String _getDayTitle(int day, List<String> activities) {
    if (day == 1) return 'Arrival & First Impressions';
    if (day == 2) return 'Deep Dive into Culture';
    if (day == 3) return 'Local Experiences';
    if (day == 4) return 'Hidden Gems Discovery';
    if (day == 5) return 'Adventure & Exploration';
    if (day == 6) return 'Relaxation & Reflection';
    if (day == 7) return 'Final Day Adventures';
    if (day == 8) return 'Extended Exploration';
    if (day == 9) return 'Off-the-Beaten-Path';
    if (day == 10) return 'Memorable Farewell';
    return 'Day $day Adventures';
  }

  Map<String, double> _parseBudgetRange(String budgetRange) {
    if (budgetRange.contains('300-800')) {
      return {'daily': 550.0, 'min': 300.0, 'max': 800.0};
    } else if (budgetRange.contains('800-1500')) {
      return {'daily': 1150.0, 'min': 800.0, 'max': 1500.0};
    } else if (budgetRange.contains('1500+')) {
      return {'daily': 2000.0, 'min': 1500.0, 'max': 3000.0};
    }
    return {'daily': 1000.0, 'min': 500.0, 'max': 1500.0};
  }

  void _shareItinerary() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing itinerary...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _saveItinerary() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Itinerary saved to favorites!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editItinerary() {
    Navigator.pop(context);
  }

  void _bookNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to booking platform...'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
