import { ArrowRight, MessageCircle, Zap, Palette, Smartphone, Target, Sparkles } from "lucide-react";
import mohammed from "@/assets/mohammed.png";

const badges = [
  { icon: Zap, label: "Fast Delivery" },
  { icon: Palette, label: "Modern Design" },
  { icon: Smartphone, label: "Mobile Friendly" },
  { icon: Target, label: "Client Focused" },
];

export function Hero() {
  return (
    <section id="home" className="relative overflow-hidden">
      <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_70%_20%,oklch(0.9_0.08_85/0.4),transparent_50%)]" />
      <div className="mx-auto max-w-7xl px-6 lg:px-10 pt-12 lg:pt-20 pb-16 grid lg:grid-cols-2 gap-12 items-center">
        <div className="space-y-8">
          <div className="inline-flex items-center gap-2 text-xs font-semibold tracking-[0.2em] text-gold">
            <Sparkles className="h-4 w-4" />
            HELLO, I'M <span className="text-foreground">MOHAMMED</span>
          </div>
          <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold leading-[1.05] text-balance">
            I build websites, apps &{" "}
            <span className="relative inline-block">
              <span className="bg-gradient-gold bg-clip-text text-transparent">digital experiences</span>
            </span>{" "}
            that drive results.
          </h1>
          <p className="text-lg text-muted-foreground max-w-xl leading-relaxed">
            I help businesses and brands stand out online with modern, high-performing websites,
            apps and creative digital solutions.
          </p>
          <div className="flex flex-wrap gap-4">
            <a href="#portfolio" className="group inline-flex items-center gap-2 bg-gradient-gold text-ink px-7 py-3.5 rounded-full font-semibold shadow-gold hover:scale-[1.03] transition-transform">
              View My Work
              <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
            </a>
            <a href="#contact" className="group inline-flex items-center gap-2 bg-ink text-ink-foreground px-7 py-3.5 rounded-full font-semibold hover:bg-ink/90 transition-colors">
              Let's Work Together
              <MessageCircle className="h-4 w-4" />
            </a>
          </div>
          <div className="flex flex-wrap gap-x-7 gap-y-3 pt-4">
            {badges.map((b) => (
              <div key={b.label} className="flex items-center gap-2 text-sm text-foreground/80">
                <span className="h-8 w-8 rounded-full border border-gold/40 bg-gold/5 flex items-center justify-center">
                  <b.icon className="h-4 w-4 text-gold" />
                </span>
                {b.label}
              </div>
            ))}
          </div>
        </div>

        <div className="relative">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,oklch(0.9_0.1_85/0.5),transparent_60%)] blur-2xl" />
          <div className="relative aspect-[4/5] max-w-md mx-auto">
            <img
              src={mohammed}
              alt="Mohammed, founder of PixelSpark"
              width={1024}
              height={1280}
              className="relative z-10 w-full h-full object-contain object-bottom drop-shadow-2xl"
            />
            <div className="absolute top-8 -right-4 lg:right-0 z-20 text-right">
              <div className="font-script text-4xl text-foreground leading-none">Mohammed</div>
              <div className="mt-2 text-[11px] tracking-[0.2em] font-semibold text-muted-foreground">
                FOUNDER OF <span className="text-gold">PIXELSPARK</span>
              </div>
            </div>
            <div className="absolute bottom-12 -left-2 lg:left-0 z-20 bg-ink text-ink-foreground rounded-2xl px-5 py-4 shadow-card max-w-[240px]">
              <div className="flex items-center gap-2 text-xs">
                <Sparkles className="h-4 w-4 text-gold" />
                <span className="font-semibold">Turning Ideas Into</span>
              </div>
              <div className="text-sm font-semibold mt-1">Powerful Digital Products.</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
