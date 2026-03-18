# Architecture Research

**Domain:** Flutter Web/PWA, offline-first content-reading app
**Researched:** 2026-03-18
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Flutter Web/PWA Client                       │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌───────────────────┐  │
│  │  UI Layer │  │  Router   │  │  Riverpod │  │   Service Worker  │  │
│  │ (Screens/ │──│ (GoRouter)│──│ Providers │  │   (PWA Cache)     │  │
│  │  Widgets) │  │          │  │           │  │                   │  │
│  └─────┬─────┘  └──────────┘  └─────┬─────┘  └────────┬──────────┘  │
│        │                            │                  │            │
│  ┌─────┴────────────────────────────┴──────────────────┴─────────┐  │
│  │                     Repository Layer                           │  │
│  │  (Offline-first: read Hive → fallback Supabase → sync back)   │  │
│  └──────┬──────────────────┬──────────────────┬──────────────────┘  │
│         │                  │                  │                     │
│  ┌──────┴──────┐  ┌───────┴───────┐  ┌───────┴──────────────────┐  │
│  │  Hive Local  │  │  just_audio   │  │  Supabase Client SDK     │  │
│  │  Storage     │  │  (Audio)      │  │  (Auth, DB, Storage)     │  │
│  └─────────────┘  └───────────────┘  └──────────┬───────────────┘  │
└─────────────────────────────────────────────────┼───────────────────┘
                                                  │ HTTPS
┌─────────────────────────────────────────────────┼───────────────────┐
│                      Supabase Backend            │                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┴──────────────┐   │
│  │  Auth         │  │  PostgreSQL   │  │  Storage (S3)           │   │
│  │  (email,      │  │  + RLS        │  │  (covers, audio files)  │   │
│  │   Google)     │  │              │  │                         │   │
│  └──────────────┘  └──────────────┘  └─────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Edge Functions                                              │   │
│  │  - YooMoney webhook (payment confirmation)                   │   │
│  │  - Subscription status management                            │   │
│  │  - Content access validation                                 │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                           │
                           │ Webhook
┌──────────────────────────┴──────────────────────────────────────────┐
│                      YooMoney Payment Gateway                       │
│  (redirect flow: app → YooMoney page → callback → Edge Function)    │
└─────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Talks To | Does NOT Touch |
|---|---|---|---|
| **UI Layer** (screens, widgets) | Renders UI, captures user input, animations | Riverpod providers, GoRouter | Database, network, local storage |
| **GoRouter** | Declarative routing, deep links, guards (auth, admin) | UI Layer, Auth provider | Business logic |
| **Riverpod Providers** | State management, business logic orchestration | Repository layer | UI widgets directly, Hive/Supabase directly |
| **Repository Layer** | Offline-first data access, sync orchestration | Hive, Supabase client, Connectivity | UI, Providers internals |
| **Hive (Local Storage)** | Cached books, reading progress, user prefs, downloaded content | Disk (IndexedDB on web) | Network |
| **Supabase Client** | Remote API calls: auth, CRUD, file upload/download | Supabase backend over HTTPS | Local storage |
| **just_audio** | Audio playback, speed control, position tracking | Audio files (local or remote URL) | State management |
| **Service Worker** | PWA install, static asset caching, offline shell | Browser Cache API | Dart code directly |
| **Edge Functions** | Server-side logic: payment webhooks, access control | PostgreSQL, YooMoney API | Client state |
| **PostgreSQL + RLS** | Data persistence, row-level security | Edge Functions, Supabase client | Client directly (always via SDK) |
| **Supabase Storage** | Binary files: covers, audio mp3 | PostgreSQL (references), client SDK | Application logic |

## Recommended Project Structure

