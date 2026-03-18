# Stack Research

**Domain:** Flutter Web/PWA — Book Summary Reading App (offline-first, audio, Markdown, payments)
**Researched:** 2026-03-18
**Confidence:** HIGH (core stack validated against pub.dev, Flutter docs, and community consensus)

## Recommended Stack

### Platform

| Parameter | Value | Notes |
|-----------|-------|-------|
| Flutter SDK | `>=3.41.0` | Latest stable (Feb 2026), Dart 3.11. Do NOT use Wasm compilation for v1 — Safari/Firefox bugs block compatibility; use JS renderer (CanvasKit) for max browser reach. Revisit Wasm for v2. |
| Dart SDK | `>=3.11.0` | Bundled with Flutter 3.41 |
| Min browser support | Chrome 119+, Firefox 120+, Safari 17+ | CanvasKit renderer works everywhere; Wasm currently Chromium-only |

### Core Technologies

| Technology | Version | Purpose | Why Recommended | Confidence |
|------------|---------|---------|-----------------|------------|
| Flutter (Web/PWA) | 3.41.x | UI framework | Single codebase for web now, mobile later. v3.41 = "Production Era" for web. CanvasKit renderer gives native-quality UI. | HIGH |
| flutter_riverpod | ^3.3.0 | State management | Compile-safe, code-gen based with `@riverpod`, excellent for offline-first (async providers for cache-then-network). Riverpod 3.0 stable. | HIGH |
| riverpod_annotation | ^4.0.2 | Riverpod code generation | Declarative `@riverpod` / `@Riverpod(keepAlive: true)` syntax. Required for modern Riverpod. | HIGH |
| riverpod_generator | ^3.0.3 | Code gen for Riverpod | Generates provider boilerplate from annotations. | HIGH |
| go_router | ^16.2.0 | Routing / deep linking | Official Flutter team package, URL-based routing critical for web (bookmarks, back button, SEO-friendly paths). Feature-complete, bug-fix mode. | HIGH |
| supabase_flutter | ^2.10.2 | Backend (Auth, DB, Storage, Edge Functions) | All-in-one BaaS: Auth (email+Google OAuth), PostgreSQL with RLS, file Storage for covers/audio, Edge Functions for YooMoney webhooks. Eliminates custom backend. | HIGH |
| hive_ce_flutter | ^2.3.4 | Offline local storage | Community Edition — actively maintained fork of abandoned Hive. Pure Dart, works on web (IndexedDB), no native deps. Key-value + typed boxes for offline cache. Use INSTEAD of original `hive_flutter` (abandoned). | HIGH |
| hive_ce | ^2.7.0 | Core Hive CE | Required alongside hive_ce_flutter. | HIGH |
| just_audio | ^0.9.43 | Audio playback | Feature-rich: speed control (0.5x-2.0x), seeking, streaming from URLs. Web uses HTML5 Audio via just_audio_web. Background playback works on web. | HIGH |
| flutter_markdown_plus | ^1.0.6 | Markdown rendering | Actively maintained successor to Google's discontinued `flutter_markdown`. GFM support, customizable styling, table rendering, extensible widgets. | HIGH |
| connectivity_plus | ^6.1.4 | Network status detection | Flutter Community Plus package, detects online/offline. Web support via Navigator.onLine API. Essential for offline-first sync logic. | HIGH |

### Supporting Libraries

