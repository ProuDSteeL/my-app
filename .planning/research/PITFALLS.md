# Pitfalls Research

**Domain:** Flutter Web/PWA book summary app with offline-first architecture, audio playback, Supabase backend, YooMoney payments (Russian market)
**Researched:** 2026-03-18
**Confidence:** HIGH (based on known Flutter Web limitations, Supabase patterns, and Russian payment ecosystem specifics)

---

## Critical Pitfalls

### P1. Flutter Web Bundle Size Explosion

**What goes wrong:** Flutter Web compiles to JavaScript (CanvasKit or HTML renderer). Default CanvasKit build downloads a ~1.5 MB WASM binary on top of application JS. With fonts (Playfair Display, Source Sans 3, Source Serif 4, JetBrains Mono — 4 font families) and icons (Phosphor), the initial bundle easily exceeds 8-10 MB uncompressed, blowing past the 5 MB gzipped target.

**Why it happens:** Flutter bundles all referenced widgets, fonts, and assets into main.dart.js. Tree-shaking helps for code but not for font glyphs or icon sets. Each Google Font family with multiple weights adds 200-500 KB.

**Warning signs:**
- `flutter build web` output shows main.dart.js > 3 MB
- Lighthouse "Total Blocking Time" > 2s on fast 3G
- Users on mobile web see blank white screen for 3-5 seconds

**How to avoid:**
- Use deferred loading (`deferred as`) for admin panel, reader, audio player modules
- Subset fonts: only include Cyrillic + Latin glyphs (reduces font files by 60-70%)
- Use HTML renderer for initial load, lazy-load CanvasKit only for reader/audio screens
- Serve fonts from CDN with caching, not bundled in the app
- Tree-shake Phosphor icons: import only used icons, not the entire package
- Enable `--dart2js-optimization O4` and gzip/brotli on server

**Phase to address:** Phase 1 (project setup / architecture). Must configure build pipeline and deferred imports from the start.

---

### P2. Hive Data Corruption and Browser Storage Limits

**What goes wrong:** Hive on Flutter Web uses IndexedDB under the hood. Data corruption occurs when: (a) the user has multiple tabs open and both write to the same box simultaneously, (b) the browser kills the tab during a write (mobile Safari is notorious for this), (c) IndexedDB storage quota is silently exceeded and writes fail without throwing in Hive.

**Why it happens:** Hive was designed for mobile (file system). Its web adapter lacks proper multi-tab locking. IndexedDB has per-origin storage limits (Safari: ~1 GB, but can purge "non-persistent" storage under memory pressure). Hive does not implement the StorageManager persistence API.

**Warning signs:**
- Users report "my downloads disappeared" (Safari eviction)
- Sporadic null reads from boxes that should have data
- `HiveError: box already open` exceptions in crash logs
- Offline content shows partial/garbled text

**How to avoid:**
- Request persistent storage via `navigator.storage.persist()` at PWA install prompt
- Implement a Hive write wrapper that catches all exceptions and retries/rebuilds the box
- Store downloaded audio in Cache API (not Hive) — Hive is wrong for large binary blobs
- Add a storage health check on app startup: verify box integrity, rebuild from Supabase if corrupted
- Implement a single-tab write lock using BroadcastChannel API
- Set explicit storage budget: warn user at 80% capacity, block downloads at 95%
- **Never store audio files in Hive/IndexedDB** — use the Cache API or OPFS (Origin Private File System) for files > 1 MB

**Phase to address:** Phase 2 (offline architecture). Storage strategy must be decided before any download features are built.

---

### P3. Audio Playback Broken on Mobile Web Browsers

**What goes wrong:** `just_audio` on Flutter Web delegates to the HTML5 `<audio>` element. Mobile browsers (especially iOS Safari) block autoplay, kill background audio when the tab is backgrounded, and do not support Media Session API fully. The mini-player stops working when the user switches tabs.

**Why it happens:** Browser autoplay policies require a user gesture to start audio. iOS Safari suspends audio when the page is not visible. Background playback requires a Service Worker audio workaround or Media Session API — which just_audio's web implementation supports only partially.

