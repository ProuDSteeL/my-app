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