```
lib/
├── main.dart                          # App entry, ProviderScope, init
├── app.dart                           # MaterialApp.router, theme setup
│
├── core/                              # Shared infrastructure
│   ├── constants/
│   │   ├── app_constants.dart         # Timeouts, limits, storage keys
│   │   ├── supabase_constants.dart    # Table names, bucket names
│   │   └── ui_constants.dart          # Sizes, paddings, breakpoints
│   ├── error/
│   │   ├── failures.dart              # Failure sealed class hierarchy
│   │   └── error_handler.dart         # Global error catching
│   ├── network/
│   │   ├── connectivity_provider.dart # Stream<ConnectivityStatus>
│   │   └── sync_manager.dart          # Queue-based sync orchestration
│   ├── storage/
│   │   ├── hive_init.dart             # Hive box registration
│   │   └── hive_keys.dart             # Type-safe box/key constants
│   ├── theme/
│   │   ├── app_theme.dart             # Light + Dark ThemeData
│   │   ├── reader_themes.dart         # Cream, Dark, White reader themes
│   │   ├── app_colors.dart            # Warm Brutalism palette
│   │   └── app_typography.dart        # Playfair, Source Sans, Mono
│   ├── utils/
│   │   ├── extensions.dart            # Dart extension methods
│   │   ├── formatters.dart            # Duration, date, price formatting
│   │   └── validators.dart            # Input validation
│   └── router/
│       ├── app_router.dart            # GoRouter configuration
│       ├── routes.dart                # Route path constants
│       └── guards.dart                # Auth guard, admin guard, paywall
│
├── data/                              # Data layer (repository implementations + data sources)
│   ├── models/                        # Data transfer objects / DB models
│   │   ├── book_model.dart            # Book JSON serialization
│   │   ├── book_model.g.dart          # Generated Hive adapter
│   │   ├── summary_model.dart
│   │   ├── key_idea_model.dart
│   │   ├── user_profile_model.dart
│   │   ├── subscription_model.dart
│   │   ├── highlight_model.dart
│   │   ├── reading_progress_model.dart
│   │   ├── collection_model.dart
│   │   └── category_model.dart
│   ├── datasources/
│   │   ├── local/                     # Hive-based local data sources
│   │   │   ├── book_local_ds.dart
│   │   │   ├── progress_local_ds.dart
│   │   │   ├── highlight_local_ds.dart
│   │   │   ├── user_prefs_local_ds.dart
│   │   │   └── download_local_ds.dart
│   │   └── remote/                    # Supabase-based remote data sources
│   │       ├── book_remote_ds.dart
│   │       ├── auth_remote_ds.dart
│   │       ├── subscription_remote_ds.dart
│   │       ├── highlight_remote_ds.dart
│   │       └── storage_remote_ds.dart
│   └── repositories/                  # Repository implementations
│       ├── book_repository_impl.dart
│       ├── auth_repository_impl.dart
│       ├── subscription_repository_impl.dart
│       ├── highlight_repository_impl.dart
│       ├── reading_progress_repository_impl.dart
│       └── download_repository_impl.dart
│
├── domain/                            # Domain layer (pure Dart, no framework imports)
│   ├── entities/                      # Domain entities (immutable, no serialization)
│   │   ├── book.dart
│   │   ├── summary.dart
│   │   ├── key_idea.dart
│   │   ├── user_profile.dart
│   │   ├── subscription.dart
│   │   ├── highlight.dart
│   │   ├── reading_progress.dart
│   │   └── collection.dart
│   ├── repositories/                  # Abstract repository interfaces
│   │   ├── book_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── subscription_repository.dart
│   │   ├── highlight_repository.dart
│   │   ├── reading_progress_repository.dart
│   │   └── download_repository.dart
│   └── enums/
│       ├── subscription_tier.dart     # free, proMonthly, proYearly
│       ├── shelf_type.dart            # favorite, read, wantToRead
│       └── reader_theme_type.dart     # cream, dark, white
│
├── presentation/                      # UI layer
│   ├── common/                        # Shared widgets
│   │   ├── book_card.dart
│   │   ├── mini_player.dart           # Persistent audio mini-player
│   │   ├── paywall_sheet.dart         # Pro upgrade BottomSheet
│   │   ├── skeleton_loader.dart
│   │   ├── app_bottom_nav.dart
│   │   ├── error_view.dart
│   │   └── responsive_layout.dart     # Breakpoint wrapper
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── banner_carousel.dart
│   │   │   ├── continue_reading_section.dart
│   │   │   ├── category_section.dart
│   │   │   └── new_popular_section.dart
│   │   └── providers/
│   │       └── home_providers.dart
│   ├── catalog/
│   │   ├── catalog_screen.dart
│   │   ├── widgets/
│   │   │   ├── search_bar.dart
│   │   │   ├── filter_chips.dart
│   │   │   └── book_grid.dart
│   │   └── providers/
│   │       └── catalog_providers.dart
│   ├── book_detail/
│   │   ├── book_detail_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── reader/
│   │   ├── reader_screen.dart
│   │   ├── widgets/
│   │   │   ├── reader_content.dart    # Markdown rendering
│   │   │   ├── reader_settings_sheet.dart
│   │   │   ├── toc_drawer.dart
│   │   │   └── text_selection_menu.dart
│   │   └── providers/
│   │       ├── reader_providers.dart
│   │       └── reader_settings_provider.dart
│   ├── audio_player/
│   │   ├── full_player_screen.dart
│   │   ├── widgets/
│   │   │   ├── player_controls.dart
│   │   │   ├── speed_selector.dart
│   │   │   └── sleep_timer.dart
│   │   └── providers/
│   │       └── audio_providers.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── shelves/
│   │   ├── shelves_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── highlights/
│   │   ├── highlights_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   │       └── auth_providers.dart
│   ├── downloads/
│   │   ├── downloads_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── subscription/
│   │   ├── subscription_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   └── admin/                         # Admin panel (role-gated)
│       ├── admin_dashboard_screen.dart
│       ├── book_editor_screen.dart
│       ├── widgets/
│       │   ├── book_form.dart
│       │   ├── key_ideas_editor.dart
│       │   ├── collection_manager.dart
│       │   └── file_uploader.dart
│       └── providers/
│           └── admin_providers.dart
│
├── providers/                         # Global/cross-feature providers
│   ├── supabase_providers.dart        # SupabaseClient, Auth state
│   ├── connectivity_provider.dart     # Online/offline status
│   ├── user_provider.dart             # Current user + subscription
│   └── sync_provider.dart             # Sync queue orchestration
│
web/
├── index.html                         # Flutter web host, PWA manifest link
├── manifest.json                      # PWA manifest (name, icons, display)
├── sw.js                              # Service Worker (custom caching strategy)
└── icons/                             # PWA icons (192x192, 512x512)

supabase/
├── migrations/                        # SQL migrations
│   ├── 001_initial_schema.sql
│   ├── 002_rls_policies.sql
│   └── 003_indexes.sql
├── functions/                         # Edge Functions (Deno/TypeScript)
│   ├── yoomoney-webhook/
│   │   └── index.ts                   # Payment confirmation handler
│   ├── create-payment/
│   │   └── index.ts                   # Initiate YooMoney payment
│   └── check-subscription/
│       └── index.ts                   # Validate active subscription
└── seed.sql                           # Dev seed data (categories, test books)

test/
├── unit/
│   ├── data/repositories/
│   ├── domain/entities/
│   └── providers/
├── widget/
│   ├── presentation/
│   └── common/
└── integration/
```

