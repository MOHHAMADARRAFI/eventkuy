// lib/features/explore/views/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/event_model.dart';
import '../../../features/bookmark/viewmodels/bookmark_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../viewmodels/explore_viewmodel.dart';
import '../widgets/filter_bottom_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreViewModel>().loadRecentSearches();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openFilter() {
    final vm = context.read<ExploreViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FilterBottomSheet(
          initialFilters: vm.filters,
          onApply: vm.applyFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<ExploreViewModel>();
    final bookmarkVm = context.watch<BookmarkViewModel>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Search Bar & Filter ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH,
                16,
                AppDimensions.screenPaddingH,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      hint: AppStrings.searchHint,
                      autofocus: false,
                      onChanged: (q) => vm.search(q),
                      onClear: () => vm.clearQuery(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter button
                  GestureDetector(
                    onTap: _openFilter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: vm.hasFilters
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.surface),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: vm.hasFilters
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Active Filters Row ─────────────────
            if (vm.hasFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Text('Filter aktif',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: vm.clearFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close_rounded,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Text(AppStrings.clearAll,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Content ────────────────────────────
            Expanded(child: _buildContent(vm, bookmarkVm, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      ExploreViewModel vm, BookmarkViewModel bookmarkVm, bool isDark) {
    if (vm.showInitialState) {
      return _InitialState(
        recentSearches: vm.recentSearches,
        popularSearches: vm.popularSearches,
        onSearch: (q) {
          _searchCtrl.text = q;
          vm.selectRecentSearch(q);
        },
        onClearRecent: vm.clearRecentSearches,
      );
    }

    if (vm.isLoading) return const ListShimmer();

    if (vm.state == ExploreState.empty) {
      return EmptyStateWidget(
        title: AppStrings.emptySearch,
        description: AppStrings.emptySearchDesc,
        icon: Icons.search_off_rounded,
        iconColor: AppColors.textTertiary,
      );
    }

    if (vm.state == ExploreState.error) {
      return AppErrorWidget(
        message: vm.error ?? 'Pencarian gagal',
        onRetry: () => vm.search(vm.query),
      );
    }

    return _SearchResults(
      events: vm.results,
      bookmarkVm: bookmarkVm,
    );
  }
}

// ── Initial State ─────────────────────────────────────
class _InitialState extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> popularSearches;
  final void Function(String) onSearch;
  final VoidCallback onClearRecent;

  const _InitialState({
    required this.recentSearches,
    required this.popularSearches,
    required this.onSearch,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.recentSearch,
                    style: AppTypography.titleMedium),
                TextButton(
                  onPressed: onClearRecent,
                  child: Text(AppStrings.clearAll,
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.error)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((q) => _SearchChip(
                    label: q,
                    icon: Icons.history_rounded,
                    onTap: () => onSearch(q),
                  )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          Text(AppStrings.popularSearch, style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularSearches.map((q) => _SearchChip(
                  label: q,
                  icon: Icons.trending_up_rounded,
                  onTap: () => onSearch(q),
                )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Search Results ────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final List<EventModel> events;
  final BookmarkViewModel bookmarkVm;

  const _SearchResults({required this.events, required this.bookmarkVm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            '${events.length} event ditemukan',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              return EventListCard(
                event: event,
                isBookmarked: bookmarkVm.isBookmarked(event.id),
                onTap: () => context.push('/event/${event.id}'),
                onBookmarkTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
