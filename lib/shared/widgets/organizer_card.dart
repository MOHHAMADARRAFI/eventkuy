// lib/shared/widgets/organizer_card.dart
// Reusable organizer card widget

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/organizer_model.dart';

class OrganizerCard extends StatelessWidget {
  final OrganizerModel organizer;
  final VoidCallback? onTap;

  const OrganizerCard({
    super.key,
    required this.organizer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.organizerCardWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: CachedNetworkImage(
                imageUrl: organizer.logoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.primaryContainer,
                  child: const Icon(Icons.business_rounded,
                      color: AppColors.primary),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: AppColors.cardGradient,
                  ),
                  child: Center(
                    child: Text(
                      organizer.name[0],
                      style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Name with verified badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    organizer.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (organizer.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${organizer.totalEvents} events',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    size: 12, color: AppColors.warning),
                const SizedBox(width: 2),
                Text(
                  organizer.rating.toStringAsFixed(1),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
