import { Sparkles, Instagram, Twitter, Linkedin, MessageCircle } from "lucide-react";

export function Footer() {
  return (
    <footer className="bg-ink text-ink-foreground">
      <div className="mx-auto max-w-7xl px-6 lg:px-10 py-14 grid md:grid-cols-4 gap-10">
        <div>
          <div className="flex items-center gap-2 font-display font-bold text-lg">
            <Sparkles className="h-5 w-5 text-gold" />
            PIXELSPARK
          </div>
          <p className="mt-4 text-sm text-ink-foreground/60 leading-relaxed">
            Building modern websites, apps and digital experiences that help businesses grow and succeed online.
          </p>
        </div>
        <div>
          <div className="font-semibold mb-4">Quick Links</div>
          <ul className="space-y-2 text-sm text-ink-foreground/60">
            <li><a href="#home" className="hover:text-gold">Home</a></li>
            <li><a href="#about" className="hover:text-gold">About</a></li>
            <li><a href="#services" className="hover:text-gold">Services</a></li>
            <li><a href="#portfolio" className="hover:text-gold">Portfolio</a></li>
            <li><a href="#pricing" className="hover:text-gold">Pricing</a></li>
            <li><a href="#contact" className="hover:text-gold">Contact</a></li>
          </ul>
        </div>
        <div>
          <div className="font-semibold mb-4">Services</div>
          <ul className="space-y-2 text-sm text-ink-foreground/60">
            <li>Websites</li>
            <li>Mobile Apps</li>
            <li>Game Development</li>
            <li>Landing Pages</li>
            <li>Online Stores</li>
            <li>Other Solutions</li>
          </ul>
        </div>
        <div>
          <div className="font-semibold mb-4">Stay Connected</div>
          <div className="flex gap-3">
            {[MessageCircle, Instagram, Twitter, Linkedin].map((Icon, i) => (
              <a key={i} href="#" aria-label="social"
                className="h-10 w-10 rounded-full border border-white/15 flex items-center justify-center hover:bg-gold hover:text-ink hover:border-gold transition-colors">
                <Icon className="h-4 w-4" />
              </a>
            ))}
          </div>
        </div>
      </div>
      <div className="border-t border-white/10">
        <div className="mx-auto max-w-7xl px-6 lg:px-10 py-5 text-xs text-ink-foreground/50">
          © 2025 PixelSpark. All Rights Reserved.
        </div>
      </div>
    </footer>
  );
}
