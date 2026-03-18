# Project Research Summary

**Project:** BookSummary — Саммари нон-фикшн книг
**Domain:** Content/Reading SaaS (Book Summaries, Russian Market)
**Researched:** 2026-03-18
**Confidence:** HIGH

## Executive Summary

BookSummary is a Flutter Web/PWA application for reading non-fiction book summaries in Russian, targeting entrepreneurs, managers, and self-learners aged 25-45. The product differentiates from the primary competitor (Smart Reading) through full offline access (text + audio), a price point 2-3x lower (200 RUB/month vs 500-700 RUB/month), and a distinctive "Warm Brutalism" design identity. V1 is web-only; mobile (iOS/Android) will follow using the same Flutter codebase.

The recommended stack centers on Flutter 3.41 (CanvasKit renderer, JS compilation), Riverpod 3 for state management, Supabase as a full BaaS (Auth, PostgreSQL with RLS, Storage, Edge Functions), Hive CE for local offline storage, and just_audio for playback. Payments use YooMoney (YooKassa API) via redirect flow and Edge Function webhooks — the only viable payment option for Russian sole proprietors at launch. All core stack choices carry HIGH confidence based on pub.dev validation, official docs, and community consensus.

The architecture follows a clean separation: domain layer (pure Dart entities + repository interfaces), data layer (Hive local + Supabase remote data sources with offline-first repositories), and presentation layer (feature-scoped screens with Riverpod providers). The offline-first strategy is the most architecturally complex aspect, requiring careful coordination between Hive (structured data), Cache API (audio/large files), Service Worker (PWA shell caching), and a sync queue for offline mutations. Eight critical pitfalls have been identified — the most severe being bundle size management, Hive/IndexedDB storage limits on web, audio playback restrictions on iOS Safari, and RLS misconfiguration leaking Pro content.

## Key Findings

### Recommended Stack (summary from STACK.md)

- **Framework:** Flutter 3.41 (Web/PWA), CanvasKit renderer, JS compilation (not Wasm — Safari/Firefox incompatible)
- **State management:** Riverpod 3 with `@riverpod` code generation — compile-safe, excellent for async offline-first patterns
- **Routing:** GoRouter 16.x — official Flutter package, URL-based routing critical for web (bookmarks, deep links)
- **Backend:** Supabase (Auth with email + Google OAuth, PostgreSQL with RLS, Storage for covers/audio, Edge Functions for payments)
- **Local storage:** Hive CE (Community Edition) — actively maintained fork, works on web via IndexedDB. Original `hive` and `hive_flutter` are abandoned
- **Audio:** just_audio — supports speed control, seeking, streaming; web uses HTML5 Audio
- **Markdown:** flutter_markdown_plus — maintained successor to Google's discontinued flutter_markdown
- **Payments:** YooKassa API via Supabase Edge Functions + redirect flow (mobile SDK does not work on web)
- **Design system:** Phosphor Icons, Google Fonts (Playfair Display, Source Sans 3, Source Serif 4), flutter_animate, shimmer
- **Code generation:** freezed + json_serializable + hive_ce_generator + riverpod_generator via build_runner
- **Key "do not use" items:** original hive/hive_flutter (abandoned), isar (no web), provider (legacy), GetX, HTML renderer, Wasm compilation, flutter_secure_storage (insecure on web), yookassa_payments_flutter (mobile-only)

### Expected Features (summary from FEATURES.md)

**Table stakes (P0):** Catalog with search/filters, text reader with settings, audio player (mini + full), auth (email + Google), freemium + paywall + YooMoney, shelves, reading progress, dark theme, profile, PWA, admin panel, "Warm Brutalism" design.

**Differentiators:** Full offline access (text + audio) as the primary competitive advantage; price 2-3x below Smart Reading; unique visual identity; key idea cards.

**Post-validation (P1):** Text highlighting + quotes with export, key idea cards, personalized recommendations, similar books, banner carousel, audio-text position sync.

**Anti-features identified:** AI content generation (quality/legal risks), social features (moderation overhead), gamification (distraction from core value), video summaries (production cost), AI chatbot, aggressive push notifications, B2B plans, A/B testing (premature optimization).

**MVP target:** 30-50 summaries at launch, 100+ at v1.x, 300+ at v2.

### Architecture Approach (summary from ARCHITECTURE.md)

