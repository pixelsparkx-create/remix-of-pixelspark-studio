
-- ============ 1. Engagement rules (configurable) ============
CREATE TABLE IF NOT EXISTS public.engagement_rules (
  key text PRIMARY KEY,
  value numeric NOT NULL,
  description text,
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.engagement_rules TO anon, authenticated;
GRANT ALL ON public.engagement_rules TO service_role;
ALTER TABLE public.engagement_rules ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "engagement_rules_read" ON public.engagement_rules;
CREATE POLICY "engagement_rules_read" ON public.engagement_rules FOR SELECT USING (true);
DROP POLICY IF EXISTS "engagement_rules_admin_write" ON public.engagement_rules;
CREATE POLICY "engagement_rules_admin_write" ON public.engagement_rules FOR ALL TO authenticated
  USING (public.is_admin()) WITH CHECK (public.is_admin());

INSERT INTO public.engagement_rules(key, value, description) VALUES
  ('view_cooldown_minutes', 360, 'Minimum minutes before the same visitor can add another view to a project'),
  ('live_visit_cooldown_minutes', 30, 'Minimum minutes between counted live-project visits per visitor'),
  ('max_events_per_minute', 15, 'Maximum engagement events a visitor may generate per minute'),
  ('max_events_per_hour', 120, 'Maximum engagement events a visitor may generate per hour'),
  ('score_hot_threshold', 75, 'Lead score at or above which a lead is HOT'),
  ('score_warm_threshold', 45, 'Lead score at or above which a lead is WARM')
ON CONFLICT (key) DO NOTHING;

-- ============ 2. Abuse diagnostics ============
CREATE TABLE IF NOT EXISTS public.engagement_abuse (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visitor_id text NOT NULL,
  project_id text,
  interaction_type text,
  reason text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, DELETE ON public.engagement_abuse TO authenticated;
GRANT ALL ON public.engagement_abuse TO service_role;
ALTER TABLE public.engagement_abuse ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "engagement_abuse_admin" ON public.engagement_abuse;
CREATE POLICY "engagement_abuse_admin" ON public.engagement_abuse FOR ALL TO authenticated
  USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE INDEX IF NOT EXISTS idx_engagement_abuse_created ON public.engagement_abuse(created_at DESC);

-- ============ 3. Interaction dedup + rate limiting ============
DROP INDEX IF EXISTS idx_project_interactions_unique_visitor;
CREATE UNIQUE INDEX IF NOT EXISTS idx_project_interactions_unique_appreciation
  ON public.project_interactions(project_id, visitor_id) WHERE interaction_type = 'appreciation';
CREATE INDEX IF NOT EXISTS idx_project_interactions_visitor_time
  ON public.project_interactions(visitor_id, created_at DESC);

CREATE OR REPLACE FUNCTION public.engagement_rule(_key text, _fallback numeric)
RETURNS numeric LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$
  SELECT COALESCE((SELECT value FROM public.engagement_rules WHERE key = _key), _fallback);
$$;

CREATE OR REPLACE FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text)
RETURNS TABLE(project_id text, appreciations bigint, views bigint, live_visits bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
  v_last timestamptz;
  v_cooldown numeric;
  v_minute int;
  v_hour int;
BEGIN
  IF _interaction_type NOT IN ('view','appreciation','live_visit') THEN
    RAISE EXCEPTION 'invalid interaction type';
  END IF;
  IF length(_visitor_id) < 8 OR length(_visitor_id) > 64 OR length(_project_id) < 1 OR length(_project_id) > 80 THEN
    RAISE EXCEPTION 'invalid identifiers';
  END IF;

  PERFORM public.ensure_project_baseline(_project_id);

  -- burst / abuse protection
  SELECT count(*) INTO v_minute FROM public.project_interactions
    WHERE visitor_id = _visitor_id AND created_at > now() - interval '1 minute';
  SELECT count(*) INTO v_hour FROM public.project_interactions
    WHERE visitor_id = _visitor_id AND created_at > now() - interval '1 hour';

  IF v_minute >= public.engagement_rule('max_events_per_minute', 15)
     OR v_hour >= public.engagement_rule('max_events_per_hour', 120) THEN
    INSERT INTO public.engagement_abuse(visitor_id, project_id, interaction_type, reason)
    VALUES (_visitor_id, _project_id, _interaction_type, 'rate_limited');
    RETURN QUERY SELECT * FROM public.get_project_engagement(ARRAY[_project_id]);
    RETURN;
  END IF;

  IF _interaction_type = 'appreciation' THEN
    INSERT INTO public.project_interactions (project_id, interaction_type, visitor_id)
    VALUES (_project_id, _interaction_type, _visitor_id)
    ON CONFLICT DO NOTHING;
  ELSE
    v_cooldown := CASE WHEN _interaction_type = 'view'
      THEN public.engagement_rule('view_cooldown_minutes', 360)
      ELSE public.engagement_rule('live_visit_cooldown_minutes', 30) END;

    SELECT max(created_at) INTO v_last FROM public.project_interactions
      WHERE project_id = _project_id AND interaction_type = _interaction_type AND visitor_id = _visitor_id;

    IF v_last IS NULL OR v_last < now() - make_interval(mins => v_cooldown::int) THEN
      INSERT INTO public.project_interactions (project_id, interaction_type, visitor_id)
      VALUES (_project_id, _interaction_type, _visitor_id);
    ELSE
      INSERT INTO public.engagement_abuse(visitor_id, project_id, interaction_type, reason)
      VALUES (_visitor_id, _project_id, _interaction_type, 'cooldown_suppressed');
    END IF;
  END IF;

  RETURN QUERY SELECT * FROM public.get_project_engagement(ARRAY[_project_id]);
END;
$$;

-- total vs unique analytics for admins
CREATE OR REPLACE FUNCTION public.get_project_engagement_detailed(_project_ids text[])
RETURNS TABLE(project_id text, total_views bigint, unique_views bigint, total_appreciations bigint,
              unique_appreciations bigint, total_live_visits bigint, unique_live_visits bigint,
              suppressed_events bigint)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$
  SELECT p.pid,
    (SELECT count(*) FROM public.project_interactions i WHERE i.project_id=p.pid AND i.interaction_type='view'),
    (SELECT count(DISTINCT i.visitor_id) FROM public.project_interactions i WHERE i.project_id=p.pid AND i.interaction_type='view'),
    (SELECT count(*) FROM public.project_interactions i WHERE i.project_id=p.pid AND i.interaction_type='appreciation'),
    (SELECT count(DISTINCT i.visitor_id) FROM public.project_interactions i WHERE i.project_id=p.pid AND i.interaction_type='appreciation'),
    (SELECT count(*) FROM public.project_interactions i WHERE i.project_id=p.pid AND i.interaction_type='live_visit'),
    (SELECT count(DISTINCT i.visitor_id) FROM public.project_interactions i WHERE i.project_id=p.pid AND i.interaction_type='live_visit'),
    (SELECT count(*) FROM public.engagement_abuse a WHERE a.project_id=p.pid)
  FROM unnest(_project_ids) AS p(pid);
$$;

-- ============ 4. Lead scoring ============
ALTER TABLE public.goldie_leads
  ADD COLUMN IF NOT EXISTS score_category text,
  ADD COLUMN IF NOT EXISTS score_reasons jsonb DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS score_signals jsonb DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS score_updated_at timestamptz,
  ADD COLUMN IF NOT EXISTS score_override text,
  ADD COLUMN IF NOT EXISTS score_override_by text,
  ADD COLUMN IF NOT EXISTS score_override_reason text,
  ADD COLUMN IF NOT EXISTS score_override_at timestamptz;

CREATE TABLE IF NOT EXISTS public.lead_score_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid NOT NULL REFERENCES public.goldie_leads(id) ON DELETE CASCADE,
  previous_score integer,
  new_score integer NOT NULL,
  previous_category text,
  new_category text NOT NULL,
  reason text,
  source text NOT NULL DEFAULT 'system',
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, DELETE ON public.lead_score_history TO authenticated;
GRANT ALL ON public.lead_score_history TO service_role;
ALTER TABLE public.lead_score_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "lead_score_history_admin" ON public.lead_score_history;
CREATE POLICY "lead_score_history_admin" ON public.lead_score_history FOR ALL TO authenticated
  USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE INDEX IF NOT EXISTS idx_lead_score_history_lead ON public.lead_score_history(lead_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_goldie_leads_score ON public.goldie_leads(lead_score DESC NULLS LAST);

-- Deterministic, transparent lead scoring
CREATE OR REPLACE FUNCTION public.score_lead(_lead_id uuid)
RETURNS TABLE(score integer, category text, reasons jsonb)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
  l public.goldie_leads%ROWTYPE;
  st jsonb;
  s int := 0;
  rs jsonb := '[]'::jsonb;
  cat text;
  prev_score int;
  prev_cat text;
  n_features int;
  n_pages int;
  has_plan boolean;
  has_proposal boolean;
  contact_events_count int;
  whatsapp_count int;
  email_count int;
BEGIN
  SELECT * INTO l FROM public.goldie_leads WHERE id = _lead_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'lead not found'; END IF;
  st := COALESCE(l.project_state, '{}'::jsonb);
  prev_score := l.lead_score;
  prev_cat := l.score_category;

  n_features := COALESCE(jsonb_array_length(CASE WHEN jsonb_typeof(st->'required_features')='array' THEN st->'required_features' ELSE '[]'::jsonb END), 0);
  n_pages := COALESCE(jsonb_array_length(CASE WHEN jsonb_typeof(st->'required_pages')='array' THEN st->'required_pages' ELSE '[]'::jsonb END), 0);

  SELECT EXISTS(SELECT 1 FROM public.pricing_plans p WHERE p.lead_id = l.id
    OR (l.goldie_session_id IS NOT NULL AND p.goldie_session_id = l.goldie_session_id)) INTO has_plan;
  SELECT EXISTS(SELECT 1 FROM public.proposals pr WHERE pr.lead_id = l.id) INTO has_proposal;
  SELECT count(*) INTO contact_events_count FROM public.contact_events ce WHERE ce.lead_id = l.id
    OR (l.goldie_session_id IS NOT NULL AND ce.goldie_session_id = l.goldie_session_id);
  SELECT count(*) INTO whatsapp_count FROM public.contact_events ce WHERE ce.source = 'whatsapp'
    AND (ce.lead_id = l.id OR (l.goldie_session_id IS NOT NULL AND ce.goldie_session_id = l.goldie_session_id));
  SELECT count(*) INTO email_count FROM public.contact_events ce WHERE ce.source = 'email'
    AND (ce.lead_id = l.id OR (l.goldie_session_id IS NOT NULL AND ce.goldie_session_id = l.goldie_session_id));

  -- Contact intent
  IF l.contact_phone IS NOT NULL OR l.contact_email IS NOT NULL THEN
    s := s + 15; rs := rs || to_jsonb('Shared direct contact details'::text);
  ELSE
    rs := rs || to_jsonb('No contact details provided'::text);
  END IF;
  IF whatsapp_count > 0 THEN s := s + 10; rs := rs || to_jsonb('Initiated WhatsApp contact'::text); END IF;
  IF email_count > 0 THEN s := s + 6; rs := rs || to_jsonb('Initiated email contact'::text); END IF;

  -- Scope clarity
  IF n_features + n_pages >= 6 THEN s := s + 15; rs := rs || to_jsonb('Clear, detailed project requirements'::text);
  ELSIF n_features + n_pages >= 2 THEN s := s + 8; rs := rs || to_jsonb('Partial project requirements captured'::text);
  ELSE rs := rs || to_jsonb('Limited project details'::text); END IF;

  IF COALESCE(l.business_name, '') <> '' OR COALESCE(l.business_type, '') <> '' THEN
    s := s + 8; rs := rs || to_jsonb('Operating or clearly defined business'::text);
  END IF;

  -- Timeline
  IF l.timeline IS NOT NULL AND l.timeline <> '' THEN
    IF l.timeline ~* '(asap|urgent|1|2|3|4)\s*(week|day)|within 30|this month' THEN
      s := s + 18; rs := rs || to_jsonb('Wants to launch soon (' || l.timeline || ')'::text);
    ELSE
      s := s + 10; rs := rs || to_jsonb('Timeline indicated: ' || l.timeline);
    END IF;
  ELSE
    rs := rs || to_jsonb('No confirmed timeline yet'::text);
  END IF;

  -- Package fit
  IF l.recommended_plan IS NOT NULL AND l.recommended_plan <> '' THEN
    s := s + 8; rs := rs || to_jsonb('Package fit identified: ' || l.recommended_plan);
  ELSE
    rs := rs || to_jsonb('No package decision yet'::text);
  END IF;

  -- Budget: never invented
  IF COALESCE(st->>'budget', '') <> '' THEN
    s := s + 10; rs := rs || to_jsonb('Indicated budget: ' || (st->>'budget'));
  ELSE
    rs := rs || to_jsonb('Budget not provided'::text);
  END IF;

  -- Engagement
  IF has_plan THEN s := s + 12; rs := rs || to_jsonb('Completed the pricing estimator'::text); END IF;
  IF has_proposal THEN s := s + 15; rs := rs || to_jsonb('A proposal has been generated'::text); END IF;
  IF COALESCE(l.conversation_summary, '') <> '' THEN s := s + 5; rs := rs || to_jsonb('Substantial Goldie conversation'::text); END IF;
  IF contact_events_count >= 3 THEN s := s + 5; rs := rs || to_jsonb('Repeat engagement across the site'::text); END IF;
  IF l.status IN ('contacted','quoted','in progress') THEN s := s + 5; rs := rs || to_jsonb('Already in the sales pipeline'::text); END IF;

  s := GREATEST(0, LEAST(100, s));
  cat := CASE
    WHEN s >= public.engagement_rule('score_hot_threshold', 75) THEN 'HOT'
    WHEN s >= public.engagement_rule('score_warm_threshold', 45) THEN 'WARM'
    ELSE 'COLD' END;

  UPDATE public.goldie_leads SET
    lead_score = s,
    score_category = cat,
    score_reasons = rs,
    score_signals = jsonb_build_object(
      'estimator_completed', has_plan,
      'proposal_generated', has_proposal,
      'whatsapp_initiated', whatsapp_count > 0,
      'email_initiated', email_count > 0,
      'contact_events', contact_events_count,
      'requirement_items', n_features + n_pages,
      'timeline_provided', l.timeline IS NOT NULL AND l.timeline <> ''),
    score_updated_at = now()
  WHERE id = l.id;

  IF prev_score IS DISTINCT FROM s OR prev_cat IS DISTINCT FROM cat THEN
    INSERT INTO public.lead_score_history(lead_id, previous_score, new_score, previous_category, new_category, reason, source)
    VALUES (l.id, prev_score, s, prev_cat, cat, 'Automatic rescore from lead activity', 'system');
  END IF;

  RETURN QUERY SELECT s, cat, rs;
END;
$$;
GRANT EXECUTE ON FUNCTION public.score_lead(uuid) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.engagement_rule(text, numeric) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_project_engagement_detailed(text[]) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.override_lead_category(_lead_id uuid, _category text, _reason text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE l public.goldie_leads%ROWTYPE; actor text;
BEGIN
  IF NOT public.is_admin() THEN RAISE EXCEPTION 'not authorized'; END IF;
  IF _category NOT IN ('HOT','WARM','COLD') THEN RAISE EXCEPTION 'invalid category'; END IF;
  SELECT * INTO l FROM public.goldie_leads WHERE id = _lead_id;
  actor := COALESCE(auth.jwt() ->> 'email', 'admin');
  UPDATE public.goldie_leads SET score_override = _category, score_override_by = actor,
    score_override_reason = _reason, score_override_at = now() WHERE id = _lead_id;
  INSERT INTO public.lead_score_history(lead_id, previous_score, new_score, previous_category, new_category, reason, source)
  VALUES (_lead_id, l.lead_score, COALESCE(l.lead_score, 0), COALESCE(l.score_override, l.score_category), _category,
    COALESCE(_reason, 'Manual admin override'), 'admin:' || actor);
END;
$$;
GRANT EXECUTE ON FUNCTION public.override_lead_category(uuid, text, text) TO authenticated;
