// lib/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Models & Repositories
import 'package:eventkuy/data/models/registration_model.dart';
import 'package:eventkuy/data/repositories/bookmark_repository.dart';
import 'package:eventkuy/data/repositories/event_repository.dart';
import 'package:eventkuy/data/repositories/user_repository.dart';
import 'package:eventkuy/data/repositories/ticket_repository.dart';
import 'package:eventkuy/data/repositories/payment_repository.dart';
import 'package:eventkuy/data/repositories/audit_repository.dart';

// Core & Base Participant Screens
import 'package:eventkuy/features/auth/views/login_screen.dart';
import 'package:eventkuy/features/auth/views/register_screen.dart';
import 'package:eventkuy/features/bookmark/views/bookmark_screen.dart';
import 'package:eventkuy/features/event_detail/viewmodels/event_detail_viewmodel.dart';
import 'package:eventkuy/features/event_detail/views/event_detail_screen.dart';
import 'package:eventkuy/features/explore/views/explore_screen.dart';
import 'package:eventkuy/features/home/views/home_screen.dart';
import 'package:eventkuy/features/main_shell/views/main_shell.dart';
import 'package:eventkuy/features/my_event/views/my_event_screen.dart';
import 'package:eventkuy/features/my_event/views/ticket_detail_screen.dart';
import 'package:eventkuy/features/notification/views/notification_screen.dart';
import 'package:eventkuy/features/onboarding/views/onboarding_screen.dart';
import 'package:eventkuy/features/organizer/viewmodels/organizer_viewmodel.dart';
import 'package:eventkuy/features/organizer/views/organizer_screen.dart';
import 'package:eventkuy/features/profile/views/edit_profile_screen.dart';
import 'package:eventkuy/features/profile/views/profile_screen.dart';
import 'package:eventkuy/features/settings/views/settings_screen.dart';
import 'package:eventkuy/features/splash/views/opening_screen.dart';
import 'package:eventkuy/features/splash/views/splash_screen.dart';

// Organizer Feature Screens & ViewModels
import 'package:eventkuy/features/organizer/dashboard/organizer_dashboard_viewmodel.dart';
import 'package:eventkuy/features/organizer/dashboard/organizer_dashboard_screen.dart';
import 'package:eventkuy/features/organizer/events/organizer_events_viewmodel.dart';
import 'package:eventkuy/features/organizer/views/my_events/organizer_my_events_screen.dart';
import 'package:eventkuy/features/organizer/views/create_event/organizer_create_event_screen.dart';
import 'package:eventkuy/features/organizer/views/event_detail/organizer_event_detail_screen.dart';
import 'package:eventkuy/features/organizer/tickets/organizer_tickets_viewmodel.dart';
import 'package:eventkuy/features/organizer/views/tickets/organizer_tickets_screen.dart';
import 'package:eventkuy/features/organizer/views/participants/organizer_participants_screen.dart';
import 'package:eventkuy/features/organizer/views/scanner/organizer_scanner_screen.dart';
import 'package:eventkuy/features/organizer/views/analytics/organizer_analytics_screen.dart';
import 'package:eventkuy/features/organizer/views/profile/organizer_profile_screen.dart';
import 'package:eventkuy/features/organizer/profile/apply_organizer_screen.dart';
import 'package:eventkuy/features/organizer/profile/organizer_verification_status_screen.dart';
import 'package:eventkuy/features/organizer/views/organizer_shell.dart';

