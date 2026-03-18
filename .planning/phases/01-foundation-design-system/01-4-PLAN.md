---
phase: 1
plan: 4
name: app-shell-navigation-animations-pwa
wave: 3
depends_on: [1, 3]
requirements: [DSGN-03, DSGN-05, DSGN-06]
files_modified:
  - lib/presentation/common/app_bottom_nav.dart
  - lib/presentation/common/app_shell.dart
  - lib/core/router/routes.dart
  - lib/core/router/app_router.dart
  - lib/core/theme/page_transitions.dart
  - lib/presentation/home/home_screen.dart
  - lib/presentation/common/animated_book_list.dart
  - lib/app.dart
  - web/sw.js
  - workbox-config.js
autonomous: true
---

# Plan 01-4: App Shell, Navigation, Animations, and PWA Service Worker

## Objective
Build the app shell with 5-tab bottom navigation (Phosphor Icons), configure GoRouter with SharedAxisTransition page transitions, implement FadeIn+SlideUp card stagger animations, create placeholder screens for all tabs, and set up the custom Workbox service worker for PWA caching.

## Tasks

<task id="1">
<title>Create route constants and placeholder screens</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §6 (GoRouter route structure)
- /root/my-app/.planning/research/ARCHITECTURE.md §Recommended Project Structure (route paths)
</read_first>
<action>
Create `lib/core/router/routes.dart`:

```dart
abstract class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const shelves = '/shelves';
  static const downloads = '/downloads';
  static const profile = '/profile';
  static const bookDetail = '/book/:bookId';
  static const reader = '/book/:bookId/read';
  static const audioPlayer = '/book/:bookId/listen';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const resetPassword = '/auth/reset-password';
  static const subscription = '/subscription';
  static const admin = '/admin';
  static const adminBookEditor = '/admin/book/:bookId';
}
```

Create placeholder screens for each main tab. Each is a simple `Scaffold` with a `Center(child: Text('ScreenName'))`:
- `lib/presentation/home/home_screen.dart` — `HomeScreen` showing "Главная"
- `lib/presentation/catalog/catalog_screen.dart` — `CatalogScreen` showing "Поиск"
- `lib/presentation/shelves/shelves_screen.dart` — `ShelvesScreen` showing "Полки"
- `lib/presentation/downloads/downloads_screen.dart` — `DownloadsScreen` showing "Загрузки"
- `lib/presentation/profile/profile_screen.dart` — `ProfileScreen` showing "Профиль"

Each placeholder screen must be a `StatelessWidget` or `ConsumerWidget`.
</action>
<acceptance_criteria>
- lib/core/router/routes.dart contains `abstract class AppRoutes`
- lib/core/router/routes.dart contains `static const home = '/'`
- lib/core/router/routes.dart contains `static const search = '/search'`
- lib/core/router/routes.dart contains `static const admin = '/admin'`
- lib/presentation/home/home_screen.dart contains `class HomeScreen`
- lib/presentation/catalog/catalog_screen.dart contains `class CatalogScreen`
- lib/presentation/shelves/shelves_screen.dart contains `class ShelvesScreen`
- lib/presentation/downloads/downloads_screen.dart contains `class DownloadsScreen`
- lib/presentation/profile/profile_screen.dart contains `class ProfileScreen`
</acceptance_criteria>
</task>

<task id="2">
<title>Create AppBottomNav with 5 tabs using Phosphor Icons</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §3 (AppBottomNav with Phosphor Icons)
- /root/my-app/.planning/PROJECT.md §Компоненты (nav bar: 5 tabs, line icons, no shadow, top divider)
- /root/my-app/lib/core/theme/app_colors.dart (border colors)
</read_first>
<action>
Create `lib/presentation/common/app_bottom_nav.dart`:

