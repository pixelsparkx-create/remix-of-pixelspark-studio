-- =====================================================================
-- PixelSpark — Lovable Cloud -> own Supabase sync migration
-- Generated from the live Lovable Cloud backend.
--
-- Safe to run on a Supabase project that already holds the older
-- PixelSpark schema: every statement is idempotent (IF NOT EXISTS /
-- CREATE OR REPLACE / DROP ... IF EXISTS first). No data is dropped.
-- Paste the whole file into the Supabase Dashboard SQL Editor and Run.
--
-- Covers: enums, tables + new columns, defaults, NOT NULL, primary /
-- unique / check / foreign-key constraints, indexes, functions,
-- triggers, table grants, RLS and every policy.
--
-- No Lovable-specific roles or extensions are referenced.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- ============ ENUM TYPES ============
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace WHERE n.nspname='public' AND t.typname='app_role') THEN CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user'); END IF; END $do$;
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'moderator';
ALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'user';

-- ============ TABLES AND COLUMNS ============
CREATE TABLE IF NOT EXISTS public.admin_allowlist ();
ALTER TABLE public.admin_allowlist ADD COLUMN IF NOT EXISTS email text;
ALTER TABLE public.admin_allowlist ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.admin_allowlist ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.admin_allowlist ALTER COLUMN email SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null admin_allowlist.email: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.admin_allowlist ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null admin_allowlist.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.admin_audit_log ();
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS action text;
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS entity_type text;
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS entity_id text;
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS detail text;
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS actor_email text;
ALTER TABLE public.admin_audit_log ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.admin_audit_log ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.admin_audit_log ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.admin_audit_log ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null admin_audit_log.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.admin_audit_log ALTER COLUMN action SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null admin_audit_log.action: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.admin_audit_log ALTER COLUMN entity_type SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null admin_audit_log.entity_type: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.admin_audit_log ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null admin_audit_log.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.contact_events ();
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS source text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS kind text DEFAULT 'initiated'::text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS title text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS message text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS client_name text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS business_name text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS contact_email text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS contact_phone text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS project text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS recommended_plan text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS status text DEFAULT 'new'::text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS priority text DEFAULT 'normal'::text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS plan_id uuid;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS goldie_session_id text;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS metadata jsonb DEFAULT '{}'::jsonb;
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.contact_events ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.contact_events ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.contact_events ALTER COLUMN kind SET DEFAULT 'initiated'::text;
ALTER TABLE public.contact_events ALTER COLUMN status SET DEFAULT 'new'::text;
ALTER TABLE public.contact_events ALTER COLUMN priority SET DEFAULT 'normal'::text;
ALTER TABLE public.contact_events ALTER COLUMN metadata SET DEFAULT '{}'::jsonb;
ALTER TABLE public.contact_events ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.contact_events ALTER COLUMN updated_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN source SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.source: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN kind SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.kind: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN title SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.title: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN priority SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.priority: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN metadata SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.metadata: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.contact_events ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null contact_events.updated_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.error_events ();
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS fingerprint text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS severity text DEFAULT 'error'::text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS status text DEFAULT 'open'::text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS feature text DEFAULT 'unknown'::text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS category text DEFAULT 'unknown'::text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS environment text DEFAULT 'production'::text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS side text DEFAULT 'client'::text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS route text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS operation text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS message text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS stack text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS context jsonb DEFAULT '{}'::jsonb;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS proposal_id uuid;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS goldie_session_id text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS occurrences integer DEFAULT 1;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS first_seen timestamp with time zone DEFAULT now();
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS last_seen timestamp with time zone DEFAULT now();
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS admin_notes text;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS resolved_at timestamp with time zone;
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.error_events ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.error_events ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.error_events ALTER COLUMN severity SET DEFAULT 'error'::text;
ALTER TABLE public.error_events ALTER COLUMN status SET DEFAULT 'open'::text;
ALTER TABLE public.error_events ALTER COLUMN feature SET DEFAULT 'unknown'::text;
ALTER TABLE public.error_events ALTER COLUMN category SET DEFAULT 'unknown'::text;
ALTER TABLE public.error_events ALTER COLUMN environment SET DEFAULT 'production'::text;
ALTER TABLE public.error_events ALTER COLUMN side SET DEFAULT 'client'::text;
ALTER TABLE public.error_events ALTER COLUMN context SET DEFAULT '{}'::jsonb;
ALTER TABLE public.error_events ALTER COLUMN occurrences SET DEFAULT 1;
ALTER TABLE public.error_events ALTER COLUMN first_seen SET DEFAULT now();
ALTER TABLE public.error_events ALTER COLUMN last_seen SET DEFAULT now();
ALTER TABLE public.error_events ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.error_events ALTER COLUMN updated_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN fingerprint SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.fingerprint: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN severity SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.severity: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN feature SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.feature: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN category SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.category: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN environment SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.environment: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN side SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.side: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN message SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.message: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN context SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.context: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN occurrences SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.occurrences: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN first_seen SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.first_seen: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN last_seen SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.last_seen: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_events ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_events.updated_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.error_occurrences ();
ALTER TABLE public.error_occurrences ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.error_occurrences ADD COLUMN IF NOT EXISTS error_id uuid;
ALTER TABLE public.error_occurrences ADD COLUMN IF NOT EXISTS route text;
ALTER TABLE public.error_occurrences ADD COLUMN IF NOT EXISTS context jsonb DEFAULT '{}'::jsonb;
ALTER TABLE public.error_occurrences ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.error_occurrences ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.error_occurrences ALTER COLUMN context SET DEFAULT '{}'::jsonb;
ALTER TABLE public.error_occurrences ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_occurrences ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_occurrences.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_occurrences ALTER COLUMN error_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_occurrences.error_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_occurrences ALTER COLUMN context SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_occurrences.context: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.error_occurrences ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null error_occurrences.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.goldie_leads ();
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS client_name text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS contact_email text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS contact_phone text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS business_name text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS business_type text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS location text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS project_type text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS recommended_plan text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS estimated_range text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS timeline text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS project_state jsonb DEFAULT '{}'::jsonb;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS conversation_summary text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS proposal_markdown text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS priority text DEFAULT 'normal'::text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS status text DEFAULT 'new'::text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS admin_notes text;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS lead_score integer DEFAULT 0;
ALTER TABLE public.goldie_leads ADD COLUMN IF NOT EXISTS last_contacted_at timestamp with time zone;
ALTER TABLE public.goldie_leads ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.goldie_leads ALTER COLUMN project_state SET DEFAULT '{}'::jsonb;
ALTER TABLE public.goldie_leads ALTER COLUMN priority SET DEFAULT 'normal'::text;
ALTER TABLE public.goldie_leads ALTER COLUMN status SET DEFAULT 'new'::text;
ALTER TABLE public.goldie_leads ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.goldie_leads ALTER COLUMN updated_at SET DEFAULT now();
ALTER TABLE public.goldie_leads ALTER COLUMN lead_score SET DEFAULT 0;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN project_state SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.project_state: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN priority SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.priority: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.updated_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.goldie_leads ALTER COLUMN lead_score SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null goldie_leads.lead_score: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.lead_followups ();
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS proposal_id uuid;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS scheduled_at timestamp with time zone;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS followup_type text DEFAULT 'check_in'::text;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS status text DEFAULT 'scheduled'::text;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS failure_reason text;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS completed_at timestamp with time zone;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS rescheduled_at timestamp with time zone;
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.lead_followups ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.lead_followups ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.lead_followups ALTER COLUMN followup_type SET DEFAULT 'check_in'::text;
ALTER TABLE public.lead_followups ALTER COLUMN status SET DEFAULT 'scheduled'::text;
ALTER TABLE public.lead_followups ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.lead_followups ALTER COLUMN updated_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN lead_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.lead_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN scheduled_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.scheduled_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN followup_type SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.followup_type: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.lead_followups ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null lead_followups.updated_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.payment_events ();
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS payment_request_id uuid;
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS event_type text;
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS from_status text;
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS to_status text;
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS detail text;
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS actor text;
ALTER TABLE public.payment_events ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.payment_events ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.payment_events ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_events ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_events.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_events ALTER COLUMN payment_request_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_events.payment_request_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_events ALTER COLUMN event_type SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_events.event_type: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_events ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_events.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.payment_requests ();
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS request_code text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS client_name text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS client_email text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS client_phone text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS project_name text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS project_type text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS payment_type text DEFAULT 'full'::text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS amount numeric(14,2);
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS currency text DEFAULT 'NGN'::text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS internal_note text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending'::text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS flutterwave_transaction_id text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS flutterwave_reference text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS flutterwave_payment_link text;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS paid_at timestamp with time zone;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS expires_at timestamp with time zone;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS created_by uuid;
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.payment_requests ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.payment_requests ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.payment_requests ALTER COLUMN payment_type SET DEFAULT 'full'::text;
ALTER TABLE public.payment_requests ALTER COLUMN currency SET DEFAULT 'NGN'::text;
ALTER TABLE public.payment_requests ALTER COLUMN status SET DEFAULT 'pending'::text;
ALTER TABLE public.payment_requests ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.payment_requests ALTER COLUMN updated_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN request_code SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.request_code: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN payment_type SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.payment_type: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN amount SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.amount: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN currency SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.currency: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.payment_requests ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null payment_requests.updated_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.pricing_plans ();
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS reference text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS client_name text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS business_name text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS industry text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS project_goal text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS target_audience text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS recommended_plan text DEFAULT 'Growth'::text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS base_price numeric DEFAULT 0;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS estimate_min numeric DEFAULT 0;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS estimate_max numeric DEFAULT 0;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS currency text DEFAULT 'NGN'::text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS answers jsonb DEFAULT '{}'::jsonb;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS complexity_factors jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS required_pages jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS required_features jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS required_integrations jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS design_direction text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS timeline text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS rationale text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS status text DEFAULT 'generated'::text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS share_count integer DEFAULT 0;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS goldie_session_id text;
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.pricing_plans ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.pricing_plans ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.pricing_plans ALTER COLUMN recommended_plan SET DEFAULT 'Growth'::text;
ALTER TABLE public.pricing_plans ALTER COLUMN base_price SET DEFAULT 0;
ALTER TABLE public.pricing_plans ALTER COLUMN estimate_min SET DEFAULT 0;
ALTER TABLE public.pricing_plans ALTER COLUMN estimate_max SET DEFAULT 0;
ALTER TABLE public.pricing_plans ALTER COLUMN currency SET DEFAULT 'NGN'::text;
ALTER TABLE public.pricing_plans ALTER COLUMN answers SET DEFAULT '{}'::jsonb;
ALTER TABLE public.pricing_plans ALTER COLUMN complexity_factors SET DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ALTER COLUMN required_pages SET DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ALTER COLUMN required_features SET DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ALTER COLUMN required_integrations SET DEFAULT '[]'::jsonb;
ALTER TABLE public.pricing_plans ALTER COLUMN status SET DEFAULT 'generated'::text;
ALTER TABLE public.pricing_plans ALTER COLUMN share_count SET DEFAULT 0;
ALTER TABLE public.pricing_plans ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.pricing_plans ALTER COLUMN updated_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN reference SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.reference: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN recommended_plan SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.recommended_plan: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN base_price SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.base_price: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN estimate_min SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.estimate_min: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN estimate_max SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.estimate_max: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN currency SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.currency: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN answers SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.answers: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN complexity_factors SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.complexity_factors: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN required_pages SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.required_pages: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN required_features SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.required_features: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN required_integrations SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.required_integrations: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN share_count SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.share_count: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.pricing_plans ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null pricing_plans.updated_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.project_baselines ();
ALTER TABLE public.project_baselines ADD COLUMN IF NOT EXISTS project_id text;
ALTER TABLE public.project_baselines ADD COLUMN IF NOT EXISTS base_appreciations integer;
ALTER TABLE public.project_baselines ADD COLUMN IF NOT EXISTS base_views integer;
ALTER TABLE public.project_baselines ADD COLUMN IF NOT EXISTS base_live_visits integer;
ALTER TABLE public.project_baselines ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.project_baselines ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_baselines ALTER COLUMN project_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_baselines.project_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_baselines ALTER COLUMN base_appreciations SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_baselines.base_appreciations: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_baselines ALTER COLUMN base_views SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_baselines.base_views: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_baselines ALTER COLUMN base_live_visits SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_baselines.base_live_visits: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_baselines ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_baselines.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.project_interactions ();
ALTER TABLE public.project_interactions ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.project_interactions ADD COLUMN IF NOT EXISTS project_id text;
ALTER TABLE public.project_interactions ADD COLUMN IF NOT EXISTS interaction_type text;
ALTER TABLE public.project_interactions ADD COLUMN IF NOT EXISTS visitor_id text;
ALTER TABLE public.project_interactions ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.project_interactions ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.project_interactions ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_interactions ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_interactions.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_interactions ALTER COLUMN project_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_interactions.project_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_interactions ALTER COLUMN interaction_type SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_interactions.interaction_type: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_interactions ALTER COLUMN visitor_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_interactions.visitor_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.project_interactions ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null project_interactions.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.proposal_versions ();
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS proposal_id uuid;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS version integer;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS snapshot jsonb DEFAULT '{}'::jsonb;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS previous_pricing text;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS new_pricing text;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS change_summary text;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS editor_email text;
ALTER TABLE public.proposal_versions ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.proposal_versions ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.proposal_versions ALTER COLUMN snapshot SET DEFAULT '{}'::jsonb;
ALTER TABLE public.proposal_versions ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposal_versions ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposal_versions.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposal_versions ALTER COLUMN proposal_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposal_versions.proposal_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposal_versions ALTER COLUMN version SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposal_versions.version: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposal_versions ALTER COLUMN snapshot SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposal_versions.snapshot: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposal_versions ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposal_versions.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.proposals ();
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS reference text DEFAULT ('PROPOSAL-'::text || upper(substr(md5((random())::text), 1, 4)));
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS title text DEFAULT 'Project Proposal'::text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS subtitle text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS client_name text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS project_name text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS template text DEFAULT 'premium'::text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS accent_color text DEFAULT '#C9A227'::text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS secondary_color text DEFAULT '#111111'::text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS logo_url text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS sections jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS recommended_plan text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS estimated_range text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS official_quote text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS timeline text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS support_period text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS terms text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS status text DEFAULT 'draft'::text;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS version integer DEFAULT 1;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS assets jsonb DEFAULT '[]'::jsonb;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
ALTER TABLE public.proposals ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.proposals ALTER COLUMN reference SET DEFAULT ('PROPOSAL-'::text || upper(substr(md5((random())::text), 1, 4)));
ALTER TABLE public.proposals ALTER COLUMN title SET DEFAULT 'Project Proposal'::text;
ALTER TABLE public.proposals ALTER COLUMN template SET DEFAULT 'premium'::text;
ALTER TABLE public.proposals ALTER COLUMN accent_color SET DEFAULT '#C9A227'::text;
ALTER TABLE public.proposals ALTER COLUMN secondary_color SET DEFAULT '#111111'::text;
ALTER TABLE public.proposals ALTER COLUMN sections SET DEFAULT '[]'::jsonb;
ALTER TABLE public.proposals ALTER COLUMN status SET DEFAULT 'draft'::text;
ALTER TABLE public.proposals ALTER COLUMN version SET DEFAULT 1;
ALTER TABLE public.proposals ALTER COLUMN assets SET DEFAULT '[]'::jsonb;
ALTER TABLE public.proposals ALTER COLUMN created_at SET DEFAULT now();
ALTER TABLE public.proposals ALTER COLUMN updated_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN reference SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.reference: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN title SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.title: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN template SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.template: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN accent_color SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.accent_color: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN secondary_color SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.secondary_color: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN sections SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.sections: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN status SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.status: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN version SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.version: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN assets SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.assets: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.created_at: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.proposals ALTER COLUMN updated_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null proposals.updated_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.testimonials ();
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS full_name text;
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS display_name text;
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS title text;
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS rating integer;
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS message text;
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS approved boolean DEFAULT false;
ALTER TABLE public.testimonials ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.testimonials ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.testimonials ALTER COLUMN approved SET DEFAULT false;
ALTER TABLE public.testimonials ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN full_name SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.full_name: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN display_name SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.display_name: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN title SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.title: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN rating SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.rating: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN message SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.message: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN approved SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.approved: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.testimonials ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null testimonials.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.transcript_exports ();
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS lead_id uuid;
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS goldie_session_id text;
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS format text DEFAULT 'pdf'::text;
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS export_type text DEFAULT 'client'::text;
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS filename text;
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS created_by uuid;
ALTER TABLE public.transcript_exports ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.transcript_exports ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.transcript_exports ALTER COLUMN format SET DEFAULT 'pdf'::text;
ALTER TABLE public.transcript_exports ALTER COLUMN export_type SET DEFAULT 'client'::text;
ALTER TABLE public.transcript_exports ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.transcript_exports ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null transcript_exports.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.transcript_exports ALTER COLUMN format SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null transcript_exports.format: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.transcript_exports ALTER COLUMN export_type SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null transcript_exports.export_type: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.transcript_exports ALTER COLUMN filename SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null transcript_exports.filename: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.transcript_exports ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null transcript_exports.created_at: %', SQLERRM; END $do$;
CREATE TABLE IF NOT EXISTS public.user_roles ();
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS id uuid DEFAULT gen_random_uuid();
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS user_id uuid;
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS role app_role;
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE public.user_roles ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.user_roles ALTER COLUMN created_at SET DEFAULT now();
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.user_roles ALTER COLUMN id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null user_roles.id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.user_roles ALTER COLUMN user_id SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null user_roles.user_id: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.user_roles ALTER COLUMN role SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null user_roles.role: %', SQLERRM; END $do$;
DO $do$ BEGIN EXECUTE 'ALTER TABLE public.user_roles ALTER COLUMN created_at SET NOT NULL'; EXCEPTION WHEN others THEN RAISE NOTICE 'skip not-null user_roles.created_at: %', SQLERRM; END $do$;

