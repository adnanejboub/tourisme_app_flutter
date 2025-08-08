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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: colorScheme.onBackground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              localizationService.translate('filters'),
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  localizationService.translate('clear'),
                  style: TextStyle(
                    color: colorScheme.primary,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySection(colorScheme, localizationService),
                      const SizedBox(height: 32),
                      _buildBudgetSection(colorScheme, localizationService),
                      const SizedBox(height: 32),
                      _buildDurationSection(colorScheme, localizationService),
                      const SizedBox(height: 32),
                      _buildTypeSection(colorScheme, localizationService),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(colorScheme, localizationService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('category'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('all', localizationService.translate('all'), _selectedCategory == 'all', colorScheme),
            _buildFilterChip('cities', localizationService.translate('cities'), _selectedCategory == 'cities', colorScheme),
            _buildFilterChip('culture', localizationService.translate('culture'), _selectedCategory == 'culture', colorScheme),
            _buildFilterChip('nature', localizationService.translate('nature'), _selectedCategory == 'nature', colorScheme),
            _buildFilterChip('adventure', localizationService.translate('adventure'), _selectedCategory == 'adventure', colorScheme),
            _buildFilterChip('beach', localizationService.translate('beach'), _selectedCategory == 'beach', colorScheme),
            _buildFilterChip('desert', localizationService.translate('desert'), _selectedCategory == 'desert', colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('budget'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('all', localizationService.translate('all_budgets'), _selectedBudget == 'all', colorScheme),
            _buildFilterChip('budget', localizationService.translate('budget_friendly'), _selectedBudget == 'budget', colorScheme),
            _buildFilterChip('mid_range', localizationService.translate('mid_range'), _selectedBudget == 'mid_range', colorScheme),
            _buildFilterChip('luxury', localizationService.translate('luxury'), _selectedBudget == 'luxury', colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('duration'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterChip('all', localizationService.translate('any_duration'), _selectedDuration == 'all', colorScheme),
            _buildFilterChip('weekend', localizationService.translate('weekend'), _selectedDuration == 'weekend', colorScheme),
            _buildFilterChip('short', localizationService.translate('short_trip'), _selectedDuration == 'short', colorScheme),
            _buildFilterChip('week', localizationService.translate('one_week'), _selectedDuration == 'week', colorScheme),
            _buildFilterChip('extended', localizationService.translate('extended'), _selectedDuration == 'extended', colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSection(ColorScheme colorScheme, LocalizationService localizationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('experience_type'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.activityTypes.map((type) {
            final isSelected = _selectedTypes.contains(type['id'] as String);
            return _buildFilterChip(
              type['id'] as String,
              localizationService.translate(type['name'] as String),
              isSelected,
              colorScheme,
              isMultiSelect: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, bool isSelected, ColorScheme colorScheme, {bool isMultiSelect = false}) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
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
            } else if (_isBudgetFilter(value)) {
              _selectedBudget = selected ? value : 'all';
            } else if (_isDurationFilter(value)) {
              _selectedDuration = selected ? value : 'all';
            } else {
              _selectedCategory = selected ? value : 'all';
            }
          }
        });
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outline,
        width: 1,
      ),
    );
  }

  bool _isBudgetFilter(String value) {
    return ['budget', 'mid_range', 'luxury'].contains(value);
  }

  bool _isDurationFilter(String value) {
    return ['weekend', 'short', 'week', 'extended'].contains(value);
  }

  Widget _buildActionButtons(ColorScheme colorScheme, LocalizationService localizationService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                localizationService.translate('cancel'),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                localizationService.translate('apply_filters'),
                style: TextStyle(
                  color: colorScheme.onPrimary,
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