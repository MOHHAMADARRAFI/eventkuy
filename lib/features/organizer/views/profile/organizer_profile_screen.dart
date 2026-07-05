// lib/features/organizer/views/profile/organizer_profile_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_dimensions.dart';
import 'package:eventkuy/core/constants/app_typography.dart';
import 'package:eventkuy/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:eventkuy/shared/widgets/app_button.dart';
import 'package:eventkuy/shared/widgets/app_dialog.dart';
import 'package:eventkuy/data/models/user_model.dart';

class OrganizerProfileScreen extends StatelessWidget {
  const OrganizerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Banner/Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusXxl)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      backgroundImage: user?.organizationLogo != null ? NetworkImage(user!.organizationLogo!) : null,
                      child: user?.organizationLogo == null
                          ? Text(user?.name[0].toUpperCase() ?? 'O', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(user?.organizationName ?? 'Organisasi', style: AppTypography.titleLarge.copyWith(color: Colors.white)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                            ],
                          ),
                          Text(user?.email ?? '', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              'Penyelenggara Terverifikasi',
                              style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 8),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Profile Menus
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                child: Column(
                  children: [
                    _buildMenuSection(
                      title: 'Profil Organisasi',
                      isDark: isDark,
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.business_rounded,
                          label: 'Detail Organisasi',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka detail organisasi (Simulasi)')));
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Icons.account_balance_rounded,
                          label: 'Rekening Bank Penerima',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Bank: BCA, No Rek: 880123456789 (Simulasi)')));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildMenuSection(
                      title: 'Keamanan & Sistem',
                      isDark: isDark,
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Ganti Password',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dialog ubah sandi dibuka (Simulasi)')));
                          },
                        ),
                        if (kDebugMode)
                          _ProfileMenuItem(
                            icon: Icons.swap_horizontal_circle_outlined,
                            label: 'Ganti Role (Debug)',
                            onTap: () => _showRoleSwitcherDialog(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Log out
                    AppSecondaryButton(
                      label: 'Keluar Akun',
                      onTap: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Keluar',
                          message: 'Apakah kamu yakin ingin keluar?',
                          confirmLabel: 'Keluar',
                          confirmColor: AppColors.error,
                        );
                        if (confirmed == true && context.mounted) {
                          await context.read<AuthViewModel>().logout();
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({required String title, required bool isDark, required List<_ProfileMenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.primary),
                    title: Text(item.label, style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 16),
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  void _showRoleSwitcherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pilih Role (Debug Mode)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              title: const Text('Participant Mode'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AuthViewModel>().switchRole(UserRole.participant);
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center_outlined, color: AppColors.secondary),
              title: const Text('Organizer Mode'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AuthViewModel>().switchRole(UserRole.organizer);
                context.go('/organizer/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.error),
              title: const Text('Admin Mode'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AuthViewModel>().switchRole(UserRole.admin);
                context.go('/admin/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap});
}
