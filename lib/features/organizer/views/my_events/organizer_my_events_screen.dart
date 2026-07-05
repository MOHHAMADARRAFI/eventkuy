// lib/features/organizer/views/my_events/organizer_my_events_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_text_field.dart';
import 'package:eventkuy/shared/widgets/empty_state_widget.dart';
import 'package:eventkuy/features/organizer/events/organizer_events_viewmodel.dart';

class OrganizerMyEventsScreen extends StatefulWidget {
  const OrganizerMyEventsScreen({super.key});

  @override
  State<OrganizerMyEventsScreen> createState() => _OrganizerMyEventsScreenState();
}

class _OrganizerMyEventsScreenState extends State<OrganizerMyEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Semua', 'status': null},
    {'label': 'Draft', 'status': EventStatus.draft},
    {'label': 'Review', 'status': EventStatus.submittedForReview},
    {'label': 'Buka', 'status': EventStatus.registrationOpen},
    {'label': 'Berlangsung', 'status': EventStatus.ongoing},
    {'label': 'Selesai', 'status': EventStatus.finished},
    {'label': 'Batal', 'status': EventStatus.cancelled},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchCtrl.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgId = context.read<AuthViewModel>().currentUser?.id ?? 'org_001';
      context.read<OrganizerEventsViewModel>().loadEvents(orgId);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index]['status'] as EventStatus?;
    context.read<OrganizerEventsViewModel>().setFilterStatus(status);
  }

  void _onSearchChanged() {
    context.read<OrganizerEventsViewModel>().setSearchQuery(_searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Event Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/organizer/create-event'),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                label: '',
                hint: 'Cari event saya...',
                controller: _searchCtrl,
                prefixIcon: Icons.search_rounded,
                suffixWidget: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Tab bar Status Groups
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTypography.labelMedium,
              tabs: _tabs.map((tab) => Tab(text: tab['label'])).toList(),
            ),
            const SizedBox(height: 12),

            // Events List
            Expanded(
              child: Consumer<OrganizerEventsViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.events.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Tidak Ada Event',
                      description: 'Silakan buat event baru atau gunakan filter lain.',
                      icon: Icons.event_busy_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: vm.events.length,
                    itemBuilder: (context, index) {
                      final event = vm.events[index];
                      return _buildEventCard(context, event, isDark);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image & status badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
                child: CachedNetworkImage(
                  imageUrl: event.posterUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: AppColors.primaryContainer, height: 140),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: event.status.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.status.label.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTypography.titleLarge),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(event.startDate.toString().substring(0, 16), style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('${event.registered} / ${event.quota} Terdaftar', style: AppTypography.labelMedium),
                    const Spacer(),
                    Text(event.priceLabel, style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.push('/organizer/edit-event/${event.id}'),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/organizer/event/${event.id}'),
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: const Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