-- ============ FUNCTIONS ============
CREATE OR REPLACE FUNCTION public.create_draft_proposal(_lead_id uuid, _title text, _client_name text, _project_name text, _description text, _recommended_plan text, _estimated_range text, _timeline text, _sections jsonb DEFAULT '[]'::jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.ensure_project_baseline(_project_id text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.generate_payment_code()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  candidate text;
  i int;
BEGIN
  LOOP
    candidate := 'PXS-';
    FOR i IN 1..7 LOOP
      candidate := candidate || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    END LOOP;
    EXIT WHEN NOT EXISTS (SELECT 1 FROM public.payment_requests WHERE request_code = candidate);
  END LOOP;
  RETURN candidate;
END;
$function$
;
CREATE OR REPLACE FUNCTION public.get_project_engagement(_project_ids text[])
 RETURNS TABLE(project_id text, appreciations bigint, views bigint, live_visits bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT
    p.pid AS project_id,
    COALESCE(b.base_appreciations, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'appreciation'), 0) AS appreciations,
    COALESCE(b.base_views, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'view'), 0) AS views,
    COALESCE(b.base_live_visits, 0) + COALESCE((SELECT count(*) FROM public.project_interactions i WHERE i.project_id = p.pid AND i.interaction_type = 'live_visit'), 0) AS live_visits
  FROM unnest(_project_ids) AS p(pid)
  LEFT JOIN public.project_baselines b ON b.project_id = p.pid;
$function$
;
CREATE OR REPLACE FUNCTION public.get_public_payment_request(_code text)
 RETURNS TABLE(request_code text, client_name text, project_name text, project_type text, payment_type text, amount numeric, currency text, description text, status text, expires_at timestamp with time zone, paid_at timestamp with time zone, created_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT
    p.request_code,
    p.client_name,
    p.project_name,
    p.project_type,
    p.payment_type,
    p.amount,
    p.currency,
    p.description,
    CASE
      WHEN p.status = 'pending' AND p.expires_at IS NOT NULL AND p.expires_at < now() THEN 'expired'
      ELSE p.status
    END AS status,
    p.expires_at,
    p.paid_at,
    p.created_at
  FROM public.payment_requests p
  WHERE upper(p.request_code) = upper(_code)
  LIMIT 1;
$function$
;
CREATE OR REPLACE FUNCTION public.get_shared_plan(_reference text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.has_appreciated(_project_id text, _visitor_id text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.project_interactions
    WHERE project_id = _project_id AND interaction_type = 'appreciation' AND visitor_id = _visitor_id
  );
$function$
;
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role);
$function$
;
CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE uid uuid; mail text;
BEGIN
  uid := auth.uid();
  IF uid IS NULL THEN RETURN false; END IF;
  IF public.has_role(uid, 'admin') THEN RETURN true; END IF;
  SELECT lower(u.email) INTO mail FROM auth.users u WHERE u.id = uid;
  IF mail IS NULL THEN RETURN false; END IF;
  RETURN EXISTS (SELECT 1 FROM public.admin_allowlist a WHERE lower(a.email) = mail);
END;
$function$
;
CREATE OR REPLACE FUNCTION public.log_error_event(_fingerprint text, _message text, _severity text DEFAULT 'error'::text, _feature text DEFAULT 'unknown'::text, _category text DEFAULT 'unknown'::text, _environment text DEFAULT 'production'::text, _side text DEFAULT 'client'::text, _route text DEFAULT NULL::text, _operation text DEFAULT NULL::text, _stack text DEFAULT NULL::text, _context jsonb DEFAULT '{}'::jsonb, _lead_id uuid DEFAULT NULL::uuid, _proposal_id uuid DEFAULT NULL::uuid, _goldie_session_id text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.mark_plan_shared(_reference text)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  UPDATE public.pricing_plans
  SET share_count = share_count + 1,
      status = CASE WHEN status IN ('draft','generated') THEN 'shared' ELSE status END
  WHERE reference = _reference;
$function$
;
CREATE OR REPLACE FUNCTION public.record_project_interaction(_project_id text, _interaction_type text, _visitor_id text)
 RETURNS TABLE(project_id text, appreciations bigint, views bigint, live_visits bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.submit_plan(_reference text, _client_name text DEFAULT NULL::text, _contact_email text DEFAULT NULL::text, _contact_phone text DEFAULT NULL::text, _note text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

-- ============ CONSTRAINTS ============
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='admin_allowlist_pkey' AND conrelid='public.admin_allowlist'::regclass) THEN ALTER TABLE public.admin_allowlist ADD CONSTRAINT admin_allowlist_pkey PRIMARY KEY (email); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='admin_audit_log_pkey' AND conrelid='public.admin_audit_log'::regclass) THEN ALTER TABLE public.admin_audit_log ADD CONSTRAINT admin_audit_log_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='contact_events_pkey' AND conrelid='public.contact_events'::regclass) THEN ALTER TABLE public.contact_events ADD CONSTRAINT contact_events_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='error_events_pkey' AND conrelid='public.error_events'::regclass) THEN ALTER TABLE public.error_events ADD CONSTRAINT error_events_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='error_occurrences_pkey' AND conrelid='public.error_occurrences'::regclass) THEN ALTER TABLE public.error_occurrences ADD CONSTRAINT error_occurrences_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='goldie_leads_pkey' AND conrelid='public.goldie_leads'::regclass) THEN ALTER TABLE public.goldie_leads ADD CONSTRAINT goldie_leads_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='lead_followups_pkey' AND conrelid='public.lead_followups'::regclass) THEN ALTER TABLE public.lead_followups ADD CONSTRAINT lead_followups_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_events_pkey' AND conrelid='public.payment_events'::regclass) THEN ALTER TABLE public.payment_events ADD CONSTRAINT payment_events_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_pkey' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='pricing_plans_pkey' AND conrelid='public.pricing_plans'::regclass) THEN ALTER TABLE public.pricing_plans ADD CONSTRAINT pricing_plans_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='project_baselines_pkey' AND conrelid='public.project_baselines'::regclass) THEN ALTER TABLE public.project_baselines ADD CONSTRAINT project_baselines_pkey PRIMARY KEY (project_id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='project_interactions_pkey' AND conrelid='public.project_interactions'::regclass) THEN ALTER TABLE public.project_interactions ADD CONSTRAINT project_interactions_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='proposal_versions_pkey' AND conrelid='public.proposal_versions'::regclass) THEN ALTER TABLE public.proposal_versions ADD CONSTRAINT proposal_versions_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='proposals_pkey' AND conrelid='public.proposals'::regclass) THEN ALTER TABLE public.proposals ADD CONSTRAINT proposals_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='testimonials_pkey' AND conrelid='public.testimonials'::regclass) THEN ALTER TABLE public.testimonials ADD CONSTRAINT testimonials_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='transcript_exports_pkey' AND conrelid='public.transcript_exports'::regclass) THEN ALTER TABLE public.transcript_exports ADD CONSTRAINT transcript_exports_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='user_roles_pkey' AND conrelid='public.user_roles'::regclass) THEN ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='error_events_fingerprint_key' AND conrelid='public.error_events'::regclass) THEN ALTER TABLE public.error_events ADD CONSTRAINT error_events_fingerprint_key UNIQUE (fingerprint); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_request_code_key' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_request_code_key UNIQUE (request_code); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='pricing_plans_reference_key' AND conrelid='public.pricing_plans'::regclass) THEN ALTER TABLE public.pricing_plans ADD CONSTRAINT pricing_plans_reference_key UNIQUE (reference); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='user_roles_user_id_role_key' AND conrelid='public.user_roles'::regclass) THEN ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='contact_events_kind_check' AND conrelid='public.contact_events'::regclass) THEN ALTER TABLE public.contact_events ADD CONSTRAINT contact_events_kind_check CHECK ((kind = ANY (ARRAY['received'::text, 'initiated'::text]))); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_amount_check' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_amount_check CHECK ((amount > (0)::numeric)); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_currency_check' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_currency_check CHECK ((currency = ANY (ARRAY['NGN'::text, 'USD'::text, 'GHS'::text, 'KES'::text, 'ZAR'::text, 'GBP'::text, 'EUR'::text]))); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_payment_type_check' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_payment_type_check CHECK ((payment_type = ANY (ARRAY['full'::text, 'deposit'::text, 'milestone'::text, 'custom'::text]))); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_status_check' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'cancelled'::text, 'expired'::text, 'refunded'::text]))); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='project_interactions_interaction_type_check' AND conrelid='public.project_interactions'::regclass) THEN ALTER TABLE public.project_interactions ADD CONSTRAINT project_interactions_interaction_type_check CHECK ((interaction_type = ANY (ARRAY['view'::text, 'appreciation'::text, 'live_visit'::text]))); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='testimonials_rating_check' AND conrelid='public.testimonials'::regclass) THEN ALTER TABLE public.testimonials ADD CONSTRAINT testimonials_rating_check CHECK (((rating >= 1) AND (rating <= 5))); END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='contact_events_lead_id_fkey' AND conrelid='public.contact_events'::regclass) THEN ALTER TABLE public.contact_events ADD CONSTRAINT contact_events_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE SET NULL; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='error_events_lead_id_fkey' AND conrelid='public.error_events'::regclass) THEN ALTER TABLE public.error_events ADD CONSTRAINT error_events_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE SET NULL; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='error_occurrences_error_id_fkey' AND conrelid='public.error_occurrences'::regclass) THEN ALTER TABLE public.error_occurrences ADD CONSTRAINT error_occurrences_error_id_fkey FOREIGN KEY (error_id) REFERENCES error_events(id) ON DELETE CASCADE; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='lead_followups_lead_id_fkey' AND conrelid='public.lead_followups'::regclass) THEN ALTER TABLE public.lead_followups ADD CONSTRAINT lead_followups_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE CASCADE; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='lead_followups_proposal_id_fkey' AND conrelid='public.lead_followups'::regclass) THEN ALTER TABLE public.lead_followups ADD CONSTRAINT lead_followups_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals(id) ON DELETE SET NULL; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_events_payment_request_id_fkey' AND conrelid='public.payment_events'::regclass) THEN ALTER TABLE public.payment_events ADD CONSTRAINT payment_events_payment_request_id_fkey FOREIGN KEY (payment_request_id) REFERENCES payment_requests(id) ON DELETE CASCADE; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='payment_requests_lead_id_fkey' AND conrelid='public.payment_requests'::regclass) THEN ALTER TABLE public.payment_requests ADD CONSTRAINT payment_requests_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE SET NULL; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='pricing_plans_lead_id_fkey' AND conrelid='public.pricing_plans'::regclass) THEN ALTER TABLE public.pricing_plans ADD CONSTRAINT pricing_plans_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE SET NULL; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='proposal_versions_proposal_id_fkey' AND conrelid='public.proposal_versions'::regclass) THEN ALTER TABLE public.proposal_versions ADD CONSTRAINT proposal_versions_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals(id) ON DELETE CASCADE; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='proposals_lead_id_fkey' AND conrelid='public.proposals'::regclass) THEN ALTER TABLE public.proposals ADD CONSTRAINT proposals_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE SET NULL; END IF; END $do$;
DO $do$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='transcript_exports_lead_id_fkey' AND conrelid='public.transcript_exports'::regclass) THEN ALTER TABLE public.transcript_exports ADD CONSTRAINT transcript_exports_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES goldie_leads(id) ON DELETE SET NULL; END IF; END $do$;