**Warning signs:**
- Audio doesn't start on first tap (autoplay blocked — no gesture registered)
- Audio pauses when user locks phone or switches tabs
- Sleep timer fires but can't pause audio because JS is throttled in background
- Speed control (0.5x-2.0x) causes audible glitches on some browsers

**How to avoid:**
- Always start audio from a direct user gesture handler (onTap/onClick), never from a Future/Timer
- Implement Media Session API metadata (title, artwork, playback controls) for lock screen controls
- For background playback on iOS: use a silent audio ping trick or accept the limitation and document it
- Test speed changes across browsers — Safari has known issues with playbackRate > 1.5x on some codecs
- Encode audio as AAC in MP4 container (broadest browser compatibility), not OGG/OPUS
- Pre-load audio on user gesture (`player.setUrl()` in the same event loop as tap) to avoid second-tap-to-play
- Sleep timer: use a Web Worker for timing instead of `Future.delayed` (throttled in background tabs)

**Phase to address:** Phase 3 (audio player feature). Prototype on real iOS Safari early — do not trust Chrome DevTools emulation.

---

### P4. Supabase RLS Misconfiguration Leaking Pro Content

**What goes wrong:** A misconfigured RLS policy exposes full book content to free users. Common mistake: the policy checks `auth.uid()` for authentication but doesn't verify subscription status, so any logged-in user can query full content via the Supabase JS/Dart client or even raw PostgREST API.

**Why it happens:** Developers write RLS policies like `auth.uid() IS NOT NULL` (authenticated = access) instead of joining against subscription state. The admin panel CRUD operations need `service_role` bypass but developers accidentally use it in client code. Edge Functions using `service_role` key in client-accessible code.

**Warning signs:**
- Free user can access full summary text by manually crafting a Supabase query in browser DevTools
- Admin operations fail without `service_role` and developer adds it to the client
- No integration tests that verify free-user queries are actually blocked

**How to avoid:**
- RLS policies must check subscription status: `EXISTS (SELECT 1 FROM subscriptions WHERE user_id = auth.uid() AND status = 'active' AND expires_at > now())`
- Content table: split into `book_summaries_preview` (public) and `book_summaries_full` (RLS-protected) — or use a computed column approach
- **Never expose `service_role` key in client code** — it bypasses all RLS
- Admin operations: use Edge Functions with service_role on server side only, called via authenticated API
- Write RLS integration tests: create a test free-user, attempt to read pro content, assert denial
- Audit RLS policies with `supabase inspect db policies` regularly

**Phase to address:** Phase 1 (database schema design). RLS must be designed with the schema, not bolted on later.

---

### P5. YooMoney Webhook Reliability and Payment State Drift

**What goes wrong:** User pays via YooMoney, webhook fails to reach Supabase Edge Function (network issue, Edge Function cold start timeout, or YooMoney retry gives up). User is charged but never gets Pro access. Alternatively, user gets Pro access but the subscription record has wrong dates due to timezone handling (Moscow Time vs UTC).

**Why it happens:** YooMoney sends webhooks to a callback URL. Supabase Edge Functions have cold start times (200-800ms) and can timeout on the free tier. YooMoney retries webhooks only a few times. There's no reconciliation loop. Timezone: YooMoney sends timestamps in Moscow Time (UTC+3), and naive `DateTime.parse()` treats it as UTC.

**Warning signs:**
- Users complain "I paid but don't have access"
- Payment records in YooMoney dashboard don't match subscription records in Supabase
- Subscriptions expire at wrong times (3 hours off = timezone bug)
- Edge Function logs show 5xx errors on webhook endpoint