| Library | Version | Purpose | When to Use | Confidence |
|---------|---------|---------|-------------|------------|
| cached_network_image | ^3.4.1 | Image loading with placeholders | Book covers in catalog/cards. NOTE: no actual caching on web (uses NonStoringObjectProvider). Pair with Service Worker cache for web. | MEDIUM |
| google_fonts | ^8.0.1 | Typography (Playfair Display, Source Sans 3, Source Serif 4) | App-wide typography. Bundles fonts at build time for offline. Use `GoogleFonts.config.allowRuntimeFetching = false` in production for PWA. | HIGH |
| file_picker | ^8.3.7 | File upload in admin panel | Admin uploads covers, audio, Markdown files. Full web support via HTML file input. | HIGH |
| shimmer | ^3.0.0 | Skeleton loading placeholders | Loading states for book cards, reader, catalog. Warm sand color per design spec. | HIGH |
| phosphor_flutter | ^2.1.0 | Icon set (Phosphor Icons) | Thin line icons (1.5px) per design spec. Consistent icon set across app. | HIGH |
| url_launcher | ^6.3.1 | Open external URLs | Terms of service, privacy policy links, YooMoney redirect. | HIGH |
| shared_preferences | ^2.3.4 | Simple key-value persistence | User settings (theme, font size, reading preferences). Lighter than Hive for small config. | HIGH |
| flutter_animate | ^4.5.2 | Declarative animations | SharedAxisTransition, FadeIn+SlideUp per design spec. Cleaner than manual AnimationControllers. | MEDIUM |
| uuid | ^4.5.1 | UUID generation | Offline-created entities need IDs before sync. | HIGH |
| intl | ^0.20.2 | Date/number formatting, i18n prep | Russian locale formatting, future i18n support. | HIGH |
| yookassa_client | ^0.2.0 | YooKassa (YooMoney) API client | Server-side payment creation via Supabase Edge Functions. Dart package for API calls. | MEDIUM |
| json_annotation | ^4.9.0 | JSON serialization annotations | Data models for API/storage. | HIGH |
| json_serializable | ^6.9.4 | JSON code generation | Build runner generates toJson/fromJson. | HIGH |
| build_runner | ^2.4.14 | Code generation runner | Runs riverpod_generator + json_serializable + hive_ce_generator. | HIGH |
| hive_ce_generator | ^1.6.0 | Hive type adapter generation | Generates TypeAdapters for Hive boxes. | HIGH |
| freezed_annotation | ^3.0.0 | Immutable data class annotations | Immutable models with copyWith, == , toString. | HIGH |
| freezed | ^3.0.6 | Freezed code generation | Generates immutable data classes. | HIGH |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| flutter_lints / very_good_analysis | Linting | Strict lint rules for consistent code quality |
| Dart DevTools | Debugging, profiling | Built into Flutter, web inspector for performance |
| Supabase CLI | Local development | `supabase start` for local Supabase, Edge Function testing |
| Workbox (JS) | Service Worker management | Custom service worker for production PWA caching. Replace default `flutter_service_worker.js` |
| Lighthouse | PWA audit | Chrome DevTools, verify PWA score, offline, performance |
| melos (optional) | Monorepo management | Only if splitting into packages (app, core, data, domain) |

## Architecture Notes

### Offline-First Strategy (Web/PWA)

1. **Service Worker (Workbox)**: Replace Flutter's default `flutter_service_worker.js` with a custom Workbox-based service worker for granular control:
   - `CacheFirst` for static assets (fonts, app shell, icons)
   - `StaleWhileRevalidate` for book cover images
   - `NetworkFirst` for API responses (catalog, user data)
2. **Hive CE for local data**: Store downloaded summaries (Markdown text), reading progress, user preferences, citation highlights in typed Hive boxes. IndexedDB backend on web.
3. **Supabase + connectivity_plus for sync**: Queue mutations offline (new highlights, progress updates), sync on reconnect. Riverpod async providers handle cache-then-network pattern.
4. **Audio caching**: For Pro users, `just_audio` streams from Supabase Storage URLs. Offline audio requires Service Worker pre-caching of audio files (Cache API). Consider a download manager that caches audio blobs via Service Worker message passing.

### YooMoney Payment Flow (Web)

Since `yookassa_payments_flutter` is mobile-only, the web flow is:
1. Flutter app calls Supabase Edge Function to create a payment via YooKassa API
2. Edge Function returns `confirmation_url` (redirect) or `confirmation_token` (widget)
3. **Option A (Recommended for v1)**: Redirect user to YooKassa payment page, handle `return_url` callback
4. **Option B (v2)**: Embed YooKassa Checkout Widget via `HtmlElementView` in Flutter web
5. Edge Function receives webhook on payment success, updates subscription in Supabase DB

### Rendering on Web

