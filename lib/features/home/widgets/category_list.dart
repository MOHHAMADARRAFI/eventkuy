// lib/features/home/widgets/category_list.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/category_model.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedId;
  final void Function(String) onSelect;

  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
        ),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedId == cat.id;

          return GestureDetector(
            onTap: () => onSelect(cat.id),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? cat.color : cat.bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cat.color.withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      cat.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? cat.color : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
