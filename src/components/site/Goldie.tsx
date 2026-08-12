import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport, type UIMessage } from "ai";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import ReactMarkdown from "react-markdown";
import {
  Sparkles,
  X,
  Send,
  Loader2,
  FileText,
  Download,
  Check,
  MessageCircle,
  Mail,
  Linkedin,
  ArrowLeft,
  RotateCcw,
  Mic,
  MicOff,
} from "lucide-react";
import {
  mergeBrief,
  submitBrief,
  goldieWhatsAppMessage,
  goldieWhatsAppLink,
  goldieEmailLink,
  STORAGE_KEY,
  type GoldieBrief,
} from "@/lib/goldie/brief";
import { downloadProposal } from "@/lib/goldie/proposal";
import { useVoiceInput } from "@/hooks/useVoiceInput";
import { LINKEDIN_URL } from "@/lib/contact";
import { toast } from "sonner";


const QUICK_STARTS = [
  "🚀 I need a website",
  "📱 I need an app",
  "💰 Help me understand pricing",
  "🎨 Help me design my website",
  "🧠 I'm not sure what I need",
];

const GREETING: UIMessage = {
  id: "goldie-greeting",
  role: "assistant",
  parts: [
    {
      type: "text",
      text: `Hey 👋 I'm **Goldie**, PixelSpark's AI business assistant.\n\nTell me what you're trying to build and I'll help you figure out the right website, features, design direction and estimated budget.\n\nWhat are you working on?`,
    },
  ],
};

type Persisted = { messages: UIMessage[] };

function loadPersisted(): Persisted {
  if (typeof window === "undefined") return { messages: [GREETING] };
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return { messages: [GREETING] };
    const parsed = JSON.parse(raw) as Persisted;
    if (!Array.isArray(parsed.messages) || parsed.messages.length === 0) return { messages: [GREETING] };
    return { messages: parsed.messages };
  } catch {
    return { messages: [GREETING] };
  }
}