5 tabs with Phosphor Icons:
1. Главная — `PhosphorIconsThin.house` / `PhosphorIconsFill.house`
2. Поиск — `PhosphorIconsThin.magnifyingGlass` / `PhosphorIconsFill.magnifyingGlass`
3. Полки — `PhosphorIconsThin.bookmarkSimple` / `PhosphorIconsFill.bookmarkSimple`
4. Загрузки — `PhosphorIconsThin.downloadSimple` / `PhosphorIconsFill.downloadSimple`
5. Профиль — `PhosphorIconsThin.userCircle` / `PhosphorIconsFill.userCircle`

Widget structure:
- Outer `Container` with top `BorderSide` (1px, cardBorder color) — no shadow
- Inner `NavigationBar` (Material 3) with `elevation: 0`, `backgroundColor: Colors.transparent`, `indicatorColor: Colors.transparent`
- Inactive icons use `PhosphorIconsThin.*` (thin 1.5px stroke)
- Active icons use `PhosphorIconsFill.*` with `Theme.of(context).colorScheme.primary` color
- Russian labels: 'Главная', 'Поиск', 'Полки', 'Загрузки', 'Профиль'
- Include `Semantics` tooltip for each destination

Parameters: `int currentIndex`, `ValueChanged<int> onTap`
</action>
<acceptance_criteria>
- lib/presentation/common/app_bottom_nav.dart contains `class AppBottomNav`
- File contains `PhosphorIconsThin.house`
- File contains `PhosphorIconsFill.house`
- File contains `PhosphorIconsThin.magnifyingGlass`
- File contains `PhosphorIconsThin.bookmarkSimple`
- File contains `PhosphorIconsThin.downloadSimple`
- File contains `PhosphorIconsThin.userCircle`
- File contains `'Главная'`
- File contains `'Поиск'`
- File contains `'Полки'`
- File contains `'Загрузки'`
- File contains `'Профиль'`
- File contains `elevation: 0`
- File contains `indicatorColor: Colors.transparent`
- File contains `BorderSide(` (top divider line)
</acceptance_criteria>
</task>

<task id="3">
<title>Create page transition helpers with SharedAxisTransition</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §3 (Animations DSGN-05)
</read_first>
<action>
Create `lib/core/theme/page_transitions.dart`:

```dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<void> sharedAxisTransitionPage({
  required Widget child,
  required GoRouterState state,
  SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> fadeTransitionPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
```
</action>
<acceptance_criteria>
- lib/core/theme/page_transitions.dart contains `sharedAxisTransitionPage(`
- File contains `SharedAxisTransition(`
- File contains `SharedAxisTransitionType.horizontal`
- File contains `CustomTransitionPage<void>`
- File contains `fadeTransitionPage(`
- File contains `import 'package:animations/animations.dart'`
- File contains `import 'package:go_router/go_router.dart'`
</acceptance_criteria>
</task>

<task id="4">
<title>Create animated book list helper for FadeIn + SlideUp stagger</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §3 (FadeIn + SlideUp stagger)
</read_first>
<action>
Create `lib/presentation/common/animated_book_list.dart`:

