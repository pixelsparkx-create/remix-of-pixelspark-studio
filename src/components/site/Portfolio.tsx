import { ArrowUpRight } from "lucide-react";
import hotel from "@/assets/project-hotel.jpg";
import solar from "@/assets/project-solar.jpg";
import portfolio from "@/assets/project-portfolio.jpg";
import game from "@/assets/project-game.jpg";

const projects = [
  { img: hotel, title: "Hotel Booking Website", tag: "Web Design" },
  { img: solar, title: "Solar Company Website", tag: "Business Site" },
  { img: portfolio, title: "Personal Portfolio Website", tag: "Personal Brand" },
  { img: game, title: "2D Adventure Game", tag: "Game Dev" },
];

export function Portfolio() {
  return (
    <section id="portfolio" className="mx-auto max-w-7xl px-6 lg:px-10 py-20">
      <div className="flex flex-wrap items-end justify-between gap-4 mb-10">
        <div>
          <div className="text-xs font-semibold tracking-[0.2em] text-gold mb-3">RECENT WORK</div>
          <h2 className="text-3xl lg:text-5xl font-bold">Some Things I've Built</h2>
        </div>
        <a href="#contact" className="inline-flex items-center gap-2 text-sm font-semibold text-gold hover:gap-3 transition-all">
          View All Projects <ArrowUpRight className="h-4 w-4" />
        </a>
      </div>
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {projects.map((p) => (
          <a key={p.title} href="#contact" className="group block">
            <div className="relative overflow-hidden rounded-2xl bg-muted aspect-[4/3] shadow-card">
              <img src={p.img} alt={p.title} loading="lazy" width={800} height={600}
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
              <div className="absolute inset-0 bg-gradient-to-t from-ink/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
              <div className="absolute bottom-3 right-3 h-9 w-9 rounded-full bg-gradient-gold text-ink flex items-center justify-center opacity-0 group-hover:opacity-100 translate-y-2 group-hover:translate-y-0 transition-all">
                <ArrowUpRight className="h-4 w-4" />
              </div>
            </div>
            <div className="mt-4">
              <div className="text-xs text-gold font-semibold tracking-wider uppercase">{p.tag}</div>
              <h3 className="mt-1 font-semibold text-foreground group-hover:text-gold transition-colors">{p.title}</h3>
            </div>
          </a>
        ))}
      </div>
    </section>
  );
}
