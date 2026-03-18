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
