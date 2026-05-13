import { Globe, Smartphone, Gamepad2, Code2, ArrowRight } from "lucide-react";

const services = [
  { icon: Globe, title: "Websites", desc: "High-performance business websites that convert visitors into customers." },
  { icon: Smartphone, title: "Mobile Apps", desc: "Beautiful, fast and user-friendly mobile applications." },
  { icon: Gamepad2, title: "Game Development", desc: "Fun, engaging and optimized games for all platforms." },
  { icon: Code2, title: "Other Solutions", desc: "Landing pages, tools, portfolios, stores and more." },
];

export function Services() {
  return (
    <section id="services" className="px-6 lg:px-10 py-12">
      <div className="mx-auto max-w-7xl bg-ink text-ink-foreground rounded-3xl p-8 lg:p-14 grid lg:grid-cols-5 gap-10 shadow-card relative overflow-hidden">
        <div className="absolute -top-20 -right-20 h-72 w-72 rounded-full bg-gold/10 blur-3xl" />
        <div className="lg:col-span-2 relative">
          <div className="text-xs font-semibold tracking-[0.2em] text-gold mb-4">WHAT I DO</div>
          <h2 className="text-3xl lg:text-4xl font-bold leading-tight">
            Digital Solutions<br />That Help You <span className="text-gold">Grow</span>
          </h2>
          <p className="mt-5 text-ink-foreground/70 leading-relaxed">
            I design and build modern websites, apps and game experiences that help businesses
            attract customers, build trust and grow faster.
          </p>
          <a href="#contact" className="mt-8 inline-flex items-center gap-2 bg-gradient-gold text-ink px-6 py-3 rounded-full font-semibold text-sm hover:scale-[1.03] transition-transform">
            Explore Services <ArrowRight className="h-4 w-4" />
          </a>
        </div>
        <div className="lg:col-span-3 grid sm:grid-cols-2 gap-4 relative">
          {services.map((s) => (
            <div key={s.title} className="group rounded-2xl bg-white/[0.03] border border-white/10 p-6 hover:border-gold/40 hover:bg-white/[0.06] transition-all">
              <div className="h-12 w-12 rounded-xl border border-gold/30 bg-gold/10 flex items-center justify-center mb-5">
                <s.icon className="h-6 w-6 text-gold" strokeWidth={1.5} />
              </div>
              <h3 className="font-bold text-lg mb-2">{s.title}</h3>
              <p className="text-sm text-ink-foreground/60 leading-relaxed">{s.desc}</p>
              <div className="mt-5 h-px w-10 bg-gold group-hover:w-20 transition-all" />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