### Structure Notes

1. **`domain/` has zero Flutter imports** -- pure Dart only. Entities use `freezed` for immutability. Repository interfaces are abstract classes.
2. **`data/models/` vs `domain/entities/`**: Models handle JSON/Hive serialization. Entities are clean domain objects. Models have `toDomain()` and `fromDomain()` methods.
3. **Feature-scoped providers** live inside `presentation/<feature>/providers/`. Global providers live in top-level `providers/`.
4. **Admin panel** is inside `presentation/admin/` gated by GoRouter guard checking `user.role == 'admin'`.

## Architectural Patterns

### 1. Repository Pattern with Offline-First Strategy

Every data operation goes through a repository that decides local vs. remote.

```dart
// domain/repositories/book_repository.dart
abstract class BookRepository {
  Future<List<Book>> getBooks({String? category, int page = 0});
  Future<Book> getBookById(String id);
  Future<void> downloadBook(String id);
  Stream<List<Book>> watchDownloadedBooks();
}

// data/repositories/book_repository_impl.dart
class BookRepositoryImpl implements BookRepository {
  final BookLocalDataSource _local;
  final BookRemoteDataSource _remote;
  final ConnectivityProvider _connectivity;

  @override
  Future<List<Book>> getBooks({String? category, int page = 0}) async {
    // 1. Return cached data immediately
    final cached = await _local.getBooks(category: category, page: page);
    if (cached.isNotEmpty) {
      // 2. Refresh in background if online
      if (_connectivity.isOnline) {
        _refreshBooksInBackground(category: category, page: page);
      }
      return cached;
    }
    // 3. If no cache, must go remote
    if (!_connectivity.isOnline) {
      throw const Failure.offline();
    }
    final remote = await _remote.getBooks(category: category, page: page);
    await _local.cacheBooks(remote);
    return remote.map((m) => m.toDomain()).toList();
  }
}
```

