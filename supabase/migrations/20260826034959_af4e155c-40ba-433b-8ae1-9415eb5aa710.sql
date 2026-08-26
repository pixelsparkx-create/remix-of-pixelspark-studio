CREATE TABLE IF NOT EXISTS public.payment_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_code text NOT NULL UNIQUE,
  client_name text,
  client_email text,
  client_phone text,
  project_name text,
  project_type text,
  payment_type text NOT NULL DEFAULT 'full' CHECK (payment_type IN ('full','deposit','milestone','custom')),
  amount numeric(14,2) NOT NULL CHECK (amount > 0),
  currency text NOT NULL DEFAULT 'NGN' CHECK (currency IN ('NGN','USD','GHS','KES','ZAR','GBP','EUR')),
  description text,
  internal_note text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','paid','failed','cancelled','expired','refunded')),
  flutterwave_transaction_id text,
  flutterwave_reference text,
  flutterwave_payment_link text,
  lead_id uuid REFERENCES public.goldie_leads(id) ON DELETE SET NULL,
  paid_at timestamptz,
  expires_at timestamptz,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS payment_requests_flw_txn_idx ON public.payment_requests (flutterwave_transaction_id) WHERE flutterwave_transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS payment_requests_status_idx ON public.payment_requests (status);
CREATE INDEX IF NOT EXISTS payment_requests_created_idx ON public.payment_requests (created_at DESC);

GRANT SELECT, INSERT, UPDATE ON public.payment_requests TO authenticated;
GRANT ALL ON public.payment_requests TO service_role;
ALTER TABLE public.payment_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins manage payment requests" ON public.payment_requests;
CREATE POLICY "Admins manage payment requests" ON public.payment_requests
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE TABLE IF NOT EXISTS public.payment_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_request_id uuid NOT NULL REFERENCES public.payment_requests(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  from_status text,
  to_status text,
  detail text,
  actor text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS payment_events_request_idx ON public.payment_events (payment_request_id, created_at DESC);

GRANT SELECT ON public.payment_events TO authenticated;
GRANT ALL ON public.payment_events TO service_role;
ALTER TABLE public.payment_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins view payment events" ON public.payment_events;
CREATE POLICY "Admins view payment events" ON public.payment_events
  FOR SELECT TO authenticated USING (public.is_admin());

DROP TRIGGER IF EXISTS update_payment_requests_updated_at ON public.payment_requests;
CREATE TRIGGER update_payment_requests_updated_at
  BEFORE UPDATE ON public.payment_requests
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE OR REPLACE FUNCTION public.generate_payment_code()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
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
$$;

-- Public-safe lookup for the /pay page. Returns only client-visible fields.
CREATE OR REPLACE FUNCTION public.get_public_payment_request(_code text)
RETURNS TABLE(
  request_code text,
  client_name text,
  project_name text,
  project_type text,
  payment_type text,
  amount numeric,
  currency text,
  description text,
  status text,
  expires_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
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
$$;

GRANT EXECUTE ON FUNCTION public.get_public_payment_request(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.generate_payment_code() TO authenticated, service_role;