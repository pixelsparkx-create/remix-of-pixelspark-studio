
REVOKE EXECUTE ON FUNCTION public.engagement_rule(text, numeric) FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.score_lead(uuid) FROM anon, public;
GRANT EXECUTE ON FUNCTION public.engagement_rule(text, numeric) TO service_role;
GRANT EXECUTE ON FUNCTION public.score_lead(uuid) TO authenticated, service_role;
