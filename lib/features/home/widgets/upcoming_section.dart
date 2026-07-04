// lib/features/home/widgets/upcoming_section.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/event_model.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/section_header.dart';

class UpcomingSection extends StatelessWidget {
  final List<EventModel> events;
  final Set<String> bookmarkedIds;
  final void Function(EventModel) onEventTap;
  final void Function(EventModel) onBookmarkTap;
  final VoidCallback? onSeeAll;

  const UpcomingSection({
    super.key,
    required this.events,
    required this.bookmarkedIds,
    required this.onEventTap,
    required this.onBookmarkTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.upcomingEvents,
          actionLabel: AppStrings.seeAll,
          onActionTap: onSeeAll,
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          itemCount: events.take(4).length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = events[index];
            return _UpcomingCard(
              event: event,
              isBookmarked: bookmarkedIds.contains(event.id),
              onTap: () => onEventTap(event),
              onBookmarkTap: () => onBookmarkTap(event),
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final EventModel event;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final bool isDark;

  const _UpcomingCard({
    required this.event,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date block
            Container(
              width: 52,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.startDate.day}',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  Text(
                    _monthShort(event.startDate.month),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: event.eventType.bgColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      event.eventType.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: event.eventType.color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')} WIB',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        event.mode == EventMode.online
                            ? Icons.laptop_rounded
                            : Icons.place_rounded,
                        size: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          event.mode == EventMode.online
                              ? 'Online'
                              : event.location.split(',').first,
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onBookmarkTap,
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20,
                    color: isBookmarked
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: event.isFree
                        ? AppColors.successLight
                        : AppColors.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    event.priceLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: event.isFree
                          ? AppColors.success
                          : AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }
}
