// lib/features/organizer/views/organizer_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventkuy/core/constants/app_colors.dart';

class OrganizerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OrganizerShell({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note_rounded),
              label: 'Event Saya',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box_rounded),
              label: 'Buat',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Peserta',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_center_outlined),
              selectedIcon: Icon(Icons.business_center_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
