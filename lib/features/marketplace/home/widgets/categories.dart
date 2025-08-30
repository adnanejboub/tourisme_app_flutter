import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/domain/category/entities/category.dart';

class CategoriesWidget extends StatefulWidget {
  final List<CategoryEntity> categories;

  const CategoriesWidget({Key? key, required this.categories}) : super(key: key);

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  CategoryEntity? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category.title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4A90E2),
              elevation: isSelected ? 4 : 0,
              shadowColor: const Color(0xFF4A90E2).withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }
  @override
  void initState() {
    super.initState();
      selectedCategory = widget.categories[0]; // ✅ Select first category
  }
}

