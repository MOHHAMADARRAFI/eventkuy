// lib/features/home/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/features/bookmark/viewmodels/bookmark_viewmodel.dart';
import 'package:eventkuy/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/shared/widgets/empty_state_widget.dart';
import 'package:eventkuy/shared/widgets/shimmer_loader.dart';
import 'package:eventkuy/features/home/viewmodels/home_viewmodel.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/nearby_section.dart';
import '../widgets/popular_organizer_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/trending_section.dart';
import '../widgets/upcoming_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final user = context.read<AuthViewModel>().currentUser;
    final interests = user?.interests ?? [];
    context.read<HomeViewModel>().loadHome(interests);
    final userId = user?.id ?? 'user_001';
    context.read<BookmarkViewModel>().loadBookmarks(userId);
    context.read<NotificationViewModel>().load(userId);
  }

  Future<void> _onRefresh() async {
    final user = context.read<AuthViewModel>().currentUser;
    await context.read<HomeViewModel>().refresh(user?.interests ?? []);
  }

  void _navigateToEvent(EventModel event) {
    context.push('/event/${event.id}');
  }

  Future<void> _toggleBookmark(EventModel event) async {
    final authVm = context.read<AuthViewModel>();
    final bookmarkVm = context.read<BookmarkViewModel>();
    final userId = authVm.currentUser?.id ?? 'user_001';
    final wasBookmarked = bookmarkVm.isBookmarked(event.id);

    if (wasBookmarked) {
      await bookmarkVm.removeBookmark(userId, event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.bookmarkRemoved,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.textSecondary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      await context
          .read<BookmarkViewModel>()
          .loadBookmarks(userId); // reload after add via detail
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return AppStrings.goodMorning;
    if (hour < 15) return AppStrings.goodAfternoon;
    if (hour < 18) return AppStrings.goodEvening;
    return AppStrings.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthViewModel>().currentUser;
    final notifVm = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ── AppBar ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    16,
                    AppDimensions.screenPaddingH,
                    8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()},',
                              style: AppTypography.bodyMedium,
                            ),
                            Text(
                              user?.name.split(' ').first ??
                                  'Pengguna',
                              style: AppTypography.headlineMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                              onPressed: () => context.push('/notification'),
                            ),
                          ),
                          if (notifVm.unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Bar ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingH,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () => context.go('/explore'),
                    child: AbsorbPointer(
                      child: AppSearchField(
                        hint: AppStrings.searchHint,
                        readOnly: true,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<HomeViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading) {
                      return const HomeShimmer();
                    }
                    if (vm.state == HomeLoadState.error) {
                      return AppErrorWidget(
                        message: vm.error ?? 'Gagal memuat data',
                        onRetry: _loadData,
                      );
                    }
                    return _HomeContent(
                      vm: vm,
                      bookmarkVm: context.watch<BookmarkViewModel>(),
                      onEventTap: _navigateToEvent,
                      onBookmarkTap: _toggleBookmark,
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeViewModel vm;
  final BookmarkViewModel bookmarkVm;
  final void Function(EventModel) onEventTap;
  final void Function(EventModel) onBookmarkTap;

  const _HomeContent({
    required this.vm,
    required this.bookmarkVm,
    required this.onEventTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkedIds = bookmarkVm.bookmarkedIds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Banner
        BannerSlider(
          events: vm.bannerEvents,
          onTap: onEventTap,
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),

        // Categories
        CategoryList(
          categories: vm.categories,
          selectedId: vm.selectedCategoryId,
          onSelect: (id) {
            vm.selectCategory(id);
            context.go('/explore');
          },
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),

        // Trending
        TrendingSection(
          events: vm.trendingEvents,
          bookmarkedIds: bookmarkedIds,
          onEventTap: onEventTap,
          onBookmarkTap: onBookmarkTap,
          onSeeAll: () => context.go('/explore'),
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),

        // Recommended
        RecommendedSection(
          events: vm.recommendedEvents,
          bookmarkedIds: bookmarkedIds,
          onEventTap: onEventTap,
          onBookmarkTap: onBookmarkTap,
          onSeeAll: () => context.go('/explore'),
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),

        // Upcoming
        UpcomingSection(
          events: vm.upcomingEvents,
          bookmarkedIds: bookmarkedIds,
          onEventTap: onEventTap,
          onBookmarkTap: onBookmarkTap,
          onSeeAll: () => context.go('/explore'),
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),

        // Nearby
        NearbySection(
          events: vm.nearbyEvents,
          bookmarkedIds: bookmarkedIds,
          onEventTap: onEventTap,
          onBookmarkTap: onBookmarkTap,
          onSeeAll: () => context.go('/explore'),
        ),
        const SizedBox(height: AppDimensions.sectionSpacing),

        // Popular Organizers
        PopularOrganizerSection(
          organizers: vm.popularOrganizers,
          onTap: (org) => context.push('/organizer-profile/${org.id}'),
        ),
      ],
    );
  }
}
