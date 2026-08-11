CREATE TABLE public.goldie_leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name text,
  contact_email text,
  contact_phone text,
  business_name text,
  business_type text,
  location text,
  project_type text,
  recommended_plan text,
  estimated_range text,
  timeline text,
  project_state jsonb NOT NULL DEFAULT '{}'::jsonb,
  conversation_summary text,
  proposal_markdown text,
  priority text NOT NULL DEFAULT 'normal',
  status text NOT NULL DEFAULT 'new',
  admin_notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

GRANT INSERT ON public.goldie_leads TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.goldie_leads TO authenticated;
GRANT ALL ON public.goldie_leads TO service_role;

ALTER TABLE public.goldie_leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit a project brief"
  ON public.goldie_leads FOR INSERT TO anon, authenticated
  WITH CHECK (status = 'new' AND priority IN ('low','normal','high') AND admin_notes IS NULL);

CREATE POLICY "Admins can view project briefs"
  ON public.goldie_leads FOR SELECT TO authenticated
  USING (public.is_admin());

CREATE POLICY "Admins can update project briefs"
  ON public.goldie_leads FOR UPDATE TO authenticated
  USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete project briefs"
  ON public.goldie_leads FOR DELETE TO authenticated
  USING (public.is_admin());

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_goldie_leads_updated_at
  BEFORE UPDATE ON public.goldie_leads
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();