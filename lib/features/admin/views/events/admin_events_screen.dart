// lib/features/admin/views/events/admin_events_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/event_model.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Review Event Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, vm, _) {
            // Filter events that are pending admin approval (submittedForReview status)
            final pendingEvents = vm.allEvents.where((e) => e.status == EventStatus.submittedForReview).toList();

            if (pendingEvents.isEmpty) {
              return const Center(child: Text('Tidak ada pengajuan event baru.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingEvents.length,
              itemBuilder: (context, index) {
                final event = pendingEvents[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(event.posterUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: AppTypography.titleLarge),
                            const SizedBox(height: 6),
                            Text('Penyelenggara: ${event.organizer.name}', style: AppTypography.caption),
                            Text('Tanggal: ${event.startDate.toString().substring(0, 16)}', style: AppTypography.caption),
                            Text('Lokasi: ${event.location}', style: AppTypography.caption),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _review(vm, event.id, false),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.error),
                                      foregroundColor: AppColors.error,
                                    ),
                                    child: const Text('Tolak'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppPrimaryButton(
                                    label: 'Approve',
                                    height: 40,
                                    onTap: () => _review(vm, event.id, true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _review(AdminViewModel vm, String eventId, bool approve) {
    vm.reviewEvent(eventId, approve);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approve ? 'Event berhasil disetujui!' : 'Event ditolak.'),
        backgroundColor: approve ? AppColors.success : AppColors.error,
      ),
    );
  }
}
