import hotel from "@/assets/project-hotel.jpg";
import solar from "@/assets/project-solar.jpg";
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
  tech: string[];
  features: string[];
  liveUrl?: string;
};

export const projects: Project[] = [
  {
    slug: "hotel-booking",
    title: "Hotel Booking Website",
    tag: "Booking + Payments",
    category: "Hotel Platforms",
    cover: hotel,
    gallery: [hotel, solar, portfolioImg],
    description:
      "A premium hotel platform with real-time room availability, secure online payments and a luxury front-end designed to convert browsers into bookings.",
    client: "Boutique Hotels & Resorts",
    tech: ["React", "TypeScript", "Tailwind CSS", "Supabase", "Stripe"],
    features: [
      "Room search & availability calendar",
      "Online payments with instant confirmation",
      "Guest profile & booking history",
      "Admin dashboard for rooms & rates",
      "Fully responsive luxury UI",
    ],
    liveUrl: "https://example.com",
  },
  {
    slug: "solar-company",
    title: "Solar Company Website",
    tag: "Business Site",
    category: "Websites",
    cover: solar,
    gallery: [solar, hotel, portfolioImg],
    description:
      "A clean, conversion-focused business website for a solar energy company — built to win leads, showcase services and rank on Google.",
    client: "Renewable Energy Brand",
    tech: ["React", "TanStack Start", "Tailwind CSS", "SEO"],
    features: [
      "Lead capture forms",
      "Service & pricing pages",
      "Project gallery",
      "WhatsApp quick-quote integration",
      "Optimized for Core Web Vitals",
    ],
    liveUrl: "https://example.com",
  },
  {
    slug: "personal-portfolio",
    title: "Personal Portfolio Website",
    tag: "Personal Brand",
    category: "UI Concepts",
    cover: portfolioImg,
    gallery: [portfolioImg, game, solar],
    description:
      "A cinematic personal brand site for a creative professional — premium typography, smooth motion and a portfolio that does the selling.",
    client: "Creative Professional",
    tech: ["React", "Framer Motion", "Tailwind CSS"],
    features: [
      "Hero animation",
      "Filterable portfolio",
      "About & contact sections",
      "Dark/light premium theme",
    ],
    liveUrl: "https://example.com",
  },
  {
    slug: "adventure-game",
    title: "2D Adventure Game",
    tag: "Game Dev",
    category: "Games",
    cover: game,
    gallery: [game, portfolioImg, hotel],
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
    cover: solar,
    gallery: [solar, portfolioImg, hotel],
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
    gallery: [portfolioImg, game, solar],
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
