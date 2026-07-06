// lib/features/organizer/views/event_detail/organizer_event_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/core/utils/extensions.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_dialog.dart';
import 'package:eventkuy/features/organizer/events/organizer_events_viewmodel.dart';

class OrganizerEventDetailScreen extends StatelessWidget {
  final String eventId;

  const OrganizerEventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Consumer<OrganizerEventsViewModel>(
        builder: (context, vm, _) {
          EventModel? event;
          try {
            event = vm.events.firstWhere((e) => e.id == eventId);
          } catch (_) {
            // Find in overall list if not in filtered
            event = null;
          }

          if (event == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Event tidak ditemukan')),
            );
          }

          final totalRevenue = event.price != null ? event.registered * event.price! : 0;

          return CustomScrollView(
            slivers: [
              // Collapsible Banner Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: event.posterUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(color: AppColors.primaryContainer),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () => context.push('/organizer/edit-event/${event!.id}'),
                  )
                ],
              ),

              // Title and status
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: event.status.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              event.status.label.toUpperCase(),
                              style: TextStyle(color: event.status.color, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            event.priceLabel,
                            style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(event.title, style: AppTypography.headlineLarge),
                      const SizedBox(height: 16),
                      
                      // Stat Cards row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStatCard(
                              title: 'Tiket Terjual',
                              value: '${event.registered}',
                              subtitle: '/ ${event.quota} Kuota',
                              color: AppColors.primary,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailStatCard(
                              title: 'Pendapatan',
                              value: currencyFormat.format(totalRevenue),
                              subtitle: 'Total Lunas',
                              color: AppColors.success,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Quick Operations
                      if (event.status == EventStatus.draft) ...[
                        AppPrimaryButton(
                          label: 'Ajukan Publikasi',
                          onTap: () {
                            final updated = event!.copyWith(status: EventStatus.submittedForReview);
                            vm.updateEvent(updated);
                            context.showSnack('Event diajukan untuk review!', backgroundColor: AppColors.success);
                          },
                        ),
                        const SizedBox(height: 12),
                      ] else if (event.status == EventStatus.approved) ...[
                        AppPrimaryButton(
                          label: 'Terbitkan Sekarang',
                          onTap: () {
                            final updated = event!.copyWith(status: EventStatus.published);
                            vm.updateEvent(updated);
                            context.showSnack('Event berhasil diterbitkan!', backgroundColor: AppColors.success);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/organizer/tickets?eventId=${event!.id}'),
                              icon: const Icon(Icons.confirmation_number_outlined),
                              label: const Text('Kelola Tiket'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: 'Hapus Event',
                                  message: 'Apakah kamu yakin ingin menghapus event ini? Aksi ini tidak dapat dibatalkan.',
                                  confirmLabel: 'Hapus',
                                  confirmColor: AppColors.error,
                                );
                                if (confirmed == true) {
                                  await vm.deleteEvent(event!.id);
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                              label: const Text('Hapus Event', style: TextStyle(color: AppColors.error)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Description
                      Text('Deskripsi Event', style: AppTypography.titleLarge),
                      const SizedBox(height: 8),
                      Text(event.description, style: AppTypography.bodyMedium),
                      const SizedBox(height: 28),
                      
                      // Mock Register list
                      Text('Daftar Pendaftar (Mock)', style: AppTypography.titleLarge),
                      const SizedBox(height: 12),
                      _buildParticipantsPreviewList(isDark),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.headlineMedium.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(subtitle, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildParticipantsPreviewList(bool isDark) {
    // Generate dummy participant data
    final list = [
      {'name': 'Ahmad Fauzi', 'email': 'ahmad.fauzi@gmail.com', 'checkedIn': true},
      {'name': 'Indah Permata', 'email': 'indah.permata@yahoo.com', 'checkedIn': false},
      {'name': 'Roni Wijaya', 'email': 'roni.wijaya@outlook.com', 'checkedIn': false},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(p['name'].toString()[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, style: AppTypography.labelMedium),
                    Text(p['email'] as String, style: AppTypography.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (p['checkedIn'] as bool) ? AppColors.successLight : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  (p['checkedIn'] as bool) ? 'Check In' : 'Absent',
                  style: TextStyle(color: (p['checkedIn'] as bool) ? AppColors.success : Colors.black45, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
