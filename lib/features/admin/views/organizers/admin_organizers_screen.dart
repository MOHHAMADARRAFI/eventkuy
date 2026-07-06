// lib/features/admin/views/organizers/admin_organizers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/data/models/user_model.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';

class AdminOrganizersScreen extends StatefulWidget {
  const AdminOrganizersScreen({super.key});

  @override
  State<AdminOrganizersScreen> createState() => _AdminOrganizersScreenState();
}

class _AdminOrganizersScreenState extends State<AdminOrganizersScreen> {
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
        title: const Text('Persetujuan Penyelenggara', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Consumer<AdminViewModel>(
          builder: (context, vm, _) {
            // Find users who have pending verification status
            final pendingApplicants = vm.users.where((u) => u.verificationStatus == VerificationStatus.pending).toList();

            if (pendingApplicants.isEmpty) {
              return const Center(child: Text('Tidak ada permohonan verifikasi pending.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingApplicants.length,
              itemBuilder: (context, index) {
                final applicant = pendingApplicants[index];
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
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: applicant.organizationLogo != null ? NetworkImage(applicant.organizationLogo!) : null,
                            child: applicant.organizationLogo == null ? const Icon(Icons.business_rounded) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(applicant.organizationName ?? 'Nama Organisasi', style: AppTypography.titleLarge),
                                Text('Pemilik: ${applicant.name}', style: AppTypography.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('No Kontak CP: ${applicant.phoneNumber ?? '-'}', style: AppTypography.bodySmall),
                      Text('Bank Account: ${applicant.bankName} - ${applicant.bankAccountNo} (a/n ${applicant.bankAccountName})', style: AppTypography.bodySmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _processApplication(vm, applicant.organizationName ?? '', false),
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
                              label: 'Verifikasi',
                              height: 40,
                              onTap: () => _processApplication(vm, applicant.organizationName ?? '', true),
                            ),
                          ),
                        ],
                      ),
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

  void _processApplication(AdminViewModel vm, String orgName, bool approve) {
    vm.verifyOrganizer(orgName, approve);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approve ? 'Permohonan organisasi disetujui!' : 'Permohonan organisasi ditolak.'),
        backgroundColor: approve ? AppColors.success : AppColors.error,
      ),
    );
  }
}