### 2. Riverpod Provider Architecture (StateNotifier + AsyncValue)

```dart
// providers/user_provider.dart
@riverpod
Stream<UserProfile?> currentUser(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.asyncMap((event) async {
    if (event.session == null) return null;
    final uid = event.session!.user.id;
    final data = await supabase.from('profiles').select().eq('id', uid).single();
    return UserProfileModel.fromJson(data).toDomain();
  });
}

// presentation/catalog/providers/catalog_providers.dart
@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  @override
  FutureOr<List<Book>> build({String? category}) async {
    final repo = ref.watch(bookRepositoryProvider);
    return repo.getBooks(category: category);
  }

  Future<void> loadMore() async { /* pagination logic */ }
  Future<void> search(String query) async { /* debounced search */ }
}

// presentation/audio_player/providers/audio_providers.dart
@riverpod
class AudioPlayerNotifier extends _$AudioPlayerNotifier {
  late final AudioPlayer _player;

  @override
  AudioPlayerState build() {
    _player = AudioPlayer();
    ref.onDispose(() => _player.dispose());
    // Listen to position stream, update reading progress
    _player.positionStream.listen((pos) {
      ref.read(readingProgressProvider.notifier).updateAudioPosition(pos);
    });
    return const AudioPlayerState.idle();
  }

  Future<void> play(String bookId, String audioUrl) async { ... }
  Future<void> setSpeed(double speed) async { ... }
  Future<void> setSleepTimer(Duration duration) async { ... }
}
```

### 3. Sync Queue Pattern (Offline Mutations)

Write operations are queued locally and replayed when connectivity resumes.

```dart
// core/network/sync_manager.dart
class SyncManager {
  final Box<SyncOperation> _syncQueue;
  final SupabaseClient _supabase;

  /// Called when connectivity is restored
  Future<void> processQueue() async {
    final operations = _syncQueue.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final op in operations) {
      try {
        await _executeOperation(op);
        await _syncQueue.delete(op.key);
      } on PostgrestException catch (e) {
        if (e.code == '409') {
          // Conflict resolution: server wins for content, client wins for user data
          await _resolveConflict(op);
          await _syncQueue.delete(op.key);
        } else {
          break; // Stop processing, retry later
        }
      }
    }
  }

  /// Enqueue a mutation when offline
  Future<void> enqueue(SyncOperation op) async {
    await _syncQueue.add(op);
  }
}
```

### 4. GoRouter Guard Pattern (Auth + Role + Paywall)

```dart
// core/router/app_router.dart
GoRouter appRouter(Ref ref) {
  final user = ref.watch(currentUserProvider);
  final subscription = ref.watch(subscriptionProvider);

  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = user.valueOrNull != null;
      final isAdmin = user.valueOrNull?.role == UserRole.admin;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      if (isAdminRoute && !isAdmin) return '/';
      return null;
    },
    routes: [ /* ... */ ],
  );
}
```

## Data Flow

### Request Flow (Read Operation)

