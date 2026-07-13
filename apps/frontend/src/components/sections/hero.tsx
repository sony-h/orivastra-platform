'use client';

import Link from 'next/link';
import { ArrowDown } from 'lucide-react';
import { Button, Badge } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { AnimatedGrid } from '@/components/ui/animated-grid';
import { Reveal } from '@/components/animations/reveal';

export function HeroSection() {
  return (
    <SectionWrapper className="relative flex min-h-[90vh] items-center justify-center overflow-hidden pt-32">
      <AnimatedGrid />
      <div className="relative z-10 mx-auto max-w-[720px] text-center">
        <Reveal>
          <Badge variant="secondary" className="mb-6">
            Technology Company
          </Badge>
        </Reveal>
        <Reveal delay={0.1}>
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
            Building Intelligent
            <br />
            Digital Solutions
          </h1>
        </Reveal>
        <Reveal delay={0.2}>
          <p className="text-muted-foreground mx-auto mt-6 max-w-xl text-lg">
            We design, develop, and operate premium digital products that help businesses work
            smarter, grow faster, and innovate with confidence.
          </p>
        </Reveal>
        <Reveal delay={0.3}>
          <div className="mt-10 flex items-center justify-center gap-4">
            <Button asChild size="lg">
              <Link href="#services">Explore Services</Link>
            </Button>
            <Button asChild variant="outline" size="lg">
              <Link href="#about">Learn More</Link>
            </Button>
          </div>
        </Reveal>
      </div>
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
        <ArrowDown className="text-muted-foreground size-5" />
      </div>
    </SectionWrapper>
  );
}