// Admin Feature Screens & ViewModels
import 'package:eventkuy/features/admin/settings/admin_viewmodel.dart';
import 'package:eventkuy/features/admin/views/admin_shell.dart';
import 'package:eventkuy/features/admin/views/dashboard/admin_dashboard_screen.dart';
import 'package:eventkuy/features/admin/views/users/admin_users_screen.dart';
import 'package:eventkuy/features/admin/views/organizers/admin_organizers_screen.dart';
import 'package:eventkuy/features/admin/views/events/admin_events_screen.dart';
import 'package:eventkuy/features/admin/views/categories/admin_categories_screen.dart';
import 'package:eventkuy/features/admin/views/reports/admin_complaints_screen.dart';
import 'package:eventkuy/features/admin/views/notifications/admin_notifications_screen.dart';
import 'package:eventkuy/features/admin/views/settings/admin_settings_screen.dart';
import 'package:eventkuy/features/admin/views/settings/admin_activity_log_screen.dart';

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

        // ── Organizer (participant view of another organizer) ─────
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

        // ── Apply Organizer Flow ──────────────────
        GoRoute(
          path: '/profile/apply-organizer',
          builder: (context, state) => const ApplyOrganizerScreen(),
        ),
        GoRoute(
          path: '/organizer/verification-status',
          builder: (context, state) => const OrganizerVerificationStatusScreen(),
        ),

        // ── Organizer Fullscreen Pages ────────────
        GoRoute(
          path: '/organizer/event/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (context) => OrganizerEventsViewModel(context.read<EventRepository>()),
              child: OrganizerEventDetailScreen(eventId: id),
            );
          },
        ),
        GoRoute(
          path: '/organizer/edit-event/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            // For mock demo, we pass it into standard create screen acting as edit screen
            return const OrganizerCreateEventScreen();
          },
        ),
        GoRoute(
          path: '/organizer/tickets',
          builder: (context, state) {
            final eventId = state.uri.queryParameters['eventId'] ?? '';
            return ChangeNotifierProvider(
              create: (context) => OrganizerTicketsViewModel(context.read<ITicketRepository>()),
              child: OrganizerTicketsScreen(eventId: eventId),
            );
          },
        ),
        GoRoute(
          path: '/organizer/scanner',
          builder: (context, state) => const OrganizerScannerScreen(),
        ),
        GoRoute(
          path: '/organizer/analytics',
          builder: (context, state) => const OrganizerAnalyticsScreen(),
        ),

        // ── Admin Fullscreen Pages ────────────────
        GoRoute(
          path: '/admin/activity-logs',
          builder: (context, state) => ChangeNotifierProvider(
            create: (context) => AdminViewModel(
              context.read<EventRepository>(),
              context.read<UserRepository>(),
              context.read<IAuditRepository>(),
            ),
            child: const AdminActivityLogScreen(),
          ),
        ),

        // ── Participant Shell Bottom Navigation ───
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

        // ── Organizer Shell Bottom Navigation ─────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ChangeNotifierProvider(
              create: (context) => OrganizerEventsViewModel(
                context.read<EventRepository>(),
              ),
              child: OrganizerShell(navigationShell: navigationShell),
            );
          },
          branches: [
            // Branch 0: Dashboard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/dashboard',
                  builder: (context, state) => ChangeNotifierProvider(
                    create: (context) => OrganizerDashboardViewModel(
                      context.read<EventRepository>(),
                      context.read<IPaymentRepository>(),
                    ),
                    child: const OrganizerDashboardScreen(),
                  ),
                ),
              ],
            ),
            // Branch 1: My Events
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/my-events',
                  builder: (context, state) => const OrganizerMyEventsScreen(),
                ),
              ],
            ),
            // Branch 2: Create Event
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/create-event',
                  builder: (context, state) => const OrganizerCreateEventScreen(),
                ),
              ],
            ),
            // Branch 3: Participants
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/participants',
                  builder: (context, state) => const OrganizerParticipantsScreen(),
                ),
              ],
            ),
            // Branch 4: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/profile',
                  builder: (context, state) => const OrganizerProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Admin Shell Sidebar/NavigationRail ────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ChangeNotifierProvider(
              create: (context) => AdminViewModel(
                context.read<EventRepository>(),
                context.read<UserRepository>(),
                context.read<IAuditRepository>(),
              ),
              child: AdminShell(navigationShell: navigationShell),
            );
          },
          branches: [
            // Branch 0: Dashboard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/dashboard',
                  builder: (context, state) => const AdminDashboardScreen(),
                ),
              ],
            ),
            // Branch 1: Users
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/users',
                  builder: (context, state) => const AdminUsersScreen(),
                ),
              ],
            ),
            // Branch 2: Organizers
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/organizers',
                  builder: (context, state) => const AdminOrganizersScreen(),
                ),
              ],
            ),
            // Branch 3: Events
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/events',
                  builder: (context, state) => const AdminEventsScreen(),
                ),
              ],
            ),
            // Branch 4: Categories
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/categories',
                  builder: (context, state) => const AdminCategoriesScreen(),
                ),
              ],
            ),
            // Branch 5: Complaints
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/complaints',
                  builder: (context, state) => const AdminComplaintsScreen(),
                ),
              ],
            ),
            // Branch 6: Notifications
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/notifications',
                  builder: (context, state) => const AdminNotificationsScreen(),
                ),
              ],
            ),
            // Branch 7: Settings
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/settings',
                  builder: (context, state) => const AdminSettingsScreen(),
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
