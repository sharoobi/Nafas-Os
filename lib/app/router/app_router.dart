import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas_os/core/bootstrap/app_entry_screen.dart';
import 'package:nafas_os/features/programs/presentation/programs_screen.dart';
import 'package:nafas_os/features/settings/presentation/profile_flow_screen.dart';
import 'package:nafas_os/features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AppEntryScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: 'programs',
          builder: (BuildContext context, GoRouterState state) {
            return const ProgramsScreen();
          },
        ),
        GoRoute(
          path: 'profile-setup',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileFlowScreen();
          },
        ),
      ],
    ),
  ],
);
