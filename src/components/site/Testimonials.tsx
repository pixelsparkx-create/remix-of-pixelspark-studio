import { useState } from "react";
import { Quote } from "lucide-react";

const items = [
  { quote: "Mohammed was amazing to work with. He delivered more than I expected and my website looks fantastic!", author: "Hotel Owner, Lagos" },
  { quote: "Fast, professional and very creative. PixelSpark made our brand look truly premium online.", author: "Founder, Solar Startup" },
  { quote: "Clear communication, clean design and on-time delivery. Highly recommend.", author: "Local Business Owner" },
];

export function Testimonials() {
  const [i, setI] = useState(0);
  return (
    <div id="testimonials" className="rounded-3xl bg-card border border-border p-8 lg:p-10 shadow-card">
      <div className="text-xs font-semibold tracking-[0.2em] text-gold mb-3">WHAT CLIENTS SAY</div>
      <h2 className="text-2xl lg:text-3xl font-bold mb-8">Words From People<br />I've Worked With</h2>
      <div className="flex gap-6 items-start">
        <Quote className="h-10 w-10 text-gold shrink-0" strokeWidth={1.5} />
        <div className="min-h-[100px]">
          <p className="text-foreground/80 leading-relaxed italic">"{items[i].quote}"</p>
          <div className="mt-4 text-sm text-muted-foreground">— {items[i].author}</div>
        </div>
      </div>
      <div className="flex gap-2 mt-6">
        {items.map((_, idx) => (
          <button
            key={idx}
            onClick={() => setI(idx)}
            aria-label={`Testimonial ${idx + 1}`}
            className={`h-2 rounded-full transition-all ${i === idx ? "w-6 bg-gold" : "w-2 bg-border"}`}
          />
        ))}
      </div>
    </div>
  );
}
