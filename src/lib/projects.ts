import tranquil1 from "@/assets/tranquil-oasis-1.png";
import rendezvous1 from "@/assets/rendezvous-solar-1.png";
import rendezvous2 from "@/assets/rendezvous-solar-2.png";
import rendezvous3 from "@/assets/rendezvous-solar-3.png";
import rendezvous4 from "@/assets/rendezvous-solar-4.png";
import portfolioImg from "@/assets/project-portfolio.jpg";
import game from "@/assets/project-game.jpg";
import bluerush1 from "@/assets/bluerush-223505.png.asset.json";
import bluerush2 from "@/assets/bluerush-223532.png.asset.json";
import bluerush3 from "@/assets/bluerush-223641.png.asset.json";
import nevada1 from "@/assets/nevada-1.png.asset.json";
import nevada2 from "@/assets/nevada-2.png.asset.json";
import nevada3 from "@/assets/nevada-3.png.asset.json";

export const BLUERUSH_URL =
  "https://lovable.dev/share-preview/e468914c-cf77-4dae-b9c3-1636eef25c55#preview_url=https%3A%2F%2Fid-preview--e468914c-cf77-4dae-b9c3-1636eef25c55.lovable.app%3F__lovable_token%3DeyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiTk1sc2RabUYxSFVNZ3dTWVN4NFR4aUEybWFpMSIsInByb2plY3RfaWQiOiJlNDY4OTE0Yy1jZjc3LTRkYWUtYjljMy0xNjM2ZWVmMjVjNTUiLCJhY2Nlc3NfdHlwZSI6InByb2plY3QiLCJpc3MiOiJsb3ZhYmxlLWFwaSIsInN1YiI6ImU0Njg5MTRjLWNmNzctNGRhZS1iOWMzLTE2MzZlZWYyNWM1NSIsImF1ZCI6WyJsb3ZhYmxlLWFwcCJdLCJleHAiOjE3ODU5NjU1NzksIm5iZiI6MTc4NTM2MDc3OSwiaWF0IjoxNzg1MzYwNzc5LCJqdGkiOiIwYTBhNGU0Ny00MzdlLTQ1MmItOTg1ZS1jNzJkZjRlMmQxYzIifQ.IygJmIbq1l3cEX-jjdEw6rCsHrG5LglZ_0EnrZTuQyf5J1UG6JssIk6Y8Rd80fkPwFumx7RqW1dCAYssVtNaLZtC7cF7tT08ZMEsygbt3weIe_49GSV4RWP3Fk3tmQmm51euYjZ4sMBhmnorDvIiAb04qlMYfoyoPL5GF5nUH4ILaXG9wsru0_HB0Q3HHRDko3hYKLUdfh4n9Azn75YRaap1J9tUlxBdjRquqLJseRF6h140NdnQ5QikGdxsLX15OUzfOJJw397L9uGV-iDN3ZhPAk2W1cx27RqWDHxv-lgJsjCZqRB8b1CRi20fuNTL59wqcrUINiEZUg_P2LKROfjPnULJb-hth67w8bdqqiZ-scsik9LOFyVTeysUfZ1e6Yb0GIl6wyqmq_Q22-aZa88No32FBAce2L_mMsaVoV-m4uHpQc4pylfHTbGVe45u2dnyPToK76YO_zOEgC04DuJH5xtu56jkAKg4jDA0oCbRuOXHMUwSDKGm6HXLjKcsB5LHwGKQ6OT-1PEUtDqdMHSoSDgD-QLTMBx3XioeZaqiw5_h-cFpYDEy4gHYR_u3XHm5UHDKHPNLmKt8mMa6HLTf24Z5l7QbFC3blRNAj8BydMlLguRi_oH9mIztqY3ZzQjgWvyovoDaEh3cv7t0hLhTlIVuAmKNPPjFFNCUawU";

export const NEVADA_URL = "https://nevada-hotels-shutdown-101.netlify.app/";
export const nevadaShots = [nevada1.url, nevada2.url, nevada3.url];



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
    slug: "nevada-hotels-suites",
    title: "Nevada Hotels & Suites",
    tag: "Luxury Hotel Website",
    category: "Hotel Platforms",
    cover: nevada1.url,
    gallery: nevadaShots,
    description:
      "Nevada Hotels & Suites is a modern hospitality website designed to showcase a premium hotel experience while making it easy for guests to explore rooms, amenities, and contact the hotel. Nestled in the vibrant heart of Lekki, Lagos, the hotel offers modern rooms, quality dining, a swimming pool, 24-hour power supply and exceptional service — and the website was built to communicate warmth, professionalism and affordability while presenting the hotel as a premium destination that drives direct bookings.",
    client: "Nevada Hotels & Suites",
    location: "Lekki, Lagos",
    tech: ["React", "TypeScript", "Tailwind CSS", "Responsive Design", "Modern UI/UX", "Netlify"],
    features: [
      "Luxury landing page",
      "Room showcase",
      "Restaurant & bar",
      "Gallery",
      "Responsive design",
      "Location & contact",
      "Modern navigation",
      "Fast loading",
      "Mobile optimized",
      "Elegant UI",
    ],
    liveUrl: NEVADA_URL,
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
    liveUrl: BLUERUSH_URL,
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
