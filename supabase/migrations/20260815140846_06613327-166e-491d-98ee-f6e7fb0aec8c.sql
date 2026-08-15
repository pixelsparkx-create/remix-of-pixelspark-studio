-- =========================
-- ERROR MONITORING
-- =========================
CREATE TABLE public.error_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fingerprint text NOT NULL UNIQUE,
  severity text NOT NULL DEFAULT 'error',
  status text NOT NULL DEFAULT 'open',
  feature text NOT NULL DEFAULT 'unknown',
  category text NOT NULL DEFAULT 'unknown',
  environment text NOT NULL DEFAULT 'production',
  side text NOT NULL DEFAULT 'client',
  route text,
  operation text,
  message text NOT NULL,
  stack text,
  context jsonb NOT NULL DEFAULT '{}'::jsonb,
  lead_id uuid REFERENCES public.goldie_leads(id) ON DELETE SET NULL,
  proposal_id uuid,
  goldie_session_id text,
  occurrences integer NOT NULL DEFAULT 1,
  first_seen timestamptz NOT NULL DEFAULT now(),
  last_seen timestamptz NOT NULL DEFAULT now(),
  admin_notes text,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, UPDATE, DELETE ON public.error_events TO authenticated;
GRANT ALL ON public.error_events TO service_role;
ALTER TABLE public.error_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view errors" ON public.error_events FOR SELECT TO authenticated USING (public.is_admin());
CREATE POLICY "Admins can update errors" ON public.error_events FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins can delete errors" ON public.error_events FOR DELETE TO authenticated USING (public.is_admin());

CREATE TABLE public.error_occurrences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  error_id uuid NOT NULL REFERENCES public.error_events(id) ON DELETE CASCADE,
  route text,
  context jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, DELETE ON public.error_occurrences TO authenticated;
GRANT ALL ON public.error_occurrences TO service_role;
ALTER TABLE public.error_occurrences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view occurrences" ON public.error_occurrences FOR SELECT TO authenticated USING (public.is_admin());
CREATE POLICY "Admins can delete occurrences" ON public.error_occurrences FOR DELETE TO authenticated USING (public.is_admin());

CREATE INDEX idx_error_events_last_seen ON public.error_events (last_seen DESC);
CREATE INDEX idx_error_events_status ON public.error_events (status);
CREATE INDEX idx_error_events_severity ON public.error_events (severity);
CREATE INDEX idx_error_occurrences_error ON public.error_occurrences (error_id, created_at DESC);

CREATE OR REPLACE FUNCTION public.log_error_event(
  _fingerprint text,
  _message text,
  _severity text DEFAULT 'error',
  _feature text DEFAULT 'unknown',
  _category text DEFAULT 'unknown',
  _environment text DEFAULT 'production',
  _side text DEFAULT 'client',
  _route text DEFAULT NULL,
  _operation text DEFAULT NULL,
  _stack text DEFAULT NULL,
  _context jsonb DEFAULT '{}'::jsonb,
  _lead_id uuid DEFAULT NULL,
  _proposal_id uuid DEFAULT NULL,
  _goldie_session_id text DEFAULT NULL
) RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _id uuid;
BEGIN
  IF _fingerprint IS NULL OR length(_fingerprint) < 4 OR length(_fingerprint) > 200 THEN
    RAISE EXCEPTION 'invalid fingerprint';
  END IF;
  IF _severity NOT IN ('info','warning','error','critical') THEN
    _severity := 'error';
  END IF;

  INSERT INTO public.error_events AS e (
    fingerprint, message, severity, feature, category, environment, side,
    route, operation, stack, context, lead_id, proposal_id, goldie_session_id
  ) VALUES (
    _fingerprint, left(coalesce(_message,'Unknown error'), 2000), _severity, left(coalesce(_feature,'unknown'),80),
    left(coalesce(_category,'unknown'),80), left(coalesce(_environment,'production'),40), left(coalesce(_side,'client'),20),
    left(_route, 300), left(_operation, 80), left(_stack, 8000), coalesce(_context,'{}'::jsonb),
    _lead_id, _proposal_id, left(_goldie_session_id, 80)
  )
  ON CONFLICT (fingerprint) DO UPDATE SET
    occurrences = e.occurrences + 1,
    last_seen = now(),
    updated_at = now(),
    message = EXCLUDED.message,
    stack = coalesce(EXCLUDED.stack, e.stack),
    severity = EXCLUDED.severity,
    context = EXCLUDED.context
  RETURNING e.id INTO _id;

  INSERT INTO public.error_occurrences (error_id, route, context)
  VALUES (_id, left(_route, 300), coalesce(_context,'{}'::jsonb));

  DELETE FROM public.error_occurrences o
  WHERE o.error_id = _id
    AND o.id NOT IN (
      SELECT id FROM public.error_occurrences WHERE error_id = _id ORDER BY created_at DESC LIMIT 25
    );

  RETURN _id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.log_error_event(text,text,text,text,text,text,text,text,text,text,jsonb,uuid,uuid,text) TO anon, authenticated, service_role;

