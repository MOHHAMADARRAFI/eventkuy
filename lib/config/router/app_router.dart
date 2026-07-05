// lib/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/registration_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/bookmark/views/bookmark_screen.dart';
import '../../features/event_detail/viewmodels/event_detail_viewmodel.dart';
import '../../features/event_detail/views/event_detail_screen.dart';
import '../../features/explore/views/explore_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/main_shell/views/main_shell.dart';
import '../../features/my_event/views/my_event_screen.dart';
import '../../features/my_event/views/ticket_detail_screen.dart';
import '../../features/notification/views/notification_screen.dart';
import '../../features/onboarding/views/onboarding_screen.dart';
import '../../features/organizer/viewmodels/organizer_viewmodel.dart';
import '../../features/organizer/views/organizer_screen.dart';
import '../../features/profile/views/edit_profile_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/splash/views/opening_screen.dart';
import '../../features/splash/views/splash_screen.dart';

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: false,
      routes: [
        // ── Standalone routes ──────────────────────
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/opening',
          builder: (context, state) => const OpeningScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // ── Event Detail ───────────────────────────
        GoRoute(
          path: '/event/:id',
          builder: (context, state) {
            final eventId = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => EventDetailViewModel(
                context.read<EventRepository>(),
                context.read<BookmarkRepository>(),
                context.read<UserRepository>(),
              ),
              child: EventDetailScreen(eventId: eventId),
            );
          },
        ),

        // ── Ticket Detail ─────────────────────────
        GoRoute(
          path: '/ticket',
          builder: (context, state) {
            final registration = state.extra as RegistrationModel;
            return TicketDetailScreen(registration: registration);
          },
        ),

        // ── Organizer ─────────────────────────────
        GoRoute(
          path: '/organizer/:id',
          builder: (context, state) {
            final organizerId = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => OrganizerViewModel(
                context.read<EventRepository>(),
              ),
              child: OrganizerScreen(organizerId: organizerId),
            );
          },
        ),

        // ── Notification (stack-push) ──────────────
        GoRoute(
          path: '/notification',
          builder: (context, state) => const NotificationScreen(),
        ),

        // ── Settings ──────────────────────────────
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // ── Edit Profile ──────────────────────────
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),

        // ── Shell with Bottom Navigation ───────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            // Branch 0: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            // Branch 1: Explore
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/explore',
                  builder: (context, state) => const ExploreScreen(),
                ),
              ],
            ),
            // Branch 2: Saved
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/saved',
                  builder: (context, state) => const BookmarkScreen(),
                ),
              ],
            ),
            // Branch 3: My Event
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/my-event',
                  builder: (context, state) => const MyEventScreen(),
                ),
              ],
            ),
            // Branch 4: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Halaman tidak ditemukan',
                  style: Theme.of(context).textTheme.headlineMedium),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
