---
phase: 1
plan: 2
name: supabase-schema-and-migrations
wave: 1
depends_on: []
requirements: [DSGN-01]
files_modified:
  - supabase/config.toml
  - supabase/migrations/20260318000001_initial_schema.sql
  - supabase/migrations/20260318000002_rls_policies.sql
  - supabase/migrations/20260318000003_storage_buckets.sql
  - supabase/seed.sql
autonomous: true
---

# Plan 01-2: Supabase Schema and Migrations

## Objective
Set up the Supabase project structure with the full PostgreSQL schema (all tables, indexes, triggers, full-text search), RLS policies for every table, storage bucket configuration, and seed data for development.

## Tasks

<task id="1">
<title>Initialize Supabase project structure</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §4 (Supabase setup)
- /root/my-app/.planning/phases/01-foundation-design-system/01-CONTEXT.md (Supabase decisions)
</read_first>
<action>
Run `supabase init` in the project root `/root/my-app` if the supabase/ directory does not exist. This creates:
- supabase/config.toml
- supabase/migrations/
- supabase/functions/
- supabase/seed.sql

If `supabase` CLI is not installed, install it first: `npm install -g supabase`.

Verify the supabase/config.toml exists and contains the project configuration.
</action>
<acceptance_criteria>
- supabase/config.toml file exists
- supabase/migrations/ directory exists
- supabase/seed.sql file exists
</acceptance_criteria>
</task>

<task id="2">
<title>Create initial schema migration with all tables</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §4 (full SQL schema)
- /root/my-app/.planning/research/PITFALLS.md §P4 (RLS design with schema)
</read_first>
<action>
Create file `supabase/migrations/20260318000001_initial_schema.sql` with the complete schema:

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Profiles (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Categories
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  icon TEXT,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Books
CREATE TABLE public.books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  cover_url TEXT,
  description TEXT,
  why_read TEXT,
  about_author TEXT,
  read_time_minutes INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Book-Category many-to-many
CREATE TABLE public.book_categories (
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, category_id)
);

-- Summaries (Markdown text content)
CREATE TABLE public.summaries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id UUID NOT NULL UNIQUE REFERENCES public.books(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  word_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Key Ideas (carousel cards on book detail)
CREATE TABLE public.key_ideas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- User reading progress
CREATE TABLE public.user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  scroll_position DOUBLE PRECISION DEFAULT 0,
  progress_percent DOUBLE PRECISION DEFAULT 0,
  audio_position_ms BIGINT DEFAULT 0,
  last_read_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, book_id)
);

-- User shelves (favorites, read, want to read)
CREATE TABLE public.user_shelves (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  shelf_type TEXT NOT NULL CHECK (shelf_type IN ('favorite', 'read', 'want_to_read')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, book_id, shelf_type)
);

-- User highlights / quotes
CREATE TABLE public.user_highlights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT 'yellow',
  position_start INT,
  position_end INT,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- User downloads tracking
CREATE TABLE public.user_downloads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  file_size_bytes BIGINT NOT NULL DEFAULT 0,
  downloaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, book_id)
);

-- User ratings
CREATE TABLE public.user_ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, book_id)
);

-- Collections (curated groups of books)
CREATE TABLE public.collections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  cover_url TEXT,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Collection-Book many-to-many
CREATE TABLE public.collection_books (
  collection_id UUID NOT NULL REFERENCES public.collections(id) ON DELETE CASCADE,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  display_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (collection_id, book_id)
);

-- Subscriptions (Pro plans)
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tier TEXT NOT NULL CHECK (tier IN ('free', 'pro_monthly', 'pro_yearly')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ,
  yoomoney_payment_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Payments log
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  yoomoney_payment_id TEXT UNIQUE,
  amount_rub NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  raw_webhook JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_books_status ON public.books(status);
CREATE INDEX idx_books_created ON public.books(created_at DESC);
CREATE INDEX idx_book_categories_category ON public.book_categories(category_id);
CREATE INDEX idx_user_progress_user ON public.user_progress(user_id);
CREATE INDEX idx_user_shelves_user ON public.user_shelves(user_id);
CREATE INDEX idx_user_highlights_user_book ON public.user_highlights(user_id, book_id);
CREATE INDEX idx_subscriptions_user ON public.subscriptions(user_id);

-- Full-text search index with Russian dictionary
ALTER TABLE public.books ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('russian', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('russian', coalesce(author, '')), 'B') ||
    setweight(to_tsvector('russian', coalesce(array_to_string(tags, ' '), '')), 'C')
  ) STORED;

