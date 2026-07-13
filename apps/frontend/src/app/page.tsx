import { HeroSection } from '@/components/sections/hero';
import { AboutPreviewSection } from '@/components/sections/about-preview';
import { ServicesSection } from '@/components/sections/services';
import { TechnologiesSection } from '@/components/sections/technologies';
import { ProcessSection } from '@/components/sections/process';
import { RoadmapSection } from '@/components/sections/roadmap';
import { CTASection } from '@/components/sections/cta';
import { ContactSection } from '@/components/sections/contact';

export default function HomePage() {
  return (
    <>
      <HeroSection />
      <AboutPreviewSection />
      <ServicesSection />
      <TechnologiesSection />
      <ProcessSection />
      <RoadmapSection />
      <CTASection />
      <ContactSection />
    </>
  );
}
