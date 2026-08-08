
CREATE TABLE public.project_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id text NOT NULL,
  interaction_type text NOT NULL CHECK (interaction_type IN ('view','appreciation','live_visit')),
  visitor_id text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT ON public.project_interactions TO authenticated;
GRANT SELECT, INSERT ON public.project_interactions TO anon;
GRANT ALL ON public.project_interactions TO service_role;

ALTER TABLE public.project_interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can register an interaction"
  ON public.project_interactions FOR INSERT TO anon, authenticated
  WITH CHECK (length(visitor_id) BETWEEN 8 AND 64 AND length(project_id) BETWEEN 1 AND 80);

CREATE INDEX idx_project_interactions_project_type ON public.project_interactions (project_id, interaction_type);
CREATE UNIQUE INDEX idx_project_interactions_unique_visitor
  ON public.project_interactions (project_id, interaction_type, visitor_id)
  WHERE interaction_type IN ('view','appreciation');

CREATE TABLE public.project_baselines (
  project_id text PRIMARY KEY,
  base_appreciations integer NOT NULL,
  base_views integer NOT NULL,
  base_live_visits integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT ON public.project_baselines TO anon, authenticated;
GRANT ALL ON public.project_baselines TO service_role;

ALTER TABLE public.project_baselines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Baselines are publicly readable"
  ON public.project_baselines FOR SELECT TO anon, authenticated USING (true);

CREATE OR REPLACE FUNCTION public.ensure_project_baseline(_project_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.project_baselines (project_id, base_appreciations, base_views, base_live_visits)
  VALUES (
    _project_id,
    17 + floor(random() * 6)::int,
    90 + floor(random() * 7)::int,
    30 + floor(random() * 6)::int
  )
  ON CONFLICT (project_id) DO NOTHING;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_project_engagement(_project_ids text[])
RETURNS TABLE (project_id text, appreciations bigint, views bigint, live_visits bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.pid AS project_id,
    COALESCE(b.base_appreciations, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'appreciation'), 0) AS appreciations,
    COALESCE(b.base_views, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'view'), 0) AS views,
    COALESCE(b.base_live_visits, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'live_visit'), 0) AS live_visits
  FROM unnest(_project_ids) AS p(pid)
  LEFT JOIN public.project_baselines b ON b.project_id = p.pid;
$$;

CREATE OR REPLACE FUNCTION public.has_appreciated(_project_id text, _visitor_id text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.project_interactions
    WHERE project_id = _project_id AND interaction_type = 'appreciation' AND visitor_id = _visitor_id
  );
$$;

CREATE OR REPLACE FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text)
RETURNS TABLE (project_id text, appreciations bigint, views bigint, live_visits bigint)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF _interaction_type NOT IN ('view','appreciation','live_visit') THEN
    RAISE EXCEPTION 'invalid interaction type';
  END IF;
  IF length(_visitor_id) < 8 OR length(_visitor_id) > 64 OR length(_project_id) < 1 OR length(_project_id) > 80 THEN
    RAISE EXCEPTION 'invalid identifiers';
  END IF;

  PERFORM public.ensure_project_baseline(_project_id);

  INSERT INTO public.project_interactions (project_id, interaction_type, visitor_id)
  VALUES (_project_id, _interaction_type, _visitor_id)
  ON CONFLICT DO NOTHING;

  RETURN QUERY SELECT * FROM public.get_project_engagement(ARRAY[_project_id]);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.ensure_project_baseline(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_project_engagement(text[]) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.has_appreciated(text, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_project_interaction(text, text, text) TO anon, authenticated;