- **Pattern:** Clean Architecture with 3 layers — domain (pure Dart), data (repositories + data sources), presentation (feature-scoped screens + providers)
- **Offline-first:** Repository pattern where reads check Hive first, fallback to Supabase, and background-refresh. Writes are optimistic (save to Hive immediately) with a sync queue that replays mutations on reconnect.
- **Provider graph:** Global providers (Supabase client, auth, connectivity, audio player) at top level; feature-scoped providers inside each presentation feature folder.
- **Routing:** GoRouter with auth guard, admin guard, and paywall guard.
- **PWA:** Custom Workbox-based Service Worker replacing Flutter's default — CacheFirst for static assets, StaleWhileRevalidate for images, NetworkFirst for API responses.
- **Payment flow:** Client calls Edge Function to create YooMoney payment, user redirected to payment page, webhook confirms payment to Edge Function, subscription updated in PostgreSQL.
- **Build order:** Foundation/core -> Auth + navigation shell -> Core content (catalog, detail) -> Reader + audio -> Monetization + downloads -> User features (profile, shelves, highlights) -> Admin panel -> PWA polish.
- **Mobile expansion:** Architecture supports it by design — Hive, just_audio, GoRouter all work cross-platform; only sw.js and manifest are web-specific.

### Critical Pitfalls (top 5 from PITFALLS.md)

1. **Bundle size explosion (P1):** CanvasKit adds ~2.5 MB, 4 font families add 1-2 MB each. Without deferred loading and font subsetting, bundle exceeds 8-10 MB. Must configure deferred imports and font optimization from project start.

2. **Hive/IndexedDB storage corruption and limits (P2):** Hive on web lacks multi-tab locking; Safari can evict IndexedDB under memory pressure; audio files must NOT go in Hive. Use Cache API for large files, request persistent storage, implement health checks.

3. **Audio broken on mobile web (P3):** iOS Safari blocks autoplay, kills background audio, throttles JS timers. Must start audio from direct user gesture, use Media Session API, encode as AAC/MP4, and accept iOS background playback limitations for PWA v1.

4. **RLS misconfiguration leaking Pro content (P4):** Checking only `auth.uid() IS NOT NULL` lets any authenticated user access full content. RLS must join against subscription status. Never expose `service_role` key in client code.

5. **YooMoney webhook reliability (P5):** Edge Function cold starts can cause webhook timeouts; lost webhooks mean user pays but gets no access. Implement idempotent handler, store raw payloads, build reconciliation cron, add client-side payment verification polling.

## Implications for Roadmap

### Phase 1: Foundation and Infrastructure
- **Delivers:** Project skeleton, theme system ("Warm Brutalism"), Supabase schema with RLS, Hive initialization, domain entities, build pipeline with deferred imports and font subsetting
- **Addresses:** Bundle size (P1), RLS security (P4), Service Worker strategy (P6)
- **Avoids:** Starting feature work before storage strategy and security policies are locked down

### Phase 2: Auth and Navigation Shell
- **Delivers:** Login/register (email + Google OAuth), GoRouter with guards, app shell (Scaffold + BottomNav + mini-player slot), light/dark theme
- **Addresses:** Auth flow edge cases (redirect vs popup on Safari), offline architecture design (sync protocol, conflict resolution rules)
- **Avoids:** Building features that depend on auth before auth is stable

### Phase 3: Core Content Path
- **Delivers:** Book repository (offline-first), home screen, catalog with search/filter/pagination, book detail screen, connectivity provider
- **Addresses:** Russian full-text search (PostgreSQL tsvector with Russian dictionary), pagination from day one
- **Avoids:** Loading all books at once (catalog performance trap), search without debounce

### Phase 4: Reader and Audio Player
- **Delivers:** Markdown reader with settings, reading progress, audio player with mini-player, speed control, sleep timer
- **Addresses:** Audio on iOS Safari (P3), Markdown XSS and performance (P7), text highlighting
- **Avoids:** Trusting Chrome DevTools emulation for audio — must test on real iOS Safari early

### Phase 5: Monetization and Downloads
- **Delivers:** Subscription model, paywall, YooMoney integration (Edge Functions), download manager, sync queue
- **Addresses:** Payment webhook reliability (P5), offline download storage (Cache API, not Hive for audio), storage quota management
- **Avoids:** Relying solely on webhooks for payment confirmation (add client-side polling)

### Phase 6: User Features
- **Delivers:** Profile with stats, shelves, highlights/quotes screen, recommendations (Pro)
- **Addresses:** Sync conflicts for user data (P8) — "furthest progress wins", append-only highlights
- **Avoids:** Building recommendation engine before sufficient catalog and user data exist

### Phase 7: Admin Panel
- **Delivers:** Admin dashboard, book CRUD, file uploads (covers, audio, markdown), collection/category management
- **Addresses:** Content pipeline for author, Markdown sanitization on write
- **Avoids:** Mixing admin UI in main bundle (deferred-load the entire admin module)

