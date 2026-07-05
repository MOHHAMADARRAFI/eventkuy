// lib/features/organizer/profile/organizer_verification_status_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/data/models/user_model.dart';

class OrganizerVerificationStatusScreen extends StatelessWidget {
  const OrganizerVerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthViewModel>().currentUser;
    final status = user?.verificationStatus ?? VerificationStatus.none;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              if (status == VerificationStatus.pending) ...[
                const Icon(Icons.hourglass_empty_rounded, size: 80, color: AppColors.warning),
                const SizedBox(height: 24),
                Text('Verifikasi Sedang Diproses', style: AppTypography.displaySmall, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Data organisasimu sedang ditinjau oleh Admin. Proses ini biasanya memakan waktu maksimal 24 jam kerja.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Debug helper
                if (kDebugMode)
                  AppSecondaryButton(
                    label: 'Setujui Instan (Debug)',
                    onTap: () async {
                      if (user != null) {
                        final verifiedUser = user.copyWith(
                          verificationStatus: VerificationStatus.approved,
                          role: UserRole.organizer,
                        );
                        final authVm = context.read<AuthViewModel>();
                        await authVm.updateProfile(verifiedUser);
                        authVm.switchRole(UserRole.organizer);
                        if (context.mounted) {
                          context.go('/organizer/dashboard');
                        }
                      }
                    },
                  ),
              ] else if (status == VerificationStatus.rejected) ...[
                const Icon(Icons.cancel_outlined, size: 80, color: AppColors.error),
                const SizedBox(height: 24),
                Text('Verifikasi Ditolak', style: AppTypography.displaySmall, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Mohon maaf, permohonan Anda ditolak karena dokumen yang diunggah kurang jelas atau tidak valid.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Ajukan Ulang',
                  onTap: () => context.go('/profile/apply-organizer'),
                ),
              ] else ...[
                const Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.success),
                const SizedBox(height: 24),
                Text('Akun Penyelenggara Aktif', style: AppTypography.displaySmall, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Akun Anda telah disetujui. Selamat membuat event menarik bersama kami!',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Masuk Dashboard',
                  onTap: () {
                    context.read<AuthViewModel>().switchRole(UserRole.organizer);
                    context.go('/organizer/dashboard');
                  },
                ),
              ],
              const Spacer(),
              AppSecondaryButton(
                label: 'Kembali ke Profil',
                onTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Text {
  // Simple workaround to center text alignment
}
