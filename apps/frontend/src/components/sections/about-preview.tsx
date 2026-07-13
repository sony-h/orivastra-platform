'use client';

import { useEffect, useRef, useState } from 'react';
import { FolderGit2, Layers, Clock } from 'lucide-react';
import Link from 'next/link';
import { Card } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { SectionHeading } from '@/components/ui/section-heading';
import { Reveal } from '@/components/animations/reveal';
import { stats } from '@/lib/constants';

const iconMap: Record<string, React.ElementType> = {
  FolderGit2,
  Layers,
  Clock,
};

function AnimatedCounter({
  value,
  suffix,
  isInView,
}: {
  value: number;
  suffix?: string;
  isInView: boolean;
}) {
  const [count, setCount] = useState(0);
  const started = useRef(false);

  useEffect(() => {
    if (!isInView || started.current) return;
    started.current = true;

    const duration = 1500;
    const steps = 40;
    const increment = value / steps;
    let current = 0;
    const timer = setInterval(() => {
      current += increment;
      if (current >= value) {
        setCount(value);
        clearInterval(timer);
      } else {
        setCount(Math.floor(current));
      }
    }, duration / steps);

    return () => clearInterval(timer);
  }, [isInView, value]);

  return (
    <span>
      {count}
      {suffix ?? ''}
    </span>
  );
}

function StatCard({
  stat,
  isInView,
  delay,
}: {
  stat: (typeof stats)[number];
  isInView: boolean;
  delay: number;
}) {
  const Icon = iconMap[stat.icon] ?? FolderGit2;

  return (
    <Reveal direction="right" delay={delay}>
      <Card className="flex items-center gap-4 p-6">
        <div className="bg-accent/10 flex size-12 shrink-0 items-center justify-center rounded-lg">
          <Icon className="text-accent size-6" />
        </div>
        <div>
          <div className="text-2xl font-bold">
            <AnimatedCounter value={stat.value} suffix={stat.suffix} isInView={isInView} />
          </div>
          <div className="text-muted-foreground text-sm">{stat.label}</div>
        </div>
      </Card>
    </Reveal>
  );
}

export function AboutPreviewSection() {
  const ref = useRef<HTMLDivElement>(null);
  const [isInView, setIsInView] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry?.isIntersecting) {
          setIsInView(true);
          observer.disconnect();
        }
      },
      { threshold: 0.3 },
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  return (
    <SectionWrapper id="about" className="bg-muted/30">
      <div ref={ref} className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
        <Reveal direction="left">
          <SectionHeading
            label="About Us"
            title="Engineering the Future of Digital Solutions"
            description="Orivastra is a modern technology company focused on designing, developing, and operating high-quality digital products. We combine software engineering, cloud infrastructure, artificial intelligence, and automation into practical solutions."
            align="left"
          />
          <p className="text-muted-foreground mt-4">
            Rather than providing isolated services, we build complete digital ecosystems where
            every product and solution works seamlessly together. Our mission is to empower
            businesses through innovative software, intelligent automation, and reliable cloud
            infrastructure.
          </p>
          <div className="mt-6">
            <Link
              href="/about"
              className="text-accent text-sm font-medium underline-offset-4 hover:underline"
            >
              Learn more about our mission &rarr;
            </Link>
          </div>
        </Reveal>

        <div className="space-y-6">
          {stats.map((stat, i) => (
            <StatCard key={stat.label} stat={stat} isInView={isInView} delay={i * 0.1} />
          ))}
        </div>
      </div>
    </SectionWrapper>
  );
}