```
User taps "Open Book"
  → UI calls ref.read(bookDetailProvider(bookId))
    → BookDetailNotifier.build(bookId) invoked
      → bookRepository.getBookById(bookId)
        → Check Hive cache (bookBox.get(bookId))
          → HIT: return cached Book, trigger background refresh
          → MISS + ONLINE: fetch from Supabase → cache in Hive → return
          → MISS + OFFLINE: throw Failure.offline()
      → Provider state = AsyncData(book) or AsyncError(failure)
    → UI rebuilds with book data or error widget
```

### State Management Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Provider Dependency Graph               │
│                                                         │
│  supabaseClientProvider (global, singleton)              │
│    ├── authStateProvider (StreamProvider)                │
│    │     └── currentUserProvider                        │
│    │           ├── subscriptionProvider                  │
│    │           │     └── paywallProvider (can access?)   │
│    │           └── isAdminProvider                       │
│    ├── bookRepositoryProvider                            │
│    │     ├── homeProvider (books for home screen)        │
│    │     ├── catalogProvider (search + filter)           │
│    │     └── bookDetailProvider(id) (family)             │
│    ├── highlightRepositoryProvider                       │
│    │     └── highlightsProvider(bookId) (family)         │
│    └── readingProgressRepositoryProvider                 │
│          └── progressProvider(bookId) (family)           │
│                                                         │
│  connectivityProvider (StreamProvider<bool>)             │
│    └── syncManagerProvider (triggers queue processing)   │
│                                                         │
│  audioPlayerProvider (global, Notifier)                  │
│    └── miniPlayerVisibilityProvider (derived)            │
│                                                         │
│  readerSettingsProvider (local prefs, Notifier)          │
│  themeProvider (light/dark, Notifier)                    │
└─────────────────────────────────────────────────────────┘
```

### Offline-First Data Flow

```
WRITE OPERATION (e.g., save highlight):

User highlights text
  → UI calls highlightNotifier.addHighlight(text, color, position)
    → Repository:
      1. Save to Hive immediately (optimistic)
      2. Check connectivity
        → ONLINE: POST to Supabase → success (done)
        → OFFLINE: Enqueue SyncOperation to sync queue
      3. Return success to UI immediately (from step 1)

SYNC ON RECONNECT:

ConnectivityProvider emits: online = true
  → SyncManager.processQueue()
    → For each queued operation:
      → Execute against Supabase
      → On success: remove from queue
      → On conflict: resolve (last-write-wins for user data)
    → Notify relevant providers to refresh

DOWNLOAD FLOW (audio/text for offline):

User taps "Download" on book
  → DownloadNotifier.download(bookId)
    → Check storage quota (Pro: unlimited, Free: blocked)
    → Fetch markdown text → save to Hive
    → Fetch audio file URL → download via HTTP → save to Hive as bytes
    → Update download status in Hive
    → UI shows downloaded badge
```

### Key Data Flows

#### 1. Authentication Flow
```
App Start → Check Supabase session
  → Valid session → Load profile from cache → Background refresh
  → No session → Show login screen
    → Email/Password or Google OAuth
    → Supabase Auth → JWT issued
    → Create/update profile row in PostgreSQL
    → GoRouter redirect → Home
```

#### 2. Payment Flow (YooMoney)
```
User taps "Subscribe Pro"
  → Client calls Edge Function: create-payment
    → Edge Function creates YooMoney payment, returns redirect URL
  → Client opens redirect URL (new tab or in-app browser)
  → User completes payment on YooMoney page
  → YooMoney sends webhook to Edge Function: yoomoney-webhook
    → Edge Function validates HMAC signature
    → Updates subscription in PostgreSQL:
        subscriptions(user_id, tier, expires_at, yoomoney_payment_id)
    → Returns 200 to YooMoney
  → Client polls subscription status OR listens to Supabase realtime
    → subscriptionProvider updates → paywall removed → UI rebuilds
```

#### 3. Audio Playback with Persistent Mini-Player
```
User taps "Play" on book detail
  → audioPlayerProvider.play(bookId, audioUrl)
    → Check if audio is downloaded in Hive
      → YES: load from local bytes
      → NO: stream from Supabase Storage URL
    → just_audio starts playback
    → miniPlayerVisibilityProvider → true
    → Mini-player appears in Scaffold (above bottom nav)
    → Position stream updates reading_progress in Hive
    → On app background/close: save position
    → On resume: restore position from Hive
