import { createFileRoute } from "@tanstack/react-router";
import { Nav } from "@/components/site/Nav";
import { Hero } from "@/components/site/Hero";
import { Services } from "@/components/site/Services";
import { Portfolio } from "@/components/site/Portfolio";
import { Process } from "@/components/site/Process";
import { Pricing } from "@/components/site/Pricing";
import { Testimonials } from "@/components/site/Testimonials";
import { Stats } from "@/components/site/Stats";
import { CTA } from "@/components/site/CTA";
import { About } from "@/components/site/About";
import { Footer } from "@/components/site/Footer";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "PixelSpark — Websites, Apps & Digital Experiences by Mohammed" },
      { name: "description", content: "PixelSpark builds premium websites, mobile apps and creative digital products that help businesses look professional and grow online." },
      { property: "og:title", content: "PixelSpark — Premium Websites, Apps & Digital Experiences" },
      { property: "og:description", content: "Modern, high-performing websites, apps and creative digital solutions by Mohammed." },
    ],
  }),
  component: Index,
});

function Index() {
  return (
    <div className="min-h-screen">
      <Nav />
      <main>
        <Hero />
        <Services />
        <section className="mx-auto max-w-7xl px-6 lg:px-10 py-12 grid lg:grid-cols-2 gap-6">
          <Process />
          <Pricing />
        </section>
        <section className="mx-auto max-w-7xl px-6 lg:px-10 pb-12 grid lg:grid-cols-2 gap-6">
          <Testimonials />
          <Stats />
        </section>
        <Portfolio />
        <About />
        <CTA />
      </main>
      <Footer />
    </div>
  );
}
