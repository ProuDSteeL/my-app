-- Seed data for BookSummary development
-- Run with: supabase db reset
-- Note: Admin user must be created via Supabase Auth first, then:
-- UPDATE public.profiles SET role = 'admin' WHERE id = '<admin-user-uuid>';

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
