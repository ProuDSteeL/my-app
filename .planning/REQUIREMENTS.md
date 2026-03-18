# Requirements: BookSummary

**Defined:** 2026-03-18
**Core Value:** Полноценный офлайн-доступ к качественным саммари нон-фикшн книг на русском языке по цене в 2–3 раза ниже конкурентов.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Авторизация

- [ ] **AUTH-01**: User can create account with email and password
- [ ] **AUTH-02**: User can log in with email and password and stay logged in across sessions
- [ ] **AUTH-03**: User can reset password via email link
- [ ] **AUTH-04**: User can log out from any page

### Каталог и навигация

- [ ] **CATL-01**: User can browse catalog of published book summaries as a grid of cards (cover + title + author + read time)
- [ ] **CATL-02**: User can search summaries by title, author, and tags with full-text search (debounce 300ms)
- [ ] **CATL-03**: User can filter catalog by categories using chips
- [ ] **CATL-04**: User can view search history (last 10 queries)
- [ ] **CATL-05**: User can view book detail page with cover, meta-info, tags, "About book", "Why read?", "About author"
- [ ] **CATL-06**: User can browse key ideas carousel (5–10 cards) on book detail page
- [ ] **CATL-07**: User can view "Continue reading" section on home screen with progress indicator
- [ ] **CATL-08**: User can browse category-based horizontal rows on home screen (business, psychology, etc.)
- [ ] **CATL-09**: User can view "New" and "Popular" sections on home screen
- [ ] **CATL-10**: User can swipe through promotional banner carousel on home screen
- [ ] **CATL-11**: User can view "Similar summaries" on book detail page
- [ ] **CATL-12**: User sees time-of-day greeting ("Доброе утро, {name}") on home screen

### Чтение

- [ ] **READ-01**: User can read summary text rendered from Markdown with custom styling
- [ ] **READ-02**: User can adjust reader settings: font size (14–28sp), theme (Cream/Dark/White), line height (1.4–2.0), font family (Source Serif 4 / Source Sans 3 / Literata)
- [ ] **READ-03**: User can navigate summary via table of contents (H2 headings) in a drawer
- [ ] **READ-04**: User's reading progress (scroll position, percent) is auto-saved and synced to Supabase
- [ ] **READ-05**: User sees a thin progress bar at top of reader with percentage
- [ ] **READ-06**: User can highlight text via long press and save quote with color selection
- [ ] **READ-07**: User can view all saved quotes grouped by book with color markers
- [ ] **READ-08**: User can export/share saved quotes

### Аудио

- [ ] **AUDI-01**: User can listen to audio summary with persistent mini-player above bottom navigation (64px)
- [ ] **AUDI-02**: User can expand mini-player to full-screen player (Hero animation) with large cover and blur background
- [ ] **AUDI-03**: User can control playback: play/pause, rewind 15s, forward 15s
- [ ] **AUDI-04**: User can adjust playback speed from 0.5x to 2.0x (step 0.25)
- [ ] **AUDI-05**: User can set sleep timer (15/30/45/60 min / end of chapter)
- [ ] **AUDI-06**: User's audio position is auto-saved and synced to Supabase
- [ ] **AUDI-07**: User can see current chapter name in full-screen player (if marked up)

### Офлайн

- [ ] **OFFL-01**: User can download text + audio of any summary for offline access (Pro only, Free for first 5)
- [ ] **OFFL-02**: User can view "My Downloads" screen with list of downloaded summaries (cover, title, size, date)
- [ ] **OFFL-03**: User sees download progress indicator and status icon (not downloaded / downloading / downloaded / error)
- [ ] **OFFL-04**: User can delete individual downloads via swipe (Dismissible)
- [ ] **OFFL-05**: User can see total download size and storage limit indicator
- [ ] **OFFL-06**: App auto-deletes oldest downloads when exceeding configurable limit (default 500 MB)
- [ ] **OFFL-07**: User can read downloaded summaries offline (text from Hive, audio from local files)
- [ ] **OFFL-08**: App shows "You are reading offline" banner when network is unavailable
- [ ] **OFFL-09**: App automatically syncs reading/listening progress when network restores
- [ ] **OFFL-10**: PWA Service Worker caches app shell and essential assets for offline launch

