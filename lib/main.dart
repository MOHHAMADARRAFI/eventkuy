// lib/main.dart
// Application entry point with MultiProvider

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/bookmark_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/user_repository.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/bookmark/viewmodels/bookmark_viewmodel.dart';
import 'features/explore/viewmodels/explore_viewmodel.dart';
import 'features/home/viewmodels/home_viewmodel.dart';
import 'features/my_event/viewmodels/my_event_viewmodel.dart';
import 'features/notification/viewmodels/notification_viewmodel.dart';
import 'features/settings/viewmodels/settings_viewmodel.dart';
import 'services/storage/local_storage.dart';
import 'services/notification/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await NotificationService.instance.initialize();

  runApp(const EventKuyApp());
}

class EventKuyApp extends StatelessWidget {
  const EventKuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Services ──────────────────────────────
        Provider<LocalStorage>(
          create: (_) => LocalStorage.instance,
        ),

        // ── Repositories ──────────────────────────
        Provider<EventRepository>(
          create: (_) => EventRepository(),
        ),
        Provider<BookmarkRepository>(
          create: (_) => BookmarkRepository(),
        ),
        Provider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
        Provider<UserRepository>(
          create: (_) => UserRepository(),
        ),

        // ── ViewModels ────────────────────────────
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<UserRepository>(),
            context.read<LocalStorage>(),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            context.read<EventRepository>(),
          ),
        ),
        ChangeNotifierProvider<ExploreViewModel>(
          create: (context) => ExploreViewModel(
            context.read<EventRepository>(),
            context.read<LocalStorage>(),
          ),
        ),
        ChangeNotifierProvider<BookmarkViewModel>(
          create: (context) => BookmarkViewModel(
            context.read<BookmarkRepository>(),
          ),
        ),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (context) => NotificationViewModel(
            context.read<NotificationRepository>(),
          ),
        ),
        ChangeNotifierProvider<MyEventViewModel>(
          create: (context) => MyEventViewModel(
            context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) => SettingsViewModel(
            context.read<LocalStorage>(),
          ),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();

    return MaterialApp.router(
      title: 'EventKuy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          settingsVm.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}

