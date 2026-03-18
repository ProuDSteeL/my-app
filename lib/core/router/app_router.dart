import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/reset_password_screen.dart';
import '../../presentation/catalog/catalog_screen.dart';
import '../../presentation/common/app_shell.dart';
import '../../presentation/downloads/downloads_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/shelves/shelves_screen.dart';
import '../../providers/auth_provider.dart';
import '../theme/page_transitions.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorShelvesKey =
    GlobalKey<NavigatorState>(debugLabel: 'shelves');
final _shellNavigatorDownloadsKey =
    GlobalKey<NavigatorState>(debugLabel: 'downloads');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

@riverpod
GoRouter appRouter(Ref ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isOnAuthPage = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isOnAuthPage) {
        return '/auth/login';
      }

      if (isAuthenticated && isOnAuthPage) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes (outside shell — no bottom nav)
      GoRoute(
        path: '/auth/login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => fadeTransitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/register',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => sharedAxisTransitionPage(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/reset-password',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => sharedAxisTransitionPage(
          state: state,
          child: const ResetPasswordScreen(),
        ),
      ),

      // Main app shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CatalogScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorShelvesKey,
            routes: [
              GoRoute(
                path: '/shelves',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ShelvesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDownloadsKey,
            routes: [
              GoRoute(
                path: '/downloads',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DownloadsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
