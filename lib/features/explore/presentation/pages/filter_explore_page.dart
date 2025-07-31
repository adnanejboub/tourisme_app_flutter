import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/constants/constants.dart';

class FilterExplorePage extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterExplorePage({
    Key? key,
    this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<FilterExplorePage> createState() => _FilterExplorePageState();
}

class _FilterExplorePageState extends State<FilterExplorePage> {
  Map<String, dynamic> _filters = {};
  String _selectedCategory = 'all';
  String _selectedBudget = 'all';
  String _selectedDuration = 'all';
  List<String> _selectedTypes = [];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters ?? {});
    _selectedCategory = _filters['category'] ?? 'all';
    _selectedBudget = _filters['budget'] ?? 'all';
    _selectedDuration = _filters['duration'] ?? 'all';
    _selectedTypes = List<String>.from(_filters['types'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Filters',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(AppConstants.primaryColor),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySection(),
                      SizedBox(height: 32),
                      _buildBudgetSection(),
                      SizedBox(height: 32),
                      _buildDurationSection(),
                      SizedBox(height: 32),
                      _buildTypeSection(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('all', 'All', _selectedCategory == 'all'),
            _buildFilterChip('cities', 'Cities', _selectedCategory == 'cities'),
            _buildFilterChip('culture', 'Culture', _selectedCategory == 'culture'),
            _buildFilterChip('nature', 'Nature', _selectedCategory == 'nature'),
            _buildFilterChip('adventure', 'Adventure', _selectedCategory == 'adventure'),
            _buildFilterChip('beach', 'Beach', _selectedCategory == 'beach'),
            _buildFilterChip('desert', 'Desert', _selectedCategory == 'desert'),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('all', 'All Budgets', _selectedBudget == 'all'),
            _buildFilterChip('budget', 'Budget', _selectedBudget == 'budget'),
            _buildFilterChip('mid_range', 'Mid-range', _selectedBudget == 'mid_range'),
            _buildFilterChip('luxury', 'Luxury', _selectedBudget == 'luxury'),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Duration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('all', 'Any Duration', _selectedDuration == 'all'),
            _buildFilterChip('weekend', 'Weekend', _selectedDuration == 'weekend'),
            _buildFilterChip('short', 'Short Trip', _selectedDuration == 'short'),
            _buildFilterChip('week', 'One Week', _selectedDuration == 'week'),
            _buildFilterChip('extended', 'Extended', _selectedDuration == 'extended'),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.activityTypes.map((type) {
            final isSelected = _selectedTypes.contains(type['id'] as String);
            return _buildFilterChip(
              type['id'] as String,
              type['name'] as String,
              isSelected,
              isMultiSelect: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, bool isSelected, {bool isMultiSelect = false}) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isMultiSelect) {
            if (selected) {
              _selectedTypes.add(value);
            } else {
              _selectedTypes.remove(value);
            }
          } else {
            if (value == 'all') {
              _selectedCategory = selected ? 'all' : _selectedCategory;
              _selectedBudget = selected ? 'all' : _selectedBudget;
              _selectedDuration = selected ? 'all' : _selectedDuration;
            } else if (label.contains('Budget')) {
              _selectedBudget = selected ? value : 'all';
            } else if (label.contains('Duration') || label.contains('Weekend') || label.contains('Short') || label.contains('Week') || label.contains('Extended')) {
              _selectedDuration = selected ? value : 'all';
            } else {
              _selectedCategory = selected ? value : 'all';
            }
          }
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Color(AppConstants.primaryColor),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Color(AppConstants.primaryColor) : Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'all';
      _selectedBudget = 'all';
      _selectedDuration = 'all';
      _selectedTypes.clear();
    });
  }

  void _applyFilters() {
    final filters = {
      'category': _selectedCategory,
      'budget': _selectedBudget,
      'duration': _selectedDuration,
      'types': _selectedTypes,
    };
    
    widget.onFiltersApplied(filters);
    Navigator.pop(context);
  }
} 