**How to avoid:**
- Implement idempotent webhook handler: use YooMoney's `payment_id` as idempotency key
- Store raw webhook payload before processing — allows manual recovery
- Build a reconciliation Edge Function (cron) that checks YooMoney API for payments not reflected in DB
- Handle timezone explicitly: parse YooMoney timestamps with `+03:00` offset, store as UTC in Postgres
- Implement client-side payment verification: after redirect back from YooMoney, poll an Edge Function that checks payment status via YooMoney API (don't rely solely on webhook)
- Set up alerting: if webhook errors > 0 in any 1-hour window, notify admin
- Handle YooMoney's test vs production environments carefully — test webhooks have different signing keys

**Phase to address:** Phase 4 (payments). Build webhook handler with reconciliation from day one.

---

### P6. PWA Service Worker Caching Creates Zombie App

**What goes wrong:** Users are stuck on an old version of the app forever. The service worker caches `main.dart.js` and `index.html` aggressively, and the update mechanism (`serviceWorkerVersion` in Flutter) fails silently. Users see stale content, broken layouts after backend API changes, or worse — a completely non-functional app that won't update.

**Why it happens:** Flutter's default service worker (`flutter_service_worker.js`) uses a cache-first strategy. If the update check fails (offline, CORS issue, CDN cache), the old version persists. Users don't know they need to hard-refresh. The "New version available" prompt is not shown, or users dismiss it.

**Warning signs:**
- Users report bugs that were fixed weeks ago
- API errors because client sends old request format
- `flutter_service_worker.js` is itself cached by the browser/CDN
- Analytics show a long tail of old app versions

**How to avoid:**
- Set `Cache-Control: no-cache` on `index.html`, `flutter_service_worker.js`, and `version.json` — CDN must not cache these
- Implement a `stale-while-revalidate` strategy: serve cached version but check for updates, then prompt user
- Build an in-app update banner: "New version available, tap to update" that calls `serviceWorkerRegistration.update()` and then `window.location.reload()`
- Version the API: backend must support at least N-1 client version
- Add a version check endpoint: app pings `/api/min-version` on startup, force-refreshes if below minimum
- Test the update flow explicitly: deploy v2, verify v1 users see the update prompt

**Phase to address:** Phase 1 (PWA setup). Service worker strategy must be configured at project inception.

---

### P7. Markdown Rendering XSS and Performance Degradation

**What goes wrong:** (a) Malicious content in Markdown (injected via admin panel compromise or copy-paste) executes JavaScript in the reader. (b) Long summaries (10,000+ words) with many headings, code blocks, and images cause the Markdown widget to rebuild slowly, making scrolling janky at 20-30 FPS.

**Why it happens:** `flutter_markdown` or `markdown_widget` packages render HTML under the hood on web. If the sanitizer is bypassed or misconfigured, raw HTML in Markdown (`<script>`, `<img onerror>`) executes. Performance: each Markdown block is a separate Flutter widget — 500 blocks = 500 widgets in the tree.

**Warning signs:**
- Scrolling FPS drops below 50 on mid-range devices in the reader
- Admin can paste `<img src=x onerror=alert(1)>` and it executes in reader
- Memory usage grows over 500 MB when reading long summaries

**How to avoid:**
- Sanitize Markdown on write (admin panel) AND on render (client): strip all raw HTML tags
- Use `markdown` package with `extensionSet: ExtensionSet.none` to disable HTML extension
- For long content: paginate the Markdown (split by chapters/headings), render only visible section
- Consider pre-rendering Markdown to a widget tree on isolate (web: Web Worker via `compute`)
- Lazy-load images in Markdown content with `CachedNetworkImage`
- Set a content length limit in admin panel (e.g., 50,000 characters per summary)

**Phase to address:** Phase 3 (reader feature). Sanitization rules in Phase 1 (schema/admin).

---

### P8. Offline-to-Online Sync Conflicts Corrupt User Progress

**What goes wrong:** User reads offline on two devices (laptop + phone PWA). Both update reading progress for the same book. When both come online, one overwrites the other. User loses bookmarks, highlights, or progress reverts to an earlier position.

**Why it happens:** Hive stores reading progress locally. On sync, a naive "last write wins" strategy based on timestamps is unreliable (device clocks differ). No conflict resolution strategy was designed upfront.

**Warning signs:**
- Users report "I lost my place" after using on a different device
- Progress bar jumps backward
- Highlights disappear

**How to avoid:**
- Use "furthest progress wins" for reading position (max of local and remote page/percent)
- For highlights/quotes: use CRDTs or append-only log with deduplication by content hash + position
- Add `updated_at` with server-side `now()` (not client timestamp) for conflict resolution
- Implement a sync queue: store offline mutations as an ordered log, replay on reconnect
- Show user a non-intrusive "Synced" indicator so they know when data is up to date
- For bookmarks: merge sets (union), never replace

**Phase to address:** Phase 2 (offline architecture) — design the sync protocol before building any synced feature.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Single `main.dart.js` bundle (no deferred loading) | Faster initial dev setup | Bundle > 8 MB, 5s+ load on 3G, fails the 5 MB target | Never for production; OK for first 2 weeks of prototyping |
| Storing audio in Hive/IndexedDB | Simple download implementation | Storage quota hit quickly (~50 MB limit effective on Safari), browser eviction | Never — use Cache API from the start |
| `service_role` key in Flutter client | Admin features "just work" | Complete RLS bypass, any user can access/modify all data | Never |
| Skipping font subsetting | All glyphs available for edge cases | +1-2 MB per font family, 4-8 MB total for 4 families | Early prototyping only; must subset before beta |
| Hardcoded Russian strings | Faster initial UI development | Impossible to add i18n later without touching every widget | OK for v1 if using `l10n` extraction tooling from start |
| No pagination in catalog API | Simpler Supabase queries | 100+ books = multi-second queries, excessive bandwidth | OK until 50 books; must add before that |
| Storing subscription status only in client state | Fewer DB queries | Users can manipulate local state to fake Pro access | Never — always verify server-side |
| Using `setState` instead of Riverpod for "quick" features | Faster to write | Inconsistent architecture, untestable, can't share state | Never if Riverpod is the chosen architecture |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Supabase Auth + Google OAuth | Using popup sign-in on mobile web (blocked by Safari) | Use redirect flow (`signInWithOAuth(redirectTo:)`), not popup. Test on iOS Safari specifically |
| Supabase Storage + Audio files | Serving audio via signed URLs that expire while user listens | Use long-lived signed URLs (24h) or public bucket with obfuscated paths; refresh URL before expiry |
| Supabase Edge Functions + YooMoney | Edge Function cold start causes webhook timeout (YooMoney expects < 5s response) | Return 200 immediately, process asynchronously. Or use a persistent webhook relay (e.g., Supabase Database Webhooks) |
| Hive + Riverpod | Opening Hive boxes inside providers (async init race condition) | Open all boxes in `main()` before `runApp()`, pass box references to providers |
| just_audio + Service Worker | Service Worker intercepts audio requests and returns cached HTML instead of audio file | Configure service worker to pass-through requests to Supabase Storage domain; don't cache audio fetch requests |
| GoRouter + Deep Links | PWA deep links (e.g., `/book/123`) hit index.html, router doesn't initialize in time | Ensure `flutter_service_worker.js` serves `index.html` for all navigation routes (SPA routing) |
| flutter_markdown + Custom Fonts | Reader custom fonts (Source Serif 4) not applied inside Markdown widgets | Pass `styleSheet` parameter to `Markdown` widget with explicit `textStyle` including fontFamily |
| Supabase Realtime + Offline | Realtime subscription reconnects flood server after user comes back online | Implement exponential backoff on reconnect; don't use Realtime for this project — use polling/pull-based sync |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| CanvasKit rendering on low-end mobile web | Blank screen for 3-5s, 200 MB+ memory usage, janky scrolling | Use HTML renderer for most screens; only CanvasKit if custom painting needed. Consider `--web-renderer auto` | Devices with < 3 GB RAM, Android WebView |
| Unoptimized cover images | Catalog loads 20+ full-resolution covers (500 KB each) | Use Supabase Storage image transforms: serve WebP thumbnails (150x200, quality 75), lazy-load below fold | Any page showing > 5 covers |
| Markdown widget rebuilds on scroll | Reader FPS drops to 20-30 during scroll | Use `ListView.builder` with chunked Markdown sections, not one giant `Markdown` widget | Summaries > 3000 words |
| Search without debounce/server-side pagination | Every keystroke fires a Supabase full-text query | Client: 300ms debounce. Server: `ts_rank` with `LIMIT 20` + cursor pagination | Catalog > 50 books |
| Riverpod providers that never dispose | Memory grows as user navigates between books | Use `autoDispose` on all content providers; verify with DevTools memory tab | After viewing 10+ books in one session |
| Loading all book data on summary page | Summary page fetches full text + audio URL + all highlights even when not reading | Fetch only metadata on summary page; lazy-load full text when reader opens | Always — especially on slow connections |
| Playfair Display font loading blocks render | Title text invisible (FOIT) for 1-2 seconds | Use `font-display: swap` in CSS, provide fallback system serif font | First visit, uncached |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| RLS policy checks `auth.uid() IS NOT NULL` instead of subscription status | Free users access all Pro content via direct API calls | Always join against `subscriptions` table in RLS policies for pro content |
| Supabase `anon` key exposed in JS bundle (normal) but used with overly permissive RLS | Anyone can read/write data they shouldn't | Design RLS assuming the `anon` key is public (it is). Lock down every table |
| YooMoney webhook not verifying signature | Attacker sends fake "payment successful" webhooks, gets free Pro | Verify `sha1_hash` in webhook payload using your `secret_key` on every request |
| Storing user JWT in `localStorage` | XSS attack steals token, attacker gets full account access | Supabase JS defaults to localStorage — this is standard, but sanitize ALL rendered content. Consider `httpOnly` cookies via Edge Function proxy for higher security |
| Admin panel accessible by role check only in UI | Attacker changes local state / calls admin API directly | RLS policy on admin tables: `auth.jwt() ->> 'role' = 'admin'`. Never rely on client-side role checks alone |
| Markdown content with `<script>` or `javascript:` URLs | XSS — attacker (or compromised admin) injects scripts into book content | Strip HTML on write AND render. Disallow raw HTML in Markdown parser config |
| Signed URLs for audio are too short-lived | URLs in cached/offline content expire, audio stops working | Use 24h+ expiry for signed URLs; refresh on app foreground. Or use public bucket with non-guessable paths |
| Edge Function secrets (YooMoney key) in client-accessible code | Payment system compromise | Store all secrets in Supabase Vault / Edge Function env vars. Never reference in Dart code |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No loading skeleton on catalog/home | Users see blank screen, assume app is broken | Implement warm-sand-colored skeleton shimmer matching the "Warm Brutalism" design |
| Paywall appears after user starts reading (at 20% mark) | User feels bait-and-switched, rage-quits | Show clear "Preview" badge before opening. Paywall at natural chapter break, not mid-sentence |
| Offline download with no progress indicator | User taps download, nothing visible happens for 30 seconds | Show download progress per-book, estimated size, cancel button |
| Audio player disappears on navigation | User navigates away from book page, audio stops, must find book again | Persistent mini-player at bottom across all screens (specified in requirements — but easy to break with GoRouter) |
| Search returns "no results" on partial Russian words | Russian morphology: user types "предприниматель" but content has "предпринимателей" | Use PostgreSQL `ts_vector` with Russian dictionary config (`to_tsvector('russian', ...)`) for stemmed search |
| Dark theme toggle doesn't affect reader | User switches to dark theme but reader stays cream-colored | Reader theme (Cream/Dark/White) must be separate from app theme but should default to matching the system theme |
| PWA install prompt never shown or shown at wrong time | User doesn't know they can "install" for better experience | Show custom install prompt after 2nd visit or after first book is saved to shelf |
| Offline mode with no clear indicator | User doesn't know they're offline, wonders why catalog is empty | Show persistent "Offline mode" banner, disable features that require network, show only downloaded content |

## "Looks Done But Isn't" Checklist

- [ ] **"Auth works"** — but did you test: email confirmation flow, password reset, Google OAuth on iOS Safari (redirect, not popup), token refresh after 1 hour, logout actually clears Hive data?
- [ ] **"Offline works"** — but did you test: opening the app while airplane mode is ON from the start (not just losing connection mid-use)? Does the Service Worker serve `index.html` for all routes?
- [ ] **"Audio plays"** — but did you test: on iOS Safari with the phone locked? After switching tabs for 5 minutes? With Bluetooth headphones connected/disconnected mid-playback? Sleep timer after 60 minutes?
- [ ] **"Search works"** — but did you test: Russian morphology (`книга` vs `книги` vs `книгу`)? Empty query? 100+ results? Search while offline (should search downloaded content)?
- [ ] **"Payment works"** — but did you test: user closes browser mid-payment and returns? Webhook arrives before redirect? Webhook never arrives? Duplicate webhook? Subscription renewal?
- [ ] **"Download works"** — but did you test: downloading 10 books simultaneously? Download interrupted by network loss? Safari storage eviction? Resume after failure?
- [ ] **"RLS is configured"** — but did you test: logged-out user querying API directly? Free user querying pro content endpoint? Non-admin user calling admin endpoints? With the actual `anon` key (not service_role)?
- [ ] **"PWA installs"** — but did you test: the update flow when v2 is deployed? What happens to cached data? Does the manifest have correct Russian-language `name` and `short_name`?
- [ ] **"Dark theme works"** — but did you test: system-level dark mode switch while app is open? All three reader themes in dark mode? Skeleton loaders in dark mode? Paywall bottom sheet in dark mode?
- [ ] **"Responsive layout"** — but did you test: 320px width (iPhone SE)? Landscape tablet? Desktop 1920px? Text at 200% browser zoom? With very long Russian book titles that wrap?

## Recovery Strategies

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Hive box corruption | App crash on box open, null reads for existing keys | Catch `HiveError`, delete box, re-sync from Supabase on next online session. Show "Restoring data..." to user |
| Service Worker serves stale app indefinitely | Version check endpoint returns mismatch | Force unregister service worker via Edge Function response header, reload page |
| YooMoney webhook lost | Reconciliation cron finds payment in YooMoney API but not in DB | Auto-create subscription record, notify admin for review |
| Audio signed URL expired in offline cache | HTTP 403 when playing cached audio | Detect 403, refresh signed URL if online; if offline, show "Re-download needed" message |
| User stuck in payment loop (charged but no access) | Support complaint or automated detection (payment exists, no subscription) | Manual Edge Function to grant access + refund flow documentation. Build admin tool for this |
| IndexedDB quota exceeded | Download fails silently or with generic error | Check `navigator.storage.estimate()` before download, show "Storage full" with cleanup suggestions |
| Supabase outage | All API calls fail | App detects network/API failure, switches to offline-only mode gracefully, queues writes |

## Pitfall-to-Phase Mapping

| Phase | Critical Pitfalls to Address | Action Items |
|-------|------------------------------|-------------|
| **Phase 1: Foundation & Architecture** | P1 (Bundle size), P4 (RLS), P6 (Service Worker) | Configure deferred imports, font subsetting, HTML renderer. Design RLS policies with schema. Set up service worker caching strategy with proper cache-control headers |
| **Phase 2: Offline Architecture** | P2 (Hive corruption), P8 (Sync conflicts) | Choose Cache API for audio/large files, Hive only for structured data. Design sync protocol with conflict resolution rules. Implement storage health checks |
| **Phase 3: Reader & Audio** | P3 (Audio playback), P7 (Markdown XSS/perf) | Test audio on real iOS Safari from day one. Implement Markdown sanitization. Chunk long content for rendering performance |
| **Phase 4: Payments** | P5 (YooMoney webhooks) | Build idempotent webhook handler, reconciliation cron, client-side payment verification. Handle Moscow timezone explicitly |
| **Phase 5: Polish & Launch** | All pitfalls — verification | Run "Looks Done But Isn't" checklist. Load test with 100+ books. Test all offline/online transitions. Verify RLS with real anon key |

## Sources

- Flutter Web rendering documentation: HTML vs CanvasKit trade-offs (flutter.dev)
- Hive package known issues on web: IndexedDB adapter limitations (github.com/hivedb/hive)
- just_audio web platform notes: browser autoplay and background playback (github.com/ryanheise/just_audio)
- Supabase RLS documentation: common policy patterns and anti-patterns (supabase.com/docs)
- YooMoney API documentation: webhook format, signing, retry policy (yookassa.ru/developers)
- Web Storage API: quota estimation, persistence, eviction (web.dev/storage-for-the-web)
- PWA service worker update patterns (web.dev/service-worker-lifecycle)
- PostgreSQL full-text search with Russian language config (postgresql.org/docs/current/textsearch)
- Safari Web Audio / Media Session API limitations (webkit.org/blog)

---
*Generated for BookSummary project. Review and update as implementation reveals new pitfalls.*
