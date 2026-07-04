// lib/features/profile/views/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _ProfileHeader(user: user, isDark: isDark),
            ),

            // Stats
            if (user != null)
              SliverToBoxAdapter(
                child: _StatsRow(user: user, isDark: isDark),
              ),

            // Menu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    _MenuSection(
                      title: 'Akun',
                      isDark: isDark,
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profil',
                          onTap: () => context.push('/profile/edit'),
                        ),
                        _MenuItem(
                          icon: Icons.event_note_rounded,
                          label: 'Event Saya',
                          onTap: () => context.go('/my-event'),
                        ),
                        _MenuItem(
                          icon: Icons.bookmark_border_rounded,
                          label: 'Tersimpan',
                          onTap: () => context.go('/saved'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _MenuSection(
                      title: 'Aplikasi',
                      isDark: isDark,
                      items: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notifikasi',
                          onTap: () => context.push('/notification'),
                        ),
                        _MenuItem(
                          icon: Icons.palette_outlined,
                          label: 'Pengaturan',
                          onTap: () => context.push('/settings'),
                        ),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Bantuan & FAQ',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          label: 'Tentang EventKuy',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Logout
                    AppSecondaryButton(
                      label: AppStrings.logout,
                      onTap: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: AppStrings.logout,
                          message: 'Apakah kamu yakin ingin keluar?',
                          confirmLabel: 'Keluar',
                          confirmColor: AppColors.error,
                          icon: Icons.logout_rounded,
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
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final bool isDark;

  const _ProfileHeader({this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withAlpha(30),
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user!.avatarUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: AppTypography.displaySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryLight,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Pengguna',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.interests.isNotEmpty == true)
                  Wrap(
                    spacing: 4,
                    children: user!.interests.take(3).map((i) =>
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull),
                        ),
                        child: Text(
                          i,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      )
                    ).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const _StatsRow({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _Stat(
            value: '${user.totalRegistrations}',
            label: 'Event',
            isDark: isDark,
          ),
          Container(
              width: 1, height: 40,
              color: isDark ? AppColors.darkBorder : AppColors.border),
          _Stat(
            value: '${user.totalBookmarks}',
            label: 'Tersimpan',
            isDark: isDark,
          ),
          Container(
              width: 1, height: 40,
              color: isDark ? AppColors.darkBorder : AppColors.border),
          _Stat(
            value: user.level,
            label: 'Level',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _Stat(
      {required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  final bool isDark;

  const _MenuSection({
    required this.title,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTypography.labelLarge.copyWith(
            color: AppColors.textTertiary,
          )),
        ),
        Container(
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
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == items.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: idx == 0 ? const Radius.circular(AppDimensions.radiusXl) : Radius.zero,
                      bottom: isLast ? const Radius.circular(AppDimensions.radiusXl) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon,
                                size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(item.label,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                )),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: isDark ? AppColors.darkBorder : AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
