import { supabase } from "@/integrations/supabase/client";

export type EngagementCounts = {
  appreciations: number;
  views: number;
  live_visits: number;
};

const VISITOR_KEY = "pxs_visitor_id";
const VIEWED_KEY = "pxs_viewed_projects";

export function getVisitorId(): string {
  if (typeof window === "undefined") return "";
  let id = localStorage.getItem(VISITOR_KEY);
  if (!id || id.length < 8) {
    id =
      typeof crypto !== "undefined" && "randomUUID" in crypto
        ? crypto.randomUUID().replace(/-/g, "")
        : Math.random().toString(36).slice(2) + Date.now().toString(36);
    localStorage.setItem(VISITOR_KEY, id);
  }
  return id;
}

function viewedSet(): Set<string> {
  if (typeof window === "undefined") return new Set();
  try {
    return new Set(JSON.parse(sessionStorage.getItem(VIEWED_KEY) || "[]") as string[]);
  } catch {
    return new Set();
  }
}

export function markViewedLocally(projectId: string) {
  const s = viewedSet();
  s.add(projectId);
  try {
    sessionStorage.setItem(VIEWED_KEY, JSON.stringify([...s]));
  } catch {
    /* ignore */
  }
}

export function alreadyViewedThisSession(projectId: string) {
  return viewedSet().has(projectId);
}

export function formatCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1).replace(/\.0$/, "")}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1).replace(/\.0$/, "")}K`;
  return `${n}`;
}

type Row = { project_id: string; appreciations: number; views: number; live_visits: number };

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const rpc = (name: string, args: Record<string, unknown>) => (supabase as any).rpc(name, args);

export async function fetchEngagement(projectId: string): Promise<EngagementCounts | null> {
  const { data, error } = await rpc("get_project_engagement", { _project_ids: [projectId] });
  if (error || !data?.length) return null;
  const row = data[0] as Row;
  return { appreciations: row.appreciations, views: row.views, live_visits: row.live_visits };
}

export async function fetchHasAppreciated(projectId: string): Promise<boolean> {
  const visitor = getVisitorId();
  if (!visitor) return false;
  const { data, error } = await rpc("has_appreciated", {
    _project_id: projectId,
    _visitor_id: visitor,
  });
  if (error) return false;
  return Boolean(data);
}

export async function recordInteraction(
  projectId: string,
  type: "view" | "appreciation" | "live_visit",
): Promise<EngagementCounts | null> {
  const visitor = getVisitorId();
  if (!visitor) return null;
  const { data, error } = await rpc("record_project_interaction", {
    _project_id: projectId,
    _interaction_type: type,
    _visitor_id: visitor,
  });
  if (error || !data?.length) return null;
  const row = data[0] as Row;
  return { appreciations: row.appreciations, views: row.views, live_visits: row.live_visits };
}