-- =========================
-- PROPOSALS
-- =========================
CREATE TABLE public.proposals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid REFERENCES public.goldie_leads(id) ON DELETE SET NULL,
  reference text NOT NULL DEFAULT ('PROPOSAL-' || upper(substr(md5(random()::text), 1, 4))),
  title text NOT NULL DEFAULT 'Project Proposal',
  subtitle text,
  client_name text,
  project_name text,
  description text,
  template text NOT NULL DEFAULT 'premium',
  accent_color text NOT NULL DEFAULT '#C9A227',
  secondary_color text NOT NULL DEFAULT '#111111',
  logo_url text,
  sections jsonb NOT NULL DEFAULT '[]'::jsonb,
  recommended_plan text,
  estimated_range text,
  official_quote text,
  timeline text,
  support_period text,
  notes text,
  terms text,
  status text NOT NULL DEFAULT 'draft',
  version integer NOT NULL DEFAULT 1,
  assets jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.proposals TO authenticated;
GRANT ALL ON public.proposals TO service_role;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage proposals" ON public.proposals FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE INDEX idx_proposals_lead ON public.proposals (lead_id);
CREATE INDEX idx_proposals_created ON public.proposals (created_at DESC);

CREATE TRIGGER update_proposals_updated_at BEFORE UPDATE ON public.proposals
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.proposal_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id uuid NOT NULL REFERENCES public.proposals(id) ON DELETE CASCADE,
  version integer NOT NULL,
  snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
  previous_pricing text,
  new_pricing text,
  change_summary text,
  editor_email text,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, DELETE ON public.proposal_versions TO authenticated;
GRANT ALL ON public.proposal_versions TO service_role;
ALTER TABLE public.proposal_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage proposal versions" ON public.proposal_versions FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE INDEX idx_proposal_versions_proposal ON public.proposal_versions (proposal_id, version DESC);

CREATE OR REPLACE FUNCTION public.create_draft_proposal(
  _lead_id uuid,
  _title text,
  _client_name text,
  _project_name text,
  _description text,
  _recommended_plan text,
  _estimated_range text,
  _timeline text,
  _sections jsonb DEFAULT '[]'::jsonb
) RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _id uuid;
BEGIN
  IF _lead_id IS NULL OR NOT EXISTS (SELECT 1 FROM public.goldie_leads WHERE id = _lead_id) THEN
    RAISE EXCEPTION 'unknown lead';
  END IF;
  IF EXISTS (SELECT 1 FROM public.proposals WHERE lead_id = _lead_id) THEN
    SELECT id INTO _id FROM public.proposals WHERE lead_id = _lead_id ORDER BY created_at LIMIT 1;
    RETURN _id;
  END IF;

  INSERT INTO public.proposals (
    lead_id, title, client_name, project_name, description,
    recommended_plan, estimated_range, timeline, sections, status
  ) VALUES (
    _lead_id, left(coalesce(_title,'Project Proposal'), 200), left(_client_name, 200), left(_project_name, 200),
    left(_description, 8000), left(_recommended_plan, 120), left(_estimated_range, 120), left(_timeline, 120),
    coalesce(_sections, '[]'::jsonb), 'draft'
  ) RETURNING id INTO _id;

  RETURN _id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_draft_proposal(uuid,text,text,text,text,text,text,text,jsonb) TO anon, authenticated, service_role;

-- =========================
-- FOLLOW-UPS
-- =========================
CREATE TABLE public.lead_followups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid NOT NULL REFERENCES public.goldie_leads(id) ON DELETE CASCADE,
  proposal_id uuid REFERENCES public.proposals(id) ON DELETE SET NULL,
  scheduled_at timestamptz NOT NULL,
  followup_type text NOT NULL DEFAULT 'check_in',
  status text NOT NULL DEFAULT 'scheduled',
  notes text,
  failure_reason text,
  completed_at timestamptz,
  rescheduled_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.lead_followups TO authenticated;
GRANT ALL ON public.lead_followups TO service_role;
ALTER TABLE public.lead_followups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage followups" ON public.lead_followups FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE INDEX idx_followups_scheduled ON public.lead_followups (scheduled_at);
CREATE INDEX idx_followups_lead ON public.lead_followups (lead_id);

CREATE TRIGGER update_followups_updated_at BEFORE UPDATE ON public.lead_followups
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =========================
-- AUDIT LOG
-- =========================
CREATE TABLE public.admin_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text,
  detail text,
  actor_email text,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, DELETE ON public.admin_audit_log TO authenticated;
GRANT ALL ON public.admin_audit_log TO service_role;
ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage audit log" ON public.admin_audit_log FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE INDEX idx_audit_created ON public.admin_audit_log (created_at DESC);

-- =========================
-- LEAD EXTRAS
-- =========================
ALTER TABLE public.goldie_leads
  ADD COLUMN IF NOT EXISTS lead_score integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_contacted_at timestamptz;

-- =========================
-- STORAGE POLICIES: proposal assets
-- =========================
CREATE POLICY "Proposal assets are publicly readable"
ON storage.objects FOR SELECT
USING (bucket_id = 'proposal-assets');

CREATE POLICY "Admins can upload proposal assets"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'proposal-assets' AND public.is_admin());

CREATE POLICY "Admins can update proposal assets"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'proposal-assets' AND public.is_admin());

CREATE POLICY "Admins can delete proposal assets"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'proposal-assets' AND public.is_admin());