// lib/features/explore/widgets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/event_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../viewmodels/explore_viewmodel.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialFilters;
  final void Function(FilterOptions) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: AppDimensions.bottomSheetHandleWidth,
            height: AppDimensions.bottomSheetHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.filter,
                    style: AppTypography.headlineSmall),
                TextButton(
                  onPressed: () =>
                      setState(() => _filters = const FilterOptions()),
                  child: Text(AppStrings.reset,
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.error)),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  _SectionTitle(AppStrings.filterByCategory),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DummyData.categories.map((cat) {
                      final isSelected = _filters.categoryId == cat.id;
                      return _FilterChip(
                        label: '${cat.icon} ${cat.name}',
                        isSelected: isSelected,
                        color: cat.color,
                        onTap: () => setState(() {
                          _filters = _filters.copyWith(
                            categoryId: isSelected ? null : cat.id,
                            clearCategory: isSelected,
                          );
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Price
                  _SectionTitle(AppStrings.filterByPrice),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _FilterChip(
                        label: '🎁 ${AppStrings.free}',
                        isSelected: _filters.isFree == true,
                        color: AppColors.success,
                        onTap: () => setState(() {
                          _filters = _filters.copyWith(
                            isFree: _filters.isFree == true ? null : true,
                            clearPrice: _filters.isFree == true,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '💳 ${AppStrings.paid}',
                        isSelected: _filters.isFree == false,
                        color: AppColors.primary,
                        onTap: () => setState(() {
                          _filters = _filters.copyWith(
                            isFree: _filters.isFree == false ? null : false,
                            clearPrice: _filters.isFree == false,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mode
                  _SectionTitle(AppStrings.filterByMode),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _FilterChip(
                        label: '💻 Online',
                        isSelected: _filters.mode == EventMode.online,
                        color: AppColors.info,
                        onTap: () => setState(() {
                          _filters = _filters.copyWith(
                            mode: _filters.mode == EventMode.online
                                ? null
                                : EventMode.online,
                            clearMode: _filters.mode == EventMode.online,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '📍 Offline',
                        isSelected: _filters.mode == EventMode.offline,
                        color: AppColors.secondary,
                        onTap: () => setState(() {
                          _filters = _filters.copyWith(
                            mode: _filters.mode == EventMode.offline
                                ? null
                                : EventMode.offline,
                            clearMode: _filters.mode == EventMode.offline,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '🔀 Hybrid',
                        isSelected: _filters.mode == EventMode.hybrid,
                        color: AppColors.catMarketing,
                        onTap: () => setState(() {
                          _filters = _filters.copyWith(
                            mode: _filters.mode == EventMode.hybrid
                                ? null
                                : EventMode.hybrid,
                            clearMode: _filters.mode == EventMode.hybrid,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Apply
                  AppPrimaryButton(
                    label: AppStrings.apply,
                    onTap: () {
                      widget.onApply(_filters);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.titleSmall);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.chip.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