### Phase 8: PWA Polish and Launch
- **Delivers:** Custom Workbox Service Worker, PWA manifest, install prompt, performance optimization, Lighthouse audit
- **Addresses:** Zombie app problem (P6) — proper cache-control headers, in-app update banner, version check endpoint
- **Avoids:** Launching without testing the full update flow (v1 -> v2 transition)

### Phase Ordering Rationale

Phases 1-2 are strict prerequisites: no feature can function without the foundation, auth, and navigation shell. Phase 3 (content) must precede Phase 4 (reader/audio) because the reader needs content to render. Phase 5 (monetization) depends on Phase 3 and 4 because the paywall gates content and audio. Phase 7 (admin) could theoretically start after Phase 3, but is lower priority since content can be seeded via SQL during development. Phase 8 (PWA polish) runs in parallel with Phases 6-7.

### Research Flags

- **CanvasKit vs HTML renderer trade-off:** STACK.md recommends CanvasKit exclusively, but PITFALLS.md notes low-end mobile web devices may need HTML renderer. Consider `--web-renderer auto` or profiling on target devices during Phase 1.
- **Wasm compilation:** Currently blocked by Safari/Firefox bugs. Monitor flutter.dev/wasm for late 2026 compatibility — could provide 40% performance improvement.
- **YooMoney sole proprietor limitations:** YooMoney for physical persons (fizlitsa) has transaction limits and limited API features vs. YooKassa for legal entities. If growth exceeds limits, will need to register as legal entity.
- **Content volume risk:** MVP requires 30-50 manually-created summaries. This is a significant content investment before product validation. Consider launching with 10-15 high-quality summaries for faster validation.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Core stack (Flutter, Riverpod, GoRouter) | HIGH | Stable, well-documented, community-validated |
| Supabase (Auth, DB, Storage) | HIGH | Production-ready, good Flutter SDK support |
| Hive CE for structured data | HIGH | Actively maintained, works on web via IndexedDB |
| Offline-first architecture | MEDIUM | Pattern is sound but web storage limitations (Safari eviction, IndexedDB quota) introduce real risk |
| Audio playback on web | MEDIUM | Works in Chrome; iOS Safari has known limitations for background playback and autoplay |
| YooMoney/YooKassa integration | MEDIUM | API is documented but webhook reliability and Edge Function cold starts need careful handling |
| Bundle size target (< 5 MB gzip) | MEDIUM | Achievable with deferred loading + font subsetting, but requires discipline from day one |
| PWA offline experience | MEDIUM | Service Worker caching is well-understood, but update mechanism and Safari storage persistence are fragile |
| Markdown rendering performance | HIGH | flutter_markdown_plus handles typical summary lengths well; chunking needed only for very long content |
| Feature completeness for MVP | HIGH | Feature list is well-defined, prioritized, and validated against competitors |
| Design system ("Warm Brutalism") | HIGH | Palette, typography, and component specs are detailed and implementable |
| Competitive positioning | HIGH | Clear price advantage and offline differentiation vs. Smart Reading |

### Gaps to Address

1. **Prototype audio on iOS Safari** before committing to Phase 4 timeline — background playback limitations may require design compromises or workaround documentation for users.
2. **Validate Hive CE + IndexedDB storage limits** with realistic data volumes (50 books metadata + 10 downloaded summaries + reading progress) on Safari specifically.
3. **YooMoney test environment setup** — confirm webhook delivery to Supabase Edge Functions works reliably before Phase 5; test cold start behavior.
4. **Bundle size budget:** Create a size budget breakdown (CanvasKit, fonts, app code, admin module) during Phase 1 and measure against it throughout development.
5. **Content creation timeline:** 30-50 summaries is a significant effort — validate whether the author can produce this volume in parallel with development, or adjust MVP content target.
6. **Legal review:** YooMoney terms for physical persons, content copyright considerations for book summaries.

## Sources

- PROJECT.md — Project definition and requirements (2026-03-18)
- STACK.md — Technology stack research with version-specific recommendations
- FEATURES.md — Feature landscape, competitor analysis, MVP definition
- ARCHITECTURE.md — System architecture, project structure, data flows, build order
- PITFALLS.md — 8 critical pitfalls with prevention strategies and phase mapping
- Flutter 3.41 release notes, Riverpod 3.0 docs, Supabase docs, YooMoney API docs
- Competitor analysis: Smart Reading, Blinkist, Shortform, getAbstract

---
*Synthesized: 2026-03-18*