### Библиотека и профиль

- [ ] **LIBR-01**: User can add books to shelves: Favorite / Read / Want to Read (via heart/bookmark icons)
- [ ] **LIBR-02**: User can view books on each shelf as a grid of cards with tabs
- [ ] **LIBR-03**: User can view profile with avatar, name, email, subscription type
- [ ] **LIBR-04**: User can view reading statistics: books read, streak days, total reading time
- [ ] **LIBR-05**: User can switch app theme: light / dark / system
- [ ] **LIBR-06**: User can configure download storage limit in settings

### Монетизация

- [ ] **MONE-01**: Free users can read 5 full summaries; remaining summaries show 20% preview
- [ ] **MONE-02**: Free users cannot access audio playback or download features
- [ ] **MONE-03**: Paywall BottomSheet appears when user attempts to access Pro-only content with benefits list and plan options
- [ ] **MONE-04**: User can subscribe to Pro (monthly 200₽ or yearly 1200₽) via YooMoney redirect flow
- [ ] **MONE-05**: App verifies subscription status via Supabase (webhook from YooMoney Edge Function)
- [ ] **MONE-06**: User can view and manage subscription in profile (status, expiry, upgrade button)
- [ ] **MONE-07**: Pro yearly users get unlimited downloads; Pro monthly users get up to 20 downloads
- [ ] **MONE-08**: Free users can save up to 10 quotes; Pro users get unlimited

### Дизайн и UX