CREATE INDEX idx_books_search ON public.books USING gin(search_vector);

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER books_updated_at BEFORE UPDATE ON public.books
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER summaries_updated_at BEFORE UPDATE ON public.summaries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER user_progress_updated_at BEFORE UPDATE ON public.user_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER subscriptions_updated_at BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create profile on new auth user
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'display_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```
</action>
<acceptance_criteria>
- supabase/migrations/20260318000001_initial_schema.sql exists
- File contains `CREATE TABLE public.profiles`
- File contains `CREATE TABLE public.books`
- File contains `CREATE TABLE public.categories`
- File contains `CREATE TABLE public.summaries`
- File contains `CREATE TABLE public.key_ideas`
- File contains `CREATE TABLE public.user_progress`
- File contains `CREATE TABLE public.user_shelves`
- File contains `CREATE TABLE public.user_highlights`
- File contains `CREATE TABLE public.user_downloads`
- File contains `CREATE TABLE public.subscriptions`
- File contains `CREATE TABLE public.payments`
- File contains `CREATE TABLE public.collections`
- File contains `search_vector tsvector`
- File contains `to_tsvector('russian'`
- File contains `FUNCTION handle_new_user()`
- File contains `SECURITY DEFINER`
- File contains `CREATE INDEX idx_books_search`
</acceptance_criteria>
</task>

<task id="3">
<title>Create RLS policies migration</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §4 (RLS policies)
- /root/my-app/.planning/research/PITFALLS.md §P4 (RLS misconfiguration risks)
</read_first>
<action>
Create file `supabase/migrations/20260318000002_rls_policies.sql` with RLS enabled on every table and policies for each:

```sql
-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.key_ideas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_shelves ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collection_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Categories (public read, admin manage)
CREATE POLICY "Anyone can read categories"
  ON public.categories FOR SELECT USING (true);
CREATE POLICY "Admins can manage categories"
  ON public.categories FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Books (published = public read, admin manage all)
CREATE POLICY "Anyone can read published books"
  ON public.books FOR SELECT USING (status = 'published');
CREATE POLICY "Admins can manage all books"
  ON public.books FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Book categories (public read)
CREATE POLICY "Anyone can read book categories"
  ON public.book_categories FOR SELECT USING (true);

-- Summaries (authenticated read)
CREATE POLICY "Authenticated users can read summaries"
  ON public.summaries FOR SELECT USING (auth.uid() IS NOT NULL);

-- Key ideas (public read for published books)
CREATE POLICY "Anyone can read key ideas"
  ON public.key_ideas FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.books WHERE id = book_id AND status = 'published'));

-- User progress (own data only)
CREATE POLICY "Users manage own progress"
  ON public.user_progress FOR ALL USING (auth.uid() = user_id);

-- User shelves (own data only)
CREATE POLICY "Users manage own shelves"
  ON public.user_shelves FOR ALL USING (auth.uid() = user_id);

-- User highlights (own data only)
CREATE POLICY "Users manage own highlights"
  ON public.user_highlights FOR ALL USING (auth.uid() = user_id);

-- User downloads (own data only)
CREATE POLICY "Users manage own downloads"
  ON public.user_downloads FOR ALL USING (auth.uid() = user_id);

-- User ratings (own data only)
CREATE POLICY "Users manage own ratings"
  ON public.user_ratings FOR ALL USING (auth.uid() = user_id);

-- Collections (public read)
CREATE POLICY "Anyone can read collections"
  ON public.collections FOR SELECT USING (true);

-- Collection books (public read)
CREATE POLICY "Anyone can read collection books"
  ON public.collection_books FOR SELECT USING (true);

-- Subscriptions (own data only)
CREATE POLICY "Users can read own subscription"
  ON public.subscriptions FOR SELECT USING (auth.uid() = user_id);

-- Payments (own data only)
CREATE POLICY "Users can read own payments"
  ON public.payments FOR SELECT USING (auth.uid() = user_id);

-- Admin policies for content management tables
CREATE POLICY "Admins can manage summaries"
  ON public.summaries FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins can manage key ideas"
  ON public.key_ideas FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins can manage book categories"
  ON public.book_categories FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins can manage collections"
  ON public.collections FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins can manage collection books"
  ON public.collection_books FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
```
</action>
<acceptance_criteria>
- supabase/migrations/20260318000002_rls_policies.sql exists
- File contains `ENABLE ROW LEVEL SECURITY` for all 15 tables
- File contains `role = 'admin'` (admin checks, not just auth.uid() IS NOT NULL)
- File contains `status = 'published'` (books policy checks publication status)
- File contains `auth.uid() = user_id` (user data policies)
- File contains `auth.uid() = id` (profiles policy)
- grep for ENABLE ROW LEVEL SECURITY returns 15 lines
</acceptance_criteria>
</task>

