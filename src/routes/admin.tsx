import { createFileRoute } from "@tanstack/react-router";
import { useCallback, useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { projects } from "@/lib/projects";
import { formatCount } from "@/lib/engagement";
import {
  Heart,
  Eye,
  ExternalLink,
  LayoutDashboard,
  MessageSquareQuote,
  BarChart3,
  FolderKanban,
  LogOut,
  Loader2,
  Check,
  X,
  Lock,
  ShieldCheck,
  Sparkles,
} from "lucide-react";

export const Route = createFileRoute("/admin")({
  ssr: false,
  head: () => ({
    meta: [
      { title: "Admin — PixelSpark" },
      { name: "description", content: "Private PixelSpark administration area." },
      { name: "robots", content: "noindex, nofollow" },
      { property: "og:title", content: "Admin — PixelSpark" },
      { property: "og:description", content: "Private PixelSpark administration area." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: AdminPage,
});

type Testimonial = {
  id: string;
  full_name: string;
  display_name: string;
  title: string;
  rating: number;
  message: string;
  approved: boolean;
  created_at: string;
};

type Engagement = { project_id: string; appreciations: number; views: number; live_visits: number };

type Status = "loading" | "signed-out" | "unauthorized" | "admin";

function AdminPage() {
  const [status, setStatus] = useState<Status>("loading");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const check = useCallback(async () => {
    const { data } = await supabase.auth.getUser();
    if (!data.user) return setStatus("signed-out");
    const { data: ok } = await (supabase as any).rpc("is_admin");
    setStatus(ok === true ? "admin" : "unauthorized");
  }, []);

  useEffect(() => {
    void check();
  }, [check]);

  async function onSignIn(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setBusy(false);
    if (error) return setError(error.message);
    setStatus("loading");
    void check();
  }

  async function signOut() {
    await supabase.auth.signOut();
    setStatus("signed-out");
  }

  if (status === "loading") {
    return (
      <main className="min-h-screen grid place-items-center bg-background">
        <Loader2 className="h-6 w-6 animate-spin text-gold" />
      </main>
    );
  }

  if (status !== "admin") {
    return (
      <main className="min-h-screen grid place-items-center px-6 py-16 bg-gradient-ink">
        <div className="w-full max-w-md rounded-3xl border border-border bg-card shadow-card p-8">
          <div className="flex items-center gap-2 text-xs font-semibold tracking-[0.2em] text-gold">
            <Lock className="h-3.5 w-3.5" /> PIXELSPARK ADMIN
          </div>
          <h1 className="mt-2 text-2xl font-bold">Private access</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            {status === "unauthorized"
              ? "This account is not authorized for the PixelSpark admin area."
              : "Sign in with your authorized administrator account."}
          </p>

          {status === "unauthorized" ? (
            <button
              onClick={signOut}
              className="mt-6 w-full rounded-full border border-border px-5 py-3 font-semibold hover:border-gold hover:text-gold transition-colors"
            >
              Sign out
            </button>
          ) : (
            <form onSubmit={onSignIn} className="mt-6 space-y-3">
              <input
                type="email"
                required
                autoComplete="username"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Admin email"
                className="w-full rounded-xl border border-border bg-background px-4 py-3 text-sm"
              />
              <input
                type="password"
                required
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Password"
                className="w-full rounded-xl border border-border bg-background px-4 py-3 text-sm"
              />
              {error && <p className="text-sm text-destructive">{error}</p>}
              <button
                disabled={busy}
                className="w-full rounded-full bg-gradient-gold text-ink px-5 py-3 font-semibold shadow-gold disabled:opacity-60"
              >
                {busy ? "Signing in…" : "Sign in"}
              </button>
            </form>
          )}
        </div>
      </main>
    );
  }

  return <AdminDashboard onSignOut={signOut} />;
}

const modules = [
  { id: "overview", label: "Overview", icon: LayoutDashboard },
  { id: "portfolio", label: "Portfolio", icon: FolderKanban },
  { id: "testimonials", label: "Testimonials", icon: MessageSquareQuote },
  { id: "analytics", label: "Analytics", icon: BarChart3 },
] as const;

type ModuleId = (typeof modules)[number]["id"];

function AdminDashboard({ onSignOut }: { onSignOut: () => void }) {
  const [tab, setTab] = useState<ModuleId>("overview");
  const [testimonials, setTestimonials] = useState<Testimonial[]>([]);
  const [engagement, setEngagement] = useState<Engagement[]>([]);
  const [loading, setLoading] = useState(true);

  const slugs = useMemo(() => projects.map((p) => p.slug), []);

  const load = useCallback(async () => {
    setLoading(true);
    const [t, e] = await Promise.all([
      supabase.from("testimonials").select("*").order("created_at", { ascending: false }),
      (supabase as any).rpc("get_project_engagement", { _project_ids: slugs }),
    ]);
    setTestimonials((t.data as Testimonial[]) ?? []);
    setEngagement((e.data as Engagement[]) ?? []);
    setLoading(false);
  }, [slugs]);

  useEffect(() => {
    void load();
  }, [load]);

  const totals = engagement.reduce(
    (acc, r) => ({
      appreciations: acc.appreciations + Number(r.appreciations ?? 0),
      views: acc.views + Number(r.views ?? 0),
      live: acc.live + Number(r.live_visits ?? 0),
    }),
    { appreciations: 0, views: 0, live: 0 },
  );

  async function setApproved(id: string, approved: boolean) {
    await supabase.from("testimonials").update({ approved }).eq("id", id);
    setTestimonials((prev) => prev.map((t) => (t.id === id ? { ...t, approved } : t)));
  }

  async function remove(id: string) {
    await supabase.from("testimonials").delete().eq("id", id);
    setTestimonials((prev) => prev.filter((t) => t.id !== id));
  }

  const engagementBySlug = new Map(engagement.map((e) => [e.project_id, e]));

  return (
    <main className="min-h-screen bg-background">
      <header className="sticky top-0 z-40 border-b border-border bg-background/80 backdrop-blur-xl">
        <div className="mx-auto max-w-7xl px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2 font-display font-bold tracking-tight">
            <Sparkles className="h-5 w-5 text-gold" strokeWidth={1.5} />
            PIXELSPARK <span className="text-gold">ADMIN</span>
          </div>
          <button
            onClick={onSignOut}
            className="inline-flex items-center gap-2 text-sm rounded-full border border-border px-4 py-2 hover:border-gold hover:text-gold transition-colors"
          >
            Sign out <LogOut className="h-4 w-4" />
          </button>
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-6 py-8 grid lg:grid-cols-[220px_1fr] gap-8">
        <nav className="flex lg:flex-col gap-2 overflow-x-auto">
          {modules.map(({ id, label, icon: Icon }) => (
            <button
              key={id}
              onClick={() => setTab(id)}
              className={`inline-flex items-center gap-2 rounded-2xl px-4 py-3 text-sm font-medium whitespace-nowrap transition-all ${
                tab === id
                  ? "bg-gradient-gold text-ink shadow-gold"
                  : "border border-border hover:border-gold/60 hover:text-gold"
              }`}
            >
              <Icon className="h-4 w-4" /> {label}
            </button>
          ))}
        </nav>

        <section>
          {loading ? (
            <div className="grid place-items-center py-24">
              <Loader2 className="h-6 w-6 animate-spin text-gold" />
            </div>
          ) : tab === "overview" ? (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
              <Stat label="Portfolio Projects" value={String(projects.length)} icon={FolderKanban} />
              <Stat
                label="Testimonials"
                value={`${testimonials.filter((t) => t.approved).length} / ${testimonials.length}`}
                hint="approved / total"
                icon={MessageSquareQuote}
              />
              <Stat label="Project Appreciations" value={formatCount(totals.appreciations)} icon={Heart} />
              <Stat label="Project Views" value={formatCount(totals.views)} icon={Eye} />
              <Stat label="Live Project Visits" value={formatCount(totals.live)} icon={ExternalLink} />
              <Stat
                label="Pending Review"
                value={String(testimonials.filter((t) => !t.approved).length)}
                icon={ShieldCheck}
              />
            </div>
          ) : tab === "portfolio" ? (
            <div className="grid md:grid-cols-2 gap-5">
              {projects.map((p) => {
                const e = engagementBySlug.get(p.slug);
                return (
                  <div key={p.slug} className="rounded-2xl border border-border bg-card p-5 hover:border-gold/60 transition-colors">
                    <div className="text-xs tracking-[0.15em] text-gold">{p.category?.toUpperCase?.() ?? ""}</div>
                    <div className="font-semibold mt-1">{p.title}</div>
                    <p className="text-sm text-muted-foreground mt-1 line-clamp-2">{p.tagline ?? p.summary ?? ""}</p>
                    <div className="mt-4 flex items-center gap-4 text-xs text-muted-foreground">
                      <span className="inline-flex items-center gap-1">
                        <Heart className="h-3.5 w-3.5 text-gold" /> {formatCount(Number(e?.appreciations ?? 0))}
                      </span>
                      <span className="inline-flex items-center gap-1">
                        <Eye className="h-3.5 w-3.5 text-gold" /> {formatCount(Number(e?.views ?? 0))}
                      </span>
                      <span className="inline-flex items-center gap-1">
                        <ExternalLink className="h-3.5 w-3.5 text-gold" /> {formatCount(Number(e?.live_visits ?? 0))}
                      </span>
                    </div>
                  </div>
                );
              })}
            </div>
          ) : tab === "testimonials" ? (
            <div className="space-y-4">
              {testimonials.length === 0 && (
                <p className="text-sm text-muted-foreground">No testimonial submissions yet.</p>
              )}
              {testimonials.map((t) => (
                <div key={t.id} className="rounded-2xl border border-border bg-card p-5">
                  <div className="flex flex-wrap items-center gap-3 justify-between">
                    <div>
                      <div className="font-semibold">
                        {t.display_name}{" "}
                        <span className="text-xs text-muted-foreground font-normal">({t.full_name})</span>
                      </div>
                      <div className="text-xs text-muted-foreground">
                        {t.title} · {"★".repeat(t.rating)} · {new Date(t.created_at).toLocaleDateString()}
                      </div>
                    </div>
                    <span
                      className={`text-[10px] font-bold uppercase tracking-wider px-3 py-1 rounded-full ${
                        t.approved ? "bg-gradient-gold text-ink" : "border border-border text-muted-foreground"
                      }`}
                    >
                      {t.approved ? "Approved" : "Pending"}
                    </span>
                  </div>
                  <p className="mt-3 text-sm text-muted-foreground">{t.message}</p>
                  <div className="mt-4 flex gap-2">
                    <button
                      onClick={() => setApproved(t.id, !t.approved)}
                      className="inline-flex items-center gap-1.5 text-xs rounded-full border border-border px-4 py-2 hover:border-gold hover:text-gold transition-colors"
                    >
                      {t.approved ? <X className="h-3.5 w-3.5" /> : <Check className="h-3.5 w-3.5" />}
                      {t.approved ? "Unapprove" : "Approve"}
                    </button>
                    <button
                      onClick={() => remove(t.id)}
                      className="inline-flex items-center gap-1.5 text-xs rounded-full border border-border px-4 py-2 text-destructive hover:border-destructive transition-colors"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="rounded-3xl border border-border bg-card p-6">
              <div className="text-xs tracking-[0.2em] text-gold mb-4">PORTFOLIO ENGAGEMENT</div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-xs text-muted-foreground">
                      <th className="py-2 pr-4">Project</th>
                      <th className="py-2 pr-4">Appreciations</th>
                      <th className="py-2 pr-4">Views</th>
                      <th className="py-2">Live visits</th>
                    </tr>
                  </thead>
                  <tbody>
                    {projects.map((p) => {
                      const e = engagementBySlug.get(p.slug);
                      return (
                        <tr key={p.slug} className="border-t border-border">
                          <td className="py-3 pr-4 font-medium">{p.title}</td>
                          <td className="py-3 pr-4">{formatCount(Number(e?.appreciations ?? 0))}</td>
                          <td className="py-3 pr-4">{formatCount(Number(e?.views ?? 0))}</td>
                          <td className="py-3">{formatCount(Number(e?.live_visits ?? 0))}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </section>
      </div>
    </main>
  );
}

function Stat({
  label,
  value,
  hint,
  icon: Icon,
}: {
  label: string;
  value: string;
  hint?: string;
  icon: React.ComponentType<{ className?: string; strokeWidth?: number }>;
}) {
  return (
    <div className="group rounded-2xl border border-border bg-card p-6 hover:-translate-y-1 hover:border-gold/60 hover:shadow-gold transition-all duration-500">
      <Icon className="h-5 w-5 text-gold mb-4" strokeWidth={1.5} />
      <div className="text-3xl font-bold">{value}</div>
      <div className="text-sm text-muted-foreground mt-1">{label}</div>
      {hint && <div className="text-xs text-muted-foreground/70">{hint}</div>}
    </div>
  );
}
