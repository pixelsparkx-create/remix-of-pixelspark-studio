-- PixelSpark Studio — complete backend schema (portable export)
-- Lovable Cloud environment-specific ACLs removed for standalone Supabase compatibility.
-- Generated from the live database. Run this once in the SQL Editor of your own
-- Supabase project. It is safe to re-run: every object is created conditionally.
--
-- After running, grant yourself admin access (see the last statement in this file).

--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--


--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

DO $enum$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user');
EXCEPTION WHEN duplicate_object THEN NULL; END $enum$;


--
-- Name: create_draft_proposal(uuid, text, text, text, text, text, text, text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.create_draft_proposal(_lead_id uuid, _title text, _client_name text, _project_name text, _description text, _recommended_plan text, _estimated_range text, _timeline text, _sections jsonb DEFAULT '[]'::jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: engagement_rule(text, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.engagement_rule(_key text, _fallback numeric) RETURNS numeric
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT COALESCE((SELECT value FROM public.engagement_rules WHERE key = _key), _fallback);
$$;


--
-- Name: ensure_project_baseline(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.ensure_project_baseline(_project_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: get_project_engagement(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.get_project_engagement(_project_ids text[]) RETURNS TABLE(project_id text, appreciations bigint, views bigint, live_visits bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT
    p.pid AS project_id,
    COALESCE(b.base_appreciations, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'appreciation'), 0) AS appreciations,
    COALESCE(b.base_views, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'view'), 0) AS views,
    COALESCE(b.base_live_visits, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'live_visit'), 0) AS live_visits
  FROM unnest(_project_ids) AS p(pid)
  LEFT JOIN public.project_baselines b ON b.project_id = p.pid;
$$;


--
-- Name: get_project_engagement_detailed(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.get_project_engagement_detailed(_project_ids text[]) RETURNS TABLE(project_id text, total_views bigint, unique_views bigint, total_appreciations bigint, unique_appreciations bigint, total_live_visits bigint, unique_live_visits bigint, suppressed_events bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


--
-- Name: get_shared_plan(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.get_shared_plan(_reference text) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: has_appreciated(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.has_appreciated(_project_id text, _visitor_id text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.project_interactions
    WHERE project_id = _project_id AND interaction_type = 'appreciation' AND visitor_id = _visitor_id
  );
$$;


--
-- Name: has_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role);
$$;


--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE uid uuid; mail text;
BEGIN
  uid := auth.uid();
  IF uid IS NULL THEN RETURN false; END IF;
  IF public.has_role(uid, 'admin') THEN RETURN true; END IF;
  SELECT lower(u.email) INTO mail FROM auth.users u WHERE u.id = uid;
  IF mail IS NULL THEN RETURN false; END IF;
  RETURN EXISTS (SELECT 1 FROM public.admin_allowlist a WHERE lower(a.email) = mail);
END;
$$;


--
-- Name: log_error_event(text, text, text, text, text, text, text, text, text, text, jsonb, uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.log_error_event(_fingerprint text, _message text, _severity text DEFAULT 'error'::text, _feature text DEFAULT 'unknown'::text, _category text DEFAULT 'unknown'::text, _environment text DEFAULT 'production'::text, _side text DEFAULT 'client'::text, _route text DEFAULT NULL::text, _operation text DEFAULT NULL::text, _stack text DEFAULT NULL::text, _context jsonb DEFAULT '{}'::jsonb, _lead_id uuid DEFAULT NULL::uuid, _proposal_id uuid DEFAULT NULL::uuid, _goldie_session_id text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: mark_plan_shared(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.mark_plan_shared(_reference text) RETURNS void
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  UPDATE public.pricing_plans
  SET share_count = share_count + 1,
      status = CASE WHEN status IN ('draft', 'generated') THEN 'shared' ELSE status END
  WHERE reference = _reference;
$$;


--
-- Name: override_lead_category(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.override_lead_category(_lead_id uuid, _category text, _reason text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


--
-- Name: record_project_interaction(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text) RETURNS TABLE(project_id text, appreciations bigint, views bigint, live_visits bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


--
-- Name: score_lead(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.score_lead(_lead_id uuid) RETURNS TABLE(score integer, category text, reasons jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


--
-- Name: submit_plan(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.submit_plan(_reference text, _client_name text DEFAULT NULL::text, _contact_email text DEFAULT NULL::text, _contact_phone text DEFAULT NULL::text, _note text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
      conversation_summary, status, priority, source, plan_reference, goldie_session_id
    ) VALUES (
      COALESCE(_client_name, p.client_name), _contact_email, _contact_phone,
      p.business_name, p.industry, p.project_goal, p.recommended_plan,
      concat('₦', to_char(p.estimate_min, 'FM999G999G999'), '–₦', to_char(p.estimate_max, 'FM999G999G999')),
      p.timeline, to_jsonb(p), COALESCE(_note, p.rationale), 'new', 'normal',
      'pricing_guide', p.reference, p.goldie_session_id
    ) RETURNING id INTO v_lead_id;
  ELSE
    UPDATE public.goldie_leads
    SET plan_reference = p.reference,
        recommended_plan = COALESCE(recommended_plan, p.recommended_plan),
        contact_email = COALESCE(_contact_email, contact_email),
        contact_phone = COALESCE(_contact_phone, contact_phone)
    WHERE id = v_lead_id;
  END IF;

  UPDATE public.pricing_plans
  SET status = 'submitted', lead_id = v_lead_id
  WHERE id = p.id;

  INSERT INTO public.contact_events (
    source, kind, title, message, client_name, business_name, project,
    recommended_plan, lead_id, plan_id, goldie_session_id, metadata
  ) VALUES (
    'pricing_guide', 'received', 'Website plan submitted',
    COALESCE(_note, 'Visitor submitted their generated website plan.'),
    COALESCE(_client_name, p.client_name), p.business_name, p.project_goal,
    p.recommended_plan, v_lead_id, p.id, p.goldie_session_id,
    jsonb_build_object('reference', p.reference)
  );

  RETURN v_lead_id;
END; $$;


--
-- Name: touch_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_allowlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.admin_allowlist (
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.admin_audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id text,
    detail text,
    actor_email text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: contact_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.contact_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source text NOT NULL,
    kind text DEFAULT 'initiated'::text NOT NULL,
    title text NOT NULL,
    message text,
    client_name text,
    business_name text,
    contact_email text,
    contact_phone text,
    project text,
    recommended_plan text,
    status text DEFAULT 'new'::text NOT NULL,
    priority text DEFAULT 'normal'::text NOT NULL,
    lead_id uuid,
    plan_id uuid,
    goldie_session_id text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT contact_events_kind_check CHECK ((kind = ANY (ARRAY['received'::text, 'initiated'::text])))
);


--
-- Name: engagement_abuse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.engagement_abuse (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    visitor_id text NOT NULL,
    project_id text,
    interaction_type text,
    reason text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: engagement_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.engagement_rules (
    key text NOT NULL,
    value numeric NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: error_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.error_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    fingerprint text NOT NULL,
    severity text DEFAULT 'error'::text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    feature text DEFAULT 'unknown'::text NOT NULL,
    category text DEFAULT 'unknown'::text NOT NULL,
    environment text DEFAULT 'production'::text NOT NULL,
    side text DEFAULT 'client'::text NOT NULL,
    route text,
    operation text,
    message text NOT NULL,
    stack text,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    lead_id uuid,
    proposal_id uuid,
    goldie_session_id text,
    occurrences integer DEFAULT 1 NOT NULL,
    first_seen timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone DEFAULT now() NOT NULL,
    admin_notes text,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: error_occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.error_occurrences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    error_id uuid NOT NULL,
    route text,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: goldie_leads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.goldie_leads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
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
    project_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    conversation_summary text,
    proposal_markdown text,
    priority text DEFAULT 'normal'::text NOT NULL,
    status text DEFAULT 'new'::text NOT NULL,
    admin_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    lead_score integer DEFAULT 0 NOT NULL,
    last_contacted_at timestamp with time zone,
    goldie_session_id text,
    plan_reference text,
    source text DEFAULT 'goldie'::text NOT NULL,
    score_category text,
    score_reasons jsonb DEFAULT '[]'::jsonb,
    score_signals jsonb DEFAULT '{}'::jsonb,
    score_updated_at timestamp with time zone,
    score_override text,
    score_override_by text,
    score_override_reason text,
    score_override_at timestamp with time zone
);


--
-- Name: lead_followups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.lead_followups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lead_id uuid NOT NULL,
    proposal_id uuid,
    scheduled_at timestamp with time zone NOT NULL,
    followup_type text DEFAULT 'check_in'::text NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    notes text,
    failure_reason text,
    completed_at timestamp with time zone,
    rescheduled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: lead_score_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.lead_score_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lead_id uuid NOT NULL,
    previous_score integer,
    new_score integer NOT NULL,
    previous_category text,
    new_category text NOT NULL,
    reason text,
    source text DEFAULT 'system'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pricing_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.pricing_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reference text NOT NULL,
    client_name text,
    business_name text,
    industry text,
    project_goal text,
    target_audience text,
    recommended_plan text DEFAULT 'Growth'::text NOT NULL,
    base_price numeric DEFAULT 0 NOT NULL,
    estimate_min numeric DEFAULT 0 NOT NULL,
    estimate_max numeric DEFAULT 0 NOT NULL,
    currency text DEFAULT 'NGN'::text NOT NULL,
    answers jsonb DEFAULT '{}'::jsonb NOT NULL,
    complexity_factors jsonb DEFAULT '[]'::jsonb NOT NULL,
    required_pages jsonb DEFAULT '[]'::jsonb NOT NULL,
    required_features jsonb DEFAULT '[]'::jsonb NOT NULL,
    required_integrations jsonb DEFAULT '[]'::jsonb NOT NULL,
    design_direction text,
    timeline text,
    rationale text,
    status text DEFAULT 'generated'::text NOT NULL,
    share_count integer DEFAULT 0 NOT NULL,
    lead_id uuid,
    goldie_session_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: project_baselines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.project_baselines (
    project_id text NOT NULL,
    base_appreciations integer NOT NULL,
    base_views integer NOT NULL,
    base_live_visits integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: project_interactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.project_interactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id text NOT NULL,
    interaction_type text NOT NULL,
    visitor_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT project_interactions_interaction_type_check CHECK ((interaction_type = ANY (ARRAY['view'::text, 'appreciation'::text, 'live_visit'::text])))
);


--
-- Name: proposal_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.proposal_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    proposal_id uuid NOT NULL,
    version integer NOT NULL,
    snapshot jsonb DEFAULT '{}'::jsonb NOT NULL,
    previous_pricing text,
    new_pricing text,
    change_summary text,
    editor_email text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.proposals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lead_id uuid,
    reference text DEFAULT ('PROPOSAL-'::text || upper(substr(md5((random())::text), 1, 4))) NOT NULL,
    title text DEFAULT 'Project Proposal'::text NOT NULL,
    subtitle text,
    client_name text,
    project_name text,
    description text,
    template text DEFAULT 'premium'::text NOT NULL,
    accent_color text DEFAULT '#C9A227'::text NOT NULL,
    secondary_color text DEFAULT '#111111'::text NOT NULL,
    logo_url text,
    sections jsonb DEFAULT '[]'::jsonb NOT NULL,
    recommended_plan text,
    estimated_range text,
    official_quote text,
    timeline text,
    support_period text,
    notes text,
    terms text,
    status text DEFAULT 'draft'::text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    assets jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: testimonials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.testimonials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    display_name text NOT NULL,
    title text NOT NULL,
    rating integer NOT NULL,
    message text NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT testimonials_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: transcript_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.transcript_exports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lead_id uuid,
    goldie_session_id text,
    format text DEFAULT 'pdf'::text NOT NULL,
    export_type text DEFAULT 'client'::text NOT NULL,
    filename text NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role public.app_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_allowlist admin_allowlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.admin_allowlist
    ADD CONSTRAINT admin_allowlist_pkey PRIMARY KEY (email);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: admin_audit_log admin_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.admin_audit_log
    ADD CONSTRAINT admin_audit_log_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: contact_events contact_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.contact_events
    ADD CONSTRAINT contact_events_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: engagement_abuse engagement_abuse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.engagement_abuse
    ADD CONSTRAINT engagement_abuse_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: engagement_rules engagement_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.engagement_rules
    ADD CONSTRAINT engagement_rules_pkey PRIMARY KEY (key);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: error_events error_events_fingerprint_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.error_events
    ADD CONSTRAINT error_events_fingerprint_key UNIQUE (fingerprint);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: error_events error_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.error_events
    ADD CONSTRAINT error_events_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: error_occurrences error_occurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.error_occurrences
    ADD CONSTRAINT error_occurrences_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: goldie_leads goldie_leads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.goldie_leads
    ADD CONSTRAINT goldie_leads_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: lead_followups lead_followups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: lead_score_history lead_score_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.lead_score_history
    ADD CONSTRAINT lead_score_history_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: pricing_plans pricing_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.pricing_plans
    ADD CONSTRAINT pricing_plans_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: pricing_plans pricing_plans_reference_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.pricing_plans
    ADD CONSTRAINT pricing_plans_reference_key UNIQUE (reference);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: project_baselines project_baselines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.project_baselines
    ADD CONSTRAINT project_baselines_pkey PRIMARY KEY (project_id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: project_interactions project_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.project_interactions
    ADD CONSTRAINT project_interactions_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: proposal_versions proposal_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.proposal_versions
    ADD CONSTRAINT proposal_versions_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: proposals proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: testimonials testimonials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: transcript_exports transcript_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.transcript_exports
    ADD CONSTRAINT transcript_exports_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: contact_events_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS contact_events_created_idx ON public.contact_events USING btree (created_at DESC);


--
-- Name: contact_events_lead_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS contact_events_lead_idx ON public.contact_events USING btree (lead_id);


--
-- Name: idx_audit_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_audit_created ON public.admin_audit_log USING btree (created_at DESC);


--
-- Name: idx_engagement_abuse_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_engagement_abuse_created ON public.engagement_abuse USING btree (created_at DESC);


--
-- Name: idx_error_events_last_seen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_error_events_last_seen ON public.error_events USING btree (last_seen DESC);


--
-- Name: idx_error_events_severity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_error_events_severity ON public.error_events USING btree (severity);


--
-- Name: idx_error_events_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_error_events_status ON public.error_events USING btree (status);


--
-- Name: idx_error_occurrences_error; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_error_occurrences_error ON public.error_occurrences USING btree (error_id, created_at DESC);


--
-- Name: idx_followups_lead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_followups_lead ON public.lead_followups USING btree (lead_id);


--
-- Name: idx_followups_scheduled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_followups_scheduled ON public.lead_followups USING btree (scheduled_at);


--
-- Name: idx_goldie_leads_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_goldie_leads_score ON public.goldie_leads USING btree (lead_score DESC NULLS LAST);


--
-- Name: idx_lead_score_history_lead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_lead_score_history_lead ON public.lead_score_history USING btree (lead_id, created_at DESC);


--
-- Name: idx_project_interactions_project_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_project_interactions_project_type ON public.project_interactions USING btree (project_id, interaction_type);


--
-- Name: idx_project_interactions_unique_appreciation; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX IF NOT EXISTS idx_project_interactions_unique_appreciation ON public.project_interactions USING btree (project_id, visitor_id) WHERE (interaction_type = 'appreciation'::text);


--
-- Name: idx_project_interactions_visitor_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_project_interactions_visitor_time ON public.project_interactions USING btree (visitor_id, created_at DESC);


--
-- Name: idx_proposal_versions_proposal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_proposal_versions_proposal ON public.proposal_versions USING btree (proposal_id, version DESC);


--
-- Name: idx_proposals_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_proposals_created ON public.proposals USING btree (created_at DESC);


--
-- Name: idx_proposals_lead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS idx_proposals_lead ON public.proposals USING btree (lead_id);


--
-- Name: pricing_plans_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS pricing_plans_created_idx ON public.pricing_plans USING btree (created_at DESC);


--
-- Name: pricing_plans_lead_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS pricing_plans_lead_idx ON public.pricing_plans USING btree (lead_id);


--
-- Name: transcript_exports_lead_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS transcript_exports_lead_idx ON public.transcript_exports USING btree (lead_id);


--
-- Name: contact_events contact_events_touch; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER contact_events_touch BEFORE UPDATE ON public.contact_events FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();


--
-- Name: pricing_plans pricing_plans_touch; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER pricing_plans_touch BEFORE UPDATE ON public.pricing_plans FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();


--
-- Name: lead_followups update_followups_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER update_followups_updated_at BEFORE UPDATE ON public.lead_followups FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: goldie_leads update_goldie_leads_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER update_goldie_leads_updated_at BEFORE UPDATE ON public.goldie_leads FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: proposals update_proposals_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE OR REPLACE TRIGGER update_proposals_updated_at BEFORE UPDATE ON public.proposals FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: contact_events contact_events_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.contact_events
    ADD CONSTRAINT contact_events_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: contact_events contact_events_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.contact_events
    ADD CONSTRAINT contact_events_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.pricing_plans(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: error_events error_events_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.error_events
    ADD CONSTRAINT error_events_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: error_occurrences error_occurrences_error_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.error_occurrences
    ADD CONSTRAINT error_occurrences_error_id_fkey FOREIGN KEY (error_id) REFERENCES public.error_events(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: lead_followups lead_followups_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: lead_followups lead_followups_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.proposals(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: lead_score_history lead_score_history_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.lead_score_history
    ADD CONSTRAINT lead_score_history_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: pricing_plans pricing_plans_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.pricing_plans
    ADD CONSTRAINT pricing_plans_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: proposal_versions proposal_versions_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.proposal_versions
    ADD CONSTRAINT proposal_versions_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.proposals(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: proposals proposals_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: transcript_exports transcript_exports_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.transcript_exports
    ADD CONSTRAINT transcript_exports_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: transcript_exports transcript_exports_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

DO $c$ BEGIN
ALTER TABLE ONLY public.transcript_exports
    ADD CONSTRAINT transcript_exports_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.goldie_leads(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; WHEN duplicate_table THEN NULL; END $c$;


--
-- Name: transcript_exports Admins can create transcript exports; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can create transcript exports" ON public.transcript_exports;
CREATE POLICY "Admins can create transcript exports" ON public.transcript_exports FOR INSERT TO authenticated WITH CHECK (public.is_admin());


--
-- Name: contact_events Admins can delete contact activity; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete contact activity" ON public.contact_events;
CREATE POLICY "Admins can delete contact activity" ON public.contact_events FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: error_events Admins can delete errors; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete errors" ON public.error_events;
CREATE POLICY "Admins can delete errors" ON public.error_events FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: error_occurrences Admins can delete occurrences; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete occurrences" ON public.error_occurrences;
CREATE POLICY "Admins can delete occurrences" ON public.error_occurrences FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: pricing_plans Admins can delete pricing plans; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete pricing plans" ON public.pricing_plans;
CREATE POLICY "Admins can delete pricing plans" ON public.pricing_plans FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: goldie_leads Admins can delete project briefs; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete project briefs" ON public.goldie_leads;
CREATE POLICY "Admins can delete project briefs" ON public.goldie_leads FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: testimonials Admins can delete testimonials; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete testimonials" ON public.testimonials;
CREATE POLICY "Admins can delete testimonials" ON public.testimonials FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: transcript_exports Admins can delete transcript exports; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can delete transcript exports" ON public.transcript_exports;
CREATE POLICY "Admins can delete transcript exports" ON public.transcript_exports FOR DELETE TO authenticated USING (public.is_admin());


--
-- Name: contact_events Admins can read contact activity; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can read contact activity" ON public.contact_events;
CREATE POLICY "Admins can read contact activity" ON public.contact_events FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: pricing_plans Admins can read pricing plans; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can read pricing plans" ON public.pricing_plans;
CREATE POLICY "Admins can read pricing plans" ON public.pricing_plans FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: transcript_exports Admins can read transcript exports; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can read transcript exports" ON public.transcript_exports;
CREATE POLICY "Admins can read transcript exports" ON public.transcript_exports FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: contact_events Admins can update contact activity; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can update contact activity" ON public.contact_events;
CREATE POLICY "Admins can update contact activity" ON public.contact_events FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: error_events Admins can update errors; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can update errors" ON public.error_events;
CREATE POLICY "Admins can update errors" ON public.error_events FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: pricing_plans Admins can update pricing plans; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can update pricing plans" ON public.pricing_plans;
CREATE POLICY "Admins can update pricing plans" ON public.pricing_plans FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: goldie_leads Admins can update project briefs; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can update project briefs" ON public.goldie_leads;
CREATE POLICY "Admins can update project briefs" ON public.goldie_leads FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: testimonials Admins can update testimonials; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can update testimonials" ON public.testimonials;
CREATE POLICY "Admins can update testimonials" ON public.testimonials FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: testimonials Admins can view all testimonials; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can view all testimonials" ON public.testimonials;
CREATE POLICY "Admins can view all testimonials" ON public.testimonials FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: error_events Admins can view errors; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can view errors" ON public.error_events;
CREATE POLICY "Admins can view errors" ON public.error_events FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: project_interactions Admins can view interactions; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can view interactions" ON public.project_interactions;
CREATE POLICY "Admins can view interactions" ON public.project_interactions FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: error_occurrences Admins can view occurrences; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can view occurrences" ON public.error_occurrences;
CREATE POLICY "Admins can view occurrences" ON public.error_occurrences FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: goldie_leads Admins can view project briefs; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins can view project briefs" ON public.goldie_leads;
CREATE POLICY "Admins can view project briefs" ON public.goldie_leads FOR SELECT TO authenticated USING (public.is_admin());


--
-- Name: admin_audit_log Admins manage audit log; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins manage audit log" ON public.admin_audit_log;
CREATE POLICY "Admins manage audit log" ON public.admin_audit_log TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: lead_followups Admins manage followups; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins manage followups" ON public.lead_followups;
CREATE POLICY "Admins manage followups" ON public.lead_followups TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: proposal_versions Admins manage proposal versions; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins manage proposal versions" ON public.proposal_versions;
CREATE POLICY "Admins manage proposal versions" ON public.proposal_versions TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: proposals Admins manage proposals; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Admins manage proposals" ON public.proposals;
CREATE POLICY "Admins manage proposals" ON public.proposals TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: pricing_plans Anyone can create a pricing plan; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Anyone can create a pricing plan" ON public.pricing_plans;
CREATE POLICY "Anyone can create a pricing plan" ON public.pricing_plans FOR INSERT TO authenticated, anon WITH CHECK (true);


--
-- Name: contact_events Anyone can log contact activity; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Anyone can log contact activity" ON public.contact_events;
CREATE POLICY "Anyone can log contact activity" ON public.contact_events FOR INSERT TO authenticated, anon WITH CHECK (true);


--
-- Name: project_interactions Anyone can register an interaction; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Anyone can register an interaction" ON public.project_interactions;
CREATE POLICY "Anyone can register an interaction" ON public.project_interactions FOR INSERT TO authenticated, anon WITH CHECK (((length(visitor_id) >= 8) AND (length(visitor_id) <= 64) AND ((length(project_id) >= 1) AND (length(project_id) <= 80))));


--
-- Name: goldie_leads Anyone can submit a project brief; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Anyone can submit a project brief" ON public.goldie_leads;
CREATE POLICY "Anyone can submit a project brief" ON public.goldie_leads FOR INSERT TO authenticated, anon WITH CHECK (((status = 'new'::text) AND (priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text])) AND (admin_notes IS NULL)));


--
-- Name: testimonials Anyone can submit testimonials; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Anyone can submit testimonials" ON public.testimonials;
CREATE POLICY "Anyone can submit testimonials" ON public.testimonials FOR INSERT TO authenticated, anon WITH CHECK ((approved = false));


--
-- Name: testimonials Anyone can view approved testimonials; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Anyone can view approved testimonials" ON public.testimonials;
CREATE POLICY "Anyone can view approved testimonials" ON public.testimonials FOR SELECT TO authenticated, anon USING ((approved = true));


--
-- Name: project_baselines Baselines are publicly readable; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Baselines are publicly readable" ON public.project_baselines;
CREATE POLICY "Baselines are publicly readable" ON public.project_baselines FOR SELECT TO authenticated, anon USING (true);


--
-- Name: user_roles Users can read own roles; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS "Users can read own roles" ON public.user_roles;
CREATE POLICY "Users can read own roles" ON public.user_roles FOR SELECT TO authenticated USING ((user_id = auth.uid()));


--
-- Name: admin_allowlist; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_allowlist ENABLE ROW LEVEL SECURITY;

--
-- Name: admin_audit_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;

--
-- Name: contact_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.contact_events ENABLE ROW LEVEL SECURITY;

--
-- Name: engagement_abuse; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.engagement_abuse ENABLE ROW LEVEL SECURITY;

--
-- Name: engagement_abuse engagement_abuse_admin; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS engagement_abuse_admin ON public.engagement_abuse;
CREATE POLICY engagement_abuse_admin ON public.engagement_abuse TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: engagement_rules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.engagement_rules ENABLE ROW LEVEL SECURITY;

--
-- Name: engagement_rules engagement_rules_admin_write; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS engagement_rules_admin_write ON public.engagement_rules;
CREATE POLICY engagement_rules_admin_write ON public.engagement_rules TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: engagement_rules engagement_rules_read; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS engagement_rules_read ON public.engagement_rules;
CREATE POLICY engagement_rules_read ON public.engagement_rules FOR SELECT USING (true);


--
-- Name: error_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.error_events ENABLE ROW LEVEL SECURITY;

--
-- Name: error_occurrences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.error_occurrences ENABLE ROW LEVEL SECURITY;

--
-- Name: goldie_leads; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.goldie_leads ENABLE ROW LEVEL SECURITY;

--
-- Name: lead_followups; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lead_followups ENABLE ROW LEVEL SECURITY;

--
-- Name: lead_score_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lead_score_history ENABLE ROW LEVEL SECURITY;

--
-- Name: lead_score_history lead_score_history_admin; Type: POLICY; Schema: public; Owner: -
--

DROP POLICY IF EXISTS lead_score_history_admin ON public.lead_score_history;
CREATE POLICY lead_score_history_admin ON public.lead_score_history TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: pricing_plans; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;

--
-- Name: project_baselines; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.project_baselines ENABLE ROW LEVEL SECURITY;

--
-- Name: project_interactions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.project_interactions ENABLE ROW LEVEL SECURITY;

--
-- Name: proposal_versions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.proposal_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: proposals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

--
-- Name: testimonials; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;

--
-- Name: transcript_exports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.transcript_exports ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION create_draft_proposal(_lead_id uuid, _title text, _client_name text, _project_name text, _description text, _recommended_plan text, _estimated_range text, _timeline text, _sections jsonb); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.create_draft_proposal(_lead_id uuid, _title text, _client_name text, _project_name text, _description text, _recommended_plan text, _estimated_range text, _timeline text, _sections jsonb) TO anon;
GRANT ALL ON FUNCTION public.create_draft_proposal(_lead_id uuid, _title text, _client_name text, _project_name text, _description text, _recommended_plan text, _estimated_range text, _timeline text, _sections jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.create_draft_proposal(_lead_id uuid, _title text, _client_name text, _project_name text, _description text, _recommended_plan text, _estimated_range text, _timeline text, _sections jsonb) TO service_role;


--
-- Name: FUNCTION engagement_rule(_key text, _fallback numeric); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.engagement_rule(_key text, _fallback numeric) FROM PUBLIC;
GRANT ALL ON FUNCTION public.engagement_rule(_key text, _fallback numeric) TO service_role;


--
-- Name: FUNCTION ensure_project_baseline(_project_id text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.ensure_project_baseline(_project_id text) TO anon;
GRANT ALL ON FUNCTION public.ensure_project_baseline(_project_id text) TO authenticated;
GRANT ALL ON FUNCTION public.ensure_project_baseline(_project_id text) TO service_role;


--
-- Name: FUNCTION get_project_engagement(_project_ids text[]); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.get_project_engagement(_project_ids text[]) TO anon;
GRANT ALL ON FUNCTION public.get_project_engagement(_project_ids text[]) TO authenticated;
GRANT ALL ON FUNCTION public.get_project_engagement(_project_ids text[]) TO service_role;


--
-- Name: FUNCTION get_project_engagement_detailed(_project_ids text[]); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.get_project_engagement_detailed(_project_ids text[]) TO anon;
GRANT ALL ON FUNCTION public.get_project_engagement_detailed(_project_ids text[]) TO authenticated;
GRANT ALL ON FUNCTION public.get_project_engagement_detailed(_project_ids text[]) TO service_role;


--
-- Name: FUNCTION get_shared_plan(_reference text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.get_shared_plan(_reference text) TO anon;
GRANT ALL ON FUNCTION public.get_shared_plan(_reference text) TO authenticated;
GRANT ALL ON FUNCTION public.get_shared_plan(_reference text) TO service_role;


--
-- Name: FUNCTION has_appreciated(_project_id text, _visitor_id text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.has_appreciated(_project_id text, _visitor_id text) TO anon;
GRANT ALL ON FUNCTION public.has_appreciated(_project_id text, _visitor_id text) TO authenticated;
GRANT ALL ON FUNCTION public.has_appreciated(_project_id text, _visitor_id text) TO service_role;


--
-- Name: FUNCTION has_role(_user_id uuid, _role public.app_role); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO anon;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO authenticated;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO service_role;


--
-- Name: FUNCTION is_admin(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.is_admin() TO anon;
GRANT ALL ON FUNCTION public.is_admin() TO authenticated;
GRANT ALL ON FUNCTION public.is_admin() TO service_role;


--
-- Name: FUNCTION log_error_event(_fingerprint text, _message text, _severity text, _feature text, _category text, _environment text, _side text, _route text, _operation text, _stack text, _context jsonb, _lead_id uuid, _proposal_id uuid, _goldie_session_id text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.log_error_event(_fingerprint text, _message text, _severity text, _feature text, _category text, _environment text, _side text, _route text, _operation text, _stack text, _context jsonb, _lead_id uuid, _proposal_id uuid, _goldie_session_id text) TO anon;
GRANT ALL ON FUNCTION public.log_error_event(_fingerprint text, _message text, _severity text, _feature text, _category text, _environment text, _side text, _route text, _operation text, _stack text, _context jsonb, _lead_id uuid, _proposal_id uuid, _goldie_session_id text) TO authenticated;
GRANT ALL ON FUNCTION public.log_error_event(_fingerprint text, _message text, _severity text, _feature text, _category text, _environment text, _side text, _route text, _operation text, _stack text, _context jsonb, _lead_id uuid, _proposal_id uuid, _goldie_session_id text) TO service_role;


--
-- Name: FUNCTION mark_plan_shared(_reference text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.mark_plan_shared(_reference text) TO anon;
GRANT ALL ON FUNCTION public.mark_plan_shared(_reference text) TO authenticated;
GRANT ALL ON FUNCTION public.mark_plan_shared(_reference text) TO service_role;


--
-- Name: FUNCTION override_lead_category(_lead_id uuid, _category text, _reason text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.override_lead_category(_lead_id uuid, _category text, _reason text) TO anon;
GRANT ALL ON FUNCTION public.override_lead_category(_lead_id uuid, _category text, _reason text) TO authenticated;
GRANT ALL ON FUNCTION public.override_lead_category(_lead_id uuid, _category text, _reason text) TO service_role;


--
-- Name: FUNCTION record_project_interaction(_project_id text, _interaction_type text, _visitor_id text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text) TO anon;
GRANT ALL ON FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text) TO authenticated;
GRANT ALL ON FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text) TO service_role;


--
-- Name: FUNCTION score_lead(_lead_id uuid); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.score_lead(_lead_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.score_lead(_lead_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.score_lead(_lead_id uuid) TO service_role;


--
-- Name: FUNCTION submit_plan(_reference text, _client_name text, _contact_email text, _contact_phone text, _note text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.submit_plan(_reference text, _client_name text, _contact_email text, _contact_phone text, _note text) TO anon;
GRANT ALL ON FUNCTION public.submit_plan(_reference text, _client_name text, _contact_email text, _contact_phone text, _note text) TO authenticated;
GRANT ALL ON FUNCTION public.submit_plan(_reference text, _client_name text, _contact_email text, _contact_phone text, _note text) TO service_role;


--
-- Name: FUNCTION touch_updated_at(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.touch_updated_at() TO anon;
GRANT ALL ON FUNCTION public.touch_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.touch_updated_at() TO service_role;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- Name: TABLE admin_allowlist; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.admin_allowlist TO anon;
GRANT ALL ON TABLE public.admin_allowlist TO authenticated;
GRANT ALL ON TABLE public.admin_allowlist TO service_role;


--
-- Name: TABLE admin_audit_log; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.admin_audit_log TO anon;
GRANT ALL ON TABLE public.admin_audit_log TO authenticated;
GRANT ALL ON TABLE public.admin_audit_log TO service_role;


--
-- Name: TABLE contact_events; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.contact_events TO anon;
GRANT ALL ON TABLE public.contact_events TO authenticated;
GRANT ALL ON TABLE public.contact_events TO service_role;


--
-- Name: TABLE engagement_abuse; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.engagement_abuse TO anon;
GRANT ALL ON TABLE public.engagement_abuse TO authenticated;
GRANT ALL ON TABLE public.engagement_abuse TO service_role;


--
-- Name: TABLE engagement_rules; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.engagement_rules TO anon;
GRANT ALL ON TABLE public.engagement_rules TO authenticated;
GRANT ALL ON TABLE public.engagement_rules TO service_role;


--
-- Name: TABLE error_events; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.error_events TO anon;
GRANT ALL ON TABLE public.error_events TO authenticated;
GRANT ALL ON TABLE public.error_events TO service_role;


--
-- Name: TABLE error_occurrences; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.error_occurrences TO anon;
GRANT ALL ON TABLE public.error_occurrences TO authenticated;
GRANT ALL ON TABLE public.error_occurrences TO service_role;


--
-- Name: TABLE goldie_leads; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.goldie_leads TO anon;
GRANT ALL ON TABLE public.goldie_leads TO authenticated;
GRANT ALL ON TABLE public.goldie_leads TO service_role;


--
-- Name: TABLE lead_followups; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.lead_followups TO anon;
GRANT ALL ON TABLE public.lead_followups TO authenticated;
GRANT ALL ON TABLE public.lead_followups TO service_role;


--
-- Name: TABLE lead_score_history; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.lead_score_history TO anon;
GRANT ALL ON TABLE public.lead_score_history TO authenticated;
GRANT ALL ON TABLE public.lead_score_history TO service_role;


--
-- Name: TABLE pricing_plans; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.pricing_plans TO anon;
GRANT ALL ON TABLE public.pricing_plans TO authenticated;
GRANT ALL ON TABLE public.pricing_plans TO service_role;


--
-- Name: TABLE project_baselines; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.project_baselines TO anon;
GRANT ALL ON TABLE public.project_baselines TO authenticated;
GRANT ALL ON TABLE public.project_baselines TO service_role;


--
-- Name: TABLE project_interactions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.project_interactions TO anon;
GRANT ALL ON TABLE public.project_interactions TO authenticated;
GRANT ALL ON TABLE public.project_interactions TO service_role;


--
-- Name: TABLE proposal_versions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.proposal_versions TO anon;
GRANT ALL ON TABLE public.proposal_versions TO authenticated;
GRANT ALL ON TABLE public.proposal_versions TO service_role;


--
-- Name: TABLE proposals; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.proposals TO anon;
GRANT ALL ON TABLE public.proposals TO authenticated;
GRANT ALL ON TABLE public.proposals TO service_role;


--
-- Name: TABLE testimonials; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.testimonials TO anon;
GRANT ALL ON TABLE public.testimonials TO authenticated;
GRANT ALL ON TABLE public.testimonials TO service_role;


--
-- Name: TABLE transcript_exports; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.transcript_exports TO anon;
GRANT ALL ON TABLE public.transcript_exports TO authenticated;
GRANT ALL ON TABLE public.transcript_exports TO service_role;


--
-- Name: TABLE user_roles; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.user_roles TO anon;
GRANT ALL ON TABLE public.user_roles TO authenticated;
GRANT ALL ON TABLE public.user_roles TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--


--
-- PostgreSQL database dump complete
--


-- ---------------------------------------------------------------------------
-- SEED: engagement + lead-scoring rules (the only configuration rows the app
-- expects to exist; every other table starts empty).
-- ---------------------------------------------------------------------------
INSERT INTO public.engagement_rules (key, value, description) VALUES
  ('view_cooldown_minutes', 360, 'Minimum minutes before the same visitor can add another view to a project'),
  ('live_visit_cooldown_minutes', 30, 'Minimum minutes between counted live-project visits per visitor'),
  ('max_events_per_minute', 15, 'Maximum engagement events a visitor may generate per minute'),
  ('max_events_per_hour', 120, 'Maximum engagement events a visitor may generate per hour'),
  ('score_warm_threshold', 45, 'Lead score at or above which a lead is WARM'),
  ('score_hot_threshold', 75, 'Lead score at or above which a lead is HOT')
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------------
-- ADMIN ACCESS
-- Replace the email below with the Google/email account you sign in with,
-- then run this line. It is what unlocks /admin.
-- ---------------------------------------------------------------------------
INSERT INTO public.admin_allowlist (email)
VALUES ('pixelsparkx@gmail.com')
ON CONFLICT (email) DO NOTHING;
