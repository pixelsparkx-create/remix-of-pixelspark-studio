import { Check } from "lucide-react";

const plans = [
  {
    name: "Starter",
    sub: "Landing Page",
    price: "$50",
    desc: "Perfect for small businesses.",
    features: ["1-page landing site", "Mobile responsive", "Contact form", "Basic SEO"],
    highlight: false,
  },
  {
    name: "Growth",
    sub: "Business Website",
    price: "$120",
    desc: "More pages, features and functionality.",
    features: ["Up to 5 pages", "Custom design", "Booking / forms", "On-page SEO", "1 month support"],
    highlight: true,
  },
  {
    name: "Premium",
    sub: "Complete Solution",
    price: "$200+",
    desc: "Advanced features, custom solutions.",
    features: ["Unlimited pages", "Web app / dashboard", "Integrations", "Priority delivery", "3 months support"],
    highlight: false,
  },
];

export function Pricing() {
  return (
    <div id="pricing" className="rounded-3xl bg-card border border-border p-8 lg:p-12 shadow-card">
      <div className="text-xs font-semibold tracking-[0.2em] text-gold mb-3">PRICING PACKAGES</div>
      <h2 className="text-2xl lg:text-3xl font-bold mb-10">Simple Packages, Real Value</h2>
      <div className="grid sm:grid-cols-3 gap-4">
        {plans.map((p) => (
          <div key={p.name} className={`relative rounded-2xl p-6 transition-all ${
            p.highlight
              ? "bg-background border-2 border-gold shadow-gold scale-[1.02]"
              : "bg-background border border-border hover:border-gold/40"
          }`}>
            {p.highlight && (
              <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-gradient-gold text-ink text-[10px] font-bold tracking-wider uppercase px-3 py-1 rounded-full">
                Most Popular
              </div>
            )}
            <div className="font-bold text-lg">{p.name}</div>
            <div className="text-xs text-muted-foreground mb-4">{p.sub}</div>
            <div className="text-4xl font-bold mb-1">
              <span className="text-base align-top">$</span>{p.price.replace("$", "")}
            </div>
            <p className="text-xs text-muted-foreground mb-5">{p.desc}</p>
            <ul className="space-y-2 mb-6">
              {p.features.map((f) => (
                <li key={f} className="flex items-center gap-2 text-sm">
                  <Check className="h-4 w-4 text-gold shrink-0" /> {f}
                </li>
              ))}
            </ul>
            <a href="#contact" className={`block text-center py-2.5 rounded-full text-sm font-semibold transition-all ${
              p.highlight
                ? "bg-gradient-gold text-ink hover:scale-[1.02]"
                : "border border-border hover:border-gold hover:text-gold"
            }`}>
              Choose Plan
            </a>
          </div>
        ))}
      </div>
    </div>
  );
}