export function Goldie() {
  const [open, setOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [initial, setInitial] = useState<UIMessage[]>([GREETING]);

  useEffect(() => {
    setInitial(loadPersisted().messages);
    setMounted(true);
  }, []);

  return (
    <>
      <button
        onClick={() => setOpen((v) => !v)}
        aria-label={open ? "Close Goldie" : "Chat with Goldie, PixelSpark's AI assistant"}
        className="fixed bottom-24 right-5 z-50 group inline-flex items-center gap-2 rounded-full border border-gold/40 bg-card/95 backdrop-blur px-4 py-3 shadow-card hover:shadow-gold hover:border-gold transition-all"
      >
        <span className="relative flex h-6 w-6 items-center justify-center rounded-full bg-gradient-gold text-ink">
          {open ? <X className="h-3.5 w-3.5" /> : <Sparkles className="h-3.5 w-3.5" strokeWidth={2.2} />}
        </span>
        <span className="text-sm font-semibold">{open ? "Close" : "Ask Goldie"}</span>
      </button>

      {mounted && open && <GoldiePanel initialMessages={initial} onClose={() => setOpen(false)} />}
    </>
  );
}

function GoldiePanel({
  initialMessages,
  onClose,
}: {
  initialMessages: UIMessage[];
  onClose: () => void;
}) {
  const [input, setInput] = useState("");
  const [view, setView] = useState<"chat" | "review" | "sent">("chat");
  const [manual, setManual] = useState<GoldieBrief>({});
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  const transport = useMemo(() => new DefaultChatTransport({ api: "/api/goldie" }), []);
  const { messages, sendMessage, status, setMessages, error } = useChat({
    id: "goldie",
    messages: initialMessages,
    transport,
    onError: (e) => toast.error(e.message || "Goldie couldn't respond. Please try again."),
  });

  const busy = status === "submitted" || status === "streaming";

  // Persist the single ongoing conversation.
  useEffect(() => {
    if (typeof window === "undefined") return;
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify({ messages }));
    } catch {
      /* storage full or blocked — chat still works in-session */
    }
  }, [messages]);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages, status, view]);

  useEffect(() => {
    if (view === "chat" && !busy) inputRef.current?.focus();
  }, [view, busy]);

  // Derive the structured project brief from every update_brief tool call.
  const brief = useMemo(() => {
    let acc: GoldieBrief = {};
    for (const m of messages) {
      for (const part of m.parts ?? []) {
        if (part.type === "tool-update_brief") {
          const input = (part as { input?: Partial<GoldieBrief> }).input;
          if (input && typeof input === "object") acc = mergeBrief(acc, input);
        }
      }
    }
    return mergeBrief(acc, manual);
  }, [messages, manual]);

  // Clickable follow-up suggestions from the most recent assistant turn.
  const suggestions = useMemo(() => {
    for (let i = messages.length - 1; i >= 0; i -= 1) {
      const m = messages[i];
      if (m.role === "user") return [];
      for (const part of m.parts ?? []) {
        if (part.type === "tool-suggest_replies") {
          const list = (part as { input?: { suggestions?: unknown } }).input?.suggestions;
          if (Array.isArray(list)) return list.map(String).filter(Boolean).slice(0, 4);
        }
      }
    }
    return [];
  }, [messages]);

  const send = useCallback(
    (text: string) => {
      const value = text.trim();
      if (!value || busy) return;
      setInput("");
      void sendMessage({ text: value });
    },
    [busy, sendMessage],
  );

  function reset() {
    setMessages([GREETING]);
    setManual({});
    setView("chat");
    try {
      window.localStorage.removeItem(STORAGE_KEY);
    } catch {
      /* ignore */
    }
  }

  return (
    <div className="fixed inset-x-0 bottom-0 top-0 sm:inset-auto sm:bottom-24 sm:right-5 z-[60] sm:w-[420px] sm:max-h-[calc(100vh-9rem)] flex flex-col bg-card sm:rounded-3xl border border-border shadow-card overflow-hidden">
      <header className="flex items-center gap-3 border-b border-border px-4 py-3 bg-gradient-ink text-background">
        <span className="h-9 w-9 rounded-full bg-gradient-gold text-ink grid place-items-center">
          <Sparkles className="h-4 w-4" strokeWidth={2.2} />
        </span>
        <div className="min-w-0 flex-1">
          <div className="font-semibold leading-tight">Goldie</div>
          <div className="text-[11px] opacity-70 truncate">PixelSpark AI Business Assistant</div>
        </div>
        <button onClick={reset} aria-label="Start over" className="p-2 opacity-70 hover:opacity-100">
          <RotateCcw className="h-4 w-4" />
        </button>
        <button onClick={onClose} aria-label="Close Goldie" className="p-2 opacity-70 hover:opacity-100">
          <X className="h-4 w-4" />
        </button>
      </header>

      {view === "chat" && (
        <>
          <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
            {messages.map((m) => (
              <Bubble key={m.id} message={m} />
            ))}

            {status === "submitted" && (
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <Loader2 className="h-3.5 w-3.5 animate-spin text-gold" /> Goldie is thinking…
              </div>
            )}

            {messages.length <= 1 && (
              <div className="flex flex-wrap gap-2 pt-1">
                {QUICK_STARTS.map((q) => (
                  <button
                    key={q}
                    onClick={() => send(q)}
                    className="rounded-full border border-border px-3 py-1.5 text-xs hover:border-gold hover:text-gold transition-colors"
                  >
                    {q}
                  </button>
                ))}
                <a
                  href={goldieWhatsAppLink("Hello Mohammed 👋 I'd like to talk about a project.")}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rounded-full border border-border px-3 py-1.5 text-xs hover:border-gold hover:text-gold transition-colors"
                >
                  💬 Talk to PixelSpark
                </a>
              </div>
            )}

            {!busy && messages.length > 1 && suggestions.length > 0 && (
              <div className="flex flex-wrap gap-2 pt-1">
                {suggestions.map((s) => (
                  <button
                    key={s}
                    onClick={() => send(s)}
                    className="rounded-full border border-gold/40 bg-gold/5 px-3 py-1.5 text-xs text-gold hover:bg-gold/10 transition-colors"
                  >
                    {s}
                  </button>
                ))}
              </div>
            )}

            {error && (

              <p className="text-xs text-destructive">
                Goldie hit a snag. Try again, or reach PixelSpark directly on WhatsApp.
              </p>
            )}
          </div>

          {brief.ready_for_review && (
            <button
              onClick={() => setView("review")}
              className="mx-4 mb-2 inline-flex items-center justify-center gap-2 rounded-full bg-gradient-gold text-ink px-4 py-2.5 text-sm font-semibold shadow-gold"
            >
              <FileText className="h-4 w-4" /> Review your project brief
            </button>
          )}

          <form
            onSubmit={(e) => {
              e.preventDefault();
              send(input);
            }}
            className="border-t border-border p-3 flex items-end gap-2"
          >
            <textarea
              ref={inputRef}
              rows={1}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                  e.preventDefault();
                  send(input);
                }
              }}
              placeholder="Tell Goldie about your business…"
              className="flex-1 resize-none max-h-32 rounded-2xl border border-border bg-background px-4 py-2.5 text-sm outline-none focus:border-gold"
            />
            <button
              type="submit"
              disabled={busy || !input.trim()}
              aria-label="Send message"
              className="h-10 w-10 shrink-0 rounded-full bg-gradient-gold text-ink grid place-items-center shadow-gold disabled:opacity-50"
            >
              {busy ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
            </button>
          </form>
        </>
      )}

      {view === "review" && (
        <ReviewBrief
          brief={brief}
          onBack={() => setView("chat")}
          onEdit={(patch) => setManual((prev) => ({ ...prev, ...patch }))}
          onSent={() => setView("sent")}
        />
      )}

      {view === "sent" && <SentView brief={brief} onBack={() => setView("chat")} />}
    </div>
  );
}

