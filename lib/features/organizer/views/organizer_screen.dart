// lib/features/organizer/views/organizer_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/bookmark/viewmodels/bookmark_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/empty_state_widget.dart';
import 'package:eventkuy/shared/widgets/event_card.dart';
import 'package:eventkuy/shared/widgets/shimmer_loader.dart';
import 'package:eventkuy/features/organizer/viewmodels/organizer_viewmodel.dart';

class OrganizerScreen extends StatefulWidget {
  final String organizerId;

  const OrganizerScreen({super.key, required this.organizerId});

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<OrganizerViewModel>().load(widget.organizerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<OrganizerViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.state == OrganizerState.error || vm.organizer == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(message: vm.error ?? 'Gagal memuat data'),
          );
        }

        final org = vm.organizer!;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor:
                    isDark ? AppColors.darkBackground : AppColors.background,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusXxl),
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    child: Column(
                      children: [
                        // Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXl),
                          child: CachedNetworkImage(
                            imageUrl: org.logoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: AppColors.primaryContainer,
                              child: Center(
                                child: Text(
                                  org.name[0],
                                  style: AppTypography.headlineLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(org.name, style: AppTypography.headlineMedium),
                            if (org.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded,
                                  size: 20, color: AppColors.primary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(org.description,
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem('${org.totalEvents}', 'Events'),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.border),
                            _StatItem(
                                org.formattedFollowers, 'Followers'),
                            Container(
                                width: 1,
                                height: 32,
                                color: AppColors.border),
                            _StatItem(
                                org.rating.toStringAsFixed(1), 'Rating'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Follow button
                        AppPrimaryButton(
                          label: vm.isFollowing ? '✓ Mengikuti' : 'Ikuti',
                          onTap: vm.toggleFollow,
                          isFullWidth: false,
                          height: 40,
                          backgroundColor: vm.isFollowing
                              ? AppColors.success
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Events list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text('Events dari ${org.name}',
                      style: AppTypography.headlineSmall),
                ),
              ),

              if (vm.events.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    title: 'Belum ada event',
                    description: 'Organizer ini belum memiliki event aktif',
                    icon: Icons.event_busy_rounded,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = vm.events[index];
                        final bookmarkVm =
                            context.watch<BookmarkViewModel>();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventListCard(
                            event: event,
                            isBookmarked: bookmarkVm.isBookmarked(event.id),
                            onTap: () => context.push('/event/${event.id}'),
                            onBookmarkTap: () {},
                          ),
                        );
                      },
                      childCount: vm.events.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineSmall.copyWith(
          color: AppColors.primary,
        )),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
