// lib/features/admin/views/reports/admin_complaints_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Laporan & Komplain', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, vm, _) {
            if (vm.complaints.isEmpty) {
              return const Center(child: Text('Tidak ada laporan'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.complaints.length,
              itemBuilder: (context, index) {
                final c = vm.complaints[index];
                final status = c['status'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: c['type'] == 'Event Report' ? AppColors.primaryContainer : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c['type'] as String,
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: c['type'] == 'Event Report' ? AppColors.primary : AppColors.error),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'Resolved' ? AppColors.successLight : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: status == 'Resolved' ? AppColors.success : AppColors.warningDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(c['title'] as String, style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Text('Target Pelanggaran: ${c['target']}', style: AppTypography.bodySmall),
                      Text('Pelapor: ${c['reporter']}', style: AppTypography.caption),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 'Review') ...[
                            OutlinedButton(
                              onPressed: () => vm.updateComplaintStatus(c['id'] as String, 'Closed'),
                              child: const Text('Close Ticket'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => vm.updateComplaintStatus(c['id'] as String, 'Resolved'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                              child: const Text('Tandai Selesai'),
                            ),
                          ] else
                            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                        ],
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
}
