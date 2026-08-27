CREATE TABLE IF NOT EXISTS public.contact_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text NOT NULL,
  kind text NOT NULL DEFAULT 'initiated',
  title text NOT NULL,
  message text,
  client_name text,
  business_name text,
  contact_email text,
  contact_phone text,
  project text,
  recommended_plan text,
  status text NOT NULL DEFAULT 'new',
  priority text NOT NULL DEFAULT 'normal',
  lead_id uuid REFERENCES public.goldie_leads(id) ON DELETE SET NULL,
  plan_id uuid,
  goldie_session_id text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT contact_events_kind_check CHECK (kind IN ('received','initiated'))
);

GRANT INSERT ON public.contact_events TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.contact_events TO authenticated;
GRANT ALL ON public.contact_events TO service_role;

ALTER TABLE public.contact_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can log contact activity" ON public.contact_events FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Admins can read contact activity" ON public.contact_events FOR SELECT TO authenticated USING (public.is_admin());
CREATE POLICY "Admins can update contact activity" ON public.contact_events FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins can delete contact activity" ON public.contact_events FOR DELETE TO authenticated USING (public.is_admin());

CREATE TRIGGER update_contact_events_updated_at BEFORE UPDATE ON public.contact_events FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.pricing_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reference text NOT NULL UNIQUE,
  client_name text,
  business_name text,
  industry text,
  project_goal text,
  target_audience text,
  recommended_plan text NOT NULL DEFAULT 'Growth',
  base_price numeric NOT NULL DEFAULT 0,
  estimate_min numeric NOT NULL DEFAULT 0,
  estimate_max numeric NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'NGN',
  answers jsonb NOT NULL DEFAULT '{}'::jsonb,
  complexity_factors jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_pages jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_features jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_integrations jsonb NOT NULL DEFAULT '[]'::jsonb,
  design_direction text,
  timeline text,
  rationale text,
  status text NOT NULL DEFAULT 'generated',
  share_count integer NOT NULL DEFAULT 0,
  lead_id uuid REFERENCES public.goldie_leads(id) ON DELETE SET NULL,
  goldie_session_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT INSERT, SELECT ON public.pricing_plans TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pricing_plans TO authenticated;
GRANT ALL ON public.pricing_plans TO service_role;

ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can create a pricing plan" ON public.pricing_plans FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Admins can read pricing plans" ON public.pricing_plans FOR SELECT TO authenticated USING (public.is_admin());
CREATE POLICY "Admins can update pricing plans" ON public.pricing_plans FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins can delete pricing plans" ON public.pricing_plans FOR DELETE TO authenticated USING (public.is_admin());

CREATE TRIGGER update_pricing_plans_updated_at BEFORE UPDATE ON public.pricing_plans FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.transcript_exports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid REFERENCES public.goldie_leads(id) ON DELETE SET NULL,
  goldie_session_id text,
  format text NOT NULL DEFAULT 'pdf',
  export_type text NOT NULL DEFAULT 'client',
  filename text NOT NULL,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT INSERT ON public.transcript_exports TO anon;
GRANT SELECT, INSERT, DELETE ON public.transcript_exports TO authenticated;
GRANT ALL ON public.transcript_exports TO service_role;

ALTER TABLE public.transcript_exports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can record a transcript export" ON public.transcript_exports FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Admins can read transcript exports" ON public.transcript_exports FOR SELECT TO authenticated USING (public.is_admin());
CREATE POLICY "Admins can delete transcript exports" ON public.transcript_exports FOR DELETE TO authenticated USING (public.is_admin());

CREATE OR REPLACE FUNCTION public.get_shared_plan(_reference text) RETURNS jsonb
  LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public'
AS $$
  SELECT jsonb_build_object(
    'reference', p.reference,
    'client_name', p.client_name,
    'business_name', p.business_name,
    'industry', p.industry,
    'project_goal', p.project_goal,
    'target_audience', p.target_audience,
    'recommended_plan', p.recommended_plan,
    'base_price', p.base_price,
    'estimate_min', p.estimate_min,
    'estimate_max', p.estimate_max,
    'currency', p.currency,
    'complexity_factors', p.complexity_factors,
    'required_pages', p.required_pages,
    'required_features', p.required_features,
    'required_integrations', p.required_integrations,
    'design_direction', p.design_direction,
    'timeline', p.timeline,
    'rationale', p.rationale,
    'status', p.status,
    'created_at', p.created_at
  )
  FROM public.pricing_plans p
  WHERE p.reference = _reference
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.mark_plan_shared(_reference text) RETURNS void
  LANGUAGE sql SECURITY DEFINER SET search_path TO 'public'
AS $$
  UPDATE public.pricing_plans
  SET share_count = share_count + 1,
      status = CASE WHEN status IN ('draft','generated') THEN 'shared' ELSE status END
  WHERE reference = _reference;
$$;

CREATE OR REPLACE FUNCTION public.submit_plan(_reference text, _client_name text DEFAULT NULL, _contact_email text DEFAULT NULL, _contact_phone text DEFAULT NULL, _note text DEFAULT NULL)
RETURNS uuid
  LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE
  p public.pricing_plans%ROWTYPE;
  v_lead_id uuid;
BEGIN
  SELECT * INTO p FROM public.pricing_plans WHERE reference = _reference;
  IF NOT FOUND THEN RAISE EXCEPTION 'Plan not found'; END IF;

  v_lead_id := p.lead_id;

  IF v_lead_id IS NULL THEN
    INSERT INTO public.goldie_leads (
      client_name, contact_email, contact_phone, business_name, business_type,
      project_type, recommended_plan, estimated_range, timeline, project_state,
      conversation_summary, status, priority
    ) VALUES (
      COALESCE(_client_name, p.client_name), _contact_email, _contact_phone,
      p.business_name, p.industry, p.project_goal, p.recommended_plan,
      concat('NGN ', to_char(p.estimate_min, 'FM999G999G999'), ' - ', to_char(p.estimate_max, 'FM999G999G999')),
      p.timeline, to_jsonb(p), COALESCE(_note, p.rationale), 'new', 'normal'
    ) RETURNING id INTO v_lead_id;
  ELSE
    UPDATE public.goldie_leads
    SET recommended_plan = COALESCE(recommended_plan, p.recommended_plan),
        contact_email = COALESCE(_contact_email, contact_email),
        contact_phone = COALESCE(_contact_phone, contact_phone)
    WHERE id = v_lead_id;
  END IF;

  UPDATE public.pricing_plans
  SET status = 'submitted', lead_id = v_lead_id
  WHERE id = p.id;

  INSERT INTO public.contact_events (
    source, kind, title, message, client_name, business_name, project,
    recommended_plan, lead_id, plan_id, goldie_session_id
  ) VALUES (
    'pricing_guide', 'received', 'Website plan submitted',
    COALESCE(_note, 'Visitor submitted their generated website plan.'),
    COALESCE(_client_name, p.client_name), p.business_name, p.project_goal,
    p.recommended_plan, v_lead_id, p.id, p.goldie_session_id
  );

  RETURN v_lead_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_shared_plan(text) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.mark_plan_shared(text) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.submit_plan(text, text, text, text, text) TO anon, authenticated, service_role;