function Bubble({ message }: { message: UIMessage }) {
  const text = (message.parts ?? [])
    .map((p) => (p.type === "text" ? p.text : ""))
    .join("")
    .trim();
  if (!text) return null;
  const isUser = message.role === "user";
  return (
    <div className={isUser ? "flex justify-end" : "flex justify-start"}>
      <div
        className={`max-w-[88%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed ${
          isUser
            ? "bg-gradient-gold text-ink rounded-br-sm font-medium"
            : "border border-border bg-background rounded-bl-sm"
        }`}
      >
        <div className="goldie-prose space-y-2 [&_ul]:list-disc [&_ul]:pl-4 [&_ol]:list-decimal [&_ol]:pl-4 [&_strong]:font-semibold [&_h1]:font-bold [&_h2]:font-bold [&_h3]:font-semibold">
          <ReactMarkdown>{text}</ReactMarkdown>
        </div>
      </div>
    </div>
  );
}

const REVIEW_FIELDS: { key: keyof GoldieBrief; label: string }[] = [
  { key: "client_name", label: "Your name" },
  { key: "contact_email", label: "Email" },
  { key: "contact_phone", label: "WhatsApp / phone" },
  { key: "business_name", label: "Business" },
  { key: "business_type", label: "Business type" },
  { key: "location", label: "Location" },
  { key: "project_type", label: "Project type" },
  { key: "timeline", label: "Timeline" },
];

const LIST_FIELDS: { key: keyof GoldieBrief; label: string }[] = [
  { key: "business_goals", label: "Goals" },
  { key: "required_pages", label: "Pages" },
  { key: "required_features", label: "Features" },
  { key: "required_integrations", label: "Integrations" },
  { key: "additional_requirements", label: "Additional requirements" },
];

