// lib/features/admin/views/admin_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventkuy/core/constants/app_colors.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 640; // Responsive threshold for sidebar/NavigationRail

    final destinations = [
      {'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'selected': Icons.dashboard_rounded},
      {'label': 'User', 'icon': Icons.people_outline_rounded, 'selected': Icons.people_rounded},
      {'label': 'Organizer', 'icon': Icons.business_center_outlined, 'selected': Icons.business_center_rounded},
      {'label': 'Event', 'icon': Icons.event_note_outlined, 'selected': Icons.event_note_rounded},
      {'label': 'Kategori', 'icon': Icons.category_outlined, 'selected': Icons.category_rounded},
      {'label': 'Laporan', 'icon': Icons.report_problem_outlined, 'selected': Icons.report_problem_rounded},
      {'label': 'Notifikasi', 'icon': Icons.campaign_outlined, 'selected': Icons.campaign_rounded},
      {'label': 'Settings', 'icon': Icons.settings_outlined, 'selected': Icons.settings_rounded},
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Responsive Sidebar / NavigationRail
            Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
              ),
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) => _onTap(context, index),
                labelType: NavigationRailLabelType.all,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                indicatorColor: AppColors.primaryContainer,
                selectedIconTheme: const IconThemeData(color: AppColors.primary),
                unselectedIconTheme: IconThemeData(color: isDark ? Colors.white60 : Colors.black54),
                selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                unselectedLabelTextStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 11),
                destinations: destinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(d['icon'] as IconData),
                          selectedIcon: Icon(d['selected'] as IconData),
                          label: Text(d['label'] as String),
                        ))
                    .toList(),
              ),
            ),
            // Content area
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // Mobile fallback (Bottom Navigation Bar)
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          destinations: destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d['icon'] as IconData),
                    selectedIcon: Icon(d['selected'] as IconData),
                    label: d['label'] as String,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
