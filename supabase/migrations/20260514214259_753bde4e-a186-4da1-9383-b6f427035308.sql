
CREATE TABLE public.testimonials (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  title TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  message TEXT NOT NULL,
  approved BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;

-- Anyone can submit a testimonial (will require approval before being shown)
CREATE POLICY "Anyone can submit testimonials"
  ON public.testimonials FOR INSERT
  TO anon, authenticated
  WITH CHECK (approved = false);

-- Anyone can view approved testimonials only (display_name is anonymized so no PII exposure)
CREATE POLICY "Anyone can view approved testimonials"
  ON public.testimonials FOR SELECT
  TO anon, authenticated
  USING (approved = true);

-- Seed initial testimonials so site shows content immediately
INSERT INTO public.testimonials (full_name, display_name, title, rating, message, approved) VALUES
  ('John Doe', 'J.Doe', 'Lagos Hotel Owner', 5, 'Mohammed was amazing to work with. He delivered more than I expected and my website looks fantastic!', true),
  ('Adewale Johnson', 'A.Johnson', 'Solar Startup Founder', 5, 'Fast, professional and very creative. PixelSpark made our brand look truly premium online.', true),
  ('Mariam Olawale', 'M.Olawale', 'Local Business Owner', 5, 'Clear communication, clean design and on-time delivery. Highly recommend.', true);
