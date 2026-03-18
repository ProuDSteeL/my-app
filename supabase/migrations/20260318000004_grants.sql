-- Grant access to anon and authenticated roles
-- RLS policies control row-level access; these grants enable table-level access

-- Public read tables (anon + authenticated)
GRANT SELECT ON public.categories TO anon, authenticated;
GRANT SELECT ON public.books TO anon, authenticated;
GRANT SELECT ON public.book_categories TO anon, authenticated;
GRANT SELECT ON public.key_ideas TO anon, authenticated;
GRANT SELECT ON public.collections TO anon, authenticated;
GRANT SELECT ON public.collection_books TO anon, authenticated;

-- Authenticated-only read
GRANT SELECT ON public.summaries TO authenticated;
GRANT SELECT ON public.profiles TO anon, authenticated;
GRANT UPDATE ON public.profiles TO authenticated;

-- User-owned tables (full CRUD for authenticated)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_progress TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_shelves TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_highlights TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_downloads TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_ratings TO authenticated;

-- Read-only for user's own data
GRANT SELECT ON public.subscriptions TO authenticated;
GRANT SELECT ON public.payments TO authenticated;

-- Admin tables (managed via RLS admin policies)
GRANT ALL ON public.books TO authenticated;
GRANT ALL ON public.categories TO authenticated;
GRANT ALL ON public.summaries TO authenticated;
GRANT ALL ON public.key_ideas TO authenticated;
GRANT ALL ON public.book_categories TO authenticated;
GRANT ALL ON public.collections TO authenticated;
GRANT ALL ON public.collection_books TO authenticated;
GRANT ALL ON public.subscriptions TO authenticated;
GRANT ALL ON public.payments TO authenticated;
