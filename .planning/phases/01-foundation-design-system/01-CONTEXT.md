# Phase 1: Foundation & Design System - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish Flutter Web/PWA project skeleton with "Warm Brutalism" design system (theme, typography, reusable components), configure Supabase cloud instance with PostgreSQL schema and RLS, set up Hive CE for offline storage, and establish build pipeline. This phase produces a running app shell with bottom navigation, theme switching, and skeleton loading — no content or business logic.

</domain>

<decisions>
## Implementation Decisions

### Flutter Web Renderer
- Use **CanvasKit** renderer (not HTML, not Wasm) — pixel-perfect rendering required for Warm Brutalism design
- Accept the ~1.5MB base overhead as acceptable within the 5MB gzipped budget
- Wasm has known Safari/Firefox bugs as of 2026 — avoid

### Font Loading Strategy
- **Subset** all 4 font families to Cyrillic + Latin character sets only
- **Defer** Source Serif 4 (reader-only, Phase 4) and JetBrains Mono (timers/counters) — load on demand
- Load Playfair Display and Source Sans 3 upfront (critical for Warm Brutalism first paint)
- Use google_fonts package with local asset fallback

### Service Worker
- Set up **custom Workbox** service worker from Phase 1 (not default Flutter SW)
- Precache app shell and critical assets
- No migration needed when Phase 6 (Offline) adds content caching — extend the existing Workbox config
- Register SW in `web/index.html`

### PWA Manifest
- App name: "BookSummary" (placeholder — will be updated when final branding is decided)
- Theme color: `#C05621` (terracotta primary)
- Background color: `#FFFAF0` (cream)
- Display: standalone
- Name is easily changeable later — just a string in manifest.json

### Supabase Setup
- **Supabase Cloud** (supabase.com) — free tier, managed infrastructure
- **Region: EU (Frankfurt)** — closest to Russian audience (~30-50ms)
- No self-hosting, no local Supabase CLI for dev (cloud only for simplicity)
- Create all tables from the spec's SQL schema in Phase 1 (profiles, books, summaries, key_ideas, user_progress, user_shelves, user_highlights, user_downloads, user_ratings, collections, categories, payments)
- Apply all RLS policies from spec

### Database Migrations
- Use **Supabase native migrations** (`supabase migration new/up`)
- Migrations stored in `supabase/migrations/` directory in repo
- Initial schema as first migration

### Test Data Seeding
- **SQL seed scripts** checked into repo (`supabase/seed.sql`)
- 5-10 fake books with placeholder covers (Supabase Storage)
- Sample categories (бизнес, психология, саморазвитие, продуктивность, здоровье)
- Test admin user + test regular user
- Run via `supabase db reset` for clean dev environment

### Claude's Discretion
- Component library scope — how many reusable widgets to build in Phase 1 vs build-as-needed
- Exact Workbox caching strategies (precache vs runtime cache split)
- Supabase Storage bucket configuration details (covers, audio, summaries)
- CI/CD pipeline specifics (GitHub Actions config)
- Exact file structure under `lib/` (use spec's structure as starting point, adjust as needed)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design System
- `.planning/PROJECT.md` §Context > Дизайн-концепция — Full color palette (light + dark), typography scale, component specs (cards, buttons, chips, nav, reader), icon set, animations
- `.planning/research/STACK.md` — Validated Flutter package versions, Hive CE migration note, flutter_markdown_plus replacement
- `.planning/research/PITFALLS.md` §Pitfall 1 — Bundle size explosion prevention strategies

### Database Schema
- `.planning/PROJECT.md` §Context — References original spec with full SQL CREATE TABLE statements, RLS policies
- `.planning/research/ARCHITECTURE.md` — Recommended project structure, repository pattern, offline-first data flow

### PWA Configuration
- `.planning/research/PITFALLS.md` §Pitfall 6 — PWA zombie app prevention (Workbox update flow)
- `.planning/research/STACK.md` §Supporting Libraries — Workbox configuration recommendations

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None — pure greenfield. Only `README.md` exists.

### Established Patterns
- None — all patterns will be established in this phase.

### Integration Points
- Supabase Cloud instance (to be created)
- Google Fonts CDN (for font loading)
- Workbox CDN or npm (for Service Worker)

</code_context>

<specifics>
## Specific Ideas

- Design spec is extremely detailed — exact HEX codes, font sizes, border radius values, animation names are all specified in PROJECT.md
- Phosphor Icons (phosphor_flutter package) — thin style (1.5px stroke) for inactive, fill for active
- Skeleton shimmer must use warm sandy color (`#FEFCF3`-ish), not standard gray
- Card components: 4px border radius, 1px solid `#E2D8C3` border, translate on press (not elevation)
- Buttons: flat, no shadows. Primary filled terracotta (6px radius), secondary outline

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-foundation-design-system*
*Context gathered: 2026-03-18*
