# Roadmap: BookSummary

**Created:** 2026-03-18
**Phases:** 8
**Requirements:** 70
**Granularity:** Standard

## Phase Overview

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Foundation & Design System | Establish project skeleton, theme system, Supabase schema, and build pipeline | DSGN-01, DSGN-02, DSGN-03, DSGN-04, DSGN-05, DSGN-06 | 4 |
| 2 | Authentication & Navigation | Users can register, log in, and navigate the app shell | AUTH-01, AUTH-02, AUTH-03, AUTH-04 | 3 |
| 3 | Catalog & Home Screen | Users can browse, search, and discover book summaries | CATL-01, CATL-02, CATL-03, CATL-04, CATL-05, CATL-06, CATL-07, CATL-08, CATL-09, CATL-10, CATL-11, CATL-12 | 5 |
| 4 | Reader & Audio Player | Users can read summaries and listen to audio with full controls | READ-01, READ-02, READ-03, READ-04, READ-05, READ-06, READ-07, READ-08, AUDI-01, AUDI-02, AUDI-03, AUDI-04, AUDI-05, AUDI-06, AUDI-07 | 5 |
| 5 | Monetization & Payments | Freemium model enforced, Pro subscription purchasable via YooMoney | MONE-01, MONE-02, MONE-03, MONE-04, MONE-05, MONE-06, MONE-07, MONE-08 | 4 |
| 6 | Offline & Downloads | Pro users can download and access content offline with full sync | OFFL-01, OFFL-02, OFFL-03, OFFL-04, OFFL-05, OFFL-06, OFFL-07, OFFL-08, OFFL-09, OFFL-10 | 5 |
| 7 | Library, Profile & User Features | Users can organize books on shelves, view stats, and manage settings | LIBR-01, LIBR-02, LIBR-03, LIBR-04, LIBR-05, LIBR-06 | 4 |
| 8 | Admin Panel | Author can manage all content through an in-app admin interface | ADMN-01, ADMN-02, ADMN-03, ADMN-04, ADMN-05, ADMN-06, ADMN-07, ADMN-08, ADMN-09 | 4 |

## Phase 1: Foundation & Design System
**Goal:** Establish project skeleton with Flutter Web/PWA configuration, implement the "Warm Brutalism" design system (theme, typography, components), set up Supabase schema with RLS, configure Hive CE, and establish build pipeline with deferred imports and font subsetting.
**Requirements:** DSGN-01, DSGN-02, DSGN-03, DSGN-04, DSGN-05, DSGN-06
**Dependencies:** None

### Success Criteria
1. User sees the app rendered with terracotta palette, Playfair Display headings, Source Sans 3 body text, and sharp-edged card components matching "Warm Brutalism" spec
2. User can switch between light and dark themes and sees correct palette for each (cream background vs. dark graphite)
3. Bottom navigation bar with 5 tabs (Home, Search, Shelves, Downloads, Profile) renders with Phosphor Icons and responds to taps
4. Loading states display warm sandy shimmer skeletons instead of gray placeholders, and screen transitions use SharedAxisTransition with FadeIn + SlideUp card animations

## Phase 2: Authentication & Navigation
**Goal:** Enable user registration, login, password reset, and logout. Set up GoRouter with auth guards and the persistent app shell (Scaffold with BottomNavigation and mini-player slot).
**Requirements:** AUTH-01, AUTH-02, AUTH-03, AUTH-04
**Dependencies:** Phase 1

### Success Criteria
1. User can create an account with email/password, log in, and remain authenticated across browser sessions (persistent JWT)
2. User can request a password reset email, follow the link, and set a new password successfully
3. User can log out from any screen and is redirected to the login page, with all subsequent navigation blocked by the auth guard

## Phase 3: Catalog & Home Screen
**Goal:** Deliver the home screen with personalized greeting, banner carousel, "Continue reading", category rows, and new/popular sections. Build the catalog with full-text search, category filters, and book detail pages.
**Requirements:** CATL-01, CATL-02, CATL-03, CATL-04, CATL-05, CATL-06, CATL-07, CATL-08, CATL-09, CATL-10, CATL-11, CATL-12
**Dependencies:** Phase 2

### Success Criteria
1. User sees time-of-day greeting on home screen and can scroll through banner carousel, "Continue reading" section, category-based horizontal rows, and "New"/"Popular" sections
2. User can browse catalog as a grid of cards (cover, title, author, read time), search by title/author/tags with 300ms debounce, and filter by category chips
3. User can view search history (last 10 queries) and select a previous query to re-execute the search
4. User can open a book detail page showing cover, meta-info, tags, "About book", "Why read?", "About author", key ideas carousel, and "Similar summaries"
5. Catalog loads with pagination and displays skeleton shimmer during loading, without loading all books at once

