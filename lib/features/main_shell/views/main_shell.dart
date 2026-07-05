// lib/features/main_shell/views/main_shell.dart
// Bottom navigation shell with Material 3 NavigationBar

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventkuy/core/constants/app_colors.dart';
import 'package:eventkuy/core/constants/app_strings.dart';
import 'package:eventkuy/features/notification/viewmodels/notification_viewmodel.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount =
        context.watch<NotificationViewModel>().unreadCount;

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
          destinations: [
            // 0: Home
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            // 1: Explore
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: AppStrings.navExplore,
            ),
            // 2: Saved
            const NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: AppStrings.navSaved,
            ),
            // 3: My Event (with notification badge)
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.event_note_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.event_note_rounded),
              ),
              label: 'Event Saya',
            ),
            // 4: Profile
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