```

## Scaling Considerations

### Web-Specific Concerns

| Concern | Strategy |
|---|---|
| **Bundle size** (target < 5 MB gzip) | Deferred loading for admin panel, tree-shaking, avoid heavy packages |
| **First paint < 3 sec on 3G** | Service Worker precache app shell, skeleton loaders, lazy image loading |
| **Hive on web uses IndexedDB** | Works well for structured data; for large audio files, consider Cache API via JS interop |
| **Audio on web** | just_audio web uses HTML5 `<audio>` element; streaming works, but downloaded audio must be served via blob URL |
| **Service Worker** | Custom SW for: (a) app shell caching, (b) cover image caching (cache-first), (c) API response caching (stale-while-revalidate) |

### Content Growth (30 → 300+ books)

| Stage | Strategy |
|---|---|
| **Catalog pagination** | Cursor-based pagination from Supabase (keyset pagination with `id > last_id`) |
| **Search** | Start with Supabase full-text search (`tsvector`); migrate to Meilisearch/Typesense if > 500 books |
| **Local cache eviction** | LRU eviction for book cache in Hive; keep only last 50 books metadata locally; downloaded content is explicit |
| **Audio storage** | Supabase Storage (S3-backed); CDN via Supabase; average 15 min audio ~15 MB per book |

### Future Mobile Expansion

The architecture supports mobile by design:
- Hive works on iOS/Android natively (file-system backed)
- just_audio supports iOS/Android background audio
- GoRouter supports platform-adaptive navigation
- Only `web/sw.js` and PWA manifest are web-specific
- Service Worker logic is isolated, not mixed into Dart code

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Hurts | Do Instead |
|---|---|---|
| **Calling Supabase directly from widgets** | Untestable, no offline support, duplicated logic | Always go through Repository via Provider |
| **Single god provider for all state** | Unscalable, rebuilds entire tree on any change | Feature-scoped providers, `select()` for granular rebuilds |
| **Storing audio as base64 in Hive** | Bloats IndexedDB, slow encoding/decoding | Store as `Uint8List` in dedicated Hive box, or use Cache API on web |
| **Synchronous Hive reads in build()** | Blocks UI frame rendering | Use `FutureProvider` or pre-load boxes at app init |
| **No conflict resolution in sync** | Silent data loss when offline changes clash with server | Define clear strategy: server-wins for content, client-wins for user data (highlights, progress) |
| **Hardcoding RLS bypass for admin** | Security hole | Admin role checked in RLS policies + GoRouter guard + Edge Function verification |
| **Mixing admin UI in main navigation** | Confuses users, larger bundle for everyone | Deferred-load admin module, separate route branch |
| **No pagination on catalog** | Loads all books at once, slow as catalog grows | Implement from day one with `limit`/`offset` or cursor |

## Integration Points

### Supabase Services Used

| Service | Purpose | Configuration |
|---|---|---|
| **Auth** | Email/password, Google OAuth, JWT tokens | Enable email + Google provider in Supabase dashboard |
| **PostgreSQL** | All structured data (books, profiles, subscriptions, highlights, progress) | RLS on every table |
| **Storage** | Book covers (public bucket), audio files (authenticated bucket) | Size limits: covers 2 MB, audio 100 MB |
| **Edge Functions** | Payment processing, subscription management | Deno runtime, secrets for YooMoney API key |
| **Realtime** (optional) | Subscription status updates after payment | Listen to `subscriptions` table changes |

### External Services

| Service | Integration Method | Failure Mode |
|---|---|---|
| **YooMoney** | Redirect flow + webhook to Edge Function | Payment page unavailable → show retry; webhook fails → YooMoney retries 3x |
| **Google OAuth** | Via Supabase Auth (server-side) | Google down → fallback to email/password |
| **Google Fonts** | Bundled in app (not CDN loaded) | No runtime dependency |

### Flutter Package Dependencies (Key Packages)

| Package | Purpose | Version Constraint |
|---|---|---|
| `flutter_riverpod` + `riverpod_annotation` | State management + code generation | ^2.5.x |
| `go_router` | Declarative routing | ^14.x |
| `supabase_flutter` | Supabase SDK (auth, db, storage) | ^2.x |
| `hive_flutter` + `hive` | Local storage (IndexedDB on web) | ^2.x |
| `just_audio` + `just_audio_web` | Audio playback | ^0.9.x |
| `freezed` + `json_serializable` | Immutable models + serialization | build_runner codegen |
| `flutter_markdown` | Reader markdown rendering | ^0.7.x |
| `cached_network_image` | Cover image caching | ^3.x |
| `connectivity_plus` | Network status detection | ^6.x |
| `phosphor_flutter` | Phosphor icon set | ^2.x |

## Suggested Build Order

Components should be built in this order due to dependencies:

```
Phase 1: Foundation (no UI yet)
  ├── core/ (constants, theme, error types)
  ├── Supabase project setup (schema, RLS, storage buckets)
  ├── Hive initialization + model adapters
  ├── domain/ entities + repository interfaces
  └── data/ models with serialization

