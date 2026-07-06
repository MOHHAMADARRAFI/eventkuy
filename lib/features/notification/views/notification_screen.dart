// lib/features/notification/views/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/models/notification_model.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/shared/widgets/empty_state_widget.dart';
import 'package:eventkuy/shared/widgets/shimmer_loader.dart';
import 'package:eventkuy/features/notification/viewmodels/notification_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId =
        context.read<AuthViewModel>().currentUser?.id ?? 'user_001';
    context.read<NotificationViewModel>().load(userId);
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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifikasi', style: AppTypography.displaySmall),
                  Consumer<NotificationViewModel>(
                    builder: (context, vm, _) {
                      if (vm.unreadCount == 0) return const SizedBox.shrink();
                      return TextButton.icon(
                        onPressed: () {
                          final userId = context
                              .read<AuthViewModel>()
                              .currentUser
                              ?.id ?? 'user_001';
                          vm.markAllAsRead(userId);
                        },
                        icon: const Icon(Icons.done_all_rounded,
                            size: 16),
                        label: const Text('Baca Semua'),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<NotificationViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) return const ListShimmer();

                  if (vm.state == NotifState.empty) {
                    return EmptyStateWidget(
                      title: AppStrings.emptyNotification,
                      description: AppStrings.emptyNotificationDesc,
                      icon: Icons.notifications_none_rounded,
                      iconColor: AppColors.textTertiary,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _load(),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: vm.notifications.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final notif = vm.notifications[index];
                        return _NotificationTile(
                          notification: notif,
                          onTap: () {
                            vm.markAsRead(notif.id);
                            if (notif.eventId != null) {
                              context.push('/event/${notif.eventId}');
                            }
                          },
                          isDark: isDark,
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

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final bool isDark;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.isDark,
  });

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.eventReminder: return AppColors.warning;
      case NotificationType.scheduleChange: return AppColors.info;
      case NotificationType.newEvent: return AppColors.primary;
      case NotificationType.registrationSuccess: return AppColors.success;
      case NotificationType.eventCancelled: return AppColors.error;
      case NotificationType.general: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        color: notification.isRead
            ? Colors.transparent
            : (isDark
                ? AppColors.primary.withAlpha(15)
                : AppColors.primaryContainer.withAlpha(80)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Text(
                  notification.type.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.createdAt.relative,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
