import { useEffect, useRef, useState } from "react";
import { Link } from "@tanstack/react-router";
import { ArrowUpRight, ExternalLink, Sparkles } from "lucide-react";
import shot1 from "@/assets/bluerush-223505.png.asset.json";
import shot2 from "@/assets/bluerush-223532.png.asset.json";
import shot3 from "@/assets/bluerush-223641.png.asset.json";

const PROJECT_URL =
  "https://lovable.dev/share-preview/e468914c-cf77-4dae-b9c3-1636eef25c55";

const features = [
  "Daily weather forecasts",
  "Rideability Score",
  "Smart ride planning",
  "Clean modern UI",
  "Weather-based recommendations",
  "Mobile-first experience",
];

const tech = ["Weather APIs", "Maps Integration", "Modern UI/UX", "Mobile Development"];

function useInView<T extends HTMLElement>() {
  const ref = useRef<T | null>(null);
  const [seen, setSeen] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      ([e]) => e.isIntersecting && setSeen(true),
      { threshold: 0.15 },
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);
  return { ref, seen };
}

function RideabilityGauge({ active }: { active: boolean }) {
  const score = 92;
  const r = 34;
  const c = 2 * Math.PI * r;
  return (
    <div className="rounded-2xl border border-gold/25 bg-background/80 backdrop-blur-xl p-4 shadow-gold w-[210px]">
      <div className="text-[10px] font-semibold tracking-[0.2em] text-gold uppercase">
        Rideability Score
      </div>
      <div className="mt-3 flex items-center gap-3">
        <svg viewBox="0 0 80 80" className="h-16 w-16 shrink-0 -rotate-90">
          <circle cx="40" cy="40" r={r} fill="none" strokeWidth="7" className="stroke-border" />
          <circle
            cx="40"
            cy="40"
            r={r}
            fill="none"
            strokeWidth="7"
            strokeLinecap="round"
            className="stroke-gold"
            style={{
              strokeDasharray: c,
              strokeDashoffset: active ? c - (c * score) / 100 : c,
              transition: "stroke-dashoffset 1.6s cubic-bezier(0.16,1,0.3,1)",
            }}
          />
        </svg>
        <div className="min-w-0">
          <div className="text-2xl font-bold leading-none">
            {score}
            <span className="text-sm text-muted-foreground"> / 100</span>
          </div>
          <div className="mt-1 text-[11px] text-foreground/70 leading-snug">
            Excellent riding conditions
          </div>
        </div>
      </div>
    </div>
  );
}