-- ============ INDEXES ============
CREATE INDEX IF NOT EXISTS idx_audit_created ON public.admin_audit_log USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_error_events_last_seen ON public.error_events USING btree (last_seen DESC);
CREATE INDEX IF NOT EXISTS idx_error_events_severity ON public.error_events USING btree (severity);
CREATE INDEX IF NOT EXISTS idx_error_events_status ON public.error_events USING btree (status);
CREATE INDEX IF NOT EXISTS idx_error_occurrences_error ON public.error_occurrences USING btree (error_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_followups_lead ON public.lead_followups USING btree (lead_id);
CREATE INDEX IF NOT EXISTS idx_followups_scheduled ON public.lead_followups USING btree (scheduled_at);
CREATE INDEX IF NOT EXISTS idx_project_interactions_project_type ON public.project_interactions USING btree (project_id, interaction_type);
CREATE INDEX IF NOT EXISTS idx_proposal_versions_proposal ON public.proposal_versions USING btree (proposal_id, version DESC);
CREATE INDEX IF NOT EXISTS idx_proposals_created ON public.proposals USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_proposals_lead ON public.proposals USING btree (lead_id);
CREATE INDEX IF NOT EXISTS payment_events_request_idx ON public.payment_events USING btree (payment_request_id, created_at DESC);
CREATE INDEX IF NOT EXISTS payment_requests_created_idx ON public.payment_requests USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS payment_requests_status_idx ON public.payment_requests USING btree (status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_project_interactions_unique_visitor ON public.project_interactions USING btree (project_id, interaction_type, visitor_id) WHERE (interaction_type = ANY (ARRAY['view'::text, 'appreciation'::text]));
CREATE UNIQUE INDEX IF NOT EXISTS payment_requests_flw_txn_idx ON public.payment_requests USING btree (flutterwave_transaction_id) WHERE (flutterwave_transaction_id IS NOT NULL);

-- ============ TRIGGERS ============
DROP TRIGGER IF EXISTS update_contact_events_updated_at ON public.contact_events;
CREATE TRIGGER update_contact_events_updated_at BEFORE UPDATE ON public.contact_events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_goldie_leads_updated_at ON public.goldie_leads;
CREATE TRIGGER update_goldie_leads_updated_at BEFORE UPDATE ON public.goldie_leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_followups_updated_at ON public.lead_followups;
CREATE TRIGGER update_followups_updated_at BEFORE UPDATE ON public.lead_followups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_payment_requests_updated_at ON public.payment_requests;
CREATE TRIGGER update_payment_requests_updated_at BEFORE UPDATE ON public.payment_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_pricing_plans_updated_at ON public.pricing_plans;
CREATE TRIGGER update_pricing_plans_updated_at BEFORE UPDATE ON public.pricing_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_proposals_updated_at ON public.proposals;
CREATE TRIGGER update_proposals_updated_at BEFORE UPDATE ON public.proposals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============ GRANTS ============
-- RLS below is what actually restricts access; PostgREST additionally requires these table grants.
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.admin_allowlist TO anon, authenticated;
GRANT ALL ON TABLE public.admin_allowlist TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.admin_audit_log TO anon, authenticated;
GRANT ALL ON TABLE public.admin_audit_log TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.contact_events TO anon, authenticated;
GRANT ALL ON TABLE public.contact_events TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.error_events TO anon, authenticated;
GRANT ALL ON TABLE public.error_events TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.error_occurrences TO anon, authenticated;
GRANT ALL ON TABLE public.error_occurrences TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.goldie_leads TO anon, authenticated;
GRANT ALL ON TABLE public.goldie_leads TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.lead_followups TO anon, authenticated;
GRANT ALL ON TABLE public.lead_followups TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.payment_events TO anon, authenticated;
GRANT ALL ON TABLE public.payment_events TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.payment_requests TO anon, authenticated;
GRANT ALL ON TABLE public.payment_requests TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.pricing_plans TO anon, authenticated;
GRANT ALL ON TABLE public.pricing_plans TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.project_baselines TO anon, authenticated;
GRANT ALL ON TABLE public.project_baselines TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.project_interactions TO anon, authenticated;
GRANT ALL ON TABLE public.project_interactions TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.proposal_versions TO anon, authenticated;
GRANT ALL ON TABLE public.proposal_versions TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.proposals TO anon, authenticated;
GRANT ALL ON TABLE public.proposals TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.testimonials TO anon, authenticated;
GRANT ALL ON TABLE public.testimonials TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.transcript_exports TO anon, authenticated;
GRANT ALL ON TABLE public.transcript_exports TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_roles TO anon, authenticated;
GRANT ALL ON TABLE public.user_roles TO service_role;

-- ============ ROW LEVEL SECURITY ============
ALTER TABLE public.admin_allowlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.error_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.error_occurrences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goldie_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_baselines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposal_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transcript_exports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins manage audit log" ON public.admin_audit_log;
CREATE POLICY "Admins manage audit log" ON public.admin_audit_log AS PERMISSIVE FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins can delete contact activity" ON public.contact_events;
CREATE POLICY "Admins can delete contact activity" ON public.contact_events AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can read contact activity" ON public.contact_events;
CREATE POLICY "Admins can read contact activity" ON public.contact_events AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can update contact activity" ON public.contact_events;
CREATE POLICY "Admins can update contact activity" ON public.contact_events AS PERMISSIVE FOR UPDATE TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Anyone can log contact activity" ON public.contact_events;
CREATE POLICY "Anyone can log contact activity" ON public.contact_events AS PERMISSIVE FOR INSERT TO anon, authenticated
  WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete errors" ON public.error_events;
CREATE POLICY "Admins can delete errors" ON public.error_events AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can update errors" ON public.error_events;
CREATE POLICY "Admins can update errors" ON public.error_events AS PERMISSIVE FOR UPDATE TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins can view errors" ON public.error_events;
CREATE POLICY "Admins can view errors" ON public.error_events AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can delete occurrences" ON public.error_occurrences;
CREATE POLICY "Admins can delete occurrences" ON public.error_occurrences AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can view occurrences" ON public.error_occurrences;
CREATE POLICY "Admins can view occurrences" ON public.error_occurrences AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can delete project briefs" ON public.goldie_leads;
CREATE POLICY "Admins can delete project briefs" ON public.goldie_leads AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can update project briefs" ON public.goldie_leads;
CREATE POLICY "Admins can update project briefs" ON public.goldie_leads AS PERMISSIVE FOR UPDATE TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins can view project briefs" ON public.goldie_leads;
CREATE POLICY "Admins can view project briefs" ON public.goldie_leads AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Anyone can submit a project brief" ON public.goldie_leads;
CREATE POLICY "Anyone can submit a project brief" ON public.goldie_leads AS PERMISSIVE FOR INSERT TO anon, authenticated
  WITH CHECK (((status = 'new'::text) AND (priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text])) AND (admin_notes IS NULL)));
