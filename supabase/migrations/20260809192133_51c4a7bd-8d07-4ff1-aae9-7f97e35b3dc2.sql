-- roles enum + table
DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin','moderator','user');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role public.app_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.admin_allowlist (
  email text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT ALL ON public.admin_allowlist TO service_role;
ALTER TABLE public.admin_allowlist ENABLE ROW LEVEL SECURITY;

INSERT INTO public.admin_allowlist (email) VALUES ('pixelsparkx@gmail.com')
ON CONFLICT (email) DO NOTHING;

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role);
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
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

CREATE POLICY "Users can read own roles" ON public.user_roles
FOR SELECT TO authenticated USING (user_id = auth.uid());

-- admin access to testimonials
CREATE POLICY "Admins can view all testimonials" ON public.testimonials
FOR SELECT TO authenticated USING (public.is_admin());

CREATE POLICY "Admins can update testimonials" ON public.testimonials
FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete testimonials" ON public.testimonials
FOR DELETE TO authenticated USING (public.is_admin());

-- admin read of engagement rows
CREATE POLICY "Admins can view interactions" ON public.project_interactions
FOR SELECT TO authenticated USING (public.is_admin());