- Use **CanvasKit** renderer (default in stable): pixel-perfect rendering, consistent with mobile
- Do NOT use HTML renderer: inconsistent text rendering, limited styling
- Do NOT use Wasm for v1: Safari/Firefox bugs, not all users on Chromium
- Bundle size target: < 5 MB gzipped. CanvasKit adds ~2.5 MB; optimize with deferred loading, tree shaking

## Installation

```bash
# Create Flutter project (if not exists)
flutter create --platforms web my_app

# Core dependencies
flutter pub add flutter_riverpod
flutter pub add riverpod_annotation
flutter pub add go_router
flutter pub add supabase_flutter
flutter pub add hive_ce_flutter
flutter pub add hive_ce
flutter pub add just_audio
flutter pub add flutter_markdown_plus
flutter pub add connectivity_plus
flutter pub add cached_network_image
flutter pub add google_fonts
flutter pub add file_picker
flutter pub add shimmer
flutter pub add phosphor_flutter
flutter pub add url_launcher
flutter pub add shared_preferences
flutter pub add flutter_animate
flutter pub add uuid
flutter pub add intl
flutter pub add json_annotation
flutter pub add freezed_annotation

# Dev dependencies (code generation)
flutter pub add --dev riverpod_generator
flutter pub add --dev build_runner
flutter pub add --dev json_serializable
flutter pub add --dev hive_ce_generator
flutter pub add --dev freezed
flutter pub add --dev very_good_analysis

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|------------------------|
| flutter_riverpod 3.x | bloc / flutter_bloc | If team has strong BLoC experience. Riverpod is simpler for offline-first async patterns. |
| go_router | auto_route | If you need strongly-typed route params with code gen. go_router is official and simpler. |
| hive_ce_flutter | drift (web) | If you need complex SQL queries, relations, migrations. Drift web uses sql.js (adds ~1MB). Overkill for key-value cache. |
| hive_ce_flutter | isar | NEVER for web — Isar has no web support. Mobile-only. |
| supabase_flutter | firebase | If you need real-time listeners, FCM push. Supabase is open-source, SQL-native, cheaper, supports RLS natively. |
| flutter_markdown_plus | markdown_widget | If you need built-in TOC generation and code syntax highlighting. flutter_markdown_plus is the maintained Google successor. |
| cached_network_image | extended_image | If you need advanced image manipulation (zoom, crop). cached_network_image is simpler for cover thumbnails. |
| CanvasKit renderer | HTML renderer | NEVER for this app — inconsistent rendering, limited custom painting |
| JS compilation | Wasm compilation | When Safari + Firefox fix WasmGC bugs (likely late 2026). Track flutter.dev/wasm |
| YooKassa redirect flow | YooKassa Checkout Widget | v2: embed widget via HtmlElementView for seamless in-app payment |
| Workbox service worker | Flutter default SW | NEVER for production PWA — default SW lacks granular cache control, no stale-while-revalidate |
| freezed | dart data classes (Dart 3.11+) | Dart 3.11 data classes are experimental. Use freezed until data classes stabilize. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `hive_flutter` (original) | Abandoned by author since 2022. No Dart 3 updates, no bug fixes. | `hive_ce_flutter` (Community Edition) |
| `hive` (original) | Same — abandoned. | `hive_ce` |
| `flutter_markdown` (Google) | Officially discontinued by Google, no longer maintained. | `flutter_markdown_plus` |
| `isar` | No web support at all. Author abandoned it. | `hive_ce` for web, Drift if SQL needed |
| `provider` | Legacy state management, Riverpod is its successor by the same author. | `flutter_riverpod` |
| `GetX` | Poor testability, global mutable state, anti-pattern for offline-first. | `flutter_riverpod` |
| `http` package | No interceptors, no retry logic. | `supabase_flutter` (uses its own HTTP client) or `dio` if needed |
| `yookassa_payments_flutter` | Mobile-only SDK (iOS/Android). Does NOT work on Flutter web. | YooKassa API via Edge Functions + redirect flow |
| Stripe | Out of scope — project requires YooMoney for Russian market. | YooKassa (YooMoney) API |
| In-App Purchase (IAP) | Web-only v1, no app stores involved. | YooKassa payments |
| HTML renderer (`--web-renderer html`) | Inconsistent text, limited CustomPaint, poor font rendering. | CanvasKit (default) |
| Wasm compilation (`--wasm`) | Safari/Firefox incompatible as of March 2026. Chromium-only. | JS compilation (default) for v1 |
| `flutter_secure_storage` | Web implementation uses localStorage (not secure). Supabase handles token storage. | Supabase Auth built-in token management |
| `sqflite` | No web support. Desktop/mobile only. | `hive_ce` for web-compatible storage |
| `path_provider` | Limited web support, not needed when using Hive CE (auto IndexedDB). | Hive CE handles storage paths internally on web |

## Version Compatibility

| Constraint | Details |
|------------|---------|
| Flutter SDK | `>=3.41.0` required for latest CanvasKit, Impeller web improvements |
| Dart SDK | `>=3.11.0` (bundled with Flutter 3.41) |
| Riverpod ecosystem | `flutter_riverpod ^3.3.0` + `riverpod_annotation ^4.0.2` + `riverpod_generator ^3.0.3` must be version-aligned |
| Supabase | `supabase_flutter ^2.10.2` requires Dart >=3.0. Compatible with Supabase platform v2. |
| Hive CE | `hive_ce ^2.7.0` + `hive_ce_flutter ^2.3.4` + `hive_ce_generator ^1.6.0` — all from same maintainer, version-aligned |
| google_fonts | `^8.0.1` — set `allowRuntimeFetching = false` for PWA offline; bundle fonts as assets |
| CanvasKit | Bundled with Flutter SDK. No separate version management needed. ~2.5 MB added to bundle. |
| Workbox | Use `workbox-cdn@7.x` or npm `workbox-build@7.x` for custom service worker generation. Separate from Flutter. |

## PWA Configuration Checklist

- [ ] `web/manifest.json` — app name, icons (192x192, 512x512), `display: standalone`, theme_color `#C05621`
- [ ] Custom service worker with Workbox (replace `flutter_service_worker.js`)
- [ ] `<meta name="theme-color" content="#C05621">` in `index.html`
- [ ] Apple touch icon and `apple-mobile-web-app-capable` meta tags
- [ ] HTTPS deployment (required for service workers)
- [ ] `google_fonts` runtime fetching disabled, fonts bundled as assets
- [ ] Offline fallback page in service worker