DROP POLICY IF EXISTS "Admins manage followups" ON public.lead_followups;
CREATE POLICY "Admins manage followups" ON public.lead_followups AS PERMISSIVE FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins view payment events" ON public.payment_events;
CREATE POLICY "Admins view payment events" ON public.payment_events AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins manage payment requests" ON public.payment_requests;
CREATE POLICY "Admins manage payment requests" ON public.payment_requests AS PERMISSIVE FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins can delete pricing plans" ON public.pricing_plans;
CREATE POLICY "Admins can delete pricing plans" ON public.pricing_plans AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can read pricing plans" ON public.pricing_plans;
CREATE POLICY "Admins can read pricing plans" ON public.pricing_plans AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can update pricing plans" ON public.pricing_plans;
CREATE POLICY "Admins can update pricing plans" ON public.pricing_plans AS PERMISSIVE FOR UPDATE TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Anyone can create a pricing plan" ON public.pricing_plans;
CREATE POLICY "Anyone can create a pricing plan" ON public.pricing_plans AS PERMISSIVE FOR INSERT TO anon, authenticated
  WITH CHECK (true);
DROP POLICY IF EXISTS "Baselines are publicly readable" ON public.project_baselines;
CREATE POLICY "Baselines are publicly readable" ON public.project_baselines AS PERMISSIVE FOR SELECT TO anon, authenticated
  USING (true);
