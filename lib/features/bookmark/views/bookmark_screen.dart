// lib/features/bookmark/views/bookmark_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../viewmodels/bookmark_viewmodel.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId =
        context.read<AuthViewModel>().currentUser?.id ?? 'user_001';
    context.read<BookmarkViewModel>().loadBookmarks(userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text('Event Tersimpan',
                  style: AppTypography.displaySmall),
            ),
            Expanded(
              child: Consumer<BookmarkViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) return const ListShimmer();

                  if (vm.state == BookmarkState.empty) {
                    return EmptyStateWidget(
                      title: AppStrings.emptyBookmark,
                      description: AppStrings.emptyBookmarkDesc,
                      icon: Icons.bookmark_border_rounded,
                      actionLabel: 'Jelajahi Event',
                      onAction: () => context.go('/explore'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _load(),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: vm.bookmarks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bookmark = vm.bookmarks[index];
                        final event = bookmark.event;
                        return EventListCard(
                          event: event,
                          isBookmarked: true,
                          onTap: () => context.push('/event/${event.id}'),
                          onBookmarkTap: () {
                            final userId = context
                                .read<AuthViewModel>()
                                .currentUser
                                ?.id ?? 'user_001';
                            vm.removeBookmark(userId, event.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.bookmarkRemoved,
                                    style: AppTypography.bodyMedium
                                        .copyWith(color: Colors.white)),
                                backgroundColor: AppColors.textSecondary,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
