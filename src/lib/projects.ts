import tranquil1 from "@/assets/tranquil-oasis-1.png";
import tranquil2 from "@/assets/tranquil-oasis-2.png";
import tranquil3 from "@/assets/tranquil-oasis-3.png";
import rendezvous1 from "@/assets/rendezvous-solar-1.png";
import rendezvous2 from "@/assets/rendezvous-solar-2.png";
import rendezvous3 from "@/assets/rendezvous-solar-3.png";
import rendezvous4 from "@/assets/rendezvous-solar-4.png";
import portfolioImg from "@/assets/project-portfolio.jpg";
import game from "@/assets/project-game.jpg";

export const categories = [
  "All",
  "Websites",
  "Hotel Platforms",
  "Mobile Apps",
  "UI Concepts",
  "Games",
] as const;
export type Category = (typeof categories)[number];

export type Project = {
  slug: string;
  title: string;
  tag: string;
  category: Category;
  cover: string;
  gallery: string[];
  description: string;
  client: string;
  location?: string;
  tech: string[];
  features: string[];
  liveUrl?: string;
};

export const projects: Project[] = [
  {
    slug: "tranquil-oasis-hotel",
    title: "Tranquil Oasis Hotel",
    tag: "Luxury Hotel Booking Platform",
    category: "Hotel Platforms",
    cover: tranquil1,
    gallery: [tranquil1, tranquil2, tranquil3],
    description:
      "A premium hospitality website crafted for Tranquil Oasis Hotel — blending elegant design, seamless booking experiences and modern hotel technology into one refined digital platform. Located in the heart of Lekki Phase 1, Lagos, the platform reflects the hotel's luxury atmosphere while making room reservations faster, easier and more immersive for guests. Cinematic visuals, smooth navigation and conversion-focused booking flows help transform visitors into confirmed guests.",
    client: "Tranquil Oasis Hotel",
    location: "Lekki Phase 1, Lagos",
    tech: ["React", "TypeScript", "Tailwind CSS", "Supabase", "Stripe"],
    features: [
      "Real-time room availability system",
      "Online booking & secure payment integration",
      "Luxury responsive UI across all devices",
      "Complimentary breakfast highlights",
      "High-speed WiFi showcase",
      "Smart room experience presentation",
      "Interactive room previews",
      "Admin management dashboard",
      "Smooth animations & premium transitions",
      "SEO-optimized hospitality structure",
      "Guest-focused booking experience",
    ],
    liveUrl: "https://tranquil-oasis-pxs-101.netlify.app",
  },
  {
    slug: "rendezvous-solar",
    title: "Rendezvous Solar Company",
    tag: "Reliable Solar Energy Platform",
    category: "Websites",
    cover: rendezvous1,
    gallery: [rendezvous1, rendezvous2, rendezvous3, rendezvous4],
    description:
      "A modern solar energy company website built for Rendezvous Solar — combining clean design, trust-focused user experience and conversion-driven layouts to help homes and businesses transition to reliable solar energy. Designed for the Nigerian market, the platform showcases professional solar solutions while educating visitors about the long-term benefits of clean, uninterrupted power. The experience blends premium visuals, smooth navigation and strong call-to-actions to convert visitors into solar clients.",
    client: "Rendezvous Solar",
    location: "17 Anjorin Street, Off Alh Alade St, Ijegun, Lagos",
    tech: ["React", "TypeScript", "Tailwind CSS", "Supabase", "Stripe"],
    features: [
      "Residential solar solution showcase",
      "Commercial solar service presentation",
      "Inverter & battery system information",
      "Interactive “Get a Quote” call-to-actions",
      "Solar energy benefits breakdown",
      "Modern responsive UI across all devices",
      "Conversion-focused landing experience",
      "Clean premium animations & transitions",
      "Trust-building service sections",
      "SEO-optimized structure",
      "Fast-loading optimized pages",
      "Business inquiry/contact integration",
    ],
    liveUrl: "https://rendezvous-solar-pxs-101.netlify.app",
  },
  {
    slug: "bluerush",
    title: "BlueRush",
    tag: "Smart Bike Ride Planner",
    category: "Mobile Apps",
    cover: bluerush1.url,
    gallery: [bluerush1.url, bluerush2.url, bluerush3.url],
    description:
      "BlueRush is an intelligent cycling companion that helps riders plan safer and smarter rides. It combines daily weather forecasts with a unique Rideability Score to help cyclists know the best time to ride. The app is designed with a clean, modern interface and focuses on making ride planning simple, accurate, and enjoyable.",
    client: "BlueRush",
    tech: ["Weather APIs", "Maps Integration", "Modern UI/UX", "Mobile Development"],
    features: [
      "Daily weather forecasts",
      "Rideability Score",
      "Smart ride planning",
      "Clean modern UI",
      "Weather-based recommendations",
      "Mobile-first experience",
    ],
    liveUrl: "https://lovable.dev/share-preview/e468914c-cf77-4dae-b9c3-1636eef25c55",
  },

  {
    slug: "adventure-game",
    title: "2D Adventure Game",
    tag: "Game Dev",
    category: "Games",
    cover: game,
    gallery: [game, portfolioImg, tranquil1],
    description:
      "A playful 2D adventure game with custom characters, smooth controls and level progression — built as a creative showcase.",
    client: "Indie Game Concept",
    tech: ["Unity", "C#", "Pixel Art"],
    features: [
      "Custom sprite animations",
      "Multiple levels",
      "Save & resume progress",
      "Mobile + desktop controls",
    ],
  },
  {
    slug: "saas-landing",
    title: "SaaS Landing Page",
    tag: "High-converting",
    category: "Websites",
    cover: rendezvous2,
    gallery: [rendezvous2, portfolioImg, tranquil1],
    description:
      "A high-converting SaaS landing page with clear pricing, social proof and a sign-up flow tuned for paid traffic.",
    client: "B2B SaaS Startup",
    tech: ["React", "Tailwind CSS", "Stripe"],
    features: [
      "Hero + value proposition",
      "Pricing tiers",
      "Testimonial slider",
      "Newsletter capture",
    ],
    liveUrl: "https://example.com",
  },
  {
    slug: "mobile-app-concept",
    title: "Mobile App Concept",
    tag: "iOS / Android",
    category: "Mobile Apps",
    cover: portfolioImg,
    gallery: [portfolioImg, game, rendezvous1],
    description:
      "A cross-platform mobile app concept with refined UI, smooth navigation and a premium onboarding flow.",
    client: "Lifestyle Startup",
    tech: ["React Native", "Expo", "TypeScript"],
    features: [
      "Onboarding & auth",
      "Profile management",
      "Push notifications",
      "Offline-ready data layer",
    ],
  },
];