<task id="4">
<title>Create storage buckets migration</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §4 (storage buckets)
</read_first>
<action>
Create file `supabase/migrations/20260318000003_storage_buckets.sql`:

```sql
-- Book covers (public)
INSERT INTO storage.buckets (id, name, public)
VALUES ('covers', 'covers', true);

-- Audio files (authenticated access)
INSERT INTO storage.buckets (id, name, public)
VALUES ('audio', 'audio', false);

-- Summary files (authenticated access)
INSERT INTO storage.buckets (id, name, public)
VALUES ('summaries', 'summaries', false);

-- Storage policies
CREATE POLICY "Public cover access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'covers');

CREATE POLICY "Authenticated audio access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'audio' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated summaries access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'summaries' AND auth.role() = 'authenticated');

CREATE POLICY "Admin upload to any bucket"
  ON storage.objects FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admin delete from any bucket"
  ON storage.objects FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```
</action>
<acceptance_criteria>
- supabase/migrations/20260318000003_storage_buckets.sql exists
- File contains `'covers', 'covers', true` (public bucket)
- File contains `'audio', 'audio', false` (private bucket)
- File contains `'summaries', 'summaries', false` (private bucket)
- File contains `Admin upload to any bucket`
- File contains `role = 'admin'`
</acceptance_criteria>
</task>

<task id="5">
<title>Create seed data for development</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §4 (seed data)
- /root/my-app/.planning/phases/01-foundation-design-system/01-CONTEXT.md (test data seeding decisions)
</read_first>
<action>
Create file `supabase/seed.sql` with development seed data including 5 categories and 5+ sample books:

