// lib/features/home/widgets/popular_organizer_section.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/organizer_model.dart';
import '../../../shared/widgets/organizer_card.dart';
import '../../../shared/widgets/section_header.dart';

class PopularOrganizerSection extends StatelessWidget {
  final List<OrganizerModel> organizers;
  final void Function(OrganizerModel) onTap;

  const PopularOrganizerSection({
    super.key,
    required this.organizers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (organizers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.popularOrganizers),
        const SizedBox(height: 14),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
            ),
            itemCount: organizers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final organizer = organizers[index];
              return OrganizerCard(
                organizer: organizer,
                onTap: () => onTap(organizer),
              );
            },
          ),
        ),
      ],
    );
  }
}