A helper widget or extension that applies FadeIn + SlideUp stagger animation to list items using `flutter_animate`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 300),
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
  }
}
```

This produces a stagger effect: each card appears 50ms after the previous one, with a combined fade + slide-up animation over 300ms with easeOutCubic curve.
</action>
<acceptance_criteria>
- lib/presentation/common/animated_book_list.dart contains `class AnimatedListItem`
- File contains `.animate()`
- File contains `.fadeIn(`
- File contains `.slideY(`
- File contains `50 * index` (stagger delay)
- File contains `Duration(milliseconds: 300)` (animation duration)
- File contains `Curves.easeOutCubic`
- File contains `import 'package:flutter_animate/flutter_animate.dart'`
</acceptance_criteria>
</task>

<task id="5">
<title>Create AppShell with bottom nav and GoRouter integration</title>
<read_first>
- /root/my-app/lib/presentation/common/app_bottom_nav.dart (bottom nav widget)
- /root/my-app/lib/core/router/routes.dart (route constants)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §6 (GoRouter StatefulShellRoute)
- /root/my-app/.planning/research/ARCHITECTURE.md §GoRouter Guard Pattern
</read_first>
<action>
Create `lib/presentation/common/app_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
```

Create `lib/core/router/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/common/app_shell.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/catalog/catalog_screen.dart';
import '../../presentation/shelves/shelves_screen.dart';
import '../../presentation/downloads/downloads_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../theme/page_transitions.dart';
import 'routes.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _shellNavigatorShelvesKey = GlobalKey<NavigatorState>(debugLabel: 'shelves');
final _shellNavigatorDownloadsKey = GlobalKey<NavigatorState>(debugLabel: 'downloads');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
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
```

Note: Auth guard redirect will be added in Phase 2. For Phase 1, all routes are accessible.
</action>
<acceptance_criteria>
- lib/presentation/common/app_shell.dart contains `class AppShell`
- lib/presentation/common/app_shell.dart contains `StatefulNavigationShell`
- lib/presentation/common/app_shell.dart contains `AppBottomNav(`
- lib/presentation/common/app_shell.dart contains `navigationShell.goBranch(`
- lib/core/router/app_router.dart contains `@riverpod`
- lib/core/router/app_router.dart contains `GoRouter appRouter(`
- lib/core/router/app_router.dart contains `StatefulShellRoute.indexedStack(`
- lib/core/router/app_router.dart contains `StatefulShellBranch(` (5 occurrences)
- lib/core/router/app_router.dart contains `NoTransitionPage(`
- lib/core/router/app_router.dart contains `HomeScreen()`
- lib/core/router/app_router.dart contains `CatalogScreen()`
- lib/core/router/app_router.dart contains `ShelvesScreen()`
- lib/core/router/app_router.dart contains `DownloadsScreen()`
- lib/core/router/app_router.dart contains `ProfileScreen()`
</acceptance_criteria>
</task>

<task id="6">
<title>Update app.dart to use GoRouter</title>
<read_first>
- /root/my-app/lib/app.dart (current state with theme)
- /root/my-app/lib/core/router/app_router.dart (router provider)
</read_first>
<action>
Update `lib/app.dart` to use `MaterialApp.router` with the GoRouter provider:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class BookSummaryApp extends ConsumerWidget {
  const BookSummaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BookSummary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

Replace the `MaterialApp` with `MaterialApp.router` and connect `routerConfig` to the Riverpod-provided GoRouter.
</action>
<acceptance_criteria>
- lib/app.dart contains `MaterialApp.router(`
- lib/app.dart contains `routerConfig: router`
- lib/app.dart contains `ref.watch(appRouterProvider)`
- lib/app.dart contains `import 'core/router/app_router.dart'`
- lib/app.dart does NOT contain `home:` parameter (replaced by router)
</acceptance_criteria>
</task>

<task id="7">
<title>Create custom Workbox service worker</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-CONTEXT.md §Service Worker (custom Workbox decision)
- /root/my-app/.planning/research/PITFALLS.md §P6 (PWA zombie app prevention)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §1 (build commands with --pwa-strategy none)
</read_first>
<action>
Create `web/sw.js` — a custom Workbox-based service worker:

```javascript
// BookSummary Service Worker (Workbox)
// This replaces Flutter's default flutter_service_worker.js

importScripts('https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js');

const { precacheAndRoute } = workbox.precaching;
const { registerRoute } = workbox.routing;
const { CacheFirst, StaleWhileRevalidate, NetworkFirst } = workbox.strategies;
const { ExpirationPlugin } = workbox.expiration;
const { CacheableResponsePlugin } = workbox.cacheableResponse;

// Precache app shell (injected by workbox-cli at build time)
precacheAndRoute(self.__WB_MANIFEST || []);

// Cache Google Fonts stylesheets
registerRoute(
  ({ url }) => url.origin === 'https://fonts.googleapis.com',
  new StaleWhileRevalidate({
    cacheName: 'google-fonts-stylesheets',
  })
);

// Cache Google Fonts webfont files
registerRoute(
  ({ url }) => url.origin === 'https://fonts.gstatic.com',
  new CacheFirst({
    cacheName: 'google-fonts-webfonts',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
      new ExpirationPlugin({
        maxAgeSeconds: 60 * 60 * 24 * 365, // 1 year
        maxEntries: 30,
      }),
    ],
  })
);

// Cache CanvasKit WASM files
registerRoute(
  ({ url }) => url.pathname.includes('canvaskit'),
  new CacheFirst({
    cacheName: 'canvaskit-cache',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
      new ExpirationPlugin({
        maxAgeSeconds: 60 * 60 * 24 * 30, // 30 days
      }),
    ],
  })
);

// SPA fallback: serve index.html for navigation requests
registerRoute(
  ({ request }) => request.mode === 'navigate',
  new NetworkFirst({
    cacheName: 'pages-cache',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
    ],
  })
);

// Handle updates: notify clients when new version available
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
```

Register the service worker in `web/index.html` by adding before the closing `</body>` tag (but after the Flutter loader script):

Add this registration snippet to index.html:
```html
<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('sw.js');
    });
  }
</script>
```

Create `workbox-config.js` in the project root for build-time manifest injection:

```javascript
module.exports = {
  globDirectory: 'build/web/',
  globPatterns: [
    '**/*.{js,css,html,png,svg,ico,woff2}',
  ],
  globIgnores: [
    'flutter_service_worker.js',
  ],
  swSrc: 'web/sw.js',
  swDest: 'build/web/sw.js',
};
```
</action>
<acceptance_criteria>
- web/sw.js contains `importScripts(` with workbox-sw.js URL
- web/sw.js contains `precacheAndRoute(`
- web/sw.js contains `CacheFirst`
- web/sw.js contains `StaleWhileRevalidate`
- web/sw.js contains `NetworkFirst`
- web/sw.js contains `canvaskit` (CanvasKit caching)
- web/sw.js contains `SKIP_WAITING` (update handling)
- web/index.html contains `serviceWorker.register('sw.js')`
- workbox-config.js contains `globDirectory: 'build/web/'`
- workbox-config.js contains `swSrc: 'web/sw.js'`
</acceptance_criteria>
</task>

<task id="8">
<title>Run code generation for Riverpod providers</title>
<read_first>
- /root/my-app/lib/core/router/app_router.dart (contains @riverpod annotation)
- /root/my-app/pubspec.yaml (build_runner and riverpod_generator dependencies)
</read_first>
<action>
Run `dart run build_runner build --delete-conflicting-outputs` from the project root to generate:
- `lib/core/router/app_router.g.dart` (appRouterProvider from @riverpod annotation)

Verify the generated file exists and contains the `appRouterProvider`.

If build_runner fails due to missing imports or type errors, fix them before re-running.
</action>
<acceptance_criteria>
- `dart run build_runner build --delete-conflicting-outputs` exits with code 0
- lib/core/router/app_router.g.dart exists
- lib/core/router/app_router.g.dart contains `appRouterProvider`
</acceptance_criteria>
</task>

## Verification
1. `flutter build web --web-renderer canvaskit --pwa-strategy none` completes successfully
2. Bottom navigation renders 5 tabs with correct Russian labels and Phosphor icons
3. Tapping each tab switches content via GoRouter StatefulShellRoute
4. Service worker file exists at web/sw.js with Workbox strategies
5. `flutter analyze` passes without errors

## Must-Haves
- 5-tab bottom navigation: Главная, Поиск, Полки, Загрузки, Профиль
- Phosphor Icons: thin style for inactive, fill for active, primary color on active
- Top border line on navigation bar (no shadow/elevation)
- GoRouter with StatefulShellRoute.indexedStack for tab persistence
- SharedAxisTransition helper ready for screen-to-screen transitions
- FadeIn + SlideUp stagger animation helper (50ms delay per item, 300ms duration, easeOutCubic)
- Custom Workbox service worker with CacheFirst for fonts/CanvasKit, NetworkFirst for pages
- Service worker registered in index.html
- All generated files (*.g.dart) present and build_runner succeeds