export function FeaturedProducts() {
  const { ref, seen } = useInView<HTMLDivElement>();

  return (
    <section id="products" ref={ref} className="mx-auto max-w-7xl px-6 lg:px-10 py-20">
      <div className="mb-12">
        <div className="text-xs font-semibold tracking-[0.2em] text-gold mb-3">
          FEATURED PRODUCTS
        </div>
        <h2 className="text-3xl lg:text-5xl font-bold">Featured Products</h2>
        <p className="mt-4 max-w-2xl text-muted-foreground">
          Real digital products built to solve real-world problems.
        </p>
      </div>

      <div
        className={`relative overflow-hidden rounded-3xl border border-border bg-card shadow-card transition-all duration-700 hover:shadow-gold hover:-translate-y-1 ${
          seen ? "opacity-100 translate-y-0" : "opacity-0 translate-y-8"
        }`}
      >
        <div className="pointer-events-none absolute -top-24 -right-24 h-72 w-72 rounded-full bg-gold/15 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-32 -left-24 h-72 w-72 rounded-full bg-gold/10 blur-3xl" />

        <div className="relative grid lg:grid-cols-2 gap-10 p-6 sm:p-10 lg:p-14">
          {/* Copy */}
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-[11px] font-semibold px-3 py-1 rounded-full bg-ink text-ink-foreground">
                Mobile App
              </span>
              <span className="text-[11px] font-semibold px-3 py-1 rounded-full bg-gold/10 text-gold border border-gold/30 inline-flex items-center gap-1.5">
                <span className="h-1.5 w-1.5 rounded-full bg-gold animate-pulse" /> Live
              </span>
            </div>

            <h3 className="mt-5 text-4xl lg:text-5xl font-bold font-display tracking-tight">
              BlueRush
            </h3>
            <p className="mt-2 text-lg text-gold font-semibold">Smart Bike Ride Planner</p>

            <p className="mt-5 text-foreground/75 leading-relaxed">
              BlueRush is an intelligent cycling companion that helps riders plan safer and
              smarter rides. It combines daily weather forecasts with a unique Rideability Score
              to help cyclists know the best time to ride.
            </p>
            <p className="mt-3 text-foreground/75 leading-relaxed">
              The app is designed with a clean, modern interface and focuses on making ride
              planning simple, accurate, and enjoyable.
            </p>

            <ul className="mt-7 grid sm:grid-cols-2 gap-x-6 gap-y-2.5">
              {features.map((f, i) => (
                <li
                  key={f}
                  className={`flex items-start gap-2.5 text-sm text-foreground/85 transition-all duration-500 ${
                    seen ? "opacity-100 translate-x-0" : "opacity-0 -translate-x-3"
                  }`}
                  style={{ transitionDelay: `${150 + i * 70}ms` }}
                >
                  <Sparkles className="h-4 w-4 text-gold shrink-0 mt-0.5" />
                  <span>{f}</span>
                </li>
              ))}
            </ul>

            <div className="mt-7 flex flex-wrap gap-2">
              {tech.map((t) => (
                <span
                  key={t}
                  className="text-xs font-medium px-3 py-1.5 rounded-full bg-gold/10 text-gold border border-gold/20 hover:bg-gold/20 transition-colors"
                >
                  {t}
                </span>
              ))}
            </div>

            <div className="mt-9 flex flex-wrap gap-3">
              <a
                href={PROJECT_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 bg-gradient-gold text-ink px-6 py-3 rounded-full font-semibold shadow-gold hover:scale-[1.03] transition-transform"
              >
                View Project <ExternalLink className="h-4 w-4" />
              </a>
              <Link
                to="/portfolio"
                className="inline-flex items-center gap-2 bg-ink text-ink-foreground px-6 py-3 rounded-full font-semibold hover:bg-gradient-gold hover:text-ink transition-all"
              >
                See More Products <ArrowUpRight className="h-4 w-4" />
              </Link>
            </div>
          </div>

          {/* Visuals */}
          <div className="relative min-w-0">
            <div
              className={`relative rounded-2xl overflow-hidden border border-border bg-muted shadow-card transition-all duration-1000 ${
                seen ? "opacity-100 translate-y-0 rotate-0" : "opacity-0 translate-y-10 rotate-1"
              }`}
            >
              <div className="flex items-center gap-1.5 px-3 py-2 bg-ink">
                <span className="h-2 w-2 rounded-full bg-ink-foreground/30" />
                <span className="h-2 w-2 rounded-full bg-ink-foreground/30" />
                <span className="h-2 w-2 rounded-full bg-gold/60" />
              </div>
              <img
                src={shot1.url}
                alt="BlueRush weather alerts and riding insights screen"
                loading="lazy"
                className="w-full object-cover"
              />
            </div>

            <div
              className={`relative sm:absolute sm:-bottom-6 sm:-left-6 sm:w-[62%] mt-5 sm:mt-0 rounded-2xl overflow-hidden border border-gold/25 bg-background/70 backdrop-blur-xl shadow-gold transition-all duration-1000 hover:-translate-y-1.5 ${
                seen ? "opacity-100 translate-y-0" : "opacity-0 translate-y-12"
              }`}
              style={{ transitionDelay: "250ms" }}
            >
              <img
                src={shot2.url}
                alt="BlueRush advanced ride analysis screen"
                loading="lazy"
                className="w-full object-cover"
              />
            </div>

            <div
              className={`relative sm:absolute sm:-top-8 sm:-right-6 sm:w-[46%] mt-5 sm:mt-0 rounded-2xl overflow-hidden border border-border bg-background/70 backdrop-blur-xl shadow-card transition-all duration-1000 hover:-translate-y-1.5 ${
                seen ? "opacity-100 translate-y-0" : "opacity-0 -translate-y-8"
              }`}
              style={{ transitionDelay: "400ms" }}
            >
              <img
                src={shot3.url}
                alt="BlueRush choose location screen"
                loading="lazy"
                className="w-full object-cover"
              />
            </div>

            <div
              className={`mt-6 sm:mt-0 sm:absolute sm:bottom-10 sm:right-0 transition-all duration-1000 ${
                seen ? "opacity-100 translate-y-0" : "opacity-0 translate-y-6"
              }`}
              style={{ transitionDelay: "550ms" }}
            >
              <RideabilityGauge active={seen} />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
