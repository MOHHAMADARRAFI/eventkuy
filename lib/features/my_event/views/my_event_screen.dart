// lib/features/my_event/views/my_event_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/registration_model.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../viewmodels/my_event_viewmodel.dart';

class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  @override
  State<MyEventScreen> createState() => _MyEventScreenState();
}

class _MyEventScreenState extends State<MyEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<MyEventViewModel>().setTab(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId =
        context.read<AuthViewModel>().currentUser?.id ?? 'user_001';
    context.read<MyEventViewModel>().load(userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('Event Saya', style: AppTypography.displaySmall),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTypography.labelMedium,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicator: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Batal'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Content
            Expanded(
              child: Consumer<MyEventViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) return const ListShimmer();

                  final registrations = vm.currentTabRegistrations;

                  if (registrations.isEmpty) {
                    return EmptyStateWidget(
                      title: AppStrings.emptyMyEvent,
                      description: AppStrings.emptyMyEventDesc,
                      icon: Icons.event_busy_rounded,
                      actionLabel: 'Jelajahi Event',
                      onAction: () => context.go('/explore'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _load(),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: registrations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _RegistrationCard(
                          registration: registrations[index],
                          isDark: isDark,
                          onTap: () => context
                              .push('/event/${registrations[index].event.id}'),
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

class _RegistrationCard extends StatelessWidget {
  final RegistrationModel registration;
  final bool isDark;
  final VoidCallback onTap;

  const _RegistrationCard({
    required this.registration,
    required this.isDark,
    required this.onTap,
  });

  Color get _statusColor {
    switch (registration.status) {
      case RegistrationStatus.upcoming: return AppColors.primary;
      case RegistrationStatus.completed: return AppColors.success;
      case RegistrationStatus.cancelled: return AppColors.error;
      case RegistrationStatus.pending: return AppColors.warning;
    }
  }

  Color get _statusBgColor {
    switch (registration.status) {
      case RegistrationStatus.upcoming: return AppColors.primaryContainer;
      case RegistrationStatus.completed: return AppColors.successLight;
      case RegistrationStatus.cancelled: return AppColors.errorLight;
      case RegistrationStatus.pending: return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = registration.event;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '${registration.status.emoji} ${registration.status.label}',
                    style: AppTypography.labelSmall.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: event.startDate.formattedDateShort,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: event.mode == EventMode.online
                      ? Icons.laptop_rounded
                      : Icons.place_rounded,
                  label: event.mode == EventMode.online
                      ? 'Online'
                      : event.location.split(',').first,
                ),
              ],
            ),
            if (registration.ticketCode != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      registration.ticketCode!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
