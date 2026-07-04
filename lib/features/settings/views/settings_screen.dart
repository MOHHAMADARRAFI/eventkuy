// lib/features/settings/views/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.settings, style: AppTypography.titleLarge),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _SettingSection(
            title: 'Tampilan',
            isDark: isDark,
            children: [
              _ToggleTile(
                icon: Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                subtitle: 'Aktifkan tema gelap',
                value: vm.isDarkMode,
                onChanged: (_) => vm.toggleDarkMode(),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: 'Notifikasi',
            isDark: isDark,
            children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notification',
                subtitle: 'Terima notifikasi event terbaru',
                value: vm.isNotificationEnabled,
                onChanged: (_) => vm.toggleNotification(),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: 'Bahasa',
            isDark: isDark,
            children: [
              _SelectTile(
                icon: Icons.language_rounded,
                title: 'Bahasa Aplikasi',
                value: vm.language,
                options: const ['Indonesia', 'English'],
                onSelect: vm.setLanguage,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: 'Tentang',
            isDark: isDark,
            children: [
              _InfoTile(
                icon: Icons.info_outline_rounded,
                title: 'Versi Aplikasi',
                value: '1.0.0',
                isDark: isDark,
              ),
              _InfoTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan Privasi',
                value: 'Baca',
                isDark: isDark,
              ),
              _InfoTile(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                value: 'Baca',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const _SettingSection({
    required this.title,
    required this.children,
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
            children: children.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              final isLast = idx == children.length - 1;
              return Column(
                children: [
                  child,
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

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;
  final bool isDark;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                )),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final void Function(String) onSelect;
  final bool isDark;

  const _SelectTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            )),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
            ),
            items: options.map((o) => DropdownMenuItem(
              value: o,
              child: Text(o),
            )).toList(),
            onChanged: (v) => v != null ? onSelect(v) : null,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            )),
          ),
          Text(value, style: AppTypography.labelMedium.copyWith(
            color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }
}