## Sources

- [Flutter 3.41 Release Notes](https://blog.flutter.dev/whats-new-in-flutter-3-41-302ec140e632)
- [Flutter Wasm Support Docs](https://docs.flutter.dev/platform-integration/web/wasm)
- [Riverpod 3.0 What's New](https://riverpod.dev/docs/whats_new)
- [flutter_riverpod on pub.dev](https://pub.dev/packages/flutter_riverpod)
- [go_router on pub.dev](https://pub.dev/packages/go_router)
- [supabase_flutter on pub.dev](https://pub.dev/packages/supabase_flutter)
- [hive_ce_flutter on pub.dev](https://pub.dev/packages/hive_ce_flutter)
- [just_audio on pub.dev](https://pub.dev/packages/just_audio)
- [flutter_markdown_plus — Google Handover](https://foresightmobile.com/blog/flutter-markdown-plus-google-handover)
- [connectivity_plus on pub.dev](https://pub.dev/packages/connectivity_plus)
- [cached_network_image Web Limitation](https://github.com/Baseflow/flutter_cached_network_image/issues/599)
- [YooKassa Checkout Widget Docs](https://yookassa.ru/developers/payment-acceptance/integration-scenarios/widget/basics)
- [Workbox Caching for Flutter PWA](https://mohanrajmuthukumaran.hashnode.dev/flutter-pwa-workbox-caching)
- [PWA Best Practices 2026](https://wirefuture.com/post/progressive-web-apps-pwa-best-practices-for-2026)
- [Flutter Web Performance — CanvasKit vs Wasm](https://medium.com/@ravipatel84184/flutter-web-just-got-40-faster-and-you-dont-have-to-do-anything-d0ea0d3c0a4a)

---
*Generated: 2026-03-18 | Stack validated against pub.dev and official Flutter/Dart release notes*