Phase 2: Auth + Navigation Shell
  ├── GoRouter setup with auth guard
  ├── Auth screens (login, register)
  ├── Auth repository (Supabase Auth)
  ├── App shell (Scaffold + BottomNav + mini-player slot)
  └── Theme (light + dark) applied

Phase 3: Core Content (Read Path)
  ├── Book repository (offline-first read)
  ├── Home screen (carousel, sections)
  ├── Catalog screen (search, filter, pagination)
  ├── Book detail screen
  └── Connectivity provider + basic sync

Phase 4: Reader + Audio
  ├── Reader screen (Markdown rendering)
  ├── Reader settings (font, theme, size)
  ├── Reading progress tracking
  ├── Audio player (just_audio integration)
  ├── Mini-player (persistent)
  └── Highlights + text selection

Phase 5: Monetization + Downloads
  ├── Subscription model + paywall logic
  ├── YooMoney Edge Functions (create-payment, webhook)
  ├── Subscription screen + paywall BottomSheet
  ├── Download manager (offline content)
  └── Sync queue (offline writes)

Phase 6: User Features
  ├── Profile screen + stats
  ├── Shelves (favorites, read, want-to-read)
  ├── Highlights/quotes screen
  └── Recommendations (Pro)

Phase 7: Admin Panel
  ├── Admin guard in GoRouter
  ├── Admin dashboard
  ├── Book CRUD editor
  ├── File upload (covers, audio, markdown)
  └── Collection/category management

Phase 8: PWA Polish
  ├── Custom Service Worker
  ├── PWA manifest + icons
  ├── Cache strategies (app shell, images, API)
  ├── Install prompt
  └── Performance optimization (deferred loading, bundle size)
```

**Key dependency insight:** Phase 1-2 must complete before any feature work. Phase 3 (read path) is prerequisite for Phase 4 (reader/audio) and Phase 5 (monetization needs content to gate). Phase 7 (admin) can technically start after Phase 3, but is lower priority since content can be seeded via SQL initially. Phase 8 is a polish layer that can happen in parallel with Phase 6-7.

## Sources

- Flutter official documentation: PWA support, web rendering (CanvasKit vs HTML) -- https://docs.flutter.dev/platform-integration/web
- Riverpod documentation: provider architecture, code generation -- https://riverpod.dev
- Supabase documentation: Auth, RLS, Storage, Edge Functions -- https://supabase.com/docs
- Hive documentation: web support via IndexedDB -- https://docs.hivedb.dev
- just_audio package: web audio playback -- https://pub.dev/packages/just_audio
- GoRouter documentation: declarative routing, redirect guards -- https://pub.dev/packages/go_router
- YooMoney API documentation: payment creation, webhook format -- https://yookassa.ru/developers
- PWA design patterns: offline-first, service worker strategies -- https://web.dev/learn/pwa

---