function ReviewBrief({
  brief,
  onBack,
  onEdit,
  onSent,
}: {
  brief: GoldieBrief;
  onBack: () => void;
  onEdit: (patch: Partial<GoldieBrief>) => void;
  onSent: () => void;
}) {
  const [sending, setSending] = useState(false);

  async function send() {
    setSending(true);
    try {
      await submitBrief(brief);
      onSent();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Couldn't send your brief. Please try WhatsApp.");
    } finally {
      setSending(false);
    }
  }

  return (
    <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
      <button onClick={onBack} className="inline-flex items-center gap-1.5 text-xs text-muted-foreground hover:text-gold">
        <ArrowLeft className="h-3.5 w-3.5" /> Back to chat
      </button>

      <div>
        <div className="text-[11px] tracking-[0.2em] text-gold font-semibold">REVIEW YOUR PROJECT BRIEF</div>
        <p className="text-xs text-muted-foreground mt-1">
          Check everything below and edit anything that isn't right. Nothing is sent to PixelSpark until you confirm.
        </p>
      </div>

      <div className="space-y-2">
        {REVIEW_FIELDS.map(({ key, label }) => (
          <label key={key} className="block">
            <span className="text-[11px] text-muted-foreground">{label}</span>
            <input
              value={(brief[key] as string) ?? ""}
              onChange={(e) => onEdit({ [key]: e.target.value } as Partial<GoldieBrief>)}
              className="mt-1 w-full rounded-xl border border-border bg-background px-3 py-2 text-sm focus:border-gold outline-none"
            />
          </label>
        ))}
      </div>

      {LIST_FIELDS.map(({ key, label }) => {
        const values = brief[key] as string[] | undefined;
        if (!values?.length) return null;
        return (
          <div key={key}>
            <div className="text-[11px] text-muted-foreground">{label}</div>
            <ul className="mt-1 text-sm list-disc pl-4 space-y-0.5">
              {values.map((v) => (
                <li key={v}>{v}</li>
              ))}
            </ul>
          </div>
        );
      })}

      <div className="rounded-2xl border border-gold/40 bg-gold/5 p-4 space-y-1">
        <div className="text-[11px] tracking-[0.15em] text-gold font-semibold">RECOMMENDATION</div>
        <div className="text-sm">
          <strong>{brief.recommended_plan ?? "—"}</strong>
        </div>
        <div className="text-sm">Estimated project range: {brief.estimated_range ?? "—"}</div>
        <div className="text-sm">Estimated timeline: {brief.estimated_timeline ?? brief.timeline ?? "—"}</div>
        <p className="text-[11px] text-muted-foreground pt-1">
          Estimated project range — final quote subject to scope confirmation. This is a project discovery summary,
          not an invoice.
        </p>
      </div>

      <div className="grid gap-2">
        <button
          onClick={() => {
            if (!downloadProposal(brief)) toast.error("Allow pop-ups to download your project summary.");
          }}
          className="inline-flex items-center justify-center gap-2 rounded-full border border-border px-4 py-2.5 text-sm font-semibold hover:border-gold hover:text-gold transition-colors"
        >
          <Download className="h-4 w-4" /> Download project summary
        </button>
        <button
          onClick={send}
          disabled={sending}
          className="inline-flex items-center justify-center gap-2 rounded-full bg-gradient-gold text-ink px-4 py-2.5 text-sm font-semibold shadow-gold disabled:opacity-60"
        >
          {sending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
          Send project brief to PixelSpark
        </button>
      </div>
    </div>
  );
}

function SentView({ brief, onBack }: { brief: GoldieBrief; onBack: () => void }) {
  const [message, setMessage] = useState(() => goldieWhatsAppMessage(brief));
  return (
    <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
      <div className="text-center space-y-2">
        <span className="mx-auto h-12 w-12 rounded-full bg-gradient-gold text-ink grid place-items-center shadow-gold">
          <Check className="h-5 w-5" strokeWidth={2.4} />
        </span>
        <h3 className="font-bold text-lg">Brief sent to PixelSpark</h3>
        <p className="text-sm text-muted-foreground">
          Mohammed will review your project and get back to you. Want to reach him directly right now?
        </p>
      </div>

      <div>
        <div className="text-[11px] text-muted-foreground mb-1">Your WhatsApp message (edit before sending)</div>
        <textarea
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          rows={8}
          className="w-full rounded-2xl border border-border bg-background px-3 py-2 text-sm outline-none focus:border-gold"
        />
      </div>

      <div className="grid gap-2">
        <a
          href={goldieWhatsAppLink(message)}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center justify-center gap-2 rounded-full bg-gradient-gold text-ink px-4 py-2.5 text-sm font-semibold shadow-gold"
        >
          <MessageCircle className="h-4 w-4" /> WhatsApp
        </a>
        <a
          href={goldieEmailLink(brief)}
          className="inline-flex items-center justify-center gap-2 rounded-full border border-border px-4 py-2.5 text-sm font-semibold hover:border-gold hover:text-gold transition-colors"
        >
          <Mail className="h-4 w-4" /> Email
        </a>
        <a
          href={LINKEDIN_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center justify-center gap-2 rounded-full border border-border px-4 py-2.5 text-sm font-semibold hover:border-gold hover:text-gold transition-colors"
        >
          <Linkedin className="h-4 w-4" /> LinkedIn
        </a>
        <button onClick={onBack} className="text-xs text-muted-foreground hover:text-gold pt-1">
          Back to chat with Goldie
        </button>
      </div>
    </div>
  );
}