DROP POLICY IF EXISTS "Admins can view interactions" ON public.project_interactions;
CREATE POLICY "Admins can view interactions" ON public.project_interactions AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Anyone can register an interaction" ON public.project_interactions;
CREATE POLICY "Anyone can register an interaction" ON public.project_interactions AS PERMISSIVE FOR INSERT TO anon, authenticated
  WITH CHECK (((length(visitor_id) >= 8) AND (length(visitor_id) <= 64) AND ((length(project_id) >= 1) AND (length(project_id) <= 80))));
DROP POLICY IF EXISTS "Admins manage proposal versions" ON public.proposal_versions;
CREATE POLICY "Admins manage proposal versions" ON public.proposal_versions AS PERMISSIVE FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins manage proposals" ON public.proposals;
CREATE POLICY "Admins manage proposals" ON public.proposals AS PERMISSIVE FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins can delete testimonials" ON public.testimonials;
CREATE POLICY "Admins can delete testimonials" ON public.testimonials AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can update testimonials" ON public.testimonials;
CREATE POLICY "Admins can update testimonials" ON public.testimonials AS PERMISSIVE FOR UPDATE TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
DROP POLICY IF EXISTS "Admins can view all testimonials" ON public.testimonials;
CREATE POLICY "Admins can view all testimonials" ON public.testimonials AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Anyone can submit testimonials" ON public.testimonials;
CREATE POLICY "Anyone can submit testimonials" ON public.testimonials AS PERMISSIVE FOR INSERT TO anon, authenticated
  WITH CHECK ((approved = false));