- [ ] **DSGN-01**: App uses "Warm Brutalism" design: terracotta palette (#C05621), Playfair Display headings, Source Sans 3 body, sharp edges (4px radius), borders instead of shadows
- [ ] **DSGN-02**: App supports dark theme with #1A1A2E background and #ED8936 primary
- [ ] **DSGN-03**: Bottom navigation with 5 tabs: Home, Search, Shelves, Downloads, Profile — using Phosphor Icons (thin/fill)
- [ ] **DSGN-04**: Skeleton loading uses warm sandy shimmer color (not gray)
- [ ] **DSGN-05**: Screen transitions use SharedAxisTransition; cards appear with FadeIn + SlideUp stagger
- [ ] **DSGN-06**: App respects system font scaling and provides semantic labels for accessibility (WCAG AA contrast)

### Админ-панель

- [ ] **ADMN-01**: Admin can view list of all books with filter by status (draft/published/archived) and search
- [ ] **ADMN-02**: Admin can create/edit book with: title, author(s), cover upload (jpg/png/webp ≤5MB), categories, tags, description, "Why read?" list, "About author", status
- [ ] **ADMN-03**: Admin can upload summary text (Markdown/TXT file or text editor input) with preview
- [ ] **ADMN-04**: Admin can upload audio file (MP3/M4A ≤100MB) to Supabase Storage with progress and cancel
- [ ] **ADMN-05**: Admin can manage key ideas: add/edit/delete/reorder (drag-and-drop) cards with preview
- [ ] **ADMN-06**: Admin can manage collections: create/edit with title, description, cover, book selection, ordering, "Featured" flag
- [ ] **ADMN-07**: Admin can manage categories: CRUD with icon selection (Phosphor) and display order
- [ ] **ADMN-08**: Read time is auto-calculated from word count (words / 200)
- [ ] **ADMN-09**: Admin panel is accessible only to users with role = 'admin' (route guard)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Авторизация

- **AUTH-05**: User can log in via Google OAuth
- **AUTH-06**: User can log in via Apple Sign-In (for iOS v2)

### Расширенные функции

- **ADVN-01**: User receives personalized recommendations based on reading history (Pro)
- **ADVN-02**: User's audio position syncs with reading position (cross-format sync)
- **ADVN-03**: User receives email digests about new summaries

### Мобильные приложения

- **MOBI-01**: App available as native iOS application via App Store
- **MOBI-02**: App available as native Android application via Google Play / RuStore
- **MOBI-03**: In-App Purchase integration for iOS/Android subscriptions

### Будущее

- **FUTR-01**: AI-powered personalized recommendations
- **FUTR-02**: Social features (share quotes to social media)
- **FUTR-03**: Gamification (achievements, streaks, levels)
- **FUTR-04**: Push notifications (new summaries, reading reminders)
- **FUTR-05**: A/B testing of paywall strategies
- **FUTR-06**: B2B / corporate plans

## Out of Scope

| Feature | Reason |
|---------|--------|
| AI-generated summaries | Quality control, legal risks, loss of author voice |
| Real-time chat / book clubs | High complexity, moderation burden, not core value |
| Video summaries | Storage/bandwidth costs, doesn't scale with single author |
| AI chatbot ("ask about book") | API cost, hallucinations, legal concerns |
| Aggressive push notifications | User annoyance, unreliable on PWA |
| Tests / quizzes after reading | Additional content per book, questionable value for adult audience |
| LMS / corporate integration | Different segment (B2B), requires separate sales team |
| Infographics (like Smart Reading) | Expensive to produce, defer to v2+ |
| Stripe payments | Not needed, YooMoney only for Russian individuals |
| In-App Purchase (Apple/Google) | Web/PWA only for v1 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | — | Pending |
| AUTH-02 | — | Pending |
| AUTH-03 | — | Pending |
| AUTH-04 | — | Pending |
| CATL-01 | — | Pending |
| CATL-02 | — | Pending |
| CATL-03 | — | Pending |
| CATL-04 | — | Pending |
| CATL-05 | — | Pending |
| CATL-06 | — | Pending |
| CATL-07 | — | Pending |
| CATL-08 | — | Pending |
| CATL-09 | — | Pending |
| CATL-10 | — | Pending |
| CATL-11 | — | Pending |
| CATL-12 | — | Pending |
| READ-01 | — | Pending |
| READ-02 | — | Pending |
| READ-03 | — | Pending |
| READ-04 | — | Pending |
| READ-05 | — | Pending |
| READ-06 | — | Pending |
| READ-07 | — | Pending |
| READ-08 | — | Pending |
| AUDI-01 | — | Pending |
| AUDI-02 | — | Pending |
| AUDI-03 | — | Pending |
| AUDI-04 | — | Pending |
| AUDI-05 | — | Pending |
| AUDI-06 | — | Pending |
| AUDI-07 | — | Pending |
| OFFL-01 | — | Pending |
| OFFL-02 | — | Pending |
| OFFL-03 | — | Pending |
| OFFL-04 | — | Pending |
| OFFL-05 | — | Pending |
| OFFL-06 | — | Pending |
| OFFL-07 | — | Pending |
| OFFL-08 | — | Pending |
| OFFL-09 | — | Pending |
| OFFL-10 | — | Pending |
| LIBR-01 | — | Pending |
| LIBR-02 | — | Pending |
| LIBR-03 | — | Pending |
| LIBR-04 | — | Pending |
| LIBR-05 | — | Pending |
| LIBR-06 | — | Pending |
| MONE-01 | — | Pending |
| MONE-02 | — | Pending |
| MONE-03 | — | Pending |
| MONE-04 | — | Pending |
| MONE-05 | — | Pending |
| MONE-06 | — | Pending |
| MONE-07 | — | Pending |
| MONE-08 | — | Pending |
| DSGN-01 | — | Pending |
| DSGN-02 | — | Pending |
| DSGN-03 | — | Pending |
| DSGN-04 | — | Pending |
| DSGN-05 | — | Pending |
| DSGN-06 | — | Pending |
| ADMN-01 | — | Pending |
| ADMN-02 | — | Pending |
| ADMN-03 | — | Pending |
| ADMN-04 | — | Pending |
| ADMN-05 | — | Pending |
| ADMN-06 | — | Pending |
| ADMN-07 | — | Pending |
| ADMN-08 | — | Pending |
| ADMN-09 | — | Pending |

**Coverage:**
- v1 requirements: 56 total
- Mapped to phases: 0
- Unmapped: 56 ⚠️

---
*Requirements defined: 2026-03-18*
*Last updated: 2026-03-18 after initial definition*
