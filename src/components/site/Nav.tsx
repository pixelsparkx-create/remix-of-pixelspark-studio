import { useState } from "react";
import { Menu, X, Sparkles, MessageCircle } from "lucide-react";

const links = [
  { href: "#home", label: "Home" },
  { href: "#about", label: "About" },
  { href: "#services", label: "Services" },
  { href: "#portfolio", label: "Portfolio" },
  { href: "#pricing", label: "Pricing" },
  { href: "#testimonials", label: "Testimonials" },
  { href: "#contact", label: "Contact" },
];

export function Nav() {
  const [open, setOpen] = useState(false);
  return (
    <header className="sticky top-0 z-50 backdrop-blur-md bg-background/80 border-b border-border/60">
      <div className="mx-auto max-w-7xl px-6 lg:px-10 h-20 flex items-center justify-between">
        <a href="#home" className="flex items-center gap-2 font-display font-bold text-lg tracking-tight">
          <Sparkles className="h-6 w-6 text-gold" strokeWidth={1.5} />
          <span>PIXELSPARK</span>
        </a>
        <nav className="hidden lg:flex items-center gap-8">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="text-sm font-medium text-foreground/70 hover:text-gold transition-colors relative after:absolute after:left-0 after:-bottom-1.5 after:h-px after:w-0 after:bg-gold hover:after:w-full after:transition-all"
            >
              {l.label}
            </a>
          ))}
        </nav>
        <a
          href="https://wa.me/0000000000"
          className="hidden lg:inline-flex items-center gap-2 bg-gradient-gold text-ink px-5 py-2.5 rounded-full font-semibold text-sm shadow-gold hover:scale-[1.03] transition-transform"
        >
          Let's Talk <MessageCircle className="h-4 w-4" />
        </a>
        <button onClick={() => setOpen(!open)} className="lg:hidden p-2" aria-label="Menu">
          {open ? <X /> : <Menu />}
        </button>
      </div>
      {open && (
        <div className="lg:hidden border-t border-border bg-background">
          <nav className="px-6 py-4 flex flex-col gap-3">
            {links.map((l) => (
              <a key={l.href} href={l.href} onClick={() => setOpen(false)} className="py-2 text-foreground/80 hover:text-gold">
                {l.label}
              </a>
            ))}
            <a href="https://wa.me/0000000000" className="mt-2 inline-flex items-center justify-center gap-2 bg-gradient-gold text-ink px-5 py-3 rounded-full font-semibold">
              Let's Talk <MessageCircle className="h-4 w-4" />
            </a>
          </nav>
        </div>
      )}
    </header>
  );
}