DROP POLICY IF EXISTS "Anyone can view approved testimonials" ON public.testimonials;
CREATE POLICY "Anyone can view approved testimonials" ON public.testimonials AS PERMISSIVE FOR SELECT TO anon, authenticated
  USING ((approved = true));
DROP POLICY IF EXISTS "Admins can delete transcript exports" ON public.transcript_exports;
CREATE POLICY "Admins can delete transcript exports" ON public.transcript_exports AS PERMISSIVE FOR DELETE TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Admins can read transcript exports" ON public.transcript_exports;
CREATE POLICY "Admins can read transcript exports" ON public.transcript_exports AS PERMISSIVE FOR SELECT TO authenticated
  USING (is_admin());
DROP POLICY IF EXISTS "Anyone can record a transcript export" ON public.transcript_exports;
CREATE POLICY "Anyone can record a transcript export" ON public.transcript_exports AS PERMISSIVE FOR INSERT TO anon, authenticated
  WITH CHECK (true);
DROP POLICY IF EXISTS "Users can read own roles" ON public.user_roles;
CREATE POLICY "Users can read own roles" ON public.user_roles AS PERMISSIVE FOR SELECT TO authenticated
  USING ((user_id = auth.uid()));


-- ============ FUNCTION EXECUTE GRANTS ============
DO $do$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT p.oid::regprocedure AS sig
    FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
  LOOP
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO anon, authenticated, service_role', r.sig);
  END LOOP;
END $do$;

-- ============ ADMIN ACCESS ============
-- is_admin() trusts public.admin_allowlist (by email) and public.user_roles.
-- Make sure your admin email is present in your own project:
INSERT INTO public.admin_allowlist (email)
VALUES ('pixelsparkx@gmail.com')
ON CONFLICT (email) DO NOTHING;

-- Optional: also grant the admin role row once the user has signed in.
-- INSERT INTO public.user_roles (user_id, role)
-- SELECT id, 'admin'::public.app_role FROM auth.users WHERE lower(email) = 'pixelsparkx@gmail.com'
-- ON CONFLICT (user_id, role) DO NOTHING;

-- ============ NOT COVERED BY SQL ============
-- * Auth providers (Google OAuth), email templates and redirect URLs are
--   configured in Authentication settings, not in SQL.
-- * No storage buckets are in use by PixelSpark, so none are created here.
-- * App secrets (FLUTTERWAVE_SECRET_KEY, FLUTTERWAVE_WEBHOOK_HASH,
--   AI gateway key) live in your hosting environment, not the database.