```sql
-- Categories
INSERT INTO public.categories (id, name, slug, icon, display_order) VALUES
  (uuid_generate_v4(), 'Бизнес', 'business', 'briefcase', 1),
  (uuid_generate_v4(), 'Психология', 'psychology', 'brain', 2),
  (uuid_generate_v4(), 'Саморазвитие', 'self-development', 'rocket', 3),
  (uuid_generate_v4(), 'Продуктивность', 'productivity', 'timer', 4),
  (uuid_generate_v4(), 'Здоровье', 'health', 'heartbeat', 5);

-- Sample books
INSERT INTO public.books (id, title, author, description, why_read, about_author, read_time_minutes, status, tags)
VALUES
  (uuid_generate_v4(), 'Атомные привычки', 'Джеймс Клир',
   'Маленькие изменения, которые приводят к замечательным результатам.',
   'Чтобы научиться формировать полезные привычки и избавляться от вредных.',
   'Джеймс Клир — автор и спикер, специализирующийся на привычках и принятии решений.',
   15, 'published', ARRAY['привычки', 'продуктивность', 'саморазвитие']),
  (uuid_generate_v4(), 'Думай медленно... решай быстро', 'Даниэль Канеман',
   'Книга о двух системах мышления и когнитивных искажениях.',
   'Чтобы понять, как мы принимаем решения и как избежать ошибок мышления.',
   'Даниэль Канеман — нобелевский лауреат по экономике.',
   20, 'published', ARRAY['психология', 'мышление', 'решения']),
  (uuid_generate_v4(), '7 навыков высокоэффективных людей', 'Стивен Кови',
   'Классика саморазвития о принципах эффективности.',
   'Чтобы развить ключевые навыки лидерства и личной эффективности.',
   'Стивен Кови — автор бестселлеров по менеджменту и лидерству.',
   18, 'published', ARRAY['лидерство', 'менеджмент', 'эффективность']),
  (uuid_generate_v4(), 'Начни с почему', 'Саймон Синек',
   'Как великие лидеры вдохновляют действовать.',
   'Чтобы найти своё "почему" и вдохновлять окружающих.',
   'Саймон Синек — мотивационный спикер и автор книг о лидерстве.',
   12, 'published', ARRAY['лидерство', 'мотивация', 'бизнес']),
  (uuid_generate_v4(), 'Тонкое искусство пофигизма', 'Марк Мэнсон',
   'Парадоксальный подход к тому, как жить хорошо.',
   'Чтобы перестать переживать о вещах, которые не имеют значения.',
   'Марк Мэнсон — блогер и автор книг о саморазвитии.',
   14, 'published', ARRAY['психология', 'саморазвитие', 'философия']),
  (uuid_generate_v4(), 'Не работайте с мудаками', 'Роберт Саттон',
   'Как создать цивилизованную рабочую среду и выжить в нецивилизованной.',
   'Чтобы научиться распознавать токсичных коллег и защищать свою продуктивность.',
   'Роберт Саттон — профессор Стэнфордского университета.',
   10, 'draft', ARRAY['бизнес', 'менеджмент', 'коммуникация']);

-- Link books to categories
INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = 'Атомные привычки' AND c.slug = 'self-development';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = 'Атомные привычки' AND c.slug = 'productivity';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = 'Думай медленно... решай быстро' AND c.slug = 'psychology';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = '7 навыков высокоэффективных людей' AND c.slug = 'self-development';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = '7 навыков высокоэффективных людей' AND c.slug = 'business';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = 'Начни с почему' AND c.slug = 'business';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = 'Тонкое искусство пофигизма' AND c.slug = 'psychology';

INSERT INTO public.book_categories (book_id, category_id)
SELECT b.id, c.id FROM public.books b, public.categories c
WHERE b.title = 'Тонкое искусство пофигизма' AND c.slug = 'self-development';
```

Include a comment at the top of seed.sql:
```sql
-- Seed data for BookSummary development
-- Run with: supabase db reset
-- Note: Admin user must be created via Supabase Auth first, then:
-- UPDATE public.profiles SET role = 'admin' WHERE id = '<admin-user-uuid>';
```
</action>
<acceptance_criteria>
- supabase/seed.sql contains `INSERT INTO public.categories`
- supabase/seed.sql contains `'Бизнес'` and `'Психология'` and `'Саморазвитие'` and `'Продуктивность'` and `'Здоровье'`
- supabase/seed.sql contains at least 5 INSERT INTO public.books statements (5 book titles)
- supabase/seed.sql contains `'Атомные привычки'`
- supabase/seed.sql contains `INSERT INTO public.book_categories`
- supabase/seed.sql contains `role = 'admin'` in a comment about admin user setup
- supabase/seed.sql contains one book with `status = 'draft'` (for testing visibility)
</acceptance_criteria>
</task>

## Verification
1. All 3 migration files exist in supabase/migrations/ in the correct order
2. The schema migration contains all 15 tables from the spec
3. The RLS migration enables RLS on all 15 tables
4. Admin policies use `role = 'admin'` check against profiles table (not just auth.uid())
5. Seed data includes 5 categories and 5+ books with category links

## Must-Haves
- Complete PostgreSQL schema with all 15 tables, proper foreign keys, and constraints
- Full-text search with Russian dictionary (`to_tsvector('russian', ...)`) on books table
- RLS enabled on every single table (no table left unprotected)
- Admin policies check `role = 'admin'` in profiles table
- Storage buckets for covers (public), audio (private), summaries (private)
- Seed data with 5 Russian categories and 5+ sample books (at least 1 draft for testing)
- Auto-create profile trigger on auth.users insert with SECURITY DEFINER