## Phase 4: Reader & Audio Player
**Goal:** Build the Markdown reader with customizable settings, reading progress tracking, text highlighting, and quotes management. Implement the audio player with persistent mini-player, full-screen mode, speed control, sleep timer, and position sync.
**Requirements:** READ-01, READ-02, READ-03, READ-04, READ-05, READ-06, READ-07, READ-08, AUDI-01, AUDI-02, AUDI-03, AUDI-04, AUDI-05, AUDI-06, AUDI-07
**Dependencies:** Phase 3

### Success Criteria
1. User can read a summary rendered from Markdown with custom styling, adjust font size/theme/line height/font family, and navigate via table of contents drawer
2. User's reading progress (scroll position and percentage) is auto-saved, displayed as a thin progress bar at top, and synced to Supabase across sessions
3. User can highlight text via long press, save quotes with color selection, view all quotes grouped by book, and export/share them
4. User can play audio with persistent mini-player (above bottom nav), expand to full-screen player, control playback (play/pause, rewind/forward 15s), adjust speed (0.5x-2.0x), and set sleep timer
5. User's audio playback position is auto-saved and synced to Supabase, and the full-screen player shows the current chapter name

## Phase 5: Monetization & Payments
**Goal:** Enforce freemium content gating (5 free summaries, 20% preview for rest), block audio/downloads for free users, implement paywall BottomSheet, and integrate YooMoney subscription flow with webhook verification.
**Requirements:** MONE-01, MONE-02, MONE-03, MONE-04, MONE-05, MONE-06, MONE-07, MONE-08
**Dependencies:** Phase 4

### Success Criteria
1. Free user can read 5 full summaries; attempting to open a 6th shows only 20% preview and triggers paywall BottomSheet with benefits list and plan options
2. Free user is blocked from audio playback and download features with paywall prompt; Pro user has unrestricted access to both
3. User can complete Pro subscription purchase (monthly 200 RUB or yearly 1200 RUB) via YooMoney redirect flow and sees subscription activated within 30 seconds of payment
4. User can view subscription status and expiry in profile, and the app correctly enforces download limits (20 for monthly, unlimited for yearly) and quote limits (10 for free, unlimited for Pro)

## Phase 6: Offline & Downloads
**Goal:** Enable downloading of text and audio for offline access, build the downloads management screen, implement storage limits and auto-cleanup, deliver offline reading/listening, and set up PWA Service Worker for app shell caching and network sync.
**Requirements:** OFFL-01, OFFL-02, OFFL-03, OFFL-04, OFFL-05, OFFL-06, OFFL-07, OFFL-08, OFFL-09, OFFL-10
**Dependencies:** Phase 5

### Success Criteria
1. Pro user can download a summary (text + audio) and see download progress indicator; downloaded summaries appear in "My Downloads" screen with cover, title, size, and date
2. User can read downloaded summaries and listen to audio while completely offline, with an "offline" banner visible when network is unavailable
3. User can delete individual downloads via swipe, view total storage used vs. limit, and the app auto-deletes oldest downloads when exceeding the configured limit (default 500 MB)
4. Reading and listening progress made offline is automatically synced to Supabase when network restores
5. PWA Service Worker caches app shell and essential assets so the app launches offline, and handles cache updates gracefully

## Phase 7: Library, Profile & User Features
**Goal:** Build user shelves (Favorite/Read/Want to Read), profile screen with avatar and reading statistics, app theme toggle, and download storage settings.
**Requirements:** LIBR-01, LIBR-02, LIBR-03, LIBR-04, LIBR-05, LIBR-06
**Dependencies:** Phase 3

### Success Criteria
1. User can add books to shelves (Favorite / Read / Want to Read) via heart/bookmark icons on book cards and detail pages
2. User can view each shelf as a grid of cards with tab navigation between shelves
3. User can view their profile (avatar, name, email, subscription type) and reading statistics (books read, streak days, total reading time)
4. User can switch app theme (light/dark/system) in settings and configure download storage limit

## Phase 8: Admin Panel
**Goal:** Build the admin interface for managing all content: book CRUD with file uploads, key idea management, collection and category management, with role-based access control.
**Requirements:** ADMN-01, ADMN-02, ADMN-03, ADMN-04, ADMN-05, ADMN-06, ADMN-07, ADMN-08, ADMN-09
**Dependencies:** Phase 3

### Success Criteria
1. Admin can view a list of all books with status filter (draft/published/archived) and search, and non-admin users are blocked from accessing admin routes
2. Admin can create and edit a book with all metadata (title, authors, cover upload, categories, tags, descriptions, status) and see auto-calculated read time based on word count
3. Admin can upload summary text (Markdown/TXT or editor input) with preview, and upload audio files (MP3/M4A up to 100 MB) to Supabase Storage with progress and cancel
4. Admin can manage key ideas (add/edit/delete/reorder with drag-and-drop), collections (create/edit with title, description, cover, book selection, ordering, "Featured" flag), and categories (CRUD with Phosphor icon selection and display order)

## Requirement Coverage
- Total v1 requirements: 70
- Mapped: 70
- Unmapped: 0 ✓

---
*Created: 2026-03-18*
