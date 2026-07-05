// lib/features/admin/views/settings/admin_settings_screen.dart

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

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Sistem', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            children: [
              _buildMenuSection(
                title: 'Content Management System (CMS)',
                isDark: isDark,
                items: [
                  _SettingsItem(
                    icon: Icons.view_carousel_rounded,
                    label: 'Kelola Banner Slider',
                    onTap: () => _simulateAction(context, 'Banner Slider Management dibuka.'),
                  ),
                  _SettingsItem(
                    icon: Icons.star_border_rounded,
                    label: 'Konfigurasi Event Pilihan (Featured)',
                    onTap: () => _simulateAction(context, 'Konfigurasi Event Pilihan dibuka.'),
                  ),
                  _SettingsItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Edit FAQ & Bantuan',
                    onTap: () => _simulateAction(context, 'FAQ Editor dibuka.'),
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    label: 'Ubah Syarat & Ketentuan',
                    onTap: () => _simulateAction(context, 'T&C Editor dibuka.'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildMenuSection(
                title: 'Sistem & Autentikasi',
                isDark: isDark,
                items: [
                  _SettingsItem(
                    icon: Icons.history_rounded,
                    label: 'Log Aktivitas (Audit Trail)',
                    onTap: () => context.push('/admin/activity-logs'),
                  ),
                  if (kDebugMode)
                    _SettingsItem(
                      icon: Icons.swap_horizontal_circle_outlined,
                      label: 'Ganti Role (Debug)',
                      onTap: () => _showRoleSwitcherDialog(context),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Logout
              AppSecondaryButton(
                label: 'Keluar Admin Panel',
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
      ),
    );
  }

  void _simulateAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildMenuSection({required String title, required bool isDark, required List<_SettingsItem> items}) {
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

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({required this.icon, required this.label, required this.onTap});
}
