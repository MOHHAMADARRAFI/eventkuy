// lib/features/home/widgets/recommended_section.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/event_model.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/section_header.dart';

class RecommendedSection extends StatelessWidget {
  final List<EventModel> events;
  final Set<String> bookmarkedIds;
  final void Function(EventModel) onEventTap;
  final void Function(EventModel) onBookmarkTap;
  final VoidCallback? onSeeAll;

  const RecommendedSection({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.recommendedEvents,
          actionLabel: AppStrings.seeAll,
          onActionTap: onSeeAll,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
            ),
            itemCount: events.take(6).length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                isBookmarked: bookmarkedIds.contains(event.id),
                onTap: () => onEventTap(event),
                onBookmarkTap: () => onBookmarkTap(event),
              );
            },
          ),
        ),
      ],
    );
  }